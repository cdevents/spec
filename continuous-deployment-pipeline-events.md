# Continuous Deployment Pipelines Events

__Note:__ This is a work-in-progress draft version and is being worked on by members of the Events SIG. You are very welcome to join the work and the discussions!

These events are related to continuos deployment pipelines and their target environments.
These events can be emitted by environments to report where software artifacts such as services, binaries, daemons, jobs or embedded software are running.

The term Service is used to represent a running Artifact. This service can represent a binary that is running, a daemon, an application, a docker container, etc.
The term Environment represent any platform which has all the means to run a Service.

- **Environment Created**: an environment has been created and it can be used to deploy Services
- **Environment Modified**: an environment has been modified, this event advertise the changes made in the environment
- **Environment Deleted**: an environment has been deleted and cannot longer be used
- **Service Deployed**: a new instance of the Service has been deployed
- **Service Upgraded**: an existing instance of a Service has been upgraded to a new version
- **Service Rolledback**: an existing instance of a Service has been rolledback to a previous version
- **Service Removed**: an existing instance of a Service has been terminated an it is not longer present in an environment

Continuous Deployment Events MUST include the following attributes:

- **Event Type**: the type is restricted to include `cd.**` prefix. For example `cd.service.upgraded` or `cd.environment.created`
- **Environment ID**: unique identifier for the Environment

Optional attributes:

- **Environment Name**: user-friendly name for the environment, to be displayed in tools or User Interfaces
- **Environment URL**: URL to reference where the environment is located
