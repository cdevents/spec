<!--
---
linkTitle: "Continuous Deployment Events"
weight: 60
description: >
   Continuous Deployment Events
---
-->
# Continuous Deployment Events

__Note:__ This is a work-in-progress draft version and is being worked on by members of the Events SIG. You are very welcome to join the work and the discussions!

Continuous Deployment (CD) events are related to continuos deployment pipelines and their target environments. These events can be emitted by environments to report where software artifacts such as services, binaries, daemons, jobs or embedded software are running.

## Subjects

This specification defines two subjects in this stage: `environment` and `service`. The term `service` is used to represent a running Artifact. A `service` can represent a binary that is running, a daemon, an application, a docker container. The term `environment` represent any platform which has all the means to run a `service`.

| Subject | Description | Predicates |
|---------|-------------|------------|
| [`environment`](#environment) | An environment where to run services | [`created`](#environment-created), [`modified`](#environment-modified), [`deleted`](#environment-deleted)|
| [`service`](#service) | A service | [`deployed`](#service-deployed), [`upgraded`](#service-upgraded), [`rolledback`](#service-rolledback), [`removed`](#service-removed), [`published`](#service-published)|

### `environment`

An `environment` is a platform which may run a `service`.

| Field | Type | Description | Examples |
|-------|------|-------------|----------|
| id    | `String` | Uniquely identifies the subject within the source. | `1234`, `maven123`, `builds/taskrun123` |
| source | `URI-Reference` | [source](../spec.md#source) from the context | `staging/tekton`, `tekton-dev-123`|
| name | `String` | Name of the environment | `dev`, `staging`, `production`, `ci-123`|
| url | `String` | URL to reference where the environment is located | `https://my-cluster.zone.my-cloud-provider`|

### `service`

A `service` can represent for example a binary that is running, a daemon, an application or a docker container.

| Field | Type | Description | Examples |
|-------|------|-------------|----------|
| id    | `String` | Uniquely identifies the subject within the source. | `service/myapp`, `daemonset/myapp` |
| source | `URI-Reference` | [source](../spec.md#source) from the context | `staging/tekton`, `tekton-dev-123`|
| environmentId | `String` | Id of the environment where the service runs | `dev`, `staging`, `production`, `ci-123`|

## Events

### `environment created`

This event represents an environment that has been created. Such an environment can be used to deploy services in.

- Event Type: __`dev.cdevents.environment.created`__
- Predicate: created
- Subject: [`environment`](#environment)

| Field | Type | Description | Examples | Mandatory ✅ \| Optional ⚪ |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | Uniquely identifies the subject within the source. | `tenant1/12345-abcde`, `namespace/pipelinerun-1234` | ✅ |
| source | `URI-Reference` | [source](../spec.md#source) from the context | | ⚪ |
| name | `String` | Name of the environment | `dev`, `staging`, `production`, `ci-123`| ⚪ |
| url | `String` | URL to reference where the environment is located | `https://my-cluster.zone.my-cloud-provider`| ⚪ |

### `environment modified`

This event represents an environment that has been modified.

- Event Type: __`dev.cdevents.environment.modified`__
- Predicate: modified
- Subject: [`environment`](#environment)

| Field | Type | Description | Examples | Mandatory ✅ \| Optional ⚪ |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | Uniquely identifies the subject within the source. | `tenant1/12345-abcde`, `namespace/pipelinerun-1234` | ✅ |
| source | `URI-Reference` | [source](../spec.md#source) from the context | | ⚪ |
| name | `String` | Name of the environment | `dev`, `staging`, `production`, `ci-123`| ⚪ |
| url | `String` | URL to reference where the environment is located | `https://my-cluster.zone.my-cloud-provider`| ⚪ |

### `environment deleted`

This event represents an environment that has been deleted.```

- Event Type: __`dev.cdevents.environment.deleted`__
- Predicate: deleted
- Subject: [`environment`](#environment)

| Field | Type | Description | Examples | Mandatory ✅ \| Optional ⚪ |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | Uniquely identifies the subject within the source. | `tenant1/12345-abcde`, `namespace/pipelinerun-1234` | ✅ |
| source | `URI-Reference` | [source](../spec.md#source) from the context | | ⚪ |
| name | `String` | Name of the environment | `dev`, `staging`, `production`, `ci-123`| ⚪ |

### `service deployed`

This event represents a new instance of a service that has been deployed

- Event Type: __`dev.cdevents.service.deployed`__
- Predicate: deployed
- Subject: [`service`](#service)

| Field | Type | Description | Examples | Mandatory ✅ \| Optional ⚪ |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | Uniquely identifies the subject within the source. | `service/myapp`, `daemonset/myapp` | ✅ |
| environmentId | `String` | Id of the environment where the service is deployed| `dev`, `staging`, `production`, `ci-123`| ✅ |

### `service upgraded`

This event represents an existing instance of a service that has been upgraded to a new version

- Event Type: __`dev.cdevents.service.upgraded`__
- Predicate: upgraded
- Subject: [`service`](#service)

| Field | Type | Description | Examples | Mandatory ✅ \| Optional ⚪ |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | Uniquely identifies the subject within the source. | `service/myapp`, `daemonset/myapp` | ✅ |
| environmentId | `String` | Id of the environment where the service runs | `dev`, `staging`, `production`, `ci-123`| ✅ |

### `service rolledback`

This event represents an existing instance of a service that has been rolled back to a previous version

- Event Type: __`dev.cdevents.service.rolledback`__
- Predicate: rolledback
- Subject: [`service`](#service)

| Field | Type | Description | Examples | Mandatory ✅ \| Optional ⚪ |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | Uniquely identifies the subject within the source. | `service/myapp`, `daemonset/myapp` | ✅ |
| environmentId | `String` | Id of the environment where the service runs | `dev`, `staging`, `production`, `ci-123`| ✅ |

### `service removed`

This event represents the removal of a previously deployed service instance and is thus not longer present in the specified environment

- Event Type: __`dev.cdevents.service.removed`__
- Predicate: removed
- Subject: [`service`](#service)

| Field | Type | Description | Examples | Mandatory ✅ \| Optional ⚪ |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | Uniquely identifies the subject within the source. | `service/myapp`, `daemonset/myapp` | ✅ |
| environmentId | `String` | Id of the environment where the service runs | `dev`, `staging`, `production`, `ci-123`| ✅ |

### `service published`

This event represents an existing of a service that has an accessible URL for users to interact with it. This event can be used to let other tools know that the service is ready and also available for consumption.

- Event Type: __`dev.cdevents.service.published`__
- Predicate: published
- Subject: [`service`](#service)

| Field | Type | Description | Examples | Mandatory ✅ \| Optional ⚪ |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | Uniquely identifies the subject within the source. | `service/myapp`, `daemonset/myapp` | ✅ |
| environmentId | `String` | Id of the environment where the service runs | `dev`, `staging`, `production`, `ci-123`| ✅ |
