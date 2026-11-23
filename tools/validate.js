#!/usr/bin/env node

// Copyright 2026-present The CDEvents Authors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import { readFileSync, unlinkSync } from "node:fs";
import { basename, dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import Ajv2020 from "ajv/dist/2020.js";
import addFormats from "ajv-formats";
import { globSync } from "glob";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Folders
const ROOT = join(__dirname, "..");
const EXAMPLES_FOLDER = join(ROOT, "conformance");
const SCHEMAS_FOLDER = join(ROOT, "schemas");
const EMBEDDED_LINKS_SCHEMAS_PATTERN = join(
  ROOT,
  "schemas/links/*.json",
);

// Helper function to load JSON file
function loadJSON(filepath) {
  try {
    return JSON.parse(readFileSync(filepath, "utf8"));
  } catch (error) {
    console.error(`Error loading ${filepath}: ${error.message}`);
    throw error;
  }
}

// Helper function to create ajv instance with options
function createAjv() {
  const ajv = new Ajv2020({
    strict: false,
    validateFormats: true,
    allErrors: true,
  });
  addFormats(ajv);
  return ajv;
}

// Load links schemas for use as references
function loadEmbeddedLinksSchemas() {
  const schemas = [];
  const files = globSync(EMBEDDED_LINKS_SCHEMAS_PATTERN);
  for (const file of files) {
    schemas.push(loadJSON(file));
  }
  return schemas;
}

// Test schema compilation
function testSchemas() {
  console.log("==> Testing Schema Files");

  let schemaFailed = 0;
  const embeddedLinksSchemas = loadEmbeddedLinksSchemas();

  // Test event schemas
  const eventSchemaFiles = globSync(join(SCHEMAS_FOLDER, "*.json"));
  let numSchemas = eventSchemaFiles.length;

  for (const schemaFile of eventSchemaFiles) {
    try {
      const ajv = createAjv();
      for (const schema of embeddedLinksSchemas) {
        ajv.addSchema(schema);
      }
      const schema = loadJSON(schemaFile);
      ajv.compile(schema);
    } catch (error) {
      console.error(`Failed to compile ${schemaFile}: ${error.message}`);
      schemaFailed++;
    }
  }

  // Test links schemas
  const linkSchemaFiles = globSync(join(SCHEMAS_FOLDER, "links/link*.json"));
  numSchemas += linkSchemaFiles.length;

  for (const schemaFile of linkSchemaFiles) {
    try {
      const ajv = createAjv();
      for (const refSchema of embeddedLinksSchemas) {
        if (!refSchema.$id?.includes("/links/link")) {
          ajv.addSchema(refSchema);
        }
      }
      const schema = loadJSON(schemaFile);
      ajv.compile(schema);
    } catch (error) {
      console.error(`Failed to compile ${schemaFile}: ${error.message}`);
      schemaFailed++;
    }
  }

  // Test custom schema
  numSchemas += 1;
  try {
    const ajv = createAjv();
    for (const schema of embeddedLinksSchemas) {
      ajv.addSchema(schema);
    }
    const customSchema = loadJSON(join(ROOT, "custom/schema.json"));
    ajv.compile(customSchema);
  } catch (error) {
    console.error(`Failed to compile custom schema: ${error.message}`);
    schemaFailed++;
  }

  console.log(
    `${numSchemas - schemaFailed} out of ${numSchemas} schemas are valid`,
  );

  return schemaFailed;
}

// Test conformance examples
function testConformance() {
  console.log("\n==> Testing Conformance Files");

  let exampleFailed = 0;
  const embeddedLinksSchemas = loadEmbeddedLinksSchemas();

  const exampleFiles = globSync(join(EXAMPLES_FOLDER, "*.json"));
  let numExamples = exampleFiles.length;

  for (const exampleFile of exampleFiles) {
    const exampleFileName = basename(exampleFile);
    const subjectPredicate = basename(exampleFileName, ".json");
    const parts = subjectPredicate.split("_");
    const subject = parts[0];
    const predicate = parts[1];
    const schemaFile = join(SCHEMAS_FOLDER, `${subject}${predicate}.json`);

    process.stdout.write(`${subject} ${predicate}: `);

    try {
      const ajv = createAjv();
      // Add embedded links schemas as references
      for (const embeddedSchema of embeddedLinksSchemas) {
        ajv.addSchema(embeddedSchema);
      }
      const schema = loadJSON(schemaFile);
      const example = loadJSON(exampleFile);
      const validate = ajv.compile(schema);
      const valid = validate(example);

      if (!valid) {
        console.log("invalid");
        console.error(validate.errors);
        exampleFailed++;
      } else {
        console.log("valid");
      }
    } catch (error) {
      console.log("failed");
      console.error(`Error: ${error.message}`);
      exampleFailed++;
    }
  }

  // Test custom example
  numExamples += 1;
  try {
    const ajv = createAjv();
    for (const embeddedSchema of embeddedLinksSchemas) {
      ajv.addSchema(embeddedSchema);
    }
    const customSchema = loadJSON(join(ROOT, "custom/schema.json"));
    const customExample = loadJSON(join(ROOT, "custom/conformance.json"));
    const validate = ajv.compile(customSchema);
    const valid = validate(customExample);

    if (!valid) {
      console.error("Custom example validation failed");
      console.error(validate.errors);
      exampleFailed++;
    }
  } catch (error) {
    console.error(`Custom example validation error: ${error.message}`);
    exampleFailed++;
  }

  // Cleanup local schemas
  const localSchemaFiles = globSync(join(ROOT, "schemas/**/*.local"));
  for (const file of localSchemaFiles) {
    unlinkSync(file);
  }

  console.log(
    `${numExamples - exampleFailed} out of ${numExamples} examples are valid`,
  );

  return exampleFailed;
}

// Test the domainId test vectors in conformance/formats/domainid.json, plus
// the examples in the domainid schema, against the domainid schema and the
// provider and resource type registries
function testDomainIds() {
  console.log("\n==> Testing Domain IDs");

  let domainIdFailed = 0;
  let numChecks = 0;

  const ajv = createAjv();
  const domainIdSchema = loadJSON(join(SCHEMAS_FOLDER, "links/domainid.json"));
  const validateDomainId = ajv.compile(domainIdSchema);
  const validateProvider = ajv.compile(
    loadJSON(join(SCHEMAS_FOLDER, "registry/providers.json")),
  );
  const validateType = ajv.compile(
    loadJSON(join(SCHEMAS_FOLDER, "registry/resource-types.json")),
  );

  // Checks one serialized domainId, returns a list of problems
  const checkDomainId = (domainId) => {
    const problems = [];
    if (!validateDomainId(domainId)) {
      problems.push("does not match the domainid schema");
      return problems;
    }
    const [, , provider, , , , type] = domainId.split(":");
    if (provider !== "" && !validateProvider(provider)) {
      problems.push(`provider "${provider}" is not in the provider registry`);
    }
    if (!validateType(type)) {
      problems.push(`type "${type}" is not in the resource type registry`);
    }
    return problems;
  };

  const report = (what, problems) => {
    numChecks++;
    if (problems.length > 0) {
      console.error(`${what}: ${problems.join(", ")}`);
      domainIdFailed++;
    }
  };

  const vectors = loadJSON(join(EXAMPLES_FOLDER, "formats/domainid.json"));

  for (const testCase of vectors.valid) {
    const { provider, providerId, namespace, groups, type, resourceId } =
      testCase.segments;
    const serialized = [
      "cdevents",
      "v0",
      provider,
      providerId,
      namespace,
      groups,
      type,
      resourceId,
    ].join(":");
    const problems = checkDomainId(testCase.expected);
    if (serialized !== testCase.expected) {
      problems.push(`segments serialize to "${serialized}"`);
    }
    report(`valid case "${testCase.description}"`, problems);
  }

  for (const testCase of vectors.invalid) {
    const problems = validateDomainId(testCase.input)
      ? ["matches the domainid schema but should not"]
      : [];
    report(`invalid case "${testCase.description}"`, problems);
  }

  for (const example of domainIdSchema.examples ?? []) {
    report(`domainid schema example "${example}"`, checkDomainId(example));
  }

  console.log(
    `${numChecks - domainIdFailed} out of ${numChecks} domain ID checks passed`,
  );

  return domainIdFailed;
}

// Main execution
try {
  const schemaFailed = testSchemas();
  const exampleFailed = testConformance();
  const domainIdFailed = testDomainIds();

  const totalFailed = schemaFailed + exampleFailed + domainIdFailed;
  process.exit(totalFailed);
} catch (error) {
  console.error(`Fatal error: ${error.message}`);
  process.exit(1);
}
