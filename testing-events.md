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

Testing events covers the subjects and predicates related to test-execution performed either independently or as part of CI/CD pipelines. 

> These subjects replace the previously defined testCase/testSuite subjects in the Continuous Integration category

## Subjects

This specification defines three subjects in this stage: `testCase`, `testSuite` and `testArtifact`. 

| Subject                         | Description                                     | Predicates                                                                                                                                  |
|---------------------------------|-------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------|
| [`testCaseRun`](#testcaserun)   | The execution of a software testCase            | [`queued`](#testcaserun-queued), [`finished`](#testcaserun-finished) [`started`](#testcaserun-started), [`finished`](#testcaserun-finished) |
| [`testSuiteRun`](#testsuiterun) | The execution of a software testSuite           | [`queued`](#testsuiterun-queued), [`started`](#testsuiterun-started), [`finished`](#testsuiterun-finished)                                  |
| [`testOutput`](#testoutput)     | An output artifact produced by a test execution | [`published`](#testoutput-published)                                                                                                        |

### `testCaseRun`

A `testCaseRun` is a process that performs a test against an input software artifact of some kind, for instance source code, a binary, a container image or else.
A `testCaseRun` is the smallest unit of testing that the user wants to track, `testSuiteRuns` are for grouping purposes.

| Field          | Type                                                                            | Description                                                                                     | Examples                                           |
|----------------|---------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|----------------------------------------------------|
| id             | `String`                                                                        | Uniquely identifies the subject within the source.                                              | `integration-test-abc`, `e2e-test1`, `scan-image1` |
| source         | `URI-Reference`                                                                 | [source](spec.md#source--context-) from the context                                             | `staging/tekton`, `tekton-dev-123`                 |
| type           | `String`                                                                        | An optional type of test                                                                        | `functional`, `unit`, `performance`, `security`    |
| environment    | `Object` [`environment`](continuous-deployment-pipeline-events.md/#environment) | The environment in which this testCaseRun is executing                                          | `dev`, `prod`                                      |
| testCaseId     | `String`                                                                        | An optional testCase ID to enable collation of events related to a specific testCase definition |                                                    |          |
| testSuiteRunId | `String`                                                                        | An optional testSuiteRun ID to associate this testCaseRun with a containing testSuiteRun        |                                                    |          |

### `testSuiteRun`

A `testSuiteRun` represents the execution of a set of one or more `testCaseRuns`. 

| Field       | Type                                                                            | Description                                                                                       | Examples                           |
|-------------|---------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------|------------------------------------|
| id          | `String`                                                                        | Uniquely identifies the subject within the source.                                                | `my-testsuite`, `regression-123`   |
| source      | `URI-Reference`                                                                 | [source](spec.md#source--context-) from the context                                               | `staging/tekton`, `tekton-dev-123` |
| environment | `Object` [`environment`](continuous-deployment-pipeline-events.md/#environment) | The environment in which this testSuiteRun is executing                                           | `dev`, `prod`                      |
| testSuiteId | `String`                                                                        | An optional testSuite ID to enable collation of events related to a specific testSuite definition |                                    |          |

### `testOutput`

One or more `testOutput` artifacts are usually produced as the result of a test execution.  

| Field         | Type            | Description                                                                       | Examples                                                 |
|---------------|-----------------|-----------------------------------------------------------------------------------|----------------------------------------------------------|
| id            | `String`        | Uniquely identifies the subject within the source.                                | `23123123`                                               |
| source        | `URI-Reference` | [source](spec.md#source--context-) from the context                               | `staging/tekton`, `tekton-dev-123`                       |
| type          | `String`        | The type of output, one of `report`, `video`, `image`, `log`, `other`             | `video`                                                  |
| format        | `String`        | The Content-Type of the output artifact                                           | `application/pdf`, `image/png`, `application/json`       |         
| uri           | `URI-Reference` | A reference to retrieve the specified output artifact                             | `https://testkube.mycluster.internal/artifacts/23123123` |         
| testCaseRunId | `String`        | An optional testCaseRun ID to link this artifact to a specific testCase execution |                                                          |          |


## Events

### `testCaseRun queued`

This event represents when a testCaseRun has been queued for execution - and is waiting for applicable preconditions
(resource availability, other tasks, etc.) to be met before actually executing.

- Event Type: __`dev.cdevents.testcaserun.queued.0.1.0-draft`__
- Predicate: queued
- Subject: [`testCaseRun`](#testcaserun)

| Field   | Type                         | Description                                         | Examples                                  | Required |
|---------|------------------------------|-----------------------------------------------------|-------------------------------------------|----------|
| id      | `String`                     | Uniquely identifies the subject within the source.  | `unitest-abc`, `e2e-test1`, `scan-image1` | ✅        |
| source  | `URI-Reference`              | [source](spec.md#source--context-) from the context |                                           |          |
| trigger | `Object` [trigger](#trigger) | What triggered this testCaseRun                     ||

### `testCaseRun started`

This event represents a started testCase execution. 

- Event Type: __`dev.cdevents.testcaserun.started.0.1.0-draft`__
- Predicate: started
- Subject: [`testCaseRun`](#testcaserun)

| Field   | Type                         | Description                                         | Examples                                  | Required |
|---------|------------------------------|-----------------------------------------------------|-------------------------------------------|----------|
| id      | `String`                     | Uniquely identifies the subject within the source.  | `unitest-abc`, `e2e-test1`, `scan-image1` | ✅        |
| source  | `URI-Reference`              | [source](spec.md#source--context-) from the context |                                           |          |
| trigger | `Object` [trigger](#trigger) | What triggered this testCaseRun                     ||

### `testCaseRun finished`

This event represents a finished testCase execution. The event will contain the finished status and additional metadata as applicable.

- Event Type: __`dev.cdevents.testcaserun.finished.0.1.0-draft`__
- Predicate: finished
- Subject: [`testCaseRun`](#testcaserun)

| Field    | Type            | Description                                                                         | Examples                                  | Required |
|----------|-----------------|-------------------------------------------------------------------------------------|-------------------------------------------|----------|
| id       | `String`        | Uniquely identifies the subject within the source.                                  | `unitest-abc`, `e2e-test1`, `scan-image1` | ✅        |
| source   | `URI-Reference` | [source](spec.md#source--context-) from the context                                 |                                           |          |
| status   | `String`        | The status of the testSuite execution, one of `pass`, `fail`, `abort`, `error`      |                                           | ✅        |
| severity | `String`        | An optional severity if the test failed, one of `low`, `medium`, `high`, `critical` | `critical`, `low`, `medium`, `high`       |
| reason   | `String`        | An optional reason related to the status of the execution                           | `Cancelled by user`, `Failed assertion`   |          |

### `testSuiteRun queued`

This event represents when a testSuiteRun has been queued for execution - and is waiting for applicable preconditions
(resource availability, other tasks, etc.) to be met before actually executing.

- Event Type: __`dev.cdevents.testsuiterun.queued.0.1.0-draft`__
- Predicate: queued
- Subject: [`testSuiteRun`](#testsuiterun)

| Field   | Type                         | Description                                         | Examples                                  | Required |
|---------|------------------------------|-----------------------------------------------------|-------------------------------------------|----------|
| id      | `String`                     | Uniquely identifies the subject within the source.  | `unitest-abc`, `e2e-test1`, `scan-image1` | ✅        |
| source  | `URI-Reference`              | [source](spec.md#source--context-) from the context |                                           |          |
| trigger | `Object` [trigger](#trigger) | What triggered this testSuiteRun                    ||

### `testSuiteRun started`

This event represents a started testSuite execution.

- Event Type: __`dev.cdevents.testsuiterun.started.0.1.0-draft`__
- Predicate: started
- Subject: [`testSuiteRun`](#testsuiterun)

| Field   | Type                         | Description                                         | Examples                  | Required |
|---------|------------------------------|-----------------------------------------------------|---------------------------|----------|
| id      | `String`                     | Uniquely identifies the subject within the source.  | `unit`, `e2e`, `security` | ✅        |
| source  | `URI-Reference`              | [source](spec.md#source--context-) from the context |                           |          |
| trigger | `Object` [trigger](#trigger) | What triggered this testSuiteRun                    ||

### `testSuiteRun finished`

This event represents a finished testSuite execution. The event will contain the execution status and additional metadata as applicable.

- Event Type: __`dev.cdevents.testsuiterun.finished.0.1.0-draft`__
- Predicate: finished
- Subject: [`testSuiteRun`](#testsuiterun)

| Field    | Type            | Description                                                                         | Examples                               | Required |
|----------|-----------------|-------------------------------------------------------------------------------------|----------------------------------------|----------|
| id       | `String`        | Uniquely identifies the subject within the source.                                  | `unit`, `e2e`, `security`              | ✅        |
| source   | `URI-Reference` | [source](spec.md#source--context-) from the context                                 |                                        |          |
| status   | `String`        | The status of the testSuite execution, one of `pass`, `fail`, `abort`, `error`      |                                        | ✅        |
| severity | `String`        | An optional severity if the test failed, one of `low`, `medium`, `high`, `critical` | `critical`, `low`, `medium`, `high`    |
| reason   | `String`        | An optional reason related to the status of the execution                           | `Cancelled by user`, `Failed testCase` |          |

### `testOutput published`

The event represents a test execution output artifact that has been published.

- Event Type: __`dev.cdevents.testoutput.published.0.1.0-draft`__
- Predicate: published
- Subject: [`testOutput`](#testoutput)

| Field         | Type            | Description                                                                       | Examples   | Required |
|---------------|-----------------|-----------------------------------------------------------------------------------|------------|----------|
| id            | `String`        | Uniquely identifies the subject within the source.                                | `12312334` | ✅        |
| source        | `URI-Reference` | [source](spec.md#source--context-) from the context                               |            | ✅        |

## Common Objects

### `trigger`

A `trigger` in this context is what started a corresponding testCaseRun/testSuiteRun.

| Field       | Type            | Description                                                                    | Examples | Required |
|-------------|-----------------|--------------------------------------------------------------------------------|----------|----------|
| type        | `String`        | The type of trigger, one of `manual`, `pipeline`, `event`, `schedule`, `other` |          | ✅        |
| uri         | `URI-Reference` | An optional uri reference to this trigger                                      |          |          |

