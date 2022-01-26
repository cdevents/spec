# Continuous Deployment Pipelines Events

__Note:__ This is a work-in-progress draft version and is being worked on by members of the Events SIG. You are very welcome to join the work and the discussions!

These events are related to continuos deployment pipelines and their target environments.
These events can be emitted by environments to report where software artifacts such as services, binaries, daemons, jobs or embedded software are running.

The term Service is used to represent a running Artifact. This service can represent a binary that is running, a daemon, an application, a docker container, etc.
The term Environment represent any platform which has all the means to run a Service.

- **Environment Created**: an environment has been created and it can be used to deploy Services

  Example:
  ```json
  {
    "data": {
      "otherdata": "data",
      "envid": "staging",
      "envname": "Staging Environment",
      "envrepourl": "http://github.com/user/myrepo",
    },
    "datacontenttype": "application/json",
    "id": "3ffbc865-3a42-438b-9465-0a5e247668af",
    "source": "cde-cli",
    "specversion": "1.0",
    "time": "2021-07-16T13:53:54.4534775Z",
    "type": "cd.environment.created.v1"
  }
  ```

- **Environment Modified**: an environment has been modified, this event advertise the changes made in the environment

  Example:
  ```json
  {
    "data": {
      "otherdata": "data",
      "envid": "staging",
      "envname": "Staging Environment",
      "envrepourl": "http://github.com/user/myrepo",
    },
    "datacontenttype": "application/json",
    "id": "0c67635a-d040-4d22-9f34-f80e499b9271",
    "source": "cde-cli",
    "specversion": "1.0",
    "time": "2021-07-16T13:54:55.5826174Z",
    "type": "cd.environment.modified.v1"
  }
  ```

- **Environment Deleted**: an environment has been deleted and cannot longer be used

  Example:
  ```json
  {
    "data": {
      "otherdata": "data",
      "envid": "staging",
      "envname": "Staging Environment",
      "envrepourl": "http://github.com/user/myrepo",
    },
    "datacontenttype": "application/json",
    "id": "80e538b3-111f-49ce-8ed8-7cff7ddd4d5b",
    "source": "cde-cli",
    "specversion": "1.0",
    "time": "2021-07-16T13:55:50.255399Z",
    "type": "cd.environment.deleted.v1"
  }
  ```

- **Service Deployed**: a new instance of the Service has been deployed

  Example:
  ```json
  {
    "data": {
      "otherservicedata": "data",
      "serviceenvid": "staging",
      "servicename": "my-service",
      "serviceversion": "1.0.2",
    },
    "datacontenttype": "application/json",
    "id": "4d609f1b-12d6-4102-865c-9d7b46417c84",
    "source": "cde-cli",
    "specversion": "1.0",
    "time": "2021-07-16T14:04:40.7275405Z",
    "type": "cd.service.deployed.v1"
  }
  ```

- **Service Upgraded**: an existing instance of a Service has been upgraded to a new version

  Example:
  ```json
  {
    "data": {
      "otherservicedata": "data",
      "serviceenvid": "staging",
      "servicename": "my-service",
      "serviceversion": "1.0.3",
    },
    "datacontenttype": "application/json",
    "id": "51b732b4-493a-4d05-ac8d-ac45c0d90118",
    "source": "cde-cli",
    "specversion": "1.0",
    "time": "2021-07-16T14:04:40.8701485Z",
    "type": "cd.service.upgraded.v1"
  }
  ```

- **Service Rolledback**: an existing instance of a Service has been rolledback to a previous version

  Example:
  ```json
  {
    "data": {
      "otherservicedata": "data",
      "serviceenvid": "staging",
      "servicename": "my-service",
      "serviceversion": "1.0.2",
    },
    "datacontenttype": "application/json",
    "id": "9c0616e2-2df8-4bda-965f-76221fea98b3",
    "source": "cde-cli",
    "specversion": "1.0",
    "time": "2021-07-16T14:24:37.9106108Z",
    "type": "cd.service.rolledback.v1"
  }
  ```

- **Service Removed**: an existing instance of a Service has been terminated an it is not longer present in an environment

  Example:
  ```json
  {
    "data": {
      "otherservicedata": "data",
      "serviceenvid": "staging",
      "servicename": "my-service",
      "serviceversion": "1.0.2",
    },
    "datacontenttype": "application/json",
    "id": "a05d436b-be93-4cbc-955a-ae2d8feb7060",
    "source": "cde-cli",
    "specversion": "1.0",
    "time": "2021-07-16T14:24:38.0761735Z",
    "type": "cd.service.removed.v1"
  }
  ```

Continuous Deployment Events MUST include the following attributes:

- **Event Type**: the type is restricted to include `cd.**` prefix. For example `cd.service.upgraded` or `cd.environment.created`
- **Environment ID**: unique identifier for the Environment

Optional attributes:

- **Environment Name**: user-friendly name for the environment, to be displayed in tools or User Interfaces
- **Environment URL**: URL to reference where the environment is located
