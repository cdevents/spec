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

This specification defines two subjects in this stage: `environment` and `service`. The term `service` is used to represent a running Artifact. A `service` can represent a binary that is running, a daemon, an application, a docker container. The term `environment` represent any platform which has all the means to run a `service`.

Changes to a target are often governed by when they are permitted to happen. A [`changeWindow`](#changewindow) is a bounded interval during which a window policy governs changes to a target.

| Subject | Description | Predicates |
|---------|-------------|------------|
| [`environment`](#environment) | An environment where to run services | [`created`](#environment-created), [`modified`](#environment-modified), [`deleted`](#environment-deleted)|
| [`service`](#service) | A service | [`deployed`](#service-deployed), [`upgraded`](#service-upgraded), [`rolledback`](#service-rolledback), [`removed`](#service-removed), [`published`](#service-published)|
| [`changeWindow`](#changewindow) | A bounded interval during which changes to a target are governed by a window policy | [`created`](#changewindow-created), [`opened`](#changewindow-opened), [`access`](#changewindow-access), [`breached`](#changewindow-breached), [`modified`](#changewindow-modified), [`revoked`](#changewindow-revoked), [`closed`](#changewindow-closed)|

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

### `changeWindow`

A [`changeWindow`](#changewindow) is a bounded interval during which changes to a target are governed by a window policy. The window is the gate: these events report that a gate exists, when it is in force, and when it stops being in force.

A window is either **permissive** — changes are allowed only inside it, as with a maintenance or deployment window — or **restrictive**, where changes are forbidden inside it, as with a freeze. `windowType` carries which, and the audit reading of every event on this subject depends on it, so it is present on all of them.

Window-governed change control has no representation in the vocabulary today. `environment.modified` says a mutation happened; it cannot say whether that mutation was permitted or whether a restriction was violated, and those are different audit facts.

Arriving at the gate is a separate occurrence from the gate existing. [`access`](#changewindow-access) reports a change presented to the window and the result, carrying the same `status` values as the `approval` subject's `closed` event so consumers handle both alike. [`breached`](#changewindow-breached) is not an access result: it reports a change that took effect without passing the gate at all.

`revoked` and `closed` are the terminal events. A revoked window was invalidated by an actor before its bounds ran out; a closed window reached `notAfter` and ended normally. Between them they account for the window ceasing to exist, so there is no separate deletion predicate.

| Field | Type | Description | Examples |
|-------|------|-------------|----------|
| id    | `String` | See [id](spec.md#id-subject)| `freeze-holiday-2026` |
| source | `URI-Reference` | See [source](spec.md#source-subject) | `/changecontrol/prod` |
| target | `Object` | The resource whose changes the window governs. `type` names its kind. | `{"id": "prod", "source": "/clusters/prod", "type": "environment"}` |
| windowType | `String (enum)` | Whether changes are allowed only inside the window or forbidden inside it | `permissive`, `restrictive` |
| notBefore | `Timestamp` | Window start bound | `2026-12-20T00:00:00Z` |
| notAfter | `Timestamp` | Window end bound | `2027-01-02T00:00:00Z` |
| author | `Object` | The actor the producer attributes the action to | `{"id": "alice", "source": "/changecontrol/prod"}` |
| change | `Object` ([`change`](source-code-version-control.md#change)) | The change presented to the window, or the change that bypassed it | `{"id": "deploy-90217", "source": "/prod/deploys"}` |
| status | `String (enum)` | The result of presenting a change to the window | `approved`, `rejected`, `cancelled`, `expired` |
| reason | `String` | Why the window exists, or detail for a result, revocation or breach | `Holiday change freeze` |

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

### [`changeWindow created`](conformance/changewindow_created.json)

A change window has been brought into existence with its bounds, type and target. The window is not necessarily in force yet.

- Event Type: __`dev.cdevents.changewindow.created.0.1.0-draft`__
- Predicate: created
- Subject: [`changeWindow`](#changewindow)

| Field | Type | Description | Examples | Required |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | See [id](spec.md#id-subject)| `freeze-holiday-2026` | ✅ |
| source | `URI-Reference` | [source](spec.md#source) from the context | | |
| target | `Object` | The resource whose changes the window governs | `{"id": "prod", "source": "/clusters/prod", "type": "environment"}` | ✅ |
| windowType | `String (enum)` | Whether changes are allowed only inside the window or forbidden inside it | `permissive`, `restrictive` | `permissive`, `restrictive` |
| notBefore | `Timestamp` | Window start bound | `2026-12-20T00:00:00Z` | ✅ |
| notAfter | `Timestamp` | Window end bound | `2027-01-02T00:00:00Z` | ✅ |
| author | `Object` | The actor the producer attributes the creation to | `{"id": "alice", "source": "/changecontrol/prod"}` | ✅ |
| reason | `String` | Why the window exists | `Holiday change freeze` | |

### [`changeWindow opened`](conformance/changewindow_opened.json)

A change window has become active. Its policy is now in force for the target.

- Event Type: __`dev.cdevents.changewindow.opened.0.1.0-draft`__
- Predicate: opened
- Subject: [`changeWindow`](#changewindow)

| Field | Type | Description | Examples | Required |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | See [id](spec.md#id-subject)| `freeze-holiday-2026` | ✅ |
| source | `URI-Reference` | [source](spec.md#source) from the context | | |
| target | `Object` | The resource whose changes the window governs | `{"id": "prod", "source": "/clusters/prod", "type": "environment"}` | ✅ |
| windowType | `String (enum)` | Whether changes are allowed only inside the window or forbidden inside it | `permissive`, `restrictive` | `permissive`, `restrictive` |
| notBefore | `Timestamp` | Window start bound | `2026-12-20T00:00:00Z` | |
| notAfter | `Timestamp` | Window end bound | `2027-01-02T00:00:00Z` | |
| reason | `String` | Why the window exists | `Holiday change freeze` | |

### [`changeWindow access`](conformance/changewindow_access.json)

A change was presented to the window and a result was reached. `status` carries the result, using the same values as the `approval` subject's `closed` event: `approved`, `rejected`, `cancelled`, `expired`.

Receiving this event is a record of what the window decided. A consumer MUST NOT treat it as authorization for anything.

- Event Type: __`dev.cdevents.changewindow.access.0.1.0-draft`__
- Predicate: access
- Subject: [`changeWindow`](#changewindow)

| Field | Type | Description | Examples | Required |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | See [id](spec.md#id-subject)| `freeze-holiday-2026` | ✅ |
| source | `URI-Reference` | [source](spec.md#source) from the context | | |
| target | `Object` | The resource whose changes the window governs | `{"id": "prod", "source": "/clusters/prod", "type": "environment"}` | ✅ |
| windowType | `String (enum)` | Whether changes are allowed only inside the window or forbidden inside it | `permissive`, `restrictive` | `permissive`, `restrictive` |
| change | `Object` ([`change`](source-code-version-control.md#change)) | The change presented to the window | `{"id": "deploy-90217", "source": "/prod/deploys"}` | ✅ |
| status | `String (enum)` | The result of presenting the change to the window | `approved`, `rejected`, `cancelled`, `expired` | `approved`, `rejected`, `cancelled`, `expired` |
| notBefore | `Timestamp` | Window start bound | `2026-12-20T00:00:00Z` | |
| notAfter | `Timestamp` | Window end bound | `2027-01-02T00:00:00Z` | |
| reason | `String` | Detail for the result | `Deployment requested during active holiday freeze` | |

### [`changeWindow breached`](conformance/changewindow_breached.json)

A change took effect in violation of the window, without passing the gate. This is not an access result: nothing was presented and nothing decided.

Which changes constitute a breach depends on polarity. A change outside a `permissive` window is a breach; a change inside a `restrictive` window is a breach.

- Event Type: __`dev.cdevents.changewindow.breached.0.1.0-draft`__
- Predicate: breached
- Subject: [`changeWindow`](#changewindow)

| Field | Type | Description | Examples | Required |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | See [id](spec.md#id-subject)| `freeze-holiday-2026` | ✅ |
| source | `URI-Reference` | [source](spec.md#source) from the context | | |
| target | `Object` | The resource whose changes the window governs | `{"id": "prod", "source": "/clusters/prod", "type": "environment"}` | ✅ |
| windowType | `String (enum)` | Whether changes are allowed only inside the window or forbidden inside it | `permissive`, `restrictive` | `permissive`, `restrictive` |
| change | `Object` ([`change`](source-code-version-control.md#change)) | The change that bypassed the window | `{"id": "deploy-90217", "source": "/prod/deploys"}` | ✅ |
| notBefore | `Timestamp` | Window start bound | `2026-12-20T00:00:00Z` | |
| notAfter | `Timestamp` | Window end bound | `2027-01-02T00:00:00Z` | |
| reason | `String` | Detail for the breach | `Deployment executed during active holiday freeze` | |

### [`changeWindow modified`](conformance/changewindow_modified.json)

A change window has been changed. The subject retains its identity across the change.

This event carries the window's complete state after the change — the resulting `notBefore`, `notAfter`, `windowType` and `target` — rather than a description of what moved. A consumer reading a single `modified` event knows the window's current bounds without holding an earlier event to compare against.

- Event Type: __`dev.cdevents.changewindow.modified.0.1.0-draft`__
- Predicate: modified
- Subject: [`changeWindow`](#changewindow)

| Field | Type | Description | Examples | Required |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | See [id](spec.md#id-subject)| `freeze-holiday-2026` | ✅ |
| source | `URI-Reference` | [source](spec.md#source) from the context | | |
| target | `Object` | The governed resource, as it stands after the change | `{"id": "prod", "source": "/clusters/prod", "type": "environment"}` | ✅ |
| windowType | `String (enum)` | The polarity, as it stands after the change | `permissive`, `restrictive` | `permissive`, `restrictive` |
| notBefore | `Timestamp` | The start bound, as it stands after the change | `2026-12-20T00:00:00Z` | ✅ |
| notAfter | `Timestamp` | The end bound, as it stands after the change | `2027-01-02T00:00:00Z` | ✅ |
| author | `Object` | The actor the producer attributes the change to | `{"id": "alice", "source": "/changecontrol/prod"}` | ✅ |
| reason | `String` | Detail for the change | `Freeze extended through the first trading day` | |

### [`changeWindow revoked`](conformance/changewindow_revoked.json)

A change window has been invalidated by an actor before its bounds ran out. Its policy is no longer in force.

- Event Type: __`dev.cdevents.changewindow.revoked.0.1.0-draft`__
- Predicate: revoked
- Subject: [`changeWindow`](#changewindow)

| Field | Type | Description | Examples | Required |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | See [id](spec.md#id-subject)| `freeze-holiday-2026` | ✅ |
| source | `URI-Reference` | [source](spec.md#source) from the context | | |
| target | `Object` | The resource the window governed | `{"id": "prod", "source": "/clusters/prod", "type": "environment"}` | ✅ |
| windowType | `String (enum)` | Whether changes were allowed only inside the window or forbidden inside it | `permissive`, `restrictive` | `permissive`, `restrictive` |
| author | `Object` | The actor the producer attributes the revocation to | `{"id": "alice", "source": "/changecontrol/prod"}` | ✅ |
| notBefore | `Timestamp` | Window start bound | `2026-12-20T00:00:00Z` | |
| notAfter | `Timestamp` | Window end bound | `2027-01-02T00:00:00Z` | |
| reason | `String` | Detail for the revocation | `Freeze lifted early by change board` | |

### [`changeWindow closed`](conformance/changewindow_closed.json)

A change window reached `notAfter` and ended normally. Its policy is no longer in force.

- Event Type: __`dev.cdevents.changewindow.closed.0.1.0-draft`__
- Predicate: closed
- Subject: [`changeWindow`](#changewindow)

| Field | Type | Description | Examples | Required |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | See [id](spec.md#id-subject)| `freeze-holiday-2026` | ✅ |
| source | `URI-Reference` | [source](spec.md#source) from the context | | |
| target | `Object` | The resource the window governed | `{"id": "prod", "source": "/clusters/prod", "type": "environment"}` | ✅ |
| windowType | `String (enum)` | Whether changes were allowed only inside the window or forbidden inside it | `permissive`, `restrictive` | `permissive`, `restrictive` |
| notBefore | `Timestamp` | Window start bound | `2026-12-20T00:00:00Z` | |
| notAfter | `Timestamp` | Window end bound | `2027-01-02T00:00:00Z` | |
| reason | `String` | Detail for the closure | `Holiday change freeze ended` | |
