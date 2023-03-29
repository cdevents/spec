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

This specification defines three subjects in this stage: `testCase`, `testSuite` and `testOutput`. 

| Subject                         | Description                                  | Predicates                                                                                                 |
|---------------------------------|----------------------------------------------|------------------------------------------------------------------------------------------------------------|
| [`testCaseRun`](#testcaserun)   | The execution of a software testCase         | [`queued`](#testcaserun-queued), [`started`](#testcaserun-started) [`finished`](#testcaserun-finished)     |
| [`testSuiteRun`](#testsuiterun) | The execution of a software testSuite        | [`queued`](#testsuiterun-queued), [`started`](#testsuiterun-started), [`finished`](#testsuiterun-finished) |
| [`testOutput`](#testoutput)     | An output artifact produced by a testCaseRun | [`published`](#testoutput-published)                                                                       |

### `testCaseRun`

A `testCaseRun` is a process that executes a test against an input software artifact of some kind, for instance source code, a binary, a container image or else.
A `testCaseRun` is the smallest unit of testing that the user wants to track, `testSuiteRuns` are for grouping purposes.

| Field        | Type                                                                            | Description                                                                           | Examples                                                                |
|--------------|---------------------------------------------------------------------------------|---------------------------------------------------------------------------------------|-------------------------------------------------------------------------|
| id           | `String`                                                                        | Uniquely identifies the subject within the source.                                    | `Login-Test-execution-1213423`, `e2e-test1`, `2334234324`               |
| source       | `URI-Reference`                                                                 | [source](spec.md#source--context-) from the context                                   | `staging/testkube`, `testkube-dev-123`                                  |
| type         | `String`                                                                        | An optional type of test                                                              | `functional`, `unit`, `performance`, `security`                         |
| environment  | `Object` [`environment`](continuous-deployment-pipeline-events.md/#environment) | The environment in which this testCaseRun is executing                                | `{"id": "1234"}`, `{"id": "dev", "source": "testkube-dev-123"}`         |
| testCase     | `Object` [`testCase`](#testcase)                                                | An optional definition of the testCase being executed                                 | `{"id": "92834723894", "name": "Login Test", "type":"integration"}`     |          |
| testSuiteRun | `Object` [`testSuiteRun`](#testsuiterun)                                        | An optional testSuiteRun to associate this testCaseRun with a containing testSuiteRun | `{"id":"Auth-TestSuite-execution-12334", "source": "staging/testkube"}` |          |

### `testSuiteRun`

A `testSuiteRun` represents the execution of a set of one or more `testCaseRuns`.

| Field       | Type                                                                            | Description                                             | Examples                                                        |
|-------------|---------------------------------------------------------------------------------|---------------------------------------------------------|-----------------------------------------------------------------|
| id          | `String`                                                                        | Uniquely identifies the subject within the source.      | `Auth-TestSuite-execution-12334`, `regression-123`              |
| source      | `URI-Reference`                                                                 | [source](spec.md#source--context-) from the context     | `staging/testkube`, `testkube-dev-123`                          |
| environment | `Object` [`environment`](continuous-deployment-pipeline-events.md/#environment) | The environment in which this testSuiteRun is executing | `{"id": "1234"}`, `{"id": "dev", "source": "testkube-dev-123"}` |
| testSuite   | `Object` [`testSuite`](#testsuite)                                              | An optional definition of the testSuite being executed  | `{"id": "92834723894", "name": "Auth TestSuite"}`               |          |

### `testOutput`

One or more `testOutput` artifacts are usually produced as the result of a test execution.  

| Field       | Type                                   | Description                                                               | Examples                                                              |
|-------------|----------------------------------------|---------------------------------------------------------------------------|-----------------------------------------------------------------------|
| id          | `String`                               | Uniquely identifies the subject within the source.                        | `report-23123123`                                                     |
| source      | `URI-Reference`                        | [source](spec.md#source--context-) from the context                       | `staging/testkube`, `testkube-dev-123`                                |
| type        | `String`                               | The type of output, one of `report`, `video`, `image`, `log`, `other`     | `video`                                                               |
| format      | `String`                               | The Content-Type of the output artifact                                   | `application/pdf`, `image/png`, `application/json`                    |         
| uri         | `URI-Reference`                        | A reference to retrieve the specified output artifact                     | `https://testkube.mycluster.internal/artifacts/23123123`              |         
| testCaseRun | `Object` [`testCaseRun`](#testcaserun) | An optional testCaseRun to link this artifact to a specific `testCaseRun` | `{"id":"Login-Test-execution-1213423", "source": "staging/testkube"}` |          |

## Events

### `testCaseRun queued`

This event represents when a testCaseRun has been queued for execution - and is waiting for applicable preconditions
(resource availability, other tasks, etc.) to be fulfilled before actually executing.

- Event Type: __`dev.cdevents.testcaserun.queued.0.1.0-draft`__
- Predicate: queued
- Subject: [`testCaseRun`](#testcaserun)

| Field        | Type                                                                            | Description                                                                           | Examples                                                                | Required |
|--------------|---------------------------------------------------------------------------------|---------------------------------------------------------------------------------------|-------------------------------------------------------------------------|----------|
| id           | `String`                                                                        | Uniquely identifies the subject within the source.                                    | `unitest-abc`, `e2e-test1`, `scan-image1`                               | ✅        |
| source       | `URI-Reference`                                                                 | [source](spec.md#source--context-) from the context                                   |                                                                         |          |
| environment  | `Object` [`environment`](continuous-deployment-pipeline-events.md/#environment) | The environment in which this testCaseRun is queued                                   | `{"id": "1234"}`, `{"id": "dev", "source": "testkube-dev-123"}`         | ✅        |
| testCase     | `Object` [`testCase`](#testcase)                                                | An optional definition of the testCase being executed                                 | `{"id": "92834723894", "name": "Login Test", "type":"integration"}`     |          |
| testSuiteRun | `Object` [`testSuiteRun`](#testsuiterun)                                        | An optional testSuiteRun to associate this testCaseRun with a containing testSuiteRun | `{"id":"Auth-TestSuite-execution-12334", "source": "staging/testkube"}` |          |
| trigger      | `Object` [trigger](#trigger)                                                    | What triggered this testSuiteRun                                                      | `{"type": "schedule}`                                                   |

### `testCaseRun started`

This event represents a started testCase execution. 

- Event Type: __`dev.cdevents.testcaserun.started.0.1.0-draft`__
- Predicate: started
- Subject: [`testCaseRun`](#testcaserun)

| Field        | Type                                                                            | Description                                                                           | Examples                                                                | Required |
|--------------|---------------------------------------------------------------------------------|---------------------------------------------------------------------------------------|-------------------------------------------------------------------------|----------|
| id           | `String`                                                                        | Uniquely identifies the subject within the source.                                    | `unitest-abc`, `e2e-test1`, `scan-image1`                               | ✅        |
| source       | `URI-Reference`                                                                 | [source](spec.md#source--context-) from the context                                   |                                                                         |          |
| environment  | `Object` [`environment`](continuous-deployment-pipeline-events.md/#environment) | The environment in which this testCaseRun is running                                  | `{"id": "1234"}`, `{"id": "dev", "source": "testkube-dev-123"}`         | ✅        |
| testCase     | `Object` [`testCase`](#testcase)                                                | An optional definition of the testCase being executed                                 | `{"id": "92834723894", "name": "Login Test", "type":"integration"}`     |          |
| testSuiteRun | `Object` [`testSuiteRun`](#testsuiterun)                                        | An optional testSuiteRun to associate this testCaseRun with a containing testSuiteRun | `{"id":"Auth-TestSuite-execution-12334", "source": "staging/testkube"}` |          |
| trigger      | `Object` [trigger](#trigger)                                                    | What triggered this testSuiteRun                                                      | `{"type": "event}`                                                      |

### `testCaseRun finished`

This event represents a finished testCase execution. The event will contain the finished status and additional metadata as applicable.

- Event Type: __`dev.cdevents.testcaserun.finished.0.1.0-draft`__
- Predicate: finished
- Subject: [`testCaseRun`](#testcaserun)

| Field        | Type                                                                            | Description                                                                           | Examples                                                                | Required |
|--------------|---------------------------------------------------------------------------------|---------------------------------------------------------------------------------------|-------------------------------------------------------------------------|----------|
| id           | `String`                                                                        | Uniquely identifies the subject within the source.                                    | `unitest-abc`, `e2e-test1`, `scan-image1`                               | ✅        |
| source       | `URI-Reference`                                                                 | [source](spec.md#source--context-) from the context                                   |                                                                         |          |
| type         | `String`                                                                        | An optional type of test                                                              | `functional`, `unit`, `performance`, `security`                         |
| environment  | `Object` [`environment`](continuous-deployment-pipeline-events.md/#environment) | The environment in which this testCaseRun was running                                 | `{"id": "1234"}`, `{"id": "dev", "source": "testkube-dev-123"}`         | ✅        |
| testCase     | `Object` [`testCase`](#testcase)                                                | An optional definition of the testCase being executed                                 | `{"id": "92834723894", "name": "Login Test", "type":"integration"}`     |          |
| testSuiteRun | `Object` [`testSuiteRun`](#testsuiterun)                                        | An optional testSuiteRun to associate this testCaseRun with a containing testSuiteRun | `{"id":"Auth-TestSuite-execution-12334", "source": "staging/testkube"}` |          |
| status       | `String`                                                                        | The status of the testSuite execution, one of `pass`, `fail`, `cancel`, `error`       | `pass`                                                                  | ✅        |
| severity     | `String`                                                                        | An optional severity if the test failed, one of `low`, `medium`, `high`, `critical`   | `critical`                                                              |
| reason       | `String`                                                                        | An optional reason related to the `status` of the execution                           | `Cancelled by user`, `Failed assertion`, `Timed out`                    |          |

### `testSuiteRun queued`

This event represents when a testSuiteRun has been queued for execution - and is waiting for applicable preconditions
(resource availability, other tasks, etc.) to be met before actually executing.

- Event Type: __`dev.cdevents.testsuiterun.queued.0.1.0-draft`__
- Predicate: queued
- Subject: [`testSuiteRun`](#testsuiterun)

| Field       | Type                                                                            | Description                                            | Examples                                                        | Required |
|-------------|---------------------------------------------------------------------------------|--------------------------------------------------------|-----------------------------------------------------------------|----------|
| id          | `String`                                                                        | Uniquely identifies the subject within the source.     | `unitest-abc`, `e2e-test1`, `scan-image1`                       | ✅        |
| source      | `URI-Reference`                                                                 | [source](spec.md#source--context-) from the context    |                                                                 |          |
| environment | `Object` [`environment`](continuous-deployment-pipeline-events.md/#environment) | The environment in which this testSuiteRun is queued   | `{"id": "1234"}`, `{"id": "dev", "source": "testkube-dev-123"}` | ✅        |
| testSuite   | `Object` [`testSuite`](#testsuite)                                              | An optional definition of the testSuite being executed | `{"id": "92834723894", "name": "Auth TestSuite"}`               |          |
| trigger     | `Object` [trigger](#trigger)                                                    | What triggered this testSuiteRun                       | `{"type": "manual}`                                             |

### `testSuiteRun started`

This event represents a started testSuite execution.

- Event Type: __`dev.cdevents.testsuiterun.started.0.1.0-draft`__
- Predicate: started
- Subject: [`testSuiteRun`](#testsuiterun)

| Field       | Type                                                                            | Description                                            | Examples                                                        | Required |
|-------------|---------------------------------------------------------------------------------|--------------------------------------------------------|-----------------------------------------------------------------|----------|
| id          | `String`                                                                        | Uniquely identifies the subject within the source.     | `unit`, `e2e`, `security`                                       | ✅        |
| source      | `URI-Reference`                                                                 | [source](spec.md#source--context-) from the context    |                                                                 |          |
| environment | `Object` [`environment`](continuous-deployment-pipeline-events.md/#environment) | The environment in which this testSuiteRun is running  | `{"id": "1234"}`, `{"id": "dev", "source": "testkube-dev-123"}` | ✅        |
| testSuite   | `Object` [`testSuite`](#testsuite)                                              | An optional definition of the testSuite being executed | `{"id": "92834723894", "name": "Auth TestSuite"}`               |          |
| trigger     | `Object` [trigger](#trigger)                                                    | What triggered this testSuiteRun                       | `{"type": "pipeline}`                                           |

### `testSuiteRun finished`

This event represents a finished testSuite execution. The event will contain the execution status and additional metadata as applicable.

- Event Type: __`dev.cdevents.testsuiterun.finished.0.1.0-draft`__
- Predicate: finished
- Subject: [`testSuiteRun`](#testsuiterun)

| Field       | Type                                                                            | Description                                                                         | Examples                                                        | Required |
|-------------|---------------------------------------------------------------------------------|-------------------------------------------------------------------------------------|-----------------------------------------------------------------|----------|
| id          | `String`                                                                        | Uniquely identifies the subject within the source.                                  | `unit`, `e2e`, `security`                                       | ✅        |
| source      | `URI-Reference`                                                                 | [source](spec.md#source--context-) from the context                                 |                                                                 |          |
| environment | `Object` [`environment`](continuous-deployment-pipeline-events.md/#environment) | The environment in which this testSuiteRun was running                              | `{"id": "1234"}`, `{"id": "dev", "source": "testkube-dev-123"}` | ✅        |
| status      | `String`                                                                        | The status of the testSuite execution, one of `pass`, `fail`, `cancel`, `error`     | `fail`                                                          | ✅        |
| severity    | `String`                                                                        | An optional severity if the test failed, one of `low`, `medium`, `high`, `critical` | `critical`, `low`, `medium`, `high`                             |
| reason      | `String`                                                                        | An optional reason related to the status of the execution                           | `Cancelled by user`, `Failed testCase`                          |          |
| testSuite   | `Object` [`testSuite`](#testsuite)                                              | An optional definition of the testSuite being executed                              | `{"id": "92834723894", "name": "Auth TestSuite"}`               |          |

### `testOutput published`

The event represents a test execution output artifact that has been published.

- Event Type: __`dev.cdevents.testoutput.published.0.1.0-draft`__
- Predicate: published
- Subject: [`testOutput`](#testoutput)

| Field       | Type                                   | Description                                                               | Examples                                                              | Required |
|-------------|----------------------------------------|---------------------------------------------------------------------------|-----------------------------------------------------------------------|----------|
| id          | `String`                               | Uniquely identifies the subject within the source.                        | `12312334`                                                            | ✅        |
| source      | `URI-Reference`                        | [source](spec.md#source--context-) from the context                       |                                                                       | ✅        |
| type        | `String`                               | The type of output, one of `report`, `video`, `image`, `log`, `other`     | `video`                                                               | ✅        |
| format      | `String`                               | The Content-Type of the output artifact                                   | `application/pdf`, `image/png`, `application/json`                    | ✅        |
| uri         | `URI-Reference`                        | A reference to retrieve the specified output artifact                     | `https://testkube.mycluster.internal/artifacts/23123123`              | ✅        |
| testCaseRun | `Object` [`testCaseRun`](#testcaserun) | An optional testCaseRun to link this artifact to a specific `testCaseRun` | `{"id":"Login-Test-execution-1213423", "source": "staging/testkube"}` |          |

## Common Objects

### `trigger`

A `trigger` in this context is what started a corresponding testCaseRun/testSuiteRun.

| Field       | Type            | Description                                                                    | Examples | Required |
|-------------|-----------------|--------------------------------------------------------------------------------|----------|----------|
| type        | `String`        | The type of trigger, one of `manual`, `pipeline`, `event`, `schedule`, `other` |          | ✅        |
| uri         | `URI-Reference` | An optional uri reference to this trigger                                      |          |          |

### `testCase`

A `testCase` is the actual test that is being run by a `testCaseRun`. 

| Field  | Type            | Description                                         | Examples                   | Required |
|--------|-----------------|-----------------------------------------------------|----------------------------|----------|
| id     | `String`        | Uniquely identifies the testCase within the source. | `12312334`                 | ✅        |
| source | `URI-Reference` | [source](spec.md#source--context-) from the context |                            | ✅        |
| type   | `String`        | An optional type of test                            | `functional`,`performance` |          |
| name   | `String`        | An user-friendly name for this testCase             | `Login Test`               |          |
| uri    | `URI-Reference` | An optional uri reference to this testCase          |                            |          |


### `testSuite`

A `testSuite` is a collection of `testCase` objects managed in an external system. Each time a `testSuite` is executed the 
corresponding `testSuiteXXX` events should be emmitted.

| Field  | Type            | Description                                          | Examples         | Required |
|--------|-----------------|------------------------------------------------------|------------------|----------|
| id     | `String`        | Uniquely identifies the testSuite within the source. | `12312334`       | ✅        |
| source | `URI-Reference` | [source](spec.md#source--context-) from the context  |                  | ✅        |
| name   | `String`        | An user-friendly name for this testSuite             | `Auth TestSuite` |          |
| uri    | `URI-Reference` | An optional uri reference to this testSuite          |                  |          |

