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
