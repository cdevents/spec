<!--
---
linkTitle: "Continuous Deployment Events"
weight: 60
hide_summary: true
icon: "fa-solid fa-satellite-dish"
description: >
   Continuous Deployment Events
---
-->
# Continuous Deployment Events

Continuous Deployment (CD) events are related to continuous deployment pipelines and their target environments. These events can be emitted by environments to report where software artifacts such as services, binaries, daemons, jobs or embedded software are running.

## Subjects

This specification defines four subjects in this stage: `environment`, `service`, `deployment`, and `targetRollout`. The term `service` is used to represent a running Artifact. A `service` can represent a binary that is running, a daemon, an application, a docker container. The term `environment` represent any platform which has all the means to run a `service`. A `deployment` is the aggregate act of applying a version of a release unit to one or more `targetRollout`s, and a `targetRollout` is a specific destination within an environment to which a release unit is deployed.

| Subject | Description | Predicates |
|---------|-------------|------------|
| [`environment`](#environment) | An environment where to run services | [`created`](#environment-created), [`modified`](#environment-modified), [`deleted`](#environment-deleted)|
| [`service`](#service) | A service | [`deployed`](#service-deployed), [`upgraded`](#service-upgraded), [`rolledback`](#service-rolledback), [`removed`](#service-removed), [`published`](#service-published)|
| [`deployment`](#deployment) | The aggregate act of deploying a release unit to one or more target rollouts | [`queued`](#deployment-queued), [`started`](#deployment-started), [`finished`](#deployment-finished)|
| [`targetRollout`](#targetrollout) | A specific deployment destination within an environment | [`queued`](#targetrollout-queued), [`started`](#targetrollout-started), [`finished`](#targetrollout-finished)|

### `environment`

An `environment` is a platform which may run a `service`.

| Field | Type | Description | Examples |
|-------|------|-------------|----------|
| id    | `String` | See [id](spec.md#id-subject)| `1234`, `maven123`, `builds/taskrun123` |
| source | `URI-Reference` | See [source](spec.md#source-subject) | `staging/tekton`, `tekton-dev-123`|
| name | `String` | Name of the environment | `dev`, `staging`, `production`, `ci-123`|
| url | `String` | URL to reference where the environment is located | `https://my-cluster.zone.my-cloud-provider`|

### `service`

A `service` can represent for example a binary that is running, a daemon, an application or a docker container.

| Field | Type | Description | Examples |
|-------|------|-------------|----------|
| id    | `String` | See [id](spec.md#id-subject)| `service/myapp`, `daemonset/myapp` |
| source | `URI-Reference` | See [source](spec.md#source-subject) | `staging/tekton`, `tekton-dev-123`|
| environment | `Object` ([`environment`](#environment)) | Reference for the environment where the service runs | `{"id": "1234"}`, `{"id": "maven123, "source": "tekton-dev-123"}` |
| artifactId | `Purl` | Identifier of the artifact deployed with this service |  `pkg:oci/myapp@sha256%3A0b31b1c02ff458ad9b7b81cbdf8f028bd54699fa151f221d1e8de6817db93427`, `pkg:golang/mygit.com/myorg/myapp@234fd47e07d1004f0aed9c` |

### `deployment`

A `deployment` is the act of applying a version of a release unit to one or more target rollouts. A deployment is a canonical SDLC fact: it represents the change to the running system that resulted from a release, as distinct in meaning from the orchestration that performed it (see [`pipelineRun`](core.md#pipelinerun)). Where a producer's pipeline execution is itself the natural deployment boundary, its `id` MAY be reused as the `deployment` subject's `id`. A deployment fans out to one or more [`targetRollout`](#targetrollout)s.

| Field | Type | Description | Examples |
|-------|------|-------------|----------|
| id    | `String` | See [id](spec.md#id-subject)| `dep-8f3a2c` |
| source | `URI-Reference` | See [source](spec.md#source-subject) | `/cd/deploy-controller` |
| artifactId | `Purl` | Identifier of the artifact being deployed | `pkg:oci/myapp@sha256%3A0b31b1c02ff458ad9b7b81cbdf8f028bd54699fa151f221d1e8de6817db93427` |
| environment | `Object` ([`environment`](#environment)) | Reference to the target environment | `{"id": "production"}` |

### `targetRollout`

A `targetRollout` is a specific destination within an environment to which a release unit may be deployed and made available, for example a Kubernetes namespace in a particular region, or a named blue/green slot. A `targetRollout` is always contained within an environment, and multiple target rollouts may exist within a single environment. Each `targetRollout` carries a `deploymentId` reference back to its parent [`deployment`](#deployment). This also gives [`environment`](#environment) a first-class inbound link to what has been deployed into it: `environment created`/`modified`/`deleted` describe the platform alone, and previously the only way to associate an environment with what is running in it was to inspect `service` events, where the reference points the other way, from the entity back down to the environment it happens to run in. `targetRollout` events point from the act of deploying to the destination, so "what was rolled out to this environment" is a direct query rather than an inference over `service` events.

| Field | Type | Description | Examples |
|-------|------|-------------|----------|
| id    | `String` | See [id](spec.md#id-subject)| `rt-us-east-1-8f3a2c` |
| source | `URI-Reference` | See [source](spec.md#source-subject) | `/cd/deploy-controller` |
| name | `String` | Name of the target rollout | `canary`, `us-east-1`, `blue-slot` |
| target | `URI-Reference` | Location identifier of where the artifact is being deployed to | `cdevents:v0:argo::my-org:prod-cluster:environment:us-east-1` |
| environment | `Object` ([`environment`](#environment)) | Reference to the containing environment | `{"id": "production"}` |
| artifactId | `Purl` | Identifier of the artifact being deployed to this target | `pkg:oci/myapp@sha256%3A0b31b1c02ff458ad9b7b81cbdf8f028bd54699fa151f221d1e8de6817db93427` |
| deploymentId | `String` | Reference to the parent [`deployment`](#deployment) | `dep-8f3a2c` |

## Events

### [`environment created`](conformance/environment_created.json)

This event represents an environment that has been created. Such an environment can be used to deploy services in.

- Event Type: __`dev.cdevents.environment.created.0.3.0`__
- Predicate: created
- Subject: [`environment`](#environment)

| Field | Type | Description | Examples | Required |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | See [id](spec.md#id-subject)| `tenant1/12345-abcde`, `namespace/pipelinerun-1234` | ✅ |
| source | `URI-Reference` | See [source](spec.md#source-subject) | | |
| name | `String` | Name of the environment | `dev`, `staging`, `production`, `ci-123`| |
| url | `String` | URL to reference where the environment is located | `https://my-cluster.zone.my-cloud-provider`| |

### [`environment modified`](conformance/environment_modified.json)

This event represents an environment that has been modified.

- Event Type: __`dev.cdevents.environment.modified.0.3.0`__
- Predicate: modified
- Subject: [`environment`](#environment)

| Field | Type | Description | Examples | Required |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | See [id](spec.md#id-subject)| `tenant1/12345-abcde`, `namespace/pipelinerun-1234` | ✅ |
| source | `URI-Reference` | See [source](spec.md#source-subject) | | |
| name | `String` | Name of the environment | `dev`, `staging`, `production`, `ci-123`| |
| url | `String` | URL to reference where the environment is located | `https://my-cluster.zone.my-cloud-provider`| |

### [`environment deleted`](conformance/environment_deleted.json)

This event represents an environment that has been deleted.```

- Event Type: __`dev.cdevents.environment.deleted.0.3.0`__
- Predicate: deleted
- Subject: [`environment`](#environment)

| Field | Type | Description | Examples | Required |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | See [id](spec.md#id-subject)| `tenant1/12345-abcde`, `namespace/pipelinerun-1234` | ✅ |
| source | `URI-Reference` | See [source](spec.md#source-subject) | | |
| name | `String` | Name of the environment | `dev`, `staging`, `production`, `ci-123`| |

### [`service deployed`](conformance/service_deployed.json)

This event represents a new instance of a service that has been deployed

- Event Type: __`dev.cdevents.service.deployed.0.3.0`__
- Predicate: deployed
- Subject: [`service`](#service)

| Field | Type | Description | Examples | Required |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | See [id](spec.md#id-subject)| `service/myapp`, `daemonset/myapp` | ✅ |
| source | `URI-Reference` | See [source](spec.md#source-subject) | | |
| environment | `Object` ([`environment`](#environment)) | Reference for the environment where the service runs | `{"id": "1234"}`, `{"id": "maven123, "source": "tekton-dev-123"}` | ✅ |
| artifactId | `Purl` | Identifier of the artifact deployed with this service |  `0b31b1c02ff458ad9b7b81cbdf8f028bd54699fa151f221d1e8de6817db93427`, `927aa808433d17e315a258b98e2f1a55f8258e0cb782ccb76280646d0dbe17b5`, `six-1.14.0-py2.py3-none-any.whl` | ✅ |

### [`service upgraded`](conformance/service_upgraded.json)

This event represents an existing instance of a service that has been upgraded to a new version

- Event Type: __`dev.cdevents.service.upgraded.0.3.0`__
- Predicate: upgraded
- Subject: [`service`](#service)

| Field | Type | Description | Examples | Required |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | See [id](spec.md#id-subject)| `service/myapp`, `daemonset/myapp` | ✅ |
| source | `URI-Reference` | See [source](spec.md#source-subject) | | |
| environment | `Object` ([`environment`](#environment)) | Reference for the environment where the service runs | `{"id": "1234"}`, `{"id": "maven123, "source": "tekton-dev-123"}` | ✅ |
| artifactId | `Purl` | Identifier of the artifact deployed with this service |`pkg:oci/myapp@sha256%3A0b31b1c02ff458ad9b7b81cbdf8f028bd54699fa151f221d1e8de6817db93427`, `pkg:golang/mygit.com/myorg/myapp@234fd47e07d1004f0aed9c` | ✅ |

### [`service rolledback`](conformance/service_rolledback.json)

This event represents an existing instance of a service that has been rolled back to a previous version

- Event Type: __`dev.cdevents.service.rolledback.0.3.0`__
- Predicate: rolledback
- Subject: [`service`](#service)

| Field | Type | Description | Examples | Required |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | See [id](spec.md#id-subject)| `service/myapp`, `daemonset/myapp` | ✅ |
| source | `URI-Reference` | See [source](spec.md#source-subject) | | |
| environment | `Object` ([`environment`](#environment)) | Reference for the environment where the service runs | `{"id": "1234"}`, `{"id": "maven123, "source": "tekton-dev-123"}` | ✅ |
| artifactId | `Purl` | Identifier of the artifact deployed with this service |  `pkg:oci/myapp@sha256%3A0b31b1c02ff458ad9b7b81cbdf8f028bd54699fa151f221d1e8de6817db93427`, `pkg:golang/mygit.com/myorg/myapp@234fd47e07d1004f0aed9c` | ✅ |

### [`service removed`](conformance/service_removed.json)

This event represents the removal of a previously deployed service instance and is thus not longer present in the specified environment

- Event Type: __`dev.cdevents.service.removed.0.3.0`__
- Predicate: removed
- Subject: [`service`](#service)

| Field | Type | Description | Examples | Required |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | See [id](spec.md#id-subject)| `service/myapp`, `daemonset/myapp` | ✅ |
| source | `URI-Reference` | See [source](spec.md#source-subject) | | |
| environment | `Object` ([`environment`](#environment)) | Reference for the environment where the service runs | `{"id": "1234"}`, `{"id": "maven123, "source": "tekton-dev-123"}` | ✅ |

### [`deployment queued`](conformance/deployment_queued.json)

This event represents a deployment that has been accepted and is waiting to begin.

- Event Type: __`dev.cdevents.deployment.queued.0.1.0`__
- Predicate: queued
- Subject: [`deployment`](#deployment)

| Field | Type | Description | Examples | Required |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | See [id](spec.md#id-subject)| `dep-8f3a2c` | ✅ |
| source | `URI-Reference` | See [source](spec.md#source-subject) | | |
| artifactId | `Purl` | Identifier of the artifact being deployed | `pkg:oci/myapp@sha256%3A0b31b1c02ff458ad9b7b81cbdf8f028bd54699fa151f221d1e8de6817db93427` | ✅ |
| environment | `Object` ([`environment`](#environment)) | Reference to the target environment | `{"id": "production"}` | ✅ |

### [`deployment started`](conformance/deployment_started.json)

This event represents a deployment controller that has begun orchestrating a rollout.

- Event Type: __`dev.cdevents.deployment.started.0.1.0`__
- Predicate: started
- Subject: [`deployment`](#deployment)

| Field | Type | Description | Examples | Required |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | See [id](spec.md#id-subject)| `dep-8f3a2c` | ✅ |
| source | `URI-Reference` | See [source](spec.md#source-subject) | | |
| artifactId | `Purl` | Identifier of the artifact being deployed | `pkg:oci/myapp@sha256%3A0b31b1c02ff458ad9b7b81cbdf8f028bd54699fa151f221d1e8de6817db93427` | ✅ |
| environment | `Object` ([`environment`](#environment)) | Reference to the target environment | `{"id": "production"}` | ✅ |

### [`deployment finished`](conformance/deployment_finished.json)

This event represents a deployment that has completed across all of its target rollouts. `deployment.finished` is the orchestration-side completion fact for a deployment, analogous to `build finished` on the CI side, and is kept separate from the entity-side fact carried by `service.deployed`. Failure semantics are all-or-nothing: if any target rollout fails, `deployment.finished` has `outcome: failure`. Consumers needing per-destination detail should inspect the individual [`targetRollout finished`](#targetrollout-finished) events.

- Event Type: __`dev.cdevents.deployment.finished.0.1.0`__
- Predicate: finished
- Subject: [`deployment`](#deployment)

| Field | Type | Description | Examples | Required |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | See [id](spec.md#id-subject)| `dep-8f3a2c` | ✅ |
| source | `URI-Reference` | See [source](spec.md#source-subject) | | |
| artifactId | `Purl` | Identifier of the artifact being deployed | `pkg:oci/myapp@sha256%3A0b31b1c02ff458ad9b7b81cbdf8f028bd54699fa151f221d1e8de6817db93427` | ✅ |
| environment | `Object` ([`environment`](#environment)) | Reference to the target environment | `{"id": "production"}` | ✅ |
| outcome | `String (enum)` | Outcome of the finished deployment | `success`, `failure`, `cancel`, `error` | ✅ |

### [`targetRollout queued`](conformance/targetrollout_queued.json)

This event represents a deployment to a specific target rollout that has been scheduled.

- Event Type: __`dev.cdevents.targetrollout.queued.0.1.0`__
- Predicate: queued
- Subject: [`targetRollout`](#targetrollout)

| Field | Type | Description | Examples | Required |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | See [id](spec.md#id-subject)| `rt-us-east-1-8f3a2c` | ✅ |
| source | `URI-Reference` | See [source](spec.md#source-subject) | | |
| name | `String` | Name of the target rollout | `canary`, `us-east-1`, `blue-slot` | ✅ |
| target | `URI-Reference` | Location identifier of where the artifact is being deployed to | `cdevents:v0:argo::my-org:prod-cluster:environment:us-east-1` | ✅ |
| environment | `Object` ([`environment`](#environment)) | Reference to the containing environment | `{"id": "production"}` | ✅ |
| artifactId | `Purl` | Identifier of the artifact being deployed to this target | `pkg:oci/myapp@sha256%3A0b31b1c02ff458ad9b7b81cbdf8f028bd54699fa151f221d1e8de6817db93427` | ✅ |
| deploymentId | `String` | Reference to the parent [`deployment`](#deployment) | `dep-8f3a2c` | |

### [`targetRollout started`](conformance/targetrollout_started.json)

This event represents a deployment to a specific target rollout that has begun.

- Event Type: __`dev.cdevents.targetrollout.started.0.1.0`__
- Predicate: started
- Subject: [`targetRollout`](#targetrollout)

| Field | Type | Description | Examples | Required |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | See [id](spec.md#id-subject)| `rt-us-east-1-8f3a2c` | ✅ |
| source | `URI-Reference` | See [source](spec.md#source-subject) | | |
| name | `String` | Name of the target rollout | `canary`, `us-east-1`, `blue-slot` | ✅ |
| target | `URI-Reference` | Location identifier of where the artifact is being deployed to | `cdevents:v0:argo::my-org:prod-cluster:environment:us-east-1` | ✅ |
| environment | `Object` ([`environment`](#environment)) | Reference to the containing environment | `{"id": "production"}` | ✅ |
| artifactId | `Purl` | Identifier of the artifact being deployed to this target | `pkg:oci/myapp@sha256%3A0b31b1c02ff458ad9b7b81cbdf8f028bd54699fa151f221d1e8de6817db93427` | ✅ |
| deploymentId | `String` | Reference to the parent [`deployment`](#deployment) | `dep-8f3a2c` | |

### [`targetRollout finished`](conformance/targetrollout_finished.json)

This event represents a deployment to a specific target rollout that has completed. `failureType` categorizes the failure reason when `outcome` is `failure`, letting consumers distinguish a policy gate, build, evaluation, deployment, or analysis failure without producer-specific convention.

- Event Type: __`dev.cdevents.targetrollout.finished.0.1.0`__
- Predicate: finished
- Subject: [`targetRollout`](#targetrollout)

| Field | Type | Description | Examples | Required |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | See [id](spec.md#id-subject)| `rt-us-east-1-8f3a2c` | ✅ |
| source | `URI-Reference` | See [source](spec.md#source-subject) | | |
| name | `String` | Name of the target rollout | `canary`, `us-east-1`, `blue-slot` | ✅ |
| target | `URI-Reference` | Location identifier of where the artifact is being deployed to | `cdevents:v0:argo::my-org:prod-cluster:environment:us-east-1` | ✅ |
| environment | `Object` ([`environment`](#environment)) | Reference to the containing environment | `{"id": "production"}` | ✅ |
| artifactId | `Purl` | Identifier of the artifact being deployed to this target | `pkg:oci/myapp@sha256%3A0b31b1c02ff458ad9b7b81cbdf8f028bd54699fa151f221d1e8de6817db93427` | ✅ |
| deploymentId | `String` | Reference to the parent [`deployment`](#deployment) | `dep-8f3a2c` | |
| outcome | `String (enum)` | Outcome of the finished target rollout | `success`, `failure`, `cancel`, `error` | ✅ |
| failureType | `String (enum)` | Category of failure, only present when `outcome` is `failure` | `gate`, `build`, `evaluation`, `deployment`, `analysis` | |

### [`service published`](conformance/service_published.json)

This event represents an existing instance of a service that has an accessible URL for users to interact with it. This event can be used to let other tools know that the service is ready and also available for consumption.

- Event Type: __`dev.cdevents.service.published.0.3.0`__
- Predicate: published
- Subject: [`service`](#service)

| Field | Type | Description | Examples | Required |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | See [id](spec.md#id-subject)| `service/myapp`, `daemonset/myapp` | ✅ |
| source | `URI-Reference` | See [source](spec.md#source-subject) | | |
| environment | `Object` ([`environment`](#environment)) | Reference for the environment where the service runs | `{"id": "1234"}`, `{"id": "maven123, "source": "tekton-dev-123"}` | ✅ |
