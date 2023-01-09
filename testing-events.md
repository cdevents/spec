<!--
---
linkTitle: "Continuous Integration Events"
weight: 50
hide_summary: true
icon: "fa-solid fa-network-wired"
description: >
   Continuous Integration Events
---
-->
# Testing Events

Testing events include the subject and predicates related to test-execution and reporting activities which are 
performed out-of-bounds of CI/CD pipelines/workflows. For test-related events performed as part of a 
CI pipeline have a look at [Continuous Integration Events](continuous-integration-pipeline-events.md)

## Subjects

This specification defines three subjects in this stage: `testCase`, `testSuite` and `testArtifact`. 

| Subject                         | Description                    | Predicates                                                                                     |
|---------------------------------|--------------------------------|------------------------------------------------------------------------------------------------|
| [`testCase`](#testcase)         | A software test case           | [`queued`](#testcase-queued), [`started`](#testcase-started), [`finished`](#testcase-finished) |
| [`testSuite`](#testsuite)       | A collection of test cases     | [`started`](#testsuite-started), [`finished`](#testsuite-finished)                             |
| [`testArtifact`](#testartifact) | An artifact produced by a test | [`published`](#testartifact-published)                                                         |

### `testCase`

A `testCase` is a process that performs a test against an input software artifact of some kind, for instance source code, a binary, a container image or else. A `testCase`  is the smallest unit of testing that the user wants to track. `testCases` are executed, and `testSuites` are for grouping purposes. For this reason, `testCases` can be queued.

| Field     | Type            | Description                                                                                                                         | Examples                                  |
|-----------|-----------------|-------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------|
| id        | `String`        | Uniquely identifies the subject within the source.                                                                                  | `unitest-abc`, `e2e-test1`, `scan-image1` |
| source    | `URI-Reference` | [source](spec.md#source--context-) from the context                                                                                           | `staging/tekton`, `tekton-dev-123`        |
| type      | `String`   | Type type of test, must be one of the following: `unit`, `functional`, `performance`, `integration`, `security`, `compliance`, `other` | `functional`                              |
| testSuite | `String`   | an optional ID of the containing testSuite                                                                                          | `functional`                              |

### `testSuite`

A `testSuite` represents a set of one or more `testCases`.

__Note:__ The data model for `testSuite` only includes `id` and `source`, inputs and outputs of the process are not specified yet, as well as the relation to `testCase`.

| Field | Type | Description | Examples |
|-------|------|-------------|----------|
| id    | `String` | Uniquely identifies the subject within the source. | `unit`, `e2e`, `security` |
| source | `URI-Reference` | [source](spec.md#source--context-) from the context | `staging/tekton`, `tekton-dev-123`|

### `testArtifact`

An `testArtifact` is usually produced as output of a test execution 

| Field  | Type            | Description                                                   | Examples                                                |
|--------|-----------------|---------------------------------------------------------------|---------------------------------------------------------|
| id     | `String`        | Uniquely identifies the subject within the source.            | `23123123`                                              |
| source | `URI-Reference` | [source](spec.md#source--context-) from the context             | `staging/tekton`, `tekton-dev-123`                      |
| type   | `String`        | The type of artifact, one of report, video, image, log, other | `video`                                                 |
| format | `String`        | The Content-Type of the artifact                              | `application/pdf`, `image/png`, `application/json`      |         
| url    | `URI-Reference` | A reference to the specified artifact                         | `https://testkube.mycluster.internal/artifacts/23123123` |         

## Events

### `testCase queued`

This event represents a Test task that has been queued, and it is waiting to be started.

- Event Type: __`dev.cdevents.testcase.queued.0.1.0`__
- Predicate: queued
- Subject: [`testCase`](#testcase)

| Field | Type | Description | Examples | Required |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | Uniquely identifies the subject within the source. | `unitest-abc`, `e2e-test1`, `scan-image1` | ✅ |
| source | `URI-Reference` | [source](spec.md#source--context-) from the context | | |

### `testCase started`

This event represents a Test task that has started.

- Event Type: __`dev.cdevents.testcase.started.0.1.0`__
- Predicate: started
- Subject: [`testCase`](#testcase)

| Field | Type | Description | Examples | Required |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | Uniquely identifies the subject within the source. | `unitest-abc`, `e2e-test1`, `scan-image1` | ✅ |
| source | `URI-Reference` | [source](spec.md#source--context-) from the context | | |

### `testCase finished`

This event represents a Test task that has finished. This event will eventually contain the finished status: success, error or failure.

- Event Type: __`dev.cdevents.testcase.finished.0.1.0`__
- Predicate: finished
- Subject: [`testCase`](#testcase)

| Field | Type | Description | Examples | Required |
|-------|------|-------------|----------|---------------------|
| id    | `String` | Uniquely identifies the subject within the source. | `unitest-abc`, `e2e-test1`, `scan-image1` | ✅ |
| source | `URI-Reference` | [source](spec.md#source--context-) from the context | | |
| status | `String` | The status of the testSuite execution, one of `passed`, `failed`, `aborted` | | ✅ |

### `testSuite started`

This event represents a Test suite that has been started.

- Event Type: __`dev.cdevents.testsuite.started.0.1.0`__
- Predicate: started
- Subject: [`testSuite`](#testsuite)

| Field | Type | Description | Examples | Required |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | Uniquely identifies the subject within the source. | `unit`, `e2e`, `security` | ✅ |
| source | `URI-Reference` | [source](spec.md#source--context-) from the context | | |

### `testSuite finished`

This event represents a Test suite that has has finished, the event will contain the finished status: success, error or failure.

- Event Type: __`dev.cdevents.testsuite.finished.0.1.0`__
- Predicate: finished
- Subject: [`testSuite`](#testsuite)

| Field | Type | Description | Examples | Required |
|-------|------|-------------|----------|----------|
| id    | `String` | Uniquely identifies the subject within the source. | `unit`, `e2e`, `security` | ✅        |
| source | `URI-Reference` | [source](spec.md#source--context-) from the context | |          |
| status | `String` | The status of the testSuite execution, one of `passed`, `failed`, `aborted` | | ✅        |

### `testArtifact published`

The event represents a test artifact that has been published and can be consumed by others.

- Event Type: __`dev.cdevents.testartifact.published.0.1.0`__
- Predicate: published
- Subject: [`testArtifact`](#testartifact)

| Field | Type | Description | Examples | Required |
|-------|------|-------------|----------|----------------------------|
| id    | `Purl` | Uniquely identifies the subject within the source. | `pkg:oci/myapp@sha256%3A0b31b1c02ff458ad9b7b81cbdf8f028bd54699fa151f221d1e8de6817db93427?repository_url=mycr.io/myapp`, `pkg:golang/mygit.com/myorg/myapp@234fd47e07d1004f0aed9c` | ✅ |
| source | `URI-Reference` | [source](spec.md#source--context-) from the context | | |
