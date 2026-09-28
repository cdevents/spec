# Event existence over time: an optional hash commitment

Status: informational companion document. This guidance is optional and additive; it
does not change the core CDEvents specification or any schema.

## Introduction

A CDEvent describes something that happened in a delivery pipeline: an artifact was
published, a build finished, a change was merged. Downstream systems make decisions on
these events — promotion gates, policy checks, audit trails — and a signature on the
event answers only part of what those decisions need.

A signature proves who emitted an event and whether its payload was altered. It does not
prove when the event existed. A signature carries no trustworthy time: any timestamp
inside the event is asserted by the emitter, and a party holding the signing key can
produce a fresh, validly-signed event with different content at any later time. Signing
CDEvents with [DSSE](https://github.com/secure-systems-lab/dsse) is the baseline, and
when a CDEvent travels as a CloudEvent the merged
[verifiability extension](https://github.com/cloudevents/spec/blob/main/cloudevents/extensions/verifiability.md)
is the way to do it. That extension's stated non-goals — stream completeness, ordering,
existence over time — are the gap this document addresses.

This document covers one optional, opt-in mechanism: a commitment to the event's
canonical hash, fixed against a timeline the emitter does not control. It is
deliberately anchor-agnostic. The commitment is just the event digest; where it is
anchored is an implementation choice.

## Background: how a CDEvent is carried

Per the CDEvents [CloudEvents binding](https://github.com/cdevents/spec/blob/main/cloudevents-binding.md),
a CDEvent is transported as the `data` of a
[CloudEvent](https://github.com/cloudevents/spec) with `datacontenttype`
`application/json`, and the CloudEvents `id`, `source`, `type`, `subject` and `time`
attributes are mapped from the CDEvent's context. The commitment below can be applied at
either layer. Hashing the CDEvent document — its `context` plus `subject`, the object
defined by the CDEvents schema — keeps the commitment tied to the event itself and
independent of the transport.

## The commitment

1. Canonicalize the CDEvent with [RFC 8785](https://www.rfc-editor.org/rfc/rfc8785)
   (JSON Canonicalization Scheme, JCS). JCS gives a single, deterministic byte
   serialization for a JSON value, so any party recomputes the same bytes from the same
   event.
2. Hash the canonical bytes with SHA-256. This digest is the commitment.
3. Record the digest on an external timeline so that its existence-by-time-T can be
   checked later.

Step 3 is where the anchor lives, and this guide does not pick one. A digest can be
fixed against a timeline in several ways, for example:

- an [RFC 3161](https://www.rfc-editor.org/rfc/rfc3161) trusted timestamp from a Time
  Stamping Authority,
- an append-only transparency log (for example a Merkle-tree log in the style of
  RFC 9162),
- inclusion in a public blockchain transaction.

Which anchor to use is an operational and threat-model choice. The only thing CDEvents
tooling needs to agree on is the commitment itself: the canonicalization (RFC 8785) and
the hash (SHA-256). Everything about the anchor is out of scope for this document and
MUST NOT be assumed by consumers.

## What the commitment proves, and what it does not

Proves:

- Existence by a time. Given the event, anyone recomputes the digest and checks it
  against the anchor's record, establishing that the event existed by the time the
  anchor was written.
- Independence from key custody. The check needs neither the emitter's signing key nor
  its clock. It survives key loss, key rotation, and emitter compromise after the anchor
  time.
- Reissue detection. A later re-signed variant of the event produces a different digest,
  with no earlier anchor behind it.

Does not prove:

- Authorship. Nothing in the commitment says who emitted the event; only a signature
  does. The two are meant to be used together.
- That the anchor was written honestly. An anchor establishes that a digest existed by a
  point in time. It does not establish that the anchoring party could not have waited to
  see how something resolved before writing it — that property has to come from what is
  committed, not from the anchor.
- Anything about events that were never committed. This is a per-event mechanism; it
  says nothing about the completeness of a stream.

## When to add it

Signing is the baseline. Add a commitment when downstream decisions need
existence-over-time, or must survive compromise of the emitter's signing key — regulated
audit trails and long-lived provenance are the usual cases. For an event consumed
minutes after it is emitted, by a system that already trusts the emitter's key, it adds
cost and nothing else.

A worked example — a real `dev.cdevents.artifact.published` event, its JCS canonical
bytes, the commitment, and a verifier that recomputes both — is kept outside this
repository so CDEvents takes no dependency on it.

## References

- RFC 8785, JSON Canonicalization Scheme (JCS). https://www.rfc-editor.org/rfc/rfc8785
- RFC 3161, Time-Stamp Protocol. https://www.rfc-editor.org/rfc/rfc3161
- RFC 9162, Certificate Transparency v2. https://www.rfc-editor.org/rfc/rfc9162
- DSSE envelope format. https://github.com/secure-systems-lab/dsse/blob/master/envelope.md
- CloudEvents verifiability extension.
  https://github.com/cloudevents/spec/blob/main/cloudevents/extensions/verifiability.md
- CDEvents CloudEvents binding.
  https://github.com/cdevents/spec/blob/main/cloudevents-binding.md
