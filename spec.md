<!--
---
linkTitle: "Common Metadata"
weight: 30
description: >
    Introduction to CDEvents and specification of common metadata
---
-->
# Continuous Delivery Events Vocabulary

__Note:__ This is a work-in-progress draft version and is being worked on by members of the Events SIG. You are very welcome to join the work and the discussions!

This document intends to describe a set of events related to different phases of a Continuous Delivery process.
These events are categorized by meaning, and the phase where they are intended to be used.
These events are agnostic from any specific tool and are designed to fit a wide range of scenarios.

The phases covered by this proposal are:

- __[Core Events](core.md)__: includes core events related to core activities and orchestration that needs to exist to be able to deterministically and continuously being able to delivery software to users.
- __[Source Code Version Control Events](source-code-version-control.md)__: Events emitted by changes in source code or by the creation, modification or deletion of new repositories that hold source code.
- __[Continuous Integration Pipelines Events](continuous-integration-pipeline-events.md)__: includes events related to building, testings, packaging and releasing software artifacts, usually binaries.
- __[Continuous Deployment Pipelines Events](continuous-deployment-pipeline-events.md)__: include events related with environments where the artifacts produced by the integration pipelines actually run. These are usually services running in a specific environment (dev, QA, production), or embedded software running in a specific hardware.

These phases can also be considered as different profiles of the vocabulary that can be adopted independently.
Also notice that we currently use the term 'pipeline' to denote a pipelines, workflows and related concepts. We also use the term 'task' to denote a job/stage/step.

## Required Metadata for CD Events

The following attributes are REQUIRED to be present in all the Events defined in this vocabulary:

- __Event ID__: defines a unique identifier for the event
- __Event Type__: defines a textual description of the event type, only event types described in this document are supported. All event types should be prefixed with `cd.`
- __Event Source__: defines the context in which an event happened
- __Event Timestamp__: defines the time when the event was produced

The following sections list the events in different phases, allowing adopters to choose the events that they are more interested in.
