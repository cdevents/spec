#!/usr/bin/env bash

# Copyright 2022 The CDEvents Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

function usage() {
    cat <<EOF
event-version.sh is tool to manage event versions

Usage:
  event-version.sh -u subject.predicate -s
  event-version.sh -u subject.predicate -m
  event-version.sh -u subject.predicate -e
  event-version.sh -u subject.predicate -p
  event-version.sh -u subject.predicate -v Major.minor.patch

-u  Specify the subject.predicate of the event to be updated

-s  Start a new event version by incrementing the minor version by one.

-m  Start a new version by incrementing the major version by one.

-e  End the current draft version.

-p  Patch the event version by increasing the latest patch available by one.

-v  Set the event version to Major.minor.patch

Examples:
  event-version.sh -u artifact.packaged -s -> updates all event references from M.m.0 to M.m+1.0-draft
  event-version.sh -u artifact.packaged -m -> updates all event references from M.m.0 to M+1.0.0-draft
  event-version.sh -u artifact.packaged -e -> updates all event references from M.m.0-draft to M.m.0
  event-version.sh -u artifact.packaged -p -> updates all event references from M.m.p to M.m.p+1
  event-version.sh -u artifact.packaged -v 1.2.3 -> updates all event references to 1.2.3
EOF
}

set -o errexit
set -o nounset
set -o pipefail

declare COMMAND INCREMENT VERSION NEW_VERSION EVENT_SUBJECT_PREDICATE
declare VERSION_FILE=version.txt

START_COMMAND=start
END_COMMAND=end
PATCH_COMMAND=patch
VERSION_COMMAND=version

# cd to the root path
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
cd "${ROOT}" 

while getopts ":smepv:u:" o; do
    case "${o}" in
        s)
            COMMAND="${START_COMMAND}"
            INCREMENT="minor"
            ;;
        m)
            COMMAND="${START_COMMAND}"
            INCREMENT="major"
            ;;
        e)
            COMMAND="${END_COMMAND}"
            ;;
        p)
            COMMAND="${PATCH_COMMAND}"
            ;;
        v)  COMMAND="${VERSION_COMMAND}"
            NEW_VERSION=${OPTARG}
            ;;
        u)  EVENT_SUBJECT_PREDICATE=${OPTARG}
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))

if [[ -z "${COMMAND}" || -z "${EVENT_SUBJECT_PREDICATE}" ]]; then
    usage
fi

if [ ! -f "$VERSION_FILE" ]; then
    echo "Version file $VERSION_FILE not found"
    exit 1
fi

# Evaluate the event subject.predicate
SPLIT_EVENT=(${EVENT_SUBJECT_PREDICATE//./ })
SUBJECT=${SPLIT_EVENT[0]}
PREDICATE=${SPLIT_EVENT[1]}
SCHEMA_FILE="schemas/${SUBJECT}${PREDICATE}.json"

# Evaluate the event version
OLD_VERSION=$(sed -n -e '/"default": "dev.cdevents.'${SUBJECT}'.'${PREDICATE}'./s/.*\.\([0-9]\.[0-9]\.[0-9]\)"/\1/p' ${SCHEMA_FILE})
VERSION="${NEW_VERSION:-$OLD_VERSION}"
SPLIT_VERSION=(${VERSION//./ })
MAJOR_VERSION=${SPLIT_VERSION[0]}
MINOR_VERSION=${SPLIT_VERSION[1]}
PATCH_VERSION_DRAFT=${SPLIT_VERSION[2]}
SPLIT_PATCH=(${PATCH_VERSION_DRAFT//-/ })
PATCH_VERSION=${SPLIT_PATCH[0]}
DRAFT_VERSION=""
if [[ ${#SPLIT_PATCH[@]} > 1 ]]; then
    DRAFT_VERSION="-${SPLIT_PATCH[1]}"
fi

if [[ "${COMMAND}" == "${END_COMMAND}" ]]; then
    if [[ -z ${DRAFT_VERSION} ]]; then
        echo "Cannot end release ${VERSION}, must be in draft to end"
        exit 1
    fi
    DRAFT_VERSION=""
fi

if [[ "${COMMAND}" == "${START_COMMAND}" ]]; then
    if [[ -n ${DRAFT_VERSION} ]]; then
        echo "Cannot start release ${VERSION}, already in ${DRAFT_VERSION}"
        exit 1
    fi
    PATCH_VERSION=0
    DRAFT_VERSION="-draft"
    if [[ "${INCREMENT}" == "minor" ]]; then
        MINOR_VERSION=$(( MINOR_VERSION + 1 ))
    else
        MAJOR_VERSION=$(( MAJOR_VERSION + 1 ))
        MINOR_VERSION=0
    fi
fi

if [[ "${COMMAND}" == "${PATCH_COMMAND}" ]]; then
    if [[ -n ${DRAFT_VERSION} ]]; then
        echo "Cannot start release ${VERSION}, already in ${DRAFT_VERSION}"
        exit 1
    fi
    PATCH_VERSION=$(( PATCH_VERSION + 1 ))
fi

VERSION="${MAJOR_VERSION}.${MINOR_VERSION}.${PATCH_VERSION}${DRAFT_VERSION}"

# Replace the version in the schema IDs
sed -i ".backup" -e 's,"dev.cdevents.*","dev.cdevents.'${SUBJECT}'.'${PREDICATE}'.'${VERSION}'",g' "${SCHEMA_FILE}"

# Update examples in docs
for doc in core source-code-version-control continuous-integration continuous-deployment continuous-operations; do
    sed -i ".backup" -e 's,__`dev.cdevents.'${SUBJECT}'.'${PREDICATE}'.*`__,__`dev.cdevents.'${SUBJECT}'.'${PREDICATE}'.'${VERSION}'`__,g' "${doc}.md"
done

# Cleanup backup files
find . -name '*.backup' | xargs rm
