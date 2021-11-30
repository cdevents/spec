# Continuous Delivery Core Events

__Note:__ This is a work-in-progress draft version and is being worked on by members of the Events SIG. You are very welcome to join the work and the discussions!

Continuous Delivery related to activities and orchestration that needs to exist to be able to deterministically and continuously being able to delivery software to users.

A pipeline, in the context of Continuous Delivery, is the definition of a set of tasks that needs to be performed to build, test, package, release and deploy software artifacts.
A pipeline can be instantiated multiple times, for example to build different versions of the same artifact.
We are referring to this instance as PipelineRun. It will have a unique Id and it will help us to track the build and release progress on a particular software artifact.

Due the dynamic nature of Pipelines, most of actual work needs to be queued to happen in a distributed way, hence Queued events are added. Adopters can choose to ignore these events if they don't apply to their use cases.

- **PipelineRun Queued**: a PipelineRun has been schedule to run
- **PipelineRun Started**: a PipelineRun has started and it is running
- **PipelineRun Finished**: a PipelineRun has finished it execution, the event will contain the finished status, success, error or failure

Each pipeline is defined as a set of Tasks to be performed in sequence, hence tracking this sequence might be important for some cases. A TaskRun is an instance of the Task defined inside the pipeline, as you can expect multiple execution of the pipelines (each a PipelineRun) you can also expect multiple execution of the Tasks, for that reason we use TaskRun to refer to one of these instances.

- **TaskRun Started**: a TaskRun inside a PipelineRun has started.
- **TaskRun Finished**: a TaskRun inside a PipelineRun has finished.

Pipeline Events MUST include the following attributes:

- **Event Type**: the type is restricted to include `cd.**` prefix. For example `cd.pipelinerun.queued` or `cd.tests.started`
- **PipelineRun Id**: unique identifier for a pipeline execution
- **Pipeline Name**: unique identifier for the pipeline, not for the instance. A pipeline can have multiple instances/runs.
- **PipelineRun Status**: current status of the PipelineRun at the time when the event was emitted. If the pipeline is finished, this attribute should reflect if it finished successfully or if there was an error on the execution. Possible statuses: [Running, Finished, Error]

Optional attributes:

- **PipelineRun URL**: URL to locate where  pipeline instances are running
- **PipelineRun Errors**: error field to indicate possible compilation, test, build and package errors.
