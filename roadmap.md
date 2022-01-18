# CDEvents Mission and Roadmap

This document describes the mission of the CDEvents and its overall roadmap for 2022.

## Mission & Vision

The mission of CDEvents project is:

> Provide interoperability in the continuous delivery ecosystem through a common events format

The vision for the CDEvents project is to have CDEvents natively produced and consumed by
as many projects and services as possible in the continuous delivery ecosystem, to provide
decoupled and scalable integration with minimal or no glue code.

We envision an ecosystem of tools to generate, store, process and visualize CDEvents.

## Roadmap

The continuous delivery ecosystem is quite large as it includes tools and services that span
from the design of software, through its implementation, build, test, release, deployment and
operation.

In 2022 we want to focus on a few [key use cases](#use-cases) and make sure that we can fully support
them with the protocol specification. More specifically:

- Capture our key use cases and design decisions in the [CDEvents primer](primer.md) document
- Develop the spec to fully support our [key use cases](#use-cases)
- Validate and demonstrate the spec through proofs-of-concept
- Specify and rework the CloudEvents binding, re-create the SDK for the `go` language
- Evolve the project bootstrap governance into a full governance
- Grow the CDEvents community of projects and contributors

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