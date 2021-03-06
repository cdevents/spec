<!--
---
linkTitle: "Source Code Version Control Events"
weight: 40
description: >
   Source Code Version Control Events
---
-->
# Source Code Version Control Events

__Note:__ This is a work-in-progress draft version and is being worked on by members of the Events SIG. You are very welcome to join the work and the discussions!

Source Code Version Control events includes the subjects and predicates related to changes in Source Code repositories that are relevant from a Continuous Delivery perspective.

## Subjects

This specification defines two subjects in this stage: `repository` and `change`. Events associated with these subjects are triggered by actions performed by software developers or bots that provide useful automation for software developers.

| Subject | Description | Predicates |
|---------|-------------|------------|
| [`repository`](#repository) | A software configuration management (SCM)repository | [`created`](#repository-created), [`modified`](#repository-modified), [`deleted`](#repository-deleted)|
| [`change`](#change) | A change proposed to the content of a *repository* | [`created`](#change-created), [`reviewed`](#change-reviewed), [`merged`](#change-merged), [`abandoned`](#change-abandoned), [`updated`](#change-updated)|

Each `repository` can emit events related with proposed source code `changes`. Each `change` can include a single or multiple commits that can also be tracked.

### `repository`

An SCM `repository` is identified by a `name`, an `owner` which can be a user or an organization, a `url` which is where the `repository` is hosted and optionally a `viewUrl`, which is a web location for humans to browse the content of the `repository`.

| Field | Type | Description | Examples |
|-------|------|-------------|----------|
| id    | `String` | Uniquely identifies the subject within the source. | `an-org/a-repo`, `an-user/a-repo` |
| source | `URI-Reference` | [source](../spec.md#source) from the context | `my-git.example`|
| name  | `String` | The name of the `repository` | `spec`, `community`, `a-repo` |
| owner | `String` | The owner of the `repository` | `cdevents`, `an-org`, `an-user`|
| url | `URI` | URL to the `repository` for API operations. This URL needs to include the protocol used to connect to the repository. | `git://my-git.example/an-org/a-repo` |
| viewUrl | `URI` | URL for humans to view the content of the `repository`  | `https://my-git.example/an-org/a-repo/view`|

### `change`

A `change` identifies a proposed set of changes to the content of a `repository`. The usual lifecycle of a `change` The data model for `changes` is not defined yet.

| Field | Type | Description | Examples |
|-------|------|-------------|----------|
| id    | `String` | Uniquely identifies the subject within the source. | `1234`, `featureBranch123` |
| source | `URI-Reference` | [source](../spec.md#source) from the context | `my-git.example`|

## Events

### `repository created`

A new Source Code Repository was created to host source code for a project.

- Event Type: __`dev.cdevents.repository.created`__
- Predicate: created
- Subject: [`repository`](#repository)

| Field | Type | Description | Examples | Mandatory ??? \| Optional ??? |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | Uniquely identifies the subject within the source. | `an-org/a-repo`, `an-user/a-repo`, `repo123` | ??? |
| source | `URI-Reference` | [source](../spec.md#source) from the context | `my-git.example`| ??? |
| name  | `String` | The name of the `repository` | `spec`, `community`, `a-repo` | ??? |
| owner | `String` | The owner of the `repository` | `cdevents`, `an-org`, `an-user`| ??? |
| url | `URI` | URL to the `repository` | `git://my-git.example/an-org/a-repo` | ??? |
| viewUrl | `URI` | URL for humans to view the content of the `repository`  | `https://my-git.example/an-org/a-repo/view`| ??? |

### `repository modified`

A Source Code Repository modified some of its attributes, like location, or owner.

- Event Type: __`dev.cdevents.repository.modified`__
- Predicate: modified
- Subject: [`repository`](#repository)

| Field | Type | Description | Examples | Mandatory ??? \| Optional ??? |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | Uniquely identifies the subject within the source. | `an-org/a-repo`, `an-user/a-repo`, `repo123` | ??? |
| source | `URI-Reference` | [source](../spec.md#source) from the context | `my-git.example`| ??? |
| name  | `String` | The name of the `repository` | `spec`, `community`, `a-repo` | ??? |
| owner | `String` | The owner of the `repository` | `cdevents`, `an-org`, `an-user`| ??? |
| url | `URI` | URL to the `repository` | `git://my-git.example/an-org/a-repo` | ??? |
| viewUrl | `URI` | URL for humans to view the content of the `repository`  | `https://my-git.example/an-org/a-repo/view`| ??? |

### `repository deleted`

- Event Type: __`dev.cdevents.repository.deleted`__
- Predicate: modified
- Subject: [`repository`](#repository)

| Field | Type | Description | Examples | Mandatory ??? \| Optional ??? |
|-------|------|-------------|----------|----------------------------|
| id    | `String` | Uniquely identifies the subject within the source. | `an-org/a-repo`, `an-user/a-repo`, `repo123` | ??? |
| source | `URI-Reference` | [source](../spec.md#source) from the context | `my-git.example`| ??? |
| name  | `String` | The name of the `repository` | `spec`, `community`, `a-repo` | ??? |
| owner | `String` | The owner of the `repository` | `cdevents`, `an-org`, `an-user`| ??? |
| url | `URI` | URL to the `repository` | `git://my-git.example/an-org/a-repo` | ??? |
| viewUrl | `URI` | URL for humans to view the content of the `repository`  | `https://my-git.example/an-org/a-repo/view`| ??? |

### `repository branch created`

A branch inside the Repository was created.

???? The branch model is work in progress.

### `repository branch deleted`

A branch inside the Repository was deleted.

???? The branch model is work in progress.

### `change created`

A source code change was created and submitted to a repository specific branch. Examples: PullRequest sent to Github, MergeRequest sent to Gitlab, Change created in Gerrit.

???? The change model is work in progress.

### `change reviewed`

Someone (user) or an automated system submitted an review to the source code change. A user or an automated system needs to be in charge of understanding how many approvals/rejections are needed for this change to be merged or rejected. The review event needs to include if the change is approved by the reviewer, more changes are needed or if the change is rejected.

???? The change model is work in progress.

### `change merged`

A change is merged to the target branch where it was submitted.

???? The change model is work in progress.

### `change abandoned`

A tool or a user decides that the change has been inactive for a while and it can be considered abandoned.

???? The change model is work in progress.

### `change updated`

A Change has been updated, for example a new commit is added or removed from an existing Change.

???? The change model is work in progress.
