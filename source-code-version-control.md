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

This phase includes events related to changes in Source Code repositories that are relevant from a Continuous Delivery perspective.

## Repository Events

These events are related to Source Code repositories

- __Repository Created Event__: a new Source Code Repository was created to host source code for a project
- __Repository Modified Event__: a Source Code Repository modified some of its attributes, like location, or owner
- __Repository Deleted Event__: a Source Code Repository was deleted and it is not longer available
- __Branch Created Event__: a Branch inside the Repository was created
- __Branch Deleted Event__: a Branch inside the Repository was deleted

Repository Events MUST include the following attributes:

- __Event Type__: the type is restricted to include `cd.__` prefix. For example `cd.repository.created` or `cd.repository.changeapproved`
- __Repository URL__: indicates the location of the source code repository for API operations, this URL needs to include the protocol used to connect to the repository. For example `git://` , `ssh://`, `https://`
- __Repository Name__: friendly name to list this repository to users

Optional attributes:

- __Repository Owner__: indicates who is the owner of the repository, usually a `user` or an `organization`
- __Repository View URL__: URL to access the repository from a user web browser

From each repository you can emit events related with proposed source code changes. Each change can include a single or multiple commits that can also be tracked.

- __Change Created Event__: a source code change was created and submitted to a repository specific branch. Examples: PullRequest sent to Github, MergeRequest sent to Gitlab, Change created in Gerrit
- __Change Reviewed Event__:  someone (user) or an automated system submitted an review to the source code change. A user or an automated system needs to be in charge of understanding how many approvals/rejections are needed for this change to be merged or rejected. The review event needs to include if the change is approved by the reviewer, more changes are needed or if the change is rejected.
- __Change Merged Event__: the change is merged to the target branch where it was submitted.
- __Change Abandoned Event__: a tool or a user decides that the change has been inactive for a while and it can be considered abandoned.
- __Change Updated__: the Change has been updated, for example a new commit is added or removed from an existing Change

Optional attributes for __Change__ Events:

- (TBD)
