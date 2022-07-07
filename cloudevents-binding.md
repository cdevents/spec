<!--
---
linkTitle: "CloudEvents Binding"
weight: 100
description: >
   CloudEvents Binding for CDEvents
---
-->
# CloudEvents Binding for CDEvents - Draft

## Abstract

The CloudEvents Binding for CDEvents defines how CDEvents are mapped to CloudEvents headers and body.

## Table Of Contents

<!-- toc -->
- [Context](#context)
  - [specversion](#specversion)
  - [id](#id)
  - [source](#source)
  - [type](#type)
  - [subject](#subject)
  - [time](#time)
  - [datacontenttype](#datacontenttype)
  - [dataschema](#dataschema)
- [Event Data](#event-data)
- [Example](#example)
<!-- /toc -->

## Context

The CloudEvents context is built by the event producer using some of the data
from the [CDEvents context](spec.md#context).

### specversion

The [CloudEvents `specversion`](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#specversion)
MUST be set to `1.0`.

### id

The [CloudEvents `id`](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#id)
MUST be set to the CDEvents [`id`](spec.md#id).

### source

The [CloudEvents `source`](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#source-1)
MUST be set to the CDEvents [`source`](spec.md#source).

### type

The [CloudEvents `type`](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#type)
MUST be set to the [`type`](spec.md#type) of the CDEvent.

### subject

The [CloudEvents `subject`](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#subject)
MUST be set to the [subject `id`](spec.md#subjectid) of the CDEvent.
__Note__: since the *subject* is mandatory in CDEvents, the `subject` in the
CloudEvents format will always be set - even if it's not mandated by the
CloudEvents specification.

### time

The [CloudEvents `time`](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#subject)
MUST be set to the [`timestamp`](spec.md#timestamp) of the CDEvent. The
CloudEvents specification allows for `time` to be set to either the current time
or the time of the occurrence, but it requires all producers to be chose the
same option. CDEvents requires all producers to use the `timestamp` from the
CDEvent to meet the CloudEvents specification.

### datacontenttype

The [CloudEvents `datacontenttype`](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#datacontenttype)
is optional, its use depends on the specific CloudEvents binding and mode in
use. See the [event data](#event-data) section for more details.

### dataschema

The [CloudEvents `dataschema`](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#dataschema)
is MAY be set to a URL that points to the event data schema included in this
specification.

## Events Data

The content and format of the event data depends on the specific CloudEvents
binding in use. All the example, unless otherwise stated, refer to the
[HTTP binding](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/bindings/http-protocol-binding.md)
in [binary content mode](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/bindings/http-protocol-binding.md#31-binary-content-mode). In this format, the
CloudEvents context is stored in HTTP headers.

### Content Modes

This specification defines two content modes for transferring events:
*structured* and *binary*. The *structured* mode can be used in all cases, the
*binary* mode may only be used in conjunction with the HTTP CloudEvent binding
in *binary* mode:

| CloudEvents / CDEvents | Structured | Binary |
|------------------------|------------|--------|
| HTTP Binary            | V          | V      |
| HTTP Structured        | V          | X      |
| HTTP Batch             | V          | X      |
| Other Binding          | V          | X      |

#### Structured Content Mode

In *structured* content mode, the [CloudEvents Event Data](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#event-data)
MUST include the full CDEvents [`context`](spec.md#context) rendered as JSON
in the format specified by the [schema](./schemas/) for the event type.

In CloudEvents HTTP binary mode, the `Content-Type` HTTP header MUST be set to
`application/cdevents+json`. In CloudEvents HTTP structured mode, the same
information is carried in the CloudEvents context field `datacontenttype`.

##### Structured Mode Examples

Full example of a CDEvents in *structured* content mode, transported through a
CloudEvent in HTTP *binary* mode:

```json
POST /sink HTTP/1.1
Host: cdevents.example.com
ce-specversion: 1.0
ce-type: dev.cdevents.taskrun.started
ce-time: 2018-04-05T17:31:00Z
ce-id: A234-1234-1234
ce-source: /staging/tekton/
ce-subject: /namespace/taskrun-123
Content-Type: application/cdevents+json; charset=utf-8
Content-Length: nnnn

{
   "context": {
      "version" : "draft",
      "id" : "A234-1234-1234",
      "source" : "/staging/tekton/",
      "type" : "dev.cdevents.taskrun.started",
      "timestamp" : "2018-04-05T17:31:00Z",
   }
   "subject" : {
      "id": "/namespace/taskrun-123",
      "type": "taskRun",
      "content": {
         "task": "my-task",
         "url": "/apis/tekton.dev/v1beta1/namespaces/default/taskruns/my-taskrun-123"
         "pipelineRun": {
            "id": "/somewherelse/pipelinerun-123",
            "source": "/staging/jenkins/"
         }
      }
   }
}
```

#### Binary Content Mode

TBD

##### Binary Mode Examples

TBD
