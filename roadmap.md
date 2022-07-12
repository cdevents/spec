# CDEvents Mission and Roadmap

This document describes the mission of the CDEvents and its overall roadmap for 2022.

## Mission & Vision

The mission of CDEvents project is:

> Provide interoperability in the continuous delivery ecosystem through a common events protocol

The vision for the CDEvents project is to have CDEvents natively produced and consumed by
as many projects and services as possible in the continuous delivery ecosystem, to provide
decoupled and scalable integration with minimal or no glue code.

We envision an ecosystem of tools to generate, store, process and visualize CDEvents.

## Roadmap

The continuous delivery ecosystem is quite large as it includes tools and services that span
from the design of software, through its implementation, build, test, release, deployment and
operation.

In 2022 we want to focus on a few [key use cases](primer.md#use-cases) and make sure that we can fully support
them with the protocol specification. More specifically:

- Capture our key use cases and design decisions in the [CDEvents primer](primer.md) document
- Develop the spec to fully support our [key use cases](primer.md#use-cases)
  - Create our first [release v0.1](https://github.com/orgs/cdevents/projects/1)
  - Define the specification versioning and stability policy
  - Define our requirements for a v1.0
- Validate and demonstrate the spec through proofs-of-concept
- Specify and rework the CloudEvents binding, and develop SDKS:
  - Re-create the SDK for the `go` language
  - Create a new SDK for the `python` language
- Evolve the project bootstrap governance into a full governance
- Grow the CDEvents community of projects and contributors

The implementation of proofs of concept will require having CDEvents emitted by various platforms
which do not support CDEvents yet. Where possible we will work with the community; it is likely we
will have to develop producers and consumers of CDEvents that can adapt existing event formats into
CDEvents. We will host such reference implementations in the `cdevents` organization at least until
they can find a new home in the target project.
These implementations will be useful to identify the mapping between the data model of a specific
platform and CDEvents; we can add these mappings to supporting documentation in `cdevents` organization.
