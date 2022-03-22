<!--
---
linkTitle: "Common Metadata"
weight: 30
description: >
    Introduction to CDEvents and specification of common metadata
---
-->
# CDEvents - Draft

__Note:__ This is a work-in-progress version and is being worked on by members
of the CDEvents project. You are very welcome to
[join the work and the discussions](https://github.com/cdevents)!

## Abstract

CDEvents is a common specification for Continuous Delivery events.

## Table of Contents

<!-- toc -->
- [Overview](#overview)
- [Notations and Terminology](#notations-and-terminology)
  - [Notational Conventions](#notational-conventions)
  - [Terminology](#terminology)
    - [Event](#event)
    - [Subject](#subject)
    - [Predicate](#predicate)
  - [Types](#types)
- [Context](#context)
  - [REQUIRED Event Attributes](#required-event-attributes)
    - [id](#id)
    - [type](#type)
    - [source](#source)
    - [timestamp](#timestamp)
    - [version](#version)
    - [subject](#subject-1)
- [Vocabulary](#vocabulary)
<!-- /toc -->

## Overview

The specification is structured in two main parts:

- The [*context*](context), made of mandatory and optional *attributes*, shared
  by all events
- The [*vocabulary*](vocabulary), which identifies *event types*, structures as
  *subjects* and *predicates*

## Notations and Terminology

### Notational Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be
interpreted as described in [RFC 2119](https://tools.ietf.org/html/rfc2119).

For clarity, when a feature is marked as "OPTIONAL" this means that it is
OPTIONAL for both the [Producer](#producer) and [Consumer](#consumer) of a
message to support that feature. In other words, a producer can choose to
include that feature in a message if it wants, and a consumer can choose to
support that feature if it wants. A consumer that does not support that feature
will then silently ignore that part of the message. The producer needs to be
prepared for the situation where a consumer ignores that feature. An
[Intermediary](#intermediary) SHOULD forward OPTIONAL attributes.

### Terminology

__Note__: CDEvents adopts, wherever applicable, the terminology used by
[CloudEvents](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#notational-conventions).
Specifically, the following terms are borrowed from the CloudEvents spec:

- [*Occurrence*](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#occurrence)
- [*Producer*](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#producer)
- [*Source*](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#source)
- [*Consumer*](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#consumer)
- [*Intermediary*](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#intermediary)

The CDEvents specification additionally defines the following terms:

#### Event

An "event" is a data record expressing an occurrence and its context. Events are
routed from an event producer (the source) to interested event consumers. The
routing can be performed based on information contained in the event, but an
event will not identify a specific routing destination.

#### Subject

The "subject" is the entity with which the occurrence in a software system
is concerned. For instance when a software build is started, the build is the
subject of the occurrence, or when a service is deployed, the subject is the
service. Subjects have a list of *attributes* associated, defined in the
[vocabulary](#vocabulary). Subjects belong to two main categories:

- long running, which stay in a running state until they're purposely stopped or
  encounter a failure or a condition that prevents them from running - for
  example a service, an environment, an artifact or a source change
- run to completion, which independently stop after they accomplished (or
  failed to) a specific task, or encounter a failure or a condition that
  prevents them from continuing - for example a task run, a build or a test

#### Predicate

A "predicate" is what happened to a subject in an occurrence.
For instance in case of a software build, started is a valid predicate in the
occurrence, or in case of a service, deployed in a valid predicate. Valid
predicate are defined in the [vocabulary](#vocabulary).

### Types

Attributes in CDEvents are defined with as typed. We use a the
[types system](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#type-system)
defined by the CloudEvents project, plus some CDEvents specific types

- `Enum`: an attribute of type `String`, constrained to a fixed set of options
- `List`: a list of values of the same type
- `Object`: a map of (key, value) tuples
  - Keys are of type `String`. Valid keys can be defined by this spec
  - Values can be any of the other kind

## Context

### REQUIRED Event Attributes

The following attributes are REQUIRED to be present in all the Events defined in
the [vocabulary](#vocabulary):

#### id

- Type: [`String`](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#type-system)
- Description: Identifier for an event.
  Subsequent delivery attempts of the same event MAY share the same
  [`id`](#id). This attribute matches the syntax and semantics of the
  [`id`](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#id)
  attribute of CloudEvents.

- Constraints:
  - REQUIRED
  - MUST be a non-empty string
  - MUST be unique within the given [`source`](#source) (in the scope of the producer)
- Examples:
  - A [UUID version 4](https://en.wikipedia.org/wiki/Universally_unique_identifier#Version_4_(random))

#### type

- Type: [`String`](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#type-system)
- Description: defines the type of event, as combination of a *subject* and
  *predicate*. Valid event types are defined in the [vocabulary](#vocabulary).
  All event types should be prefixed with `dev.cdevents.`. One occurrence may
  have multiple events associated, as long as they have different event types

- Constraints:
  - REQUIRED
  - MUST be defined in the [vocabulary](#vocabulary)
- Examples:
  - `dev.cdevents.taskrun.started`
  - `dev.cdevents.environment.created`
  - `dev.cdevents.<subject>.<predicate>`

#### source

- Type: [`URI-Reference`](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#type-system)
- Description: defines the context in which an event happened. The main purpose
  of the source is to provide global uniqueness for [`source`](#source) +
  [`id`](#id).

  The source MAY identify a single producer or a group of producer that belong
  to the same application.

  When selecting the format for the source, it may be useful to think about how
  clients may use it. Using the [root use cases](./primer.md#use-cases) as
  reference:

  - A client may want to react only to events sent by a specific service, like
    the instance of Tekton that runs in a specific cluster or the instance of
    Jenkins managed by team X
  - A client may want to collate all events coming from a specific source for
    monitoring, observability or visualization purposes

- Constraints:
  - REQUIRED
  - MUST be a non-empty URI-reference
  - An absolute URI is RECOMMENDED

- Examples:

  - If there is a single "context" (cloud, cluster or platform of some kind)
    - `/tekton`
    - `https://www.jenkins.io/`

  - If there are multiple "contexts":
    - `/cloud1/spinnaker-A`
    - `/cluster2/keptn-A`
    - `/teamX/knative-1`

#### timestamp

- Type: [timestamp](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#type-system)
- Description: defines the time of the occurrence. When the time of the
  occurrence is not available, the time when the event was produced MAY be used.

  In case the transport layer should require a re-transmission of the event,
  the timestamp SHOULD NOT be updated, i.e. it should be the same for the same
  [`source`](#source) + [`id`](#id) combination.

- Constraints:
  - REQUIRED
  - MUST adhere to the format specified in [RFC 3339](https://datatracker.ietf.org/doc/html/rfc3339)

#### version

- Type: `String`
- Description: The version of the CDEvents specification which the event
  uses. This enables the interpretation of the context. Compliant event
  producers MUST use a value of `draft` when referring to this version of the
  specification.

- Constraints:
  - REQUIRED
  - MUST be a non-empty string

#### subject

- Type: [`Object`](#types)
- Description: This provides all the relevant details of the [`subject`](#subject). The
  format of the [`subject`](#subject-1) depends on the event [`type`](#type).

  The attributes available for each subject are defined in the
  [vocabulary](#vocabulary). The REQUIRED and OPTIONAL attributes depend on
  the event [`type`](#type) and are specified in the [vocabulary](#vocabulary).

- Constraints:
  - REQUIRED
  - If present, MUST comply with the spec from the [vocabulary](#vocabulary).

- Example:
  - Considering the event type `dev.cdevents.taskrun.started`, an example of
    subject, serialised as JSON, is:

    ```json
        "taskrun" : {
          "id": "my-taskrun-123",
          "task": "my-task",
          "status": "Running",
          "URL": "/apis/tekton.dev/v1beta1/namespaces/default/taskruns/my-taskrun-123"
        }
    ```

## Vocabulary

The vocabulary defines *event types*, which are made of *subjects*, and
*predicates*. An example of *subject* is a `build`. The `build` can be `started`
or `finished`, which are the predicates. The `build` is of type `Object` and
has several *attributes* associated; the *event type* schema defines which ones
are mandatory and which ones are optional. *Subjects* can represent the core
context of an event, but may also be referenced to in other areas of the
protocol.

The *subjects* are grouped, to help browsing the spec, in different *stages*,
which are associated to different parts of a Continuous Delivery process where
they are expected to be *produced*.

These *subjects*, with their associated *predicates* and *attributes*, are
agnostic from any specific tool and are designed to fit a wide range of
scenarios. The CDEvents project collaborates with the
[SIG Interoperability](https://github.com/cdfoundation/sig-interoperability) to
identify a the common terminology to be used and how it maps to different terms
in different platforms.

### Format of *subjects*

All subjects are of type `Object` and they share a base `Object` which they
may extend:

| Field | Type | Description | Examples |
|-------|------|-------------|----------|
| ID    | `String` | Uniquely identifies the subject within the source. | `tenant1/12345-abcde`, `namespace/12345-abcde` |
| Source | `URI-Reference` | [source](spec.md#source) from the context | |

The `ID` field is a mandatory in all cases. The `source` field is only
required when a `subject` does not belong to the *source* of the event.

For instance, in case of a distributed pipeline, a `TaskRun` subject could
belong to a `PipelineRun` associated to a different *source*:

```json
{
  "source": "/tenant1/jenkins",
  "subject": {
    "taskrun" : {
      "id": "my-taskrun-123",
      "task": "my-task",
      "status": "Running",
      "URL": "/apis/tekton.dev/v1beta1/namespaces/default/taskruns/my-taskrun-123"
      "pipelinerun": {
        "id": "my-distributed-pipelinerun",
        "source": "/tenant1/tekton"
}}}}
```

### Vocabulary Stages

The *stages* defined are:

- __[Core](core.md)__: includes core events related to core activities and
  orchestration that needs to exist to be able to deterministically and
  continuously being able to delivery software to users.
- __[Source Code Version Control](source-code-version-control.md)__: Events
  emitted by changes in source code or by the creation, modification or deletion
  of new repositories that hold source code.
- __[Continuous Integration](continuous-integration-pipeline-events.md)__:
  includes events related to building, testings, packaging and releasing
  software artifacts, usually binaries.
- __[Continuous Deployment](continuous-deployment-pipeline-events.md)__: include
  events related with environments where the artifacts produced by the
  integration pipelines actually run. These are usually services running in a
  specific environment (dev, QA, production), or embedded software running in a
  specific hardware.

The grouping may serve in future as a reference for different CDEvents
compliance profiles, which can be supported individually by implementing
platforms.
