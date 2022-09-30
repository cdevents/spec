<!--
---
linkTitle: "Primer"
weight: 20
description: >
    A CDEvents primer
---
-->
# CDEvents Primer - Draft

## Abstract

This non-normative document provides an overview of the CDEvents specification. It is meant to complement the CDEvents specification to provide additional background and insight into the history and design decisions made during the development of the specification. This allows the specification itself to focus on the normative technical details.

## Table of Contents

<!-- toc -->
- [History](#history)
- [Design reflections](#design-reflections)
  - [How does CDEvents enable tools to communicate in an interoperable way?](#how-does-cdevents-enable-tools-to-communicate-in-an-interoperable-way)
  - [Why use events?](#why-use-events)
  - [Why not point-to-point communication?](#why-not-point-to-point-communication)
- [Relations to CloudEvents](#relations-to-cloudevents)
- [Acknowledgments](#acknowledgments)
- [Use Cases](#use-cases)
- [Design Decisions](#design-decisions)
  - [Keys, Values and Types](#keys-values-and-types)
<!-- /toc -->

## History

The [Events in CI/CD Worksteam](https://github.com/cdfoundation/sig-interoperability/tree/master/workstreams/archived/events_in_cicd)
was originally formed by the [CDF Interoperability Special Interest Group](https://github.com/cdfoundation/sig-interoperability)
with the mission to *Standardize events to be used in a CI/CD process*. The workstream later evolved into [Event Special Interest Group](https://github.com/cdfoundation/sig-events/), which defined the initial vocabulary for CI/CD events, developed a golang
SDK and a first proof of concept which involved [Tekton](https://tekton.dev) and [keptn](https://keptn.sh).

The initial vocabulary then became [CDEvents](https://cdevents.dev), a new standalone [CDF](https://cd.foundation) incubated project.

## Design reflections

### How does CDEvents enable tools to communicate in an interoperable way?

By creating a language, we define how tools and services communicate with each
other about occurrences in a CI/CD system. As this language does not tie to a
specific tool it serves a neutral ground for communication.

Using this language we define a set of events with purpose and semantic meaning.
With such a well-defined language, tools know what events to send, and receivers
know how to interpret the information received. This enables tools to have a
common understanding of the information sent in the events.

The language enables creating an ecosystem of tools for monitoring, tracing,
measuring, and orchestrating using our events without having to write a
"plugin" for every tool.

### Why use events?

Reading from the
[CloudEvents primer - design goals](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/primer.md#design-goals)

> The goal of the CloudEvents specification is to define interoperability of
> event systems that allow services to produce or consume events, where the
> producer and consumer can be developed and deployed independently. A producer
> can generate events before a consumer is listening, and a consumer can express
> an interest in an event or class of events that is not yet being produced.

We believe that using events will lead to a more decoupled systems with services
and tools developed and deployed independently. This makes us agnostic of the
underlying infrastructure

### Why not point-to-point communication?

We believe that using integrations based on point-to-point communication will
create a system that will:

* Not scale - when trying to add new consumers or producers each tool have to make
  an update
* Create a coupled architecture - using point-to-point communication creates a
  tightly intertwined architecture difficult to expand and monitor.

## Relations to CloudEvents

CDEvents defines a [specification](./cloudevents-binding.md) that provides a set
of JSON object schemas (one for each event type, covering mandatory and optional
attributes etc.)

When used with CloudEvents, CDEvents passes the JSON schema  via the
[`dataschema`](https://github.com/cloudevents/spec/blob/v1.0.1/spec.md#dataschema)
attribute and provide the corresponding JSON object through the
[`data`](https://github.com/cloudevents/spec/blob/v1.0.1/spec.md#event-data)
attribute.

CDEvents aims to use existing CloudEvents extension attributes (e.g.
`partitionkey` from the
[Partitioning](https://github.com/cloudevents/spec/blob/v1.0.1/extensions/partitioning.md)
extension) before defining its own extensions. When no appropriate extension
attributes exists, CDEvents aims to make an official CloudEvents extension for
the CloudEvents specification and listed with other [documented
extensions](https://github.com/cloudevents/spec/blob/v1.0.1/documented-extensions.md).

## Versioning

The CDEvents specification and events are versioned independently, both
following the principle of semantic versioning.

### Versioning of CDEvents

Individual CDEvents are versioned using semantic versioning, with a
`major.minor.patch` format of the version.

Backward compatible changes are changes that allow existing consumers to parse
messages with a newer version, have access to the same data as before, as long
the extra fields are ignored. Broadening the accepted values for a property is a
backward incompatible change, as the consumer may not be prepared to manage the
new format of value.

Note that this means that consumers SHOULD be prepared to handle (and disregard)
unrecognized properties in higher minor versions than they are familiar with.

- Major versions (e.g. 0.3.1 -> 1.0.0): backward incompatible changes to events.
  Renamed, moved or removed fields requires a new major version.

- Minor versions (e.g. 0.1.2 -> 0.2.0): backward compatible changes to events
  that involve a structural change in the schema. A new field is added, a copy
  of an existing field is added and the old location deprecated, or a new

- Patch versions (e.g. 0.1.0 -> 0.1.1): backward compatible changes to events
  that do not involve any structural change in the schema, for instance
  narrowing the accepted values for a property

While the specification of an event is work in progress, its version is tagged
with an extra `-draft` at the end.

The version of an event is included in its type. This allows for easy filtering
of events of a specific version, by looking at a single field in the context.
Examples of full event versions are:

- `dev.cdevents.build.queued.0.1.0-draft`
- `dev.cdevents.environment.deleted.0.1.0`

### Versioning of the CDEvents specification

The overall CDEvents specification is versioned using semantic versioning, with
a `major.minor.patch` format of the version. The specification version is
associated to a git version (tag) in the `cdevents/spec` repository, in the
format `vMajor.Minor.Patch`.

- A specification that includes only cosmetic fixes is identified by a change in
  the patch version, for instance 0.1.0 -> 0.1.1

- A specification that includes only backwards compatible change is identified
  by a change in the minor version, for instance 0.1.3 -> 0.2.0

- A specification that includes at least one backward incompatible change, is
  identified by a change in the major version, for instance 0.1.2 -> 2.0.0

While a version of the specification is work in progress, its version is tagged
with an extra `-draft` at the end, for instance 0.1.0-draft.

### Development of a new version

The specification on the main branch is versioned with the number of the next
version followed by a `-draft`. If any event is modified, its version is changed
accordingly, followed by a `-draft` as well.

Once a specification is ready for release, its number if updated, the event versions
are finalized (`-draft` is removed), schemas are updated and a git tag is created for
this last commit.

## Acknowledgments

The initial structure of the CDEvents specification format was based on the specification of the [CloudEvents](https://github.com/cloudevents/spec) project.

## Use Cases

There are two root use cases that we are considering:

- *Interoperability through CDEvents*: In this use case, platforms from the CD landscape either produce
  or consume CDEvents. On the producing side, a system broadcasts that certain value has been produced,
  like a code change, an artifact or a test result. On the consumer side, a system takes an action that
  takes advantage of that value that has been produced.

- *Observability & Metrics*: In this use case, platforms from the CD landscape produce CDEvents that describe
  the start and end of parts of an end of end CD workflow, for instance build started and finished, artifact
  packaged and published and deployment started and finished. We want to visualize the end to end CD workflow,
  for instance from a change being written, through its build, test, release, deployment and possibly rollback
  in case a remediation is required. To achieve that, events are sent to an event router and collected
  by a pipeline visualization application, that uses the information in the events to correlate them with each
  other and build an end to end view. With the same events, we want to measure DevOps performance as well.
  The same events can be used to track different metrics over time, to be visualized through a dashboard.

The use cases are work in progress - the list is being drafted in a [separate document](https://hackmd.io/ZCS2KYKZTpKBqhU9PMuCew).

## Design Decisions

### Keys, Values and Types

The CDEvents specification defines event types, keys and, for ENUM types, values.

Event types are defined as all lowercase, separated by dots. The first part of
each type is always "dev.cdevents" which is the reverse DNS domain of the
CDEvents project.

Keys and ENUM values are always written in [lowerCamelCase](https://en.wikipedia.org/wiki/Camel_case)
for readability purposes.
