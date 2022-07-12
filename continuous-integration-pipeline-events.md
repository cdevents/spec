<!--
---
linkTitle: "Continuous Integration Events"
weight: 50
description: >
   Continuous Integration Events
---
-->
# Continuous Integration Events

__Note:__ This is a work-in-progress draft version and is being worked on by members of the Events SIG. You are very welcome to join the work and the discussions!

Continuous Integration (CI) events include the subject and predicates related to CI activities such as building software, producing artifacts and running tests.

## Subjects

This specification defines three subjects in this stage: `builds`, `artifacts` and `tests`. Events associated with these subjects are typically generated either by a CI system that orchestrates the process or by a specific build or test tool directly. Some artifact events may be triggered by the system that stores the artifact as well.

| Subject | Description | Predicates |
|---------|-------------|------------|
| [`build`](#build) | A software build | [`queued`](#build-queued), [`started`](#build-started), [`finished`](#build-finished)|
| [`testCase`](#testCase) | A software test case | [`queued`](#testCase-queued), [`started`](#testCase-started), [`finished`](#testCase-finished)|
| [`testSuite`](#testSuite) | A collection of test cases | [`started`](#testSuite-started), [`finished`](#testSuite-finished)|

### `build`

A `build` is a process that uses a recipe to produce an artifact from source code.

__Note:__ The data model for `builds`, apart from `id` and `source`, only includes the identifier of the artifact produced by the build. The inputs to the build process are not specified yet.

| Field | Type | Description | Examples |
|-------|------|-------------|----------|
| id    | `String` | Uniquely identifies the subject within the source. | `1234`, `maven123`, `builds/taskrun123` |
| source | `URI-Reference` | [source](../spec.md#source) from the context | `staging/tekton`, `tekton-dev-123`|
| artifactId | `String` | Identifier of the artifact produced by the build | `0b31b1c02ff458ad9b7b81cbdf8f028bd54699fa151f221d1e8de6817db93427`, `927aa808433d17e315a258b98e2f1a55f8258e0cb782ccb76280646d0dbe17b5`, `-six-1.14.0-py2.py3-none-any.whl`|

### `testCase`

A `testCase` is a process that performs a test against an input software artifact of some kind, for instance source code, a binary, a container image or else.

__Note:__ The data model for `testCase` only includes `id` and `source`, inputs and outputs of the process are not specified yet, as well as the relation to `testSuite`.

| Field | Type | Description | Examples |
|-------|------|-------------|----------|
| id    | `String` | Uniquely identifies the subject within the source. | `unitest`, `maven123`, `builds/taskrun123` |
| source | `URI-Reference` | [source](../spec.md#source) from the context | `staging/tekton`, `tekton-dev-123`|

### `testSuite`

A `testSuite` represents a set of one or more `testCases`.

__Note:__ The data model for `testSuite` only includes `id` and `source`, inputs and outputs of the process are not specified yet, as well as the relation to `testCase`.

| Field | Type | Description | Examples |
|-------|------|-------------|----------|
| id    | `String` | Uniquely identifies the subject within the source. | `1234`, `maven123`, `builds/taskrun123` |
| source | `URI-Reference` | [source](../spec.md#source) from the context | `staging/tekton`, `tekton-dev-123`|

## Events

### `build queued`

The following events represent concrete Tasks that are associated with the execution of CI pipelines:

- __Build Queued__: a Build task has been queued, this build process usually is in charge of producing a binary from source code

### `build started`

- __Build Started__: a Build task has started

### `build finished`

- __Build Finished__: a Build task has finished, the event will contain the finished status, success, error or failure

The following Test events are defined in two separate categories __Test Case__ and __Test Suite__. A __Test Case__ is the smallest unit of testing that the user wants to track. A __Test Suite__ is a collection of test case executions and/or other test suite executions. __Test Cases__ executed, and Test Suites are for grouping purposes. For this reason, __Test Cases__ can be queued.

### `testCase queued`

- __Test Case Queued__: a Test task has been queued, and it is waiting to be started

### `testCase started`

- __Test Case Started__: a Test task has started

### `testCase finished`

- __Test Case Finished__: a Test task has finished, the event will contain the finished status: success, error or failure

### `testSuite started`

- __Test Suite Started__: a Test Suite has started

### `testSuite finished`

- __Test Suite Finished__: a Test Suite has finished, the event will contain the finished status: success, error or failure

Finally, events needs to be generated for the output of the pipeline such as the artifacts that were packaged and released for others to use.

### `artifact packaged`

- __Artifact Packaged__: an artifact has been packaged for distribution, this artifact is now versioned with a fixed version

### `artifact published`

- __Artifact Published__: an artifact has been published and it can be advertised for others to use

CI Events MUST include the following attributes:

- __Event Type__: the type is restricted to include `dev.cdevents.__` prefix. For example `dev.cdevents.build.queued` or `dev.cdevents.artifact.packaged`

Optional attributes:

- __Artifact Id__: the unique identifier of the artifact that the event is referring to.
