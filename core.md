# Continuous Delivery Core Events

__Note:__ This is a work-in-progress draft version and is being worked on by members of the Events SIG. You are very welcome to join the work and the discussions!

Continuous Delivery related to activities and orchestration that needs to exist to be able to deterministically and continuously being able to delivery software to users.

A pipeline, in the context of Continuous Delivery, is the definition of a set of tasks that needs to be performed to build, test, package, release and deploy software artifacts.
A pipeline can be instantiated multiple times, for example to build different versions of the same artifact.
We are referring to this instance as PipelineRun. It will have a unique Id and it will help us to track the build and release progress on a particular software artifact.

Due the dynamic nature of Pipelines, most of actual work needs to be queued to happen in a distributed way, hence Queued events are added. Adopters can choose to ignore these events if they don't apply to their use cases.

- **PipelineRun Queued**: a PipelineRun has been schedule to run

  Example:
  ```json
  {
    "data": {
      "otherdata": "data",
      "pipelinerunerrors": "Hopfully no errors",
      "pipelinerunid": "pipe1",
      "pipelinerunname": "My Pipeline",
      "pipelinerunstatus": "Queued",
      "pipelinerunurl": "http://my-pipelinerunner",
    },
    "datacontenttype": "application/json",
    "id": "bfab7170-9bf9-4487-9f4d-c7bdf5552183",
    "source": "cde-cli",
    "specversion": "1.0",
    "time": "2021-07-16T14:30:32.9551306Z",
    "type": "cd.pipelinerun.queued.v1"
  }
  ```

- **PipelineRun Started**: a PipelineRun has started and it is running

  Example:
  ```json
  {
    "data": {
      "otherdata": "data",
      "pipelinerunerrors": "Hopfully no errors",
      "pipelinerunid": "pipe1",
      "pipelinerunname": "My Pipeline",
      "pipelinerunstatus": "Starting",
      "pipelinerunurl": "http://my-pipelinerunner",
    },
    "datacontenttype": "application/json",
    "id": "8ba216bb-b443-4019-956e-f9b4d1700847",
    "source": "cde-cli",
    "specversion": "1.0",
    "time": "2021-07-16T14:30:33.1000937Z",
    "type": "cd.pipelinerun.started.v1"
  }
  ```

- **PipelineRun Finished**: a PipelineRun has finished it execution, the event will contain the finished status, success, error or failure

  Example:
  ```json
  {
    "data": {
      "otherdata": "data",
      "pipelinerunerrors": "Hopfully no errors",
      "pipelinerunid": "pipe1",
      "pipelinerunname": "My Pipeline",
      "pipelinerunstatus": "Finished",
      "pipelinerunurl": "http://my-pipelinerunner",
    },
    "datacontenttype": "application/json",
    "id": "627ce912-e5e6-4c92-9351-a76dabdd0c9b",
    "source": "cde-cli",
    "specversion": "1.0",
    "time": "2021-07-16T14:30:33.2450299Z",
    "type": "cd.pipelinerun.finished.v1"
  }
  ```

Each pipeline is defined as a set of Tasks to be performed in sequence, hence tracking this sequence might be important for some cases. A TaskRun is an instance of the Task defined inside the pipeline, as you can expect multiple execution of the pipelines (each a PipelineRun) you can also expect multiple execution of the Tasks, for that reason we use TaskRun to refer to one of these instances.

- **TaskRun Started**: a TaskRun inside a PipelineRun has started.

  Example:
  ```json
  {
    "data": {
      "othertaskdata": "data",
      "taskrunid": "task1",
      "taskrunname": "My Task Run",
      "taskrunpipelineid": "pipe1",
    },
    "datacontenttype": "application/json",
    "id": "c311908e-854b-4213-bb2b-c268b94d6deb",
    "source": "cde-cli",
    "specversion": "1.0",
    "time": "2021-07-20T13:26:30.9900211Z",
    "type": "cd.taskrun.started.v1"
  }
  ```

- **TaskRun Finished**: a TaskRun inside a PipelineRun has finished.

  Example:
  ```json
  {
    "data": {
      "othertaskdata": "data",
      "taskrunid": "task1",
      "taskrunname": "My Task Run",
      "taskrunpipelineid": "pipe1",
    },
    "datacontenttype": "application/json",
    "id": "fef0d377-573d-4e51-8135-0c9922c49303",
    "source": "cde-cli",
    "specversion": "1.0",
    "time": "2021-07-20T13:29:40.3994827Z",
    "type": "cd.taskrun.finished.v1"
  }
  ```

Pipeline Events MUST include the following attributes:

- **Event Type**: the type is restricted to include `cd.**` prefix. For example `cd.pipelinerun.queued` or `cd.tests.started`
- **PipelineRun Id**: unique identifier for a pipeline execution
- **Pipeline Name**: unique identifier for the pipeline, not for the instance. A pipeline can have multiple instances/runs.
- **PipelineRun Status**: current status of the PipelineRun at the time when the event was emitted. If the pipeline is finished, this attribute should reflect if it finished successfully or if there was an error on the execution. Possible statuses: [Running, Finished, Error]

Optional attributes:

- **PipelineRun URL**: URL to locate where  pipeline instances are running
- **PipelineRun Errors**: error field to indicate possible compilation, test, build and package errors.
