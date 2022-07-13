<!--
---
linkTitle: "Continuous Deployment Events"
weight: 50
description: >
   Continuous Deployment Events
---
-->
# Continuous Deployment Events

__Note:__ This is a work-in-progress draft version and is being worked on by members of the Events SIG. You are very welcome to join the work and the discussions!

These events are related to continuos deployment pipelines and their target environments.
These events can be emitted by environments to report where software artifacts such as services, binaries, daemons, jobs or embedded software are running.

The term Service is used to represent a running Artifact. This service can represent a binary that is running, a daemon, an application, a docker container, etc.
The term Environment represent any platform which has all the means to run a Service.

- __Environment Created__: an environment has been created and it can be used to deploy Services
- __Environment Modified__: an environment has been modified, this event advertise the changes made in the environment
- __Environment Deleted__: an environment has been deleted and cannot longer be used
- __Service Deployed__: a new instance of the Service has been created but isn't yet exposed/ready for consumption. eg. the external IP from LB is not yet assigned
- __Service Upgraded__: an existing instance of a Service has been upgraded to a new version
- __Service Rolledback__: an existing instance of a Service has been rolledback to a previous version
- __Service Removed__: an existing instance of a Service has been terminated an it is no longer present in an environment
- __Service Published__: an existing instance of a Service has an accessible URL for users to interact with it. This event can be used to let other tools know that the service is ready and also available for consumption. 

Continuous Deployment Events MUST include the following attributes:

- __Event Type__: the type is restricted to include `dev.cdevents.__` prefix. For example `dev.cdevents.service.upgraded` or `dev.cdevents.environment.created`
- __Environment ID__: unique identifier for the Environment

Optional attributes:

- __Environment Name__: user-friendly name for the environment, to be displayed in tools or User Interfaces
- __Environment URL__: URL to reference where the environment is located
