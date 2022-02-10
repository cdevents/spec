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

## Context

The following attributes are REQUIRED to be present in all the Events defined in
this vocabulary:

- __Event ID__: defines an identifier for the event. The Event ID MUST be unique
  within the given Event Source.
- __Event Type__: defines the type of event, as combination of a *subject* and
  *predicate*. Valid event types are defined in the [vocabulary](#vocabulary).
  All event types should be prefixed with `dev.cdevents.`. One occurrence may
  have multiple events associated, as long as they have different event types
- __Event Source__: defines the context in which an event happened
- __Event Timestamp__: defines the time when the event was produced

## Vocabulary

The vocabulary defines *event types*, which are made of *subjects*, and
*predicates*. An example of *subject* is a `build`. The `build` can be `started`
or `finished`, which are the predicates. The `build` subject has several
*attributes* associated; the *event type* schema defines which ones are
mandatory and which ones are optional. *Subjects* can represent the core context
of an event, but may also be referenced to in other areas of the protocol.

The *subjects* are grouped, to help browsing the spec, in different *stages*,
which are associated to different parts of a Continuous Delivery process where
they are expected to be *produced*.

These *subjects*, with their associated *predicates* and *attributes*, are
agnostic from any specific tool and are designed to fit a wide range of
scenarios. The CDEvents project collaborates with the
[SIG Interoperability](https://github.com/cdfoundation/sig-interoperability) to
identify a the common terminology to be used and how it maps to different terms
in different platforms.

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
