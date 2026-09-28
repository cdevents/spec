# RFC: CDrus Expressions and Workflow Schema for CDEvents-Based SDLC Orchestration

**Submitted to:** [cdevents/spec#253](https://github.com/cdevents/spec/issues/253) — *Enable CI/CD Interoperability Through SDLC Workflow Segments*
**Author:** Dadisi Sanyika
**Date:** 2026-07-31
**Schema artifacts:** `cdrus/expression.schema.json`, `cdrus/workflow.schema.json`

---

## Abstract

This document specifies two JSON Schemas that together define a declarative language for SDLC workflow intent on top of [CDEvents](https://cdevents.dev): the **CDrus Expression** schema, which defines reusable, identity-bound, composable units of intent expressed as ordered productions of CDEvents; and the **CDrus Workflow** schema, which defines concrete, tool-bound pipelines that reference one or more Expressions. Every Expression is bound to an identity tuple — `(group, author, expression)`. Together they realize the design goal of issue [#253](https://github.com/cdevents/spec/issues/253): a portable, tool-agnostic semantic layer for SDLC orchestration. The proposal supersedes the term *Workflow Segment* with *CDrus Expression* on grammatical grounds explained in §4.2, retains backwards compatibility of intent with the original proposal, and contributes five new mechanisms not present in [#253](https://github.com/cdevents/spec/issues/253): identity-bound expressions (replacing implicit versioning), depth-first nested production, and **spawned chains** in two forms — *Blocking* (`spawn`; parallel, awaited) and *Detached* (`detach`; fire-and-forget) — each running on its own chain; plus a Workflow layer that carries tool binding distinct from intent.

---

## 1. Status of This Document

This is a Draft RFC submitted for comment to the CDEvents specification project. It is not a final specification. Section numbering, normative language, and schema `$id` values are subject to change pending CDEvents governance decisions (see §10.2).

The two JSON Schemas referenced in this RFC (`expression.schema.json` and `workflow.schema.json`) are normative attachments. Where this prose and the schemas disagree, the schemas are authoritative for structural validation; the prose is authoritative for semantics not expressible in JSON Schema (resolution order, spawned-chain semantics, identity binding behavior).

---

## 2. Introduction

### 2.1 Background

Issue #253 proposed *Workflow Segments* as a shared, declarative contract for what a unit of SDLC work means by defining the CDEvents expected for a build, a deploy, a verify, regardless of which tool performs the work. The proposal identified the missing layer in CI/CD interoperability: CDEvents standardizes the vocabulary of *what happened*, but no shared structure exists for *what was intended*.

The discussion thread in #253 surfaced three open questions that this RFC addresses directly:

1. **Naming and scope** (`@thompson-tomo`): Should the construct be named differently? Should tool binding be a separate concept from workflow definition?
2. **Producer vs. consumer compliance** (`@afrittoli`): Tools that produce events cannot always be made compliant with segments because pipeline definitions are end-user defined; tools that consume events can reason in segment terms.
3. **Hosting and governance** (`@afrittoli`): Should segments live in a new repository under the CDEvents org, or as a subspec of the existing `spec` repo?

This RFC takes a position on (1) and (2). Question (3) is deferred to CDEvents project maintainers; the schemas are written so that the `$id` URIs can be reassigned without semantic change.

### 2.2 Problem Statement

CDEvents provides a shared vocabulary for SDLC events. It does not provide:

- A way to declare which group of events constitutes a recognizable unit of intent (e.g., "a build")
- A way to compose units of intent into larger workflows
- A way to bind units of intent to a specific human commitment so that authorship and accountability travel with the intent
- A way to express ordering, nesting, and fan-out into spawned chains — both *Detached* (fire-and-forget) and *Blocking* (awaited) — between events at the level of intent
- A way to bind units of intent to concrete tools in a portable manner

Without these mechanisms, orchestrators and policy engines are forced to encode workflow semantics imperatively in code or in tool-specific configuration, defeating the interoperability value that CDEvents otherwise enables. The vocabulary alone is insufficient: a dictionary does not yield a language without grammar, and a grammar without authorship leaves intent unowned.

### 2.3 Vocabulary, Grammar, and Identity

CDEvents standardizes the vocabulary of SDLC events by describing the facts about what happened. This RFC adds a grammar layer atop that vocabulary as a set of declarations of what was intended, and binds each declaration to the human whose intent it carries:

- **CDrus Expressions** (§4): identity-bound, composable units of intent that declare which CDEvents fulfill them. Each Expression is identified by the tuple `(group, author, expression)`.
- **CDrus Workflows** (§5): concrete pipeline documents that reference Expressions by identity and bind them to tools, sources, and per-event content.

Together, Expressions and Workflows make SDLC intent declarable, composable, accountable, and portable across tools. The Workflow schema is the binding surface between intent and execution: Expressions remain tool-agnostic, while Workflows supply the concrete `tool`, `source`, `pipeline`, and `content` bindings that any downstream execution engine needs to act on the events. How that execution engine works is orthogonal to this RFC.

This separation is the answer to `@thompson-tomo`'s "split into Tools and Workflows" suggestion in #253. Tool binding belongs in the Workflow layer; Expressions remain pure intent. The Workflow schema supports both `defaults` and per-expression `overrides` (§5.3–§5.4), which provides the substitutability that motivated the original suggestion without fragmenting the grammar.

---

## 3. Conventions and Terminology

The key words **MUST**, **MUST NOT**, **REQUIRED**, **SHOULD**, **SHOULD NOT**, **MAY**, and **OPTIONAL** in this document are to be interpreted as described in BCP 14 (RFC 2119, RFC 8174).

The following terms are used throughout:

- **CDEvent**: A single event conformant to the CDEvents specification, identified by a type string of the form `dev.cdevents.<subject>.<predicate>.<version>`.
- **CDrus Expression** (or **Expression**): An identity-bound declarative unit defined by `expression.schema.json` that produces an ordered sequence of CDEvents and/or sub-Expressions.
- **Identity tuple**: The ordered triple `(group, author, expression)` that uniquely identifies a CDrus Expression. The tuple is indivisible: all three components are required, order is significant, and the combination is treated as a single addressable identity.
- **Group**: Organizational unit within an enterprise. The first component of an Expression's identity tuple.
- **Author**: The engineer (or service account) whose intent the Expression encodes. The second component of an Expression's identity tuple.
- **Workflow**: A document conformant to `workflow.schema.json` that carries its own required `(group, author)` identity, references one or more Expressions by identity, and supplies tool bindings. The workflow's `(group, author)` is the default context against which abbreviated Expression references resolve; the workflow's `id` is its unique handle.
- **Chain**: The ordered set of CDEvents sharing a common `chainId`, representing a single execution thread of intent.
- **Spawned chain**: A new chain an event triggers. It has its own `chainId` and is linked back to the spawning event by a CDEvents RELATION link of kind TRIGGER. Every spawned chain is one of two kinds — **Blocking** or **Detached** — distinguished by a single bit: whether the spawning chain waits on it. Declared by an event's `spawn` or `detach` array (§4.7, §4.8).
- **Blocking spawned chain**: A spawned chain the spawning chain **waits** on: the spawning chain cannot reach completion until every chain it spawned this way has completed. Declared by an event's `spawn` array (§4.7).
- **Detached spawned chain**: A spawned chain the spawning chain does **not** wait on: the spawning event's next sibling fires immediately and the spawning chain's completion is not gated on it. Declared by an event's `detach` array (§4.8).
- **Concurrent** (*concurrently*): the run-time condition of two or more spawned chains being live at once. It is an **emergent property** of the resolved tree — declaring several spawned chains (via `spawn`, `detach`, or both) makes them concurrent — not a distinct kind of chain and not a keyword. Sibling Blocking spawned chains are the usual way it arises.
- **Chain item**: An element of a `produces`, `spawn`, or `detach` list that is itself one step on a single chain: an event item or an expression reference. (A spawned chain, by contrast, is a nested list of chain items; see §4.7.)
- **Resolution**: The process of taking an Expression or Workflow and recursively expanding all sub-Expression identity references into a concrete event sequence.

---

## 4. CDrus Expressions

### 4.1 Overview

A CDrus Expression declares an intent — `build`, `deploy`, `verify`, `build-deploy` — by listing the CDEvents (and/or sub-Expressions) that together fulfill that intent. An Expression is:

- **Identified**: by the tuple `(group, author, expression)`. The identity is the commitment.
- **Composable**: `produces` items may reference other Expressions by identity.
- **Tool-agnostic**: no field in the Expression schema names a tool, source URI, or pipeline.
- **Ordered**: `produces` is an array, and order is semantically significant for sequential items (§4.6). Sibling spawned chains (§4.7) run concurrently, so order among the spawned chains themselves is not significant.
- **Owned**: the `author` component of the identity binds the Expression to the engineer responsible for what its name commits to and for exception handling.
- **Hinting**: CDEvent subjects appearing in the name declare what the Expression is expected to produce (§4.1.1).

A minimal Expression:

```yaml
group: payment-engineering
author: mchen
expression: change-request
description: A change has been created and merged.
produces:
  - event: dev.cdevents.change.created
  - event: dev.cdevents.change.merged
```

The canonical file naming pattern is `<group>.<author>.<expression>.expression.yaml`:

```
payment-engineering.mchen.change-request.expression.yaml
```

#### 4.1.1 Name Hints — CDEvent Subjects as Keywords

An Expression's `produces` array declares the events it expects to produce. CDEvent subjects are **reserved keywords** in the `expression` token: a subject is a **hint** when it appears as a complete token, delimited by a hyphen or by the start or end of the name, as the whole name (`build`), leading (`build-…`), trailing (`…-build`), or interior (`…-build-…`). A hint tells the consumer what to expect of the Expression and constrains its declaration:

- If the subject has a clear **beginning and ending predicate** in its CDEvents definition (e.g. `build`: `started` … `finished`), the `produces` array **MUST** contain **both** the beginning and the ending event. Pre-state or intermediate predicates such as `queued` are permitted but not required.
- If the subject has **no** clear beginning/ending pair such as a flat predicate set (e.g. `artifact`: `packaged` / `signed` / `published` / …) — the `produces` array **MUST** contain **at least one** event of that subject.

Beginning and ending predicates are taken from the subject's CDEvents predicate definitions; CDrus introduces no separate classification. A name containing no subject keyword carries no hint (`my-favorite-expression` constrains nothing). Hints are a **floor, not a ceiling**: a hinted Expression **MAY** contain any additional events its name does not mention. A name **MAY** carry multiple hints, each enforced independently. Substring occurrences that are not delimited tokens are not hints, `rebuild` and `buildpack` do not trigger the `build` hint. The check is static, against `produces`, at publication or load.

### 4.2 Naming Rationale: Workflow Segment → CDrus Expression

Issue #253 proposed the term *Workflow Segment*. This RFC supersedes that term with *CDrus Expression* for three reasons:

1. **Grammatical accuracy.** A "segment" implies a piece of a larger pre-existing whole. The construct defined here is generative: it produces a sequence of events. In linguistic terms, it is an expression; a unit that evaluates to a value. The schema treats it as such (identified, referenceable, composable by name).
2. **Composition closure.** Segments do not compose with segments. Pieces of a thing do not contain other pieces of that thing without paradox. Expressions compose with expressions without grammatical strain. The schema's `expression_item` reference (§4.5) reads naturally; an equivalent "segment of a segment" reading does not.
3. **Three-pillar coherence.** Naming the grammar pillar *CDrus Expressions* parallels naming the vocabulary pillar *CDEvents*. The naming surface advertises the architecture.

The semantic content of the original proposal is preserved. Implementations migrating from a #253-style "segment" need only update the keyword and supply the `(group, author, expression)` identity tuple.

### 4.3 Expression Schema (summary)

The complete schema is reproduced in Appendix A. Top-level required fields:

| Field        | Type             | Required | Description                                                      |
| ------------ | ---------------- | -------- | ---------------------------------------------------------------- |
| `group`      | string (pattern) | Yes      | Group component of the identity tuple                            |
| `author`     | string (pattern) | Yes      | Author component of the identity tuple                           |
| `expression` | string (pattern) | Yes      | Expression component of the identity tuple                       |
| `description`| string           | No       | Human-readable intent description                                |
| `produces`   | array (≥ 1)      | Yes      | Ordered productions: event items and/or expression references (chain items) |

The top-level `produces` holds chain items only (event items and expression references); spawned chains attach to an event via `spawn` or `detach`. Each item is one of two structurally distinct object forms:

**Event item** (`event_item`):

| Field              | Type             | Required | Description                                              |
| ------------------ | ---------------- | -------- | -------------------------------------------------------- |
| `event`            | string (pattern) | Yes      | CDEvent type (see §6 for resolution forms)               |
| `event_schema_uri` | string (URI)     | No       | Pointer to the event's JSON Schema                       |
| `produces`         | array (≥ 1)      | No       | Same-chain children fired depth-first before this event's next sibling; never spawns a chain |
| `spawn`            | array (≥ 1)      | No       | Blocking spawned chains this event triggers; the spawning chain waits (see §4.7) |
| `detach`           | array (≥ 1)      | No       | Detached spawned chains this event triggers; not awaited (see §4.8) |
| `as`               | string           | No       | Metadata anchor for the event                            |

**Expression reference** (`expression_item`):

| Field        | Type             | Required | Description                                                                 |
| ------------ | ---------------- | -------- | --------------------------------------------------------------------------- |
| `expression` | string (pattern) | Yes      | Path-style identity reference: `name`, `author/name`, or `group/author/name` |

**Spawned chain** (`spawned_chain`): a nested list (array) whose elements are chain items, forming an ordered sub-sequence that runs on its own chain. It is not a `produces` item; it appears only inside an event's `spawn` (Blocking) or `detach` (Detached) array — in the nested form, one spawned chain per nested list (§4.7, §4.8). It carries no keyword of its own; the construct is the nested list, structurally distinct from the two object forms above by being an array.

Expression references **MUST NOT** carry `produces`, `spawn`, or `detach`; those properties belong to the events declared inside the referenced Expression's own definition. This constraint is enforced by `additionalProperties: false` on `expression_item` and prevents call-site mutation of grammar.

### 4.4 Identity Semantics

The identity of an Expression is the ordered tuple `(group, author, expression)`. The identity **MUST** be expressed as a tuple: implementations **MAY** represent it using language-native structures (immutable records, objects, dictionaries), but the semantic invariants, completeness of all three components, fixed order, and indivisibility, **MUST** be preserved.

The identity is a commitment, not an enforced contract over an Expression's behavior. It records *who* (`group`, `author`) expects *what* (the events the name's hints declare, §4.1.1). Expressions do not carry versions. Because hints are a floor, the rules for changing identity are asymmetric:

- **Adding** events to `produces` never changes identity. An Expression **MAY** declare more than its name hints at, at any time. Adding deployment steps to a `build` Expression does **not** require a new name.
- **Removing** events from `produces` changes identity **only if** the removal leaves a name hint unsatisfied. The declaration would no longer contain what its own name hints. Removing the build events from a `build` Expression breaks the `build` hint and **REQUIRES** a new `expression` token whose hints the remaining events satisfy. A removal that leaves every hint satisfied preserves identity.
- Identity change driven by ownership, author departure and/or group restructure, changes the `author` or `group` component and is governed separately; it is not a content concern.

References to Expressions use path-style identity notation:

| Form                                  | Meaning                                                       |
| ------------------------------------- | ------------------------------------------------------------- |
| `build`                               | Same group, same author as the referring Expression           |
| `mchen/build`                         | Same group as the referrer; explicit author                   |
| `payment-engineering/mchen/build`     | Fully qualified identity                                      |

The processing service resolves abbreviated references against the current processing context. All three components of an identity follow the same lowercase-hyphen pattern: `^[a-z][a-z0-9-]*$`.

The identity is a consistent addressing key. The store **MUST** hold at most one definition per `(group, author, expression)`, so that references resolve unambiguously and the same tuple always names the same Expression. Consistency and uniqueness are all that resolution requires of an identity; whether `group` or `author` correspond to any real team or principal is not the language's concern and does not affect resolution.

The Expression store (out of scope for this RFC) **SHOULD** track changes to Expressions over time as an audit log keyed by identity. Consumers see the current state of an Expression at its identity; historical states are recoverable from the audit log but are not part of the resolution contract.

### 4.5 Composition

An Expression composes by referencing another Expression in its `produces` list. References resolve recursively at resolution time, with each reference expanded in-place. For example:

```yaml
group: payment-engineering
author: mchen
expression: build-deploy
description: Pipeline that builds then deploys.
produces:
  - event: dev.cdevents.pipelinerun.queued
  - event: dev.cdevents.pipelinerun.started
  - expression: build
  - expression: deploy
  - event: dev.cdevents.pipelinerun.finished
```

After resolution, each `expression: build` and `expression: deploy` reference is replaced by the body of the resolved Expression's `produces` array, at that position, depth-first. Because no group or author is qualified on those references, both resolve within the same `(payment-engineering, mchen)` context as the referring Expression.

Cross-group composition uses the fully qualified form:

```yaml
group: payment-engineering
author: mchen
expression: build-and-archive
produces:
  - expression: build
  - expression: data-platform/jpatel/artifact-archive
```

Circular references **MUST** be detected by the resolver and rejected. The Expression store **SHOULD** detect cycles at publication time.

### 4.6 Depth-First Production Order

Order within `produces` is significant. When an event item carries its own nested `produces`, the production order is **depth-first**:

> A parent event fires. All its nested descendants fire (recursively, depth-first). Only then does the parent's next sibling fire.

This is the semantic difference between:

```yaml
produces:
  - event: A
    produces:
      - event: A.1
      - event: A.2
  - event: B
```

and a flat list `[A, A.1, A.2, B]`. The nested form declares that `A.1` and `A.2` are caused by `A`; the flat form declares only that they follow `A` in time. Depth-first nesting is the mechanism by which causal structure (the parent-child relationship between CDEvents within a chain) is expressible at the Expression level.

All events produced by depth-first nesting share the parent's `chainId`. Causal links between parent and children are represented by CDEvents context links per the CDEvents core specification.

Depth-first nesting expresses **sequential** causation: each nested child runs after the previous, all on the parent's `chainId`. When a parent causes children that run **in parallel** rather than in sequence, spawn a Blocking chain (§4.7); when it causes children the parent does **not** wait on, spawn a Detached chain (§4.8).

### 4.7 Blocking Spawned Chains (`spawn`)

An event item **MAY** carry a `spawn` array, declaring one or more **Blocking spawned chains** — chains the spawning chain **waits** on. A conformant loader MUST reject a document with duplicate mapping `spawn` keys rather than inherit parser-specific behavior. The array takes one of two forms, mirroring `detach` (§4.8):

- **Single chain (flat form).** An array of chain items declares **one** spawned chain: its items form a single ordered sub-sequence, running in declared order on one chain.
- **Multiple chains (nested form).** An array of nested lists declares one spawned chain **per nested list**. Each nested list is an ordered sub-sequence on its own chain.

The two forms **MUST NOT** be mixed within one `spawn` array. Every spawned chain receives its own `chainId` and a `RELATION` link of kind `TRIGGER` from the spawning event to the chain's first event. Because the chain is *Blocking*, the spawning chain **waits**:

- The spawning event's next sibling does not fire, and the spawning chain does not reach completion, until **every** chain spawned here has completed.
- There is **no join**. The spawned chains' events are themselves the output; the spawning chain's completion is simply gated on theirs. No synthetic join event is emitted, and no result is merged.

`spawn` carries no per-chain keyword beyond itself; a spawned chain is the nested list (or, in the flat form, the single sequence). When two or more spawned chains are live at once they run **concurrently** — concurrency is that emergent run-time condition (§3), not a distinct construct or keyword. Sibling spawned chains whose event sequences are identical are legal and expected, and are disambiguated by their distinct `chainId`s, not by content. (Two parallel test-case runs under one suite emit the same `testcaserun.*` types concurrently; distinct chains are what make them individually trackable.)

Example: two test cases run concurrently under a suite, and the suite does not finish until both complete:

```yaml
group: quality-engineering
author: msommer
expression: verify
description: A suite that runs two test cases in parallel.
produces:
  - event: dev.cdevents.testsuiterun.queued
  - event: dev.cdevents.testsuiterun.started
    spawn:
      - - event: dev.cdevents.testcaserun.queued
        - event: dev.cdevents.testcaserun.started
        - event: dev.cdevents.testcaserun.finished
      - - event: dev.cdevents.testcaserun.queued
        - event: dev.cdevents.testcaserun.started
        - event: dev.cdevents.testcaserun.finished
  - event: dev.cdevents.testsuiterun.finished
```

The two chains spawned under `testsuiterun.started` run independently. `testsuiterun.finished` does not fire, and the parent chain does not complete, until both spawned chains have completed.

### 4.8 Detached Spawned Chains (`detach`)

An event item **MAY** carry a `detach` array, declaring **Detached spawned chains** — work the spawning chain does not wait for. A conformant loader MUST reject a document with duplicate mapping `detach` keys rather than inherit parser-specific behavior. The array takes one of two forms:

- **Single chain (flat form).** An array of chain items declares **one** detached spawned chain: its items form a single ordered sub-sequence, running in declared order on one chain.
- **Multiple chains (nested form).** An array of nested lists declares one detached spawned chain **per nested list**, mirroring `spawn` (§4.7). Each nested list is an ordered sub-sequence on its own chain.

The two forms **MUST NOT** be mixed within one `detach` array: each chain is declared separately, and declared uniformly.

Every detached spawned chain is its own chain, with its own `chainId`; a CDEvents `RELATION` link of kind `TRIGGER` is created from the spawning event to the first event of the chain; and the spawning event's next sibling fires **immediately** — the spawning chain does not wait for any detached chain to complete.

The motivating use case: a build event triggers a downstream notification pipeline that runs asynchronously and whose completion is not gating. Without an explicit `detach` declaration, that downstream chain is orphaned: tied to its parent by no declared relation and claimed by no expectation, it falls outside the expected graph entirely.

`detach` is the **not-awaited** counterpart of `spawn` (§4.7). The two are structurally symmetric — both declare spawned chains in the same flat-or-nested form, each on its own chain with a `RELATION` link back to the spawning event — and differ only in the single bit of whether the spawning chain's completion is gated on them: `spawn` waits, `detach` does not.

Example:

```yaml
group: payment-engineering
author: mchen
expression: build-store-notify
produces:
  - event: dev.cdevents.build.finished
    detach:
      - - event: dev.cdeventsx.mytool-notification.dispatched
        - expression: data-platform/jpatel/artifact-store
      - - expression: bac/wjones/stakeholder-notifier
        - expression: bac/wjones/change-request
  - event: dev.cdevents.pipelinerun.finished
```

Here there are **two detached spawned chains**. The first runs the notification dispatch and then the cross-group `data-platform/jpatel/artifact-store` Expression, in declared order, on one chain; the second runs the compliance notification and the `bac/wjones/change-request` Expression on a second chain. The `pipelinerun.finished` event fires immediately after `build.finished`, waiting for neither chain. The cross-group references use fully qualified identities because the referenced Expressions live outside the referring Expression's group.


### 4.9 Named Event Anchors (`as:`)

Within a resolved tree, the same event type routinely occurs at more than one
position, identical sibling spawned chains (§4.7) are legal, and composition
reproduces a sub-Expression's events at every reference site (an Expression that
references `verify` beneath both `build` and `deploy` resolves to two
`testcaserun.finished` events). Addressing an event purely by position is both
brittle (an inserted upstream event renumbers everything after it) and unable, on
its own, to name a recurring event stably.

An event item **MAY** carry an optional **`as:`** field, an author-given anchor
that labels the event:

```yaml
produces:
  - event: dev.cdevents.testsuiterun.started.0.3.0
  - event: dev.cdevents.testcaserun.finished.0.3.0
  - event: dev.cdevents.testsuiterun.finished.0.3.0
    as: suite-done
```

An anchor name **MUST** match the identity token charset `^[a-z][a-z0-9-]*$` (the
same charset as an identity component), so it cannot collide with the selector
operators of §6.3. A reference to an anchor is written with a leading `@`
(`@suite-done`); the bare token written after `as:` is the anchor's declared name.

**Declaration vs. reference.** An anchor is *declared* where an event is authored
and *referenced* where an event is consumed:

- The **authoritative declaration point is the resolution root**. When a
  **Workflow** is the root (§5) — the common case — its author sees the whole
  resolved tree and labels the specific events to expose, via `as:` on the
  Workflow's own event items; an `as:` appearing inside a referenced Expression
  is permitted, reused verbatim, and carried through resolution, becoming
  authoritative under that Workflow root. When an **Expression** is resolved
  top-level with no Workflow (§6.2), its own `as:` anchors are authoritative for
  that resolved tree. Authority attaches to the root of resolution, not to the
  reference site.
- A **subscription references anchors; it does not declare them.** A consumer
  selects by anchor (`@suite-done`, §6.3); it never introduces a new anchor at
  read time. Naming is an authoring act, addressing is a reading act, and the two
  do not cross.

The same `as:` in a Workflow is authoritative because the Workflow is the
resolution root — here labeling the suite's completion for consumers to select as
`@suite-done`:

```yaml
workflow:
  id: nightly-verify
  group: quality-engineering
  author: msommer
  name: Nightly Verify
  cdrus:
    version: 0.1.0
  produces:
    - expression: verify
    - event: dev.cdevents.testsuiterun.finished
      as: suite-done
```

**Anchors need not be unique; a reference resolves to a list.** An anchor is a key
into a reference dictionary over the resolved tree: a reference to `@name`
resolves to the **list of every event carrying that anchor**, in resolved-tree
(depth-first) order — an **empty list** when none carry it, a one-element list in
the common single-target case, and a longer list when the anchor legitimately
recurs (the same sub-Expression used twice; the same suite run in parallel). The
behavior is **total and uniform**: a reference always resolves to a list, so a
consumer never has to distinguish "one" from "many," and the resolver needs no
position-qualifying or de-duplication machinery. Anchors thus carry the same
set-valued semantics as the type selectors of §6.3: a *named* subset rather than
a *typed* one. Anchors share a **single flat namespace** over the resolved tree: a
reference gathers every carrier regardless of which composed Expression declared
it, so unrelated anchors that happen to share a name are indistinguishable by name
alone — a consumer that must separate them scopes the reference with a §6.3
ancestor path (`deploy @name`). This is a deliberate consequence of the total,
uniform list model.

`as:` is **pure intent metadata**: it does not affect event production, ordering,
versioning, or chain assignment; a declaration with or without `as:` produces
identical events. It is additive and backward-compatible — its absence is exactly
today's behavior.

---

## 5. CDrus Workflow

### 5.1 Overview

A Workflow is the binding layer between Expressions and execution. Where an Expression is pure intent, a Workflow declares:

- Its own required `(group, author)` identity — the same first two components as an Expression's tuple — establishing ownership and the default resolution context for abbreviated Expression references
- Which Expressions are invoked, addressed by identity
- What tool, source, and pipeline are bound to each event
- Per-event content payload overrides
- Workflow-wide defaults

A Workflow is the document an orchestrator consumes to run a concrete pipeline.

### 5.2 Workflow Schema (summary)

The complete schema is reproduced in Appendix B. Top-level structure:

```yaml
workflow:
  id: <unique identifier>
  group: <group identity>
  author: <author identity>
  name: <human-readable name>
  cdrus:
    version: <schema version targeted>
    metadata: { ... }            # optional free-form
  defaults:                       # optional, applied to every event
    tool: <tool name>
    source: <URI>
    pipeline: <pipeline name>
    timeout_ms: <number>
    min_wait_ms: <number>
  produces:                       # ordered, same shape as Expression.produces
    - event: dev.cdevents...
      tool: ...
      source: ...
      pipeline: ...
      content: { ... }
      produces: [ ... ]
      spawn: [ ... ]
      detach: [ ... ]
    - expression: payment-engineering/mchen/build
      tool: jenkins
      source: https://jenkins.example.com
      overrides:
        dev.cdevents.build.started:
          tool: tekton
          content: { trigger: manual }
    - event: dev.cdevents...
      as: targeted-event       
```

A Workflow `produces` item may be an event item or an expression reference — the same chain-item forms as an Expression's `produces` (§4.3); an event may attach Blocking (`spawn`) or Detached (`detach`) spawned chains. Spawned chains carry the same semantics in a Workflow as in an Expression.

### 5.3 Defaults

The optional `defaults` block applies its fields to every event node in the Workflow that does not specify them explicitly. This eliminates repetition in workflows where most events share a tool or source. Defaults **MUST NOT** override values explicitly set on an event or in an expression `override` block.

Among the defaults, `timeout_ms` and `min_wait_ms` are set by the Workflow declarer, the pipeline owner, and express how long to wait for an expected event and the minimum interval before it is expected. Timing is the declarer's to set, because the pipeline owner is the party positioned to know it.

### 5.4 Expression References and Overrides

A workflow's `produces` item may be an expression reference. The reference uses the same path-style identity notation as in §4.4 (`name`, `author/name`, `group/author/name`). Abbreviated references resolve against the workflow's own `(group, author)`: `build` resolves to `(workflow.group, workflow.author, build)` and `mchen/build` to `(workflow.group, mchen, build)`, before any fully qualified lookup.

Expression references in a Workflow **MAY** carry:

| Field        | Description                                                                                                 |
| ------------ | ----------------------------------------------------------------------------------------------------------- |
| `tool`       | Applies the named tool to every event in the resolved Expression                                            |
| `source`     | Applies the source URI to every event in the resolved Expression                                            |
| `pipeline`   | Applies the pipeline name to every event in the resolved Expression                                         |
| `timeout_ms` | Applies a wait duration to every event in the resolved Expression                                           |
| `min_wait_ms`| Applies a minimum-wait interval to every event in the resolved Expression                                   |
| `overrides`  | Map of event-type → `{ tool, source, pipeline, content, timeout_ms, min_wait_ms }` for per-event binding, including per-event timing |

The `overrides` mechanism is the answer to the "different tools for different steps of a composite" use case. A `build-deploy` reference can be bound such that `build.*` events route to Jenkins and `deployment.*` events route to Spinnaker, without touching the Expression definition.

### 5.5 Workflow as the Tool-Binding Layer

This separation, Expressions are tool-agnostic and Workflows bind tools, addresses `@thompson-tomo`'s concern in #253 about tool substitutability. To swap Jenkins for Tekton in a given pipeline, the user changes one line of one Workflow. The Expression graph is untouched. No Expression in the store needs to know that Tekton exists.

This is also the answer to `@afrittoli`'s observation that producers may not always be made compliant with segments. Producers emit raw CDEvents in whatever form their tool natively supports. The Workflow binds the producer's tool identity to each event so that the consumer (orchestrator, policy engine, observability layer) can match emitted events to declared Expression identities and reason in expression terms. Compliance lives on the consumer side; binding lives in the Workflow; intent lives in the Expression.

---

## 6. Event Type Resolution

### 6.1 Syntactic Forms

The `event` field in an event item accepts four syntactic forms:

| Form                                              | Meaning                                  |
| ------------------------------------------------- | ---------------------------------------- |
| `dev.cdevents.build.started.0.3.0`                | Canonical embedded-version, exact match  |
| `dev.cdevents.build.started:0.1.1`                | Colon form, exact match (equivalent)     |
| `dev.cdevents.build.started`                      | No version resolves to latest available  |
| `dev.cdevents.build.started:^0.1.0`               | Colon-separated semver range             |

CDEvents themselves are versioned by the CDEvents specification. This is distinct from CDrus Expression identity, which is unversioned. Event-type version resolution is a CDEvents concern preserved unchanged from issue #253's original treatment. The canonical and colon forms are equivalent and resolve identically. Linters **MAY** normalize between them.

Extended event types are referenced by their full extended type string, e.g., `dev.cdeventsx.mytool-build.started.0.2.0`. How extended event types or other CDEvent extension mechanisms are created and/or implemented is out of scope for this RFC; this RFC only specifies that the `event` field accepts strings matching the pattern declared in `expression.schema.json`.

### 6.2 Resolution Algorithm

The recommended resolution algorithm for a top-level Expression or Workflow:

1. **Parse** the document against the appropriate schema.
2. **Cycle-check** the graph of expression references.
3. **Resolve identity references** by looking up each `expression_item` in the Expression store, expanding abbreviated forms against the current processing context.
4. **Recursively expand** each resolved Expression by substituting its `produces` body in-place.
5. **Resolve event versions** by looking up each `event` string against the CDEvents catalog, applying range matching where present.
6. **Build the production plan** from the resolved tree, preserving depth-first order (§4.6). Spawned chains — Blocking (§4.7) and Detached (§4.8) — are **not** linearized into the spawning chain's single sequence; each becomes its own chain, so the plan is a set of related chains rather than one linear list. Blocking spawned chains additionally gate the spawning chain's completion; detached spawned chains do not.
7. **Apply Workflow bindings** (defaults, expression-level tool/source/pipeline, event-level overrides) to each event in the plan.

Resolution failure modes a conformant implementation **MUST** report:

- Unknown identity (no Expression definition exists for the referenced tuple)
- Duplicate mapping keys
- Circular Expression reference
- Unknown CDEvent type
- Conflicting binding (a value set in both `defaults` and a non-override location)

### 6.3 Event Selectors *(informative)*

§6.2 resolves an Expression to an ordered tree of concrete events. To address a specific event, or a set of events, within that tree, this section recommends a query surface. It is **informative**: the normative addressing primitives are the §4.9 anchor and an event's position in the resolved tree; selectors are an ergonomic surface over those primitives.

#### 6.3.1 Selector grammar

A **selector** is a query that resolves, against the resolved tree, to a (possibly empty) **set** of events. The recommended grammar is `[scope] target [occurrence]`:

| Part         | Meaning                                                                                                  |
| ------------ | -------------------------------------------------------------------------------------------------------- |
| `target`     | a CDEvent type (the forms of §6.1), or @anchor, a §4.9 named anchor, resolving to the events carrying it |
| `scope`      | an ancestor Expression-name path (`deploy`, `deploy/verify`) restricting matches to that subtree         |
| `occurrence` | a positional pseudo-class over the matched set, in resolved-tree (depth-first) order: `:first`, `:last`, `:nth(k)`, `:odd`, `:even`, `:nth(an+b)` |

| Selector              | Resolves to                                              |
| --------------------- | -------------------------------------------------------- |
| `build.finished`      | every `build.finished` in the tree (the whole set)       |
| `build.finished:odd`  | the 1st, 3rd, 5th… in depth-first order                  |
| `build.finished:nth(3)` | only the 3rd                                           |
| `deploy build.finished` | only `build.finished` under the `deploy` sub-Expression |
| `@suite-done`         | the list of events carrying the suite-done anchor (§4.9) |

A bare type selects **all** matching occurrences in the tree. Because the resolved tree is fully determined (§6.2), a selector resolves to a determinate set of events, and its cardinality follows from the tree. Selectors are CSS-/XPath-style by deliberate analogy: a familiar query over a node tree.

#### 6.3.2 One addressing surface

Anchors (§4.9) and selectors are not competing schemes. An author writes a **selector**; an `@anchor` is one kind of target token within it. An anchor serves the named-subset end (`@suite-done`, resolving to every event that carries it, §4.9); a bare type plus occurrence serves the typed-subset/pattern end (`build.finished:odd`). Both resolve to sets, and the same surface spans both.

---

## 7. Worked Examples

### 7.1 Atomic build Expression

```yaml
group: payment-engineering
author: mchen
expression: build
description: A CI build that emits queue, start, verify, and finish.
produces:
  - event: dev.cdevents.change.created
  - event: dev.cdevents.build.queued
  - event: dev.cdevents.build.started
    produces:
      - expression: verify
  - event: dev.cdevents.build.finished
```

The `verify` reference resolves within the same `(payment-engineering, mchen)` context. The nested `verify` runs depth-first after `build.started` and before `build.finished`, on the same `chainId`.

### 7.2 Composite build-deploy

```yaml
group: payment-engineering
author: mchen
expression: build-deploy
description: Pipeline that builds then deploys.
produces:
  - event: dev.cdevents.pipelinerun.started
    produces:
      - expression: build
      - expression: deploy
  - event: dev.cdevents.pipelinerun.finished
```

### 7.3 Workflow binding the composite to concrete tools

```yaml
workflow:
  id: payments-mobile-release
  group: payment-engineering
  author: mchen
  name: Payments Mobile Release Pipeline
  cdrus:
    version: 0.1.0
  defaults:
    source: https://ci.example.com
  produces:
    - expression: payment-engineering/mchen/build-deploy
      overrides:
        dev.cdevents.build.started:
          tool: jenkins
          content:
            trigger: scheduled
        dev.cdevents.deployment.started:
          tool: spinnaker
          content:
            strategy: blue-green
```

### 7.4 Expression with a Detached spawned chain and cross-group reference

```yaml
group: payment-engineering
author: mchen
expression: build-store-notify
produces:
  - event: dev.cdevents.build.finished
    detach:
      - event: dev.cdeventsx.mytool-notification.dispatched
      - expression: data-platform/jpatel/artifact-store
  - event: dev.cdevents.pipelinerun.finished
```

Both the `data-platform/jpatel/artifact-store` Expression and the notification dispatch run on the same chain as a single **Detached spawned chain**. The `pipelinerun.finished` event does not wait for that chain to complete. The cross-group reference uses the fully qualified identity because the referenced Expression lives outside the referring Expression's group.

### 7.5 Expression with Blocking spawned chains (concurrency)

```yaml
group: quality-engineering
author: msommer
expression: verify
description: A suite that runs two test cases in parallel, then finishes.
produces:
  - event: dev.cdevents.testsuiterun.queued
  - event: dev.cdevents.testsuiterun.started
    spawn:
      - - event: dev.cdevents.testcaserun.queued
        - event: dev.cdevents.testcaserun.started
        - event: dev.cdevents.testcaserun.finished
      - - event: dev.cdevents.testcaserun.queued
        - event: dev.cdevents.testcaserun.started
        - event: dev.cdevents.testcaserun.finished
  - event: dev.cdevents.testsuiterun.finished
```

The two nested lists under `testsuiterun.started`'s `spawn` are **Blocking spawned chains**: they run concurrently on their own chains, and `testsuiterun.finished` (and the suite chain's completion) is gated until both spawned chains complete. The two chains emit identical event sequences and are distinguished by their distinct `chainId`s. The structural position under `spawn`, not the event content, is what tells them apart. Contrast §7.4: a Detached spawned chain would let the suite finish without waiting.

---

## 8. Relationship to Existing Proposals

### 8.1 Mapping from Issue #253 Workflow Segments

| #253 Concept                  | This RFC                                                            |
| ----------------------------- | ------------------------------------------------------------------- |
| Workflow Segment              | CDrus Expression (§4)                                               |
| `segment` keyword             | `expression` keyword                                                |
| Implicit versioning           | Identity binding via `(group, author, expression)` tuple (§4.4)     |
| Flat `produces` array         | Ordered `produces` with optional depth-first nesting (§4.6)         |
| Sub-segment references        | Expression references by identity, path-style (§4.5)                |
| `required_fields` block       | Out of scope here; recommended to live on the CDEvent schemas, not the Expression |
| (not present in #253)         | Detached spawned chain: declarative fire-and-forget chains, via `detach` (§4.8) |
| (not present in #253)         | Blocking spawned chain: declarative parallel, awaited chains, via `spawn` (§4.7) |
| (not present in #253)         | Workflow schema with defaults and overrides (§5)                     |
| (not present in #253)         | Identity tuple `(group, author, expression)` as the addressing key (§4.4) |

### 8.2 `@afrittoli`'s Producer vs. Consumer Compliance Point

`@afrittoli` noted that tools producing events may not be made compliant with segments because pipeline definitions are end-user defined; tools consuming events can reason in segment terms. This RFC adopts that distinction explicitly:

- **Expressions are consumer-facing.** They describe what an orchestrator, policy engine, or observability layer expects to see.
- **Workflows are the binding surface.** They map a tool's event emissions to the consumer's expected Expression by declaring which tool produces which event.
- **Producers remain free.** A producer emits whatever CDEvents its native pipeline definition yields. The Workflow tells the consumer how to interpret that stream in expression terms.

This is the correct separation. Forcing producer-side compliance would defeat the interoperability goal of #253 by demanding behavioral change from every CI/CD tool. Consumer-side reasoning, with Workflow as the translation layer, achieves the same semantic guarantee without that demand.

### 8.3 `@thompson-tomo`'s Tools / Roles / Skills Model

`@thompson-tomo` proposed splitting the construct into separate Tool and Workflow definitions. This RFC accepts the underlying intuition and realizes it differently:

- The "Tools" surface in `@thompson-tomo`'s model is the Workflow's tool-binding (`tool`, `source`, `pipeline`, `overrides`).
- The "Roles" surface is the Expression itself, an identity-bound unit of intent that a tool can fulfill.
- The "Skills" surface (a tool advertising which roles it can perform) is **not** in scope for this RFC. It is a discovery concern. It could be a separate, complementary spec; nothing in CDrus Expressions or Workflows precludes it.

This RFC's position: the grammar layer (Expression + Workflow) is the minimum coherent unit to standardize first. A discovery layer can be built on top once the grammar is stable.

---

## 9. Security Considerations

### 9.1 Provenance and Chain Identity

CDEvents provides `chainId` as a unique workflow tracking identifier; this RFC inherits it. As cryptographic provenance mechanisms for CDEvents (e.g., DSSE-signed events) are adopted, implementations of CDrus Expressions and Workflows **SHOULD** preserve such provenance signals through orchestration. Three considerations apply:

- **Spawned chains**, both Detached (§4.8) and Blocking (§4.7), receive their own `chainId`. The `RELATION` link of kind `TRIGGER` back to the spawning event **MUST** be preserved through any downstream event store, for every spawned chain. Loss of the relation link is loss of observability for the declared chain, and, for a Blocking spawned chain, loss of the linkage on which the spawning chain's completion gate depends.
- **Resolved Expression identities** become part of the workflow's logical provenance. Implementations **SHOULD** record the resolved `(group, author, expression)` tuple alongside the chain, so that auditors can determine which Expression's intent, and which author's commitment, was being executed when an event was emitted.
- **Identity transitions** (an Expression being replaced with new content under the same identity) **SHOULD** be recorded in an audit log, with the resolved tuple plus a content hash captured at execution time, so that historical executions remain attributable to the specific Expression content that ran.

### 9.2 Identity and Expression Trust

CDrus treats identity as a consistent addressing key, not a verified credential: the language does not check that `group` or `author` correspond to real principals, and resolution does not depend on it. The following are therefore deployment concerns, not language requirements:

- **Who may publish under an identity.** A deployment that wants authorship to be accountable controls, through its own identity and authorization systems, who may create or modify Expressions under a given `(group, author)`. The language neither enforces nor relies on this.
- **Integrity of Expression content.** Independent of identity, a consumer relies on the content under a key being stable. A deployment **SHOULD** record changes immutably and **SHOULD** let consumers pin a referenced identity to a content hash where security context demands, so that a silently mutated Expression cannot change a consumer's resolved meaning without detection.

Both are governance the deployment provides; neither is part of the CDrus language or required for it to operate.

---

## 10. Compatibility Considerations

### 10.1 Backwards Compatibility with CDEvents

This RFC adds no new requirements to the CDEvents core specification. Expressions reference CDEvents by their existing type strings and use existing context fields (`chainId`, `links`). The CDEvents v0.5.x specification is sufficient as a substrate; no version bump is required to adopt CDrus Expressions.

CDrus Expressions are additive to CDEvents. A CDEvents-conformant tool that does not know about Expressions continues to function; consumers that do know about Expressions gain the ability to reason in identity-bound intent terms.

### 10.2 Schema Identifiers

The attached schemas declare `$id` URIs that use `cdrus.dev` as an example namespace. Final `$id` assignment is a governance decision for the CDEvents project; the schemas are written so that reassignment is a non-breaking structural change.

Both attached schemas are versioned **0.1.0**, with matching version-path segments (`/schemas/0.1.0/`). Versioning of subsequent revisions follows CDEvents project governance from this initial submission.

---

## 11. References

- [CDEvents Specification](https://github.com/cdevents/spec) — base vocabulary
- [cdevents/spec#253](https://github.com/cdevents/spec/issues/253) — *Enable CI/CD Interoperability Through SDLC Workflow Segments* — the originating proposal
- [Sanyika Principles of Interoperability](https://hackmd.io/@dadisi/By0YJEkWlg) — design rationale cited in #253
- [JSON Schema Draft 2020-12](https://json-schema.org/draft/2020-12/schema) — schema dialect used by the attached schemas, matching the dialect used by the CDEvents event schemas
- BCP 14 ([RFC 2119](https://www.rfc-editor.org/rfc/rfc2119), [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174)) — normative keywords

---

## Appendix A: Expression JSON Schema

The complete `expression.schema.json` accompanies this document in the same directory. The schema validates the structural rules described in §4, including the two `chain_item` forms — event item and expression reference — and the `spawned_chain` nested-list form attached to an event through its `spawn` (Blocking) or `detach` (Detached) array. The `$id` value in the attached schema is an example using `cdrus.dev` as the namespace; final `$id` assignment is per §10.2.

## Appendix B: Workflow JSON Schema

The complete `workflow.schema.json` accompanies this document in the same directory. The schema validates the structural rules described in §5. The `$id` value in the attached schema is an example using `cdrus.dev` as the namespace; final `$id` assignment and path normalization is per §10.2.

---

*End of RFC.*