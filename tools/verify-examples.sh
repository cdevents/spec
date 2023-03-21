#!/usr/bin/env bash

# Copyright 2023 The CDEvents Authors.
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
verify-examples.sh is tool to check the examples against the JSON schema

Usage:
  verify-examples.sh

Examples:
  verify-examples.sh
EOF
}

set -o errexit
set -o nounset
set -o pipefail

# Folders
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
EXAMPLES_FOLDER="${ROOT}/examples"
SCHEMAS_FOLDER="${ROOT}/schemas"

# Install the tool
cd ${ROOT}/tools
go install github.com/neilpa/yajsv@v1.4.1

# Loop over all example files
# - examples are subject_predicate.json
# - schemas are subjectpredicate.json
num_failed=0
num_examples=$(ls "$EXAMPLES_FOLDER" | wc -l | awk '{ print $1 }')
for example in $(ls "$EXAMPLES_FOLDER"); do
    SUBJECT_PREDICATE=$(basename $example .json)
    splitArray=(${SUBJECT_PREDICATE//_/ })
    SUBJECT=${splitArray[0]}
    PREDICATE=${splitArray[1]}
    EXAMPLE_FILE=${EXAMPLES_FOLDER}/${example}
    SCHEMA_FILE=${SCHEMAS_FOLDER}/${SUBJECT}${PREDICATE}.json
    echo "==> $SUBJECT $PREDICATE"
    yajsv -s "$SCHEMA_FILE" "$EXAMPLE_FILE" || num_failed=$(( num_failed + 1 ))
    echo
done

if [ $num_failed -gt 0 ]; then
    echo "${num_failed} out of ${num_examples} examples failed validation"
fi
exit $num_failed