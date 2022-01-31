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

These events are related to __Continuous Integration(CI)__ activities. CI usually include activities such as building, testing, packaging and releasing software artifacts.

The following events represent concrete Tasks that are associated with the execution of CI pipelines:

- __Build Queued__: a Build task has been queued, this build process usually is in charge of producing a binary from source code
- __Build Started__: a Build task has started
- __Build Finished__: a Build task has finished, the event will contain the finished status, success, error or failure

The following Test events are defined in two separate categories __Test Case__ and __Test Suite__. A __Test Case__ is the smallest unit of testing that the user wants to track. A __Test Suite__ is a collection of test case executions and/or other test suite executions. __Test Cases__ executed, and Test Suites are for grouping purposes. For this reason, __Test Cases__ can be queued.

- __Test Case Queued__: a Test task has been queued, and it is waiting to be started
- __Test Case Started__: a Test task has started
- __Test Case Finished__: a Test task has finished, the event will contain the finished status: success, error or failure
- __Test Suite Started__: a Test Suite has started
- __Test Suite Finished__: a Test Suite has finished, the event will contain the finished status: success, error or failure

Finally, events needs to be generated for the output of the pipeline such as the artifacts that were packaged and released for others to use.

- __Artifact Packaged__: an artifact has been packaged for distribution, this artifact is now versioned with a fixed version
- __Artifact Published__: an artifact has been published and it can be advertised for others to use

CI Events MUST include the following attributes:

- __Event Type__: the type is restricted to include `cd.__` prefix. For example `cd.build.queued` or `cd.artifact.packaged`

Optional attributes:

- __Artifact Id__: the unique identifier of the artifact that the event is referring to.
