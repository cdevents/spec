# Continuous Integration Events

__Note:__ This is a work-in-progress draft version and is being worked on by members of the Events SIG. You are very welcome to join the work and the discussions!

These events are related to **Continuous Integration(CI)** activities. CI usually include activities such as building, testing, packaging and releasing software artifacts.

The following events represent concrete Tasks that are associated with the execution of CI pipelines:

- **Build Queued**: a Build task has been queued, this build process usually is in charge of producing a binary from source code
- **Build Started**: a Build task has started
- **Build Finished**: a Build task has finished, the event will contain the finished status, success, error or failure

The following Test events are defined in two separate categories **Test Case** and **Test Suite**. A **Test Case** is the smallest unit of testing that the user wants to track. A **Test Suite** is a collection of test case executions and/or other test suite executions. **Test Cases** executed, and Test Suites are for grouping purposes. For this reason, **Test Cases** can be queued.

- **Test Case Queued**: a Test task has been queued, and it is waiting to be started
- **Test Case Started**: a Test task has started
- **Test Case Finished**: a Test task has finished, the event will contain the finished status: success, error or failure
- **Test Suite Started**: a Test Suite has started
- **Test Suite Finished**: a Test Suite has finished, the event will contain the finished status: success, error or failure

Finally, events needs to be generated for the output of the pipeline such as the artifacts that were packaged and released for others to use.

- **Artifact Packaged**: an artifact has been packaged for distribution, this artifact is now versioned with a fixed version
- **Artifact Published**: an artifact has been published and it can be advertised for others to use

CI Events MUST include the following attributes:

- **Event Type**: the type is restricted to include `cd.**` prefix. For example `cd.build.queued` or `cd.artifact.packaged`

Optional attributes:

- **Artifact Id**: the unique identifier of the artifact that the event is referring to.
