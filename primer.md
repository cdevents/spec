# CDEvents Primer - Draft

## Abstract

This non-normative document provides an overview of the CDEvents specification. It is meant to complement the CDEvents specification to provide additional background and insight into the history and design decisions made during the development of the specification. This allows the specification itself to focus on the normative technical details.

## Table of Contents

<!-- toc -->
- [History](#history)
- [Acknowledgments](#acknowledgments)
- [Use Cases](#use-cases)
<!-- /toc -->

## History

TBD

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
