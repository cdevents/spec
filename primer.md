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
- [Relations to CloudEvents](#relations-to-cloudevents)
- [Acknowledgments](#acknowledgments)
- [Use Cases](#use-cases)
<!-- /toc -->

## History

TBD

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
