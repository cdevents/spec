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

# The script requires the packages from requirements-dev.txt

function usage() {
    cat <<EOF
validate.sh is tool to check the examples against the JSON schema

Usage:
  validate.sh

Examples:
  validate.sh
EOF
}

set -o errexit
set -o nounset
set -o pipefail
set -o noglob

# Folders
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
EXAMPLES_FOLDER="${ROOT}/examples"
SCHEMAS_FOLDER="${ROOT}/schemas"
EMBEDDED_LINKS_SCHEMAS="${ROOT}/schemas/links/embedded*.json"
JSON_VALIDATOR_OPTIONS="--strict=false --spec=draft2020 -c ajv-formats"

# Loop over all schema files
echo "==> Testing Schema Files"

schema_failed=0
# Test event schemas. Embedded links schemas are tested through this too.
num_schemas=$(find "${SCHEMAS_FOLDER}" -type f -name '*json' -maxdepth 1 | wc -l | awk '{ print $1 }')
while read -r schema; do
  ajv compile ${JSON_VALIDATOR_OPTIONS} -r "${EMBEDDED_LINKS_SCHEMAS}" -s "${schema}" || schema_failed=$(( schema_failed + 1 ))
done <<<$(find "${SCHEMAS_FOLDER}" -type f -name '*.json' -maxdepth 1)
# Test links schemas
num_schemas=$(( num_schemas + $(find "${SCHEMAS_FOLDER}/links" -type f -name 'link*json' -maxdepth 1 | wc -l | awk '{ print $1 }') ))
while read -r schema; do
  ajv compile ${JSON_VALIDATOR_OPTIONS} -s "${schema}" || schema_failed=$(( schema_failed + 1 ))
done <<<$(find "${SCHEMAS_FOLDER}/links" -type f -name 'link*json' -maxdepth 1)
# Test custom schema
num_schemas=$(( num_schemas + 1 ))
ajv compile ${JSON_VALIDATOR_OPTIONS} -r "${EMBEDDED_LINKS_SCHEMAS}" -s custom/schema.json || schema_failed=$(( schema_failed + 1 ))

echo "$(( num_schemas - schema_failed )) out of ${num_schemas} schemas are valid"

# Loop over all example files
# - examples are subject_predicate.json
# - schemas are subjectpredicate.json
echo -e "\n==> Testing Example Files"
example_failed=0
num_examples=$(find "${EXAMPLES_FOLDER}" -type f -name '*json' | wc -l | awk '{ print $1 }')
find "${EXAMPLES_FOLDER}" -type f -name '*.json' | while read -r example; do
    EXAMPLE_FILE=$(basename "${example}")
    SUBJECT_PREDICATE=$(basename "${EXAMPLE_FILE}" .json)
    splitArray=(${SUBJECT_PREDICATE//_/ })
    SUBJECT=${splitArray[0]}
    PREDICATE=${splitArray[1]}
    SCHEMA_FILE=${SCHEMAS_FOLDER}/${SUBJECT}${PREDICATE}.json
    printf "%s %s: " "${SUBJECT}" "${PREDICATE}"
    ajv validate ${JSON_VALIDATOR_OPTIONS} -r "${EMBEDDED_LINKS_SCHEMAS}" -s "${SCHEMA_FILE}" -d "${example}" || example_failed=$(( example_failed + 1 ))
done

# Cleanup local schemas
find "${ROOT}/schemas" -name '*.local' -exec rm {} +

echo "$(( num_examples - example_failed )) out of ${num_examples} examples are valid"

exit "$(( schema_failed + example_failed ))"
