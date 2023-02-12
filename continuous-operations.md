<!--
---
linkTitle: "Continuous Operations Events"
weight: 70
description: >
   Continuous Operations Events
---
-->
# Continuous Operations Events

Continuous Operations events are related to the operation of services deployed in target environments, tracking of incidents and their resolution. Incidents, and their resolution, can be detected by a number of different actors, like the end-user, a quality gate, a monitoring system, an SRE through a ticketing system or even the service itself.

## Subjects

This specification defines one subject in this stage, the [`incident`](#incident). To quote the definition of the term from the NIST glossary, and [incident][] is:

> An occurrence that actually or potentially jeopardizes the confidentiality, integrity, or availability of an information system or the information the system processes, stores, or transmits or that constitutes a violation or imminent threat of violation of security policies, security procedures, or acceptable use policies.

| Subject | Description | Predicates |
|---------|-------------|------------|
| [`incident`](#incident) | A problem in a production environment | [`detected`](#incident-detected), [`reported`](#incident-reported), [`resolved`](#incident-resolved)|

### `incident`

An `incident` represents a problem in a production environment.

| Field | Type | Description | Examples |
|-------|------|-------------|----------|
| id    | `String` | Uniquely identifies the subject within the source. | `04896C75-F34D-40FF-A584-3F2B71CB9D47`, `issue123`, `risk-CVE123` |
| source | `URI-Reference` | [source](../spec.md#source) from the context | `region1/production`, `monitoring-system/metricA`|
| description | `String` | Short, free style description of the incident | "Response time above 10ms", "New CVE-123 detected" |
| environment | `Object` ([`environment`](./continuous-deployment.md#environment)) | Reference to the environment | `{"id": "production"}`, `{"id": "staging"}`, `{"id": "prod123", "source": "iaas-region-1"}` |
| service | `Object` ([`service`](./continuous-deployment.md#service)) | Reference to the service | `{"id": "service123"}`, `{"id": "service123", "source": "region1/k8s/namespace"}` |
| artifactId | `Purl` | Identifier of the artifact deployed with this service |  `0b31b1c02ff458ad9b7b81cbdf8f028bd54699fa151f221d1e8de6817db93427`, `927aa808433d17e315a258b98e2f1a55f8258e0cb782ccb76280646d0dbe17b5`, `six-1.14.0-py2.py3-none-any.whl` |

## Events

### `incident detected`

This event represents an incident that has been detected by a system or human.

- Event Type: __`dev.cdevents.incident.detected.0.1.0-draft`__
- Predicate: detected
- Subject: [`incident`](#incident)

| Field | Type | Description | Examples | Mandatory ✅ |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | Uniquely identifies the subject within the source. | `04896C75-F34D-40FF-A584-3F2B71CB9D47`, `issue123`, `risk-CVE123` | ✅ |
| source | `URI-Reference` | [source](../spec.md#source) from the context | `region1/production`, `monitoring-system/metricA`| |
| description | `String` | Short, free style description of the incident | "Response time above 10ms", "New CVE-123 detected" | |
| environment | `Object` ([`environment`](./continuous-deployment.md#environment)) | Reference to the environment | `{"id": "production"}`, `{"id": "staging"}`, `{"id": "prod123", "source": "iaas-region-1"}` | ✅ |
| service | `Object` ([`service`](./continuous-deployment.md#service)) | Reference to the service | `{"id": "service123"}`, `{"id": "service123", "source": "region1/k8s/namespace"}` | |
| artifactId | `Purl` | Identifier of the artifact deployed with this service |  `0b31b1c02ff458ad9b7b81cbdf8f028bd54699fa151f221d1e8de6817db93427`, `927aa808433d17e315a258b98e2f1a55f8258e0cb782ccb76280646d0dbe17b5`, `six-1.14.0-py2.py3-none-any.whl` | |

### `incident reported`

This event represents an incident that has been reported through a ticketing system. Compared to the `detected` predicated, it introduces a ticket URI.

- Event Type: __`dev.cdevents.incident.reported.0.1.0-draft`__
- Predicate: reported
- Subject: [`incident`](#incident)

| Field | Type | Description | Examples | Mandatory ✅ |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | Uniquely identifies the subject within the source. | `04896C75-F34D-40FF-A584-3F2B71CB9D47`, `issue123`, `risk-CVE123` | ✅ |
| source | `URI-Reference` | [source](../spec.md#source) from the context | `region1/production`, `monitoring-system/metricA`| |
| description | `String` | Short, free style description of the incident | "Response time above 10ms", "New CVE-123 detected" | |
| environment | `Object` ([`environment`](./continuous-deployment.md#environment)) | Reference to the environment | `{"id": "production"}`, `{"id": "staging"}`, `{"id": "prod123", "source": "iaas-region-1"}` | ✅ |
| ticketURI | `URI` | URI of the ticket |  `example.issues.com/ticket123` | ✅ |
| service | `Object` ([`service`](./continuous-deployment.md#service)) | Reference to the service | `{"id": "service123"}`, `{"id": "service123", "source": "region1/k8s/namespace"}` | |
| artifactId | `Purl` | Identifier of the artifact deployed with this service |  `0b31b1c02ff458ad9b7b81cbdf8f028bd54699fa151f221d1e8de6817db93427`, `927aa808433d17e315a258b98e2f1a55f8258e0cb782ccb76280646d0dbe17b5`, `six-1.14.0-py2.py3-none-any.whl` | |

### `incident resolved`

This event represents an incident that has been resolved, meaning that the problem identified by the incident has been solved or recalled.

- Event Type: __`dev.cdevents.incident.resolved.0.1.0-draft`__
- Predicate: resolved
- Subject: [`incident`](#incident)

| Field | Type | Description | Examples | Mandatory ✅ |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | Uniquely identifies the subject within the source. | `04896C75-F34D-40FF-A584-3F2B71CB9D47`, `issue123`, `risk-CVE123` | ✅ |
| source | `URI-Reference` | [source](../spec.md#source) from the context | `region1/production`, `monitoring-system/metricA`| |
| description | `String` | Short, free style description of the incident resolution | "Response time restored below 10ms", "CVE-123 acknowledged as non-exploitable" | |
| environment | `Object` ([`environment`](./continuous-deployment.md#environment)) | Reference to the environment | `{"id": "production"}`, `{"id": "staging"}`, `{"id": "prod123", "source": "iaas-region-1"}` | ✅ |
| service | `Object` ([`service`](./continuous-deployment.md#service)) | Reference to the service | `{"id": "service123"}`, `{"id": "service123", "source": "region1/k8s/namespace"}` | |
| artifactId | `Purl` | Identifier of the artifact deployed with this service |  `0b31b1c02ff458ad9b7b81cbdf8f028bd54699fa151f221d1e8de6817db93427`, `927aa808433d17e315a258b98e2f1a55f8258e0cb782ccb76280646d0dbe17b5`, `six-1.14.0-py2.py3-none-any.whl` | |

[incident]: https://csrc.nist.gov/glossary/term/incident