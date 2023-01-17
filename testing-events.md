<!--
---
linkTitle: "Testing Events"
weight: 50
hide_summary: true
icon: "fa-solid fa-network-wired"
description: >
   Testing Events
---
-->
# Testing Events

Testing events covers the subjects and predicates related to test-execution 
performed independently of CI/CD pipelines. 

## Subjects

This specification defines three subjects in this stage: `testCase`, `testSuite` and `testArtifact`. 

| Subject                     | Description                                     | Predicates                                                         |
|-----------------------------|-------------------------------------------------|--------------------------------------------------------------------|
| [`testCase`](#testcase)     | A software test case                            | [`started`](#testcase-started), [`finished`](#testcase-finished)   |
| [`testSuite`](#testsuite)   | A collection of test cases                      | [`started`](#testsuite-started), [`finished`](#testsuite-finished) |
| [`testOutput`](#testoutput) | An output artifact produced by a test execution | [`published`](#testoutput-published)                               |

### `testCase`

A `testCase` is a process that performs a test against an input software artifact of some kind, for instance source code, a binary, a container image or else.
A `testCase` is the smallest unit of testing that the user wants to track. `testCases` are executed, and `testSuites` are for grouping purposes.

| Field  | Type            | Description                                                 | Examples                                                     |
|--------|-----------------|-------------------------------------------------------------|--------------------------------------------------------------|
| id     | `String`        | Uniquely identifies the subject within the source.          | `integration-test-abc`, `e2e-test1`, `scan-image1`           |
| source | `URI-Reference` | [source](spec.md#source--context-) from the context         | `staging/tekton`, `tekton-dev-123`                           |
| type   | `String`        | An optional type of test                                    | `functional`, `unit`, `performance`, `security`              |
| url    | `URI-Reference` | An optional reference to view/access the specified testCase | `https://testkube.mycluster.internal/testCases/untitest-abc` |

### `testSuite`

A `testSuite` represents a set of one or more `testCases`.

| Field  | Type            | Description                                                  | Examples                                                      |
|--------|-----------------|--------------------------------------------------------------|---------------------------------------------------------------|
| id     | `String`        | Uniquely identifies the subject within the source.           | `my-testsuite`, `regression-123`                              |
| source | `URI-Reference` | [source](spec.md#source--context-) from the context          | `staging/tekton`, `tekton-dev-123`                            |
| url    | `URI-Reference` | An optional reference to view/access the specified testSuite | `https://testkube.mycluster.internal/testSuites/my-testsuite` |         

### `testOutput`

One or more `testOutput` artifacts are usually produced as the result of a test execution.  

| Field      | Type            | Description                                                             | Examples                                                 |
|------------|-----------------|-------------------------------------------------------------------------|----------------------------------------------------------|
| id         | `String`        | Uniquely identifies the subject within the source.                      | `23123123`                                               |
| source     | `URI-Reference` | [source](spec.md#source--context-) from the context                     | `staging/tekton`, `tekton-dev-123`                       |
| type       | `String`        | The type of output, one of `report`, `video`, `image`, `log`, `other`   | `video`                                                  |
| format     | `String`        | The Content-Type of the output artifact                                 | `application/pdf`, `image/png`, `application/json`       |         
| url        | `URI-Reference` | A reference to retrieve the specified output artifact                   | `https://testkube.mycluster.internal/artifacts/23123123` |         
| testCaseId | `URI-Reference` | An optional reference to the testCase resulting in this output artifact | `https://testkube.mycluster.internal/testCase/123123`    |         

## Events

### `testCase started`

This event represents a started testCase execution. 

- Event Type: __`dev.cdevents.testcase.started.0.1.1`__
- Predicate: started
- Subject: [`testCase`](#testcase)

| Field       | Type            | Description                                                                                | Examples                                  | Required |
|-------------|-----------------|--------------------------------------------------------------------------------------------|-------------------------------------------|----------|
| id          | `String`        | Uniquely identifies the subject within the source.                                         | `unitest-abc`, `e2e-test1`, `scan-image1` | ✅        |
| source      | `URI-Reference` | [source](spec.md#source--context-) from the context                                        |                                           |          |
| executionId | `String`        | An optional execution ID to enable handling of multiple simultaneous executions            |                                           |          |
| testSuiteId | `String`        | An optional `testSuite` ID if this `testCase` was started as part of a testSuite execution |                                           |          |

### `testCase finished`

This event represents a finished testCase execution. The event will contain the finished status and additional metadata as applicable.

- Event Type: __`dev.cdevents.testcase.finished.0.1.1`__
- Predicate: finished
- Subject: [`testCase`](#testcase)

| Field       | Type            | Description                                                                         | Examples                                  | Required |
|-------------|-----------------|-------------------------------------------------------------------------------------|-------------------------------------------|----------|
| id          | `String`        | Uniquely identifies the subject within the source.                                  | `unitest-abc`, `e2e-test1`, `scan-image1` | ✅        |
| source      | `URI-Reference` | [source](spec.md#source--context-) from the context                                 |                                           |          |
| executionId | `String`        | An optional execution ID to enable handling of multiple simultaneous executions     |                                           |          |
| status      | `String`        | The status of the testSuite execution, one of `passed`, `failed`, `aborted`         |                                           | ✅        |
| severity    | `String`        | An optional severity if the test failed, one of `critical`, `low`, `medium`, `high` | `critical`, `low`, `medium`, `high`       |
| reason      | `String`        | An optional reason related to the status of the execution                           | `Cancelled by user`, `Failed assertion`   |          |


### `testSuite started`

This event represents a started testSuite execution.

- Event Type: __`dev.cdevents.testsuite.started.0.1.0`__
- Predicate: started
- Subject: [`testSuite`](#testsuite)

| Field       | Type            | Description                                                                     | Examples                  | Required |
|-------------|-----------------|---------------------------------------------------------------------------------|---------------------------|----------|
| id          | `String`        | Uniquely identifies the subject within the source.                              | `unit`, `e2e`, `security` | ✅        |
| source      | `URI-Reference` | [source](spec.md#source--context-) from the context                             |                           |          |
| executionId | `String`        | An optional execution ID to enable handling of multiple simultaneous executions |                           |          |

### `testSuite finished`

This event represents a finished testSuite execution. The event will contain the execution status and additional metadata as applicable.

- Event Type: __`dev.cdevents.testsuite.finished.0.1.0`__
- Predicate: finished
- Subject: [`testSuite`](#testsuite)

| Field    | Type            | Description                                                                              | Examples                               | Required |
|----------|-----------------|------------------------------------------------------------------------------------------|----------------------------------------|----------|
| id       | `String`        | Uniquely identifies the subject within the source.                                       | `unit`, `e2e`, `security`              | ✅        |
| source   | `URI-Reference` | [source](spec.md#source--context-) from the context                                      |                                        |          |
| status   | `String`        | The status of the testSuite execution, one of `passed`, `failed`, `aborted`              |                                        | ✅        |
| severity | `String`        | An optional severity if the testSuite failed, one of `critical`, `low`, `medium`, `high` | `critical`, `low`, `medium`, `high`    |
| reason   | `String`        | An optional reason related to the status of the execution                                | `Cancelled by user`, `Failed testCase` |          |

### `testOutput published`

The event represents a test execution output artifact that has been published.

- Event Type: __`dev.cdevents.testoutput.published.0.1.0`__
- Predicate: published
- Subject: [`testOutput`](#testoutput)

| Field       | Type            | Description                                                                                      | Examples   | Required |
|-------------|-----------------|--------------------------------------------------------------------------------------------------|------------|----------|
| id          | `String`        | Uniquely identifies the subject within the source.                                               | `12312334` | ✅        |
| source      | `URI-Reference` | [source](spec.md#source--context-) from the context                                              |            |          |
| executionId | `String`        | An optional execution ID to link this artifact to a specific `testCase` or `testSuite` execution |            |          |
