# Source Code Version Control Events

__Note:__ This is a work-in-progress draft version and is being worked on by members of the Events SIG. You are very welcome to join the work and the discussions!

This phase includes events related to changes in Source Code repositories that are relevant from a Continuous Delivery perspective.

## Repository Events

These events are related to Source Code repositories

- **Repository Created Event**: a new Source Code Repository was created to host source code for a project
- **Repository Modified Event**: a Source Code Repository modified some of its attributes, like location, or owner
- **Repository Deleted Event**: a Source Code Repository was deleted and it is not longer available
- **Branch Created Event**: a Branch inside the Repository was created
- **Branch Deleted Event**: a Branch inside the Repository was deleted

Repository Events MUST include the following attributes:

- **Event Type**: the type is restricted to include `cd.**` prefix. For example `cd.repository.created` or `cd.repository.changeapproved`
- **Repository URL**: indicates the location of the source code repository for API operations, this URL needs to include the protocol used to connect to the repository. For example `git://` , `ssh://`, `https://`
- **Repository Name**: friendly name to list this repository to users

Optional attributes:

- **Repository Owner**: indicates who is the owner of the repository, usually a `user` or an `organization`
- **Repository View URL**: URL to access the repository from a user web browser

From each repository you can emit events related with proposed source code changes. Each change can include a single or multiple commits that can also be tracked.

- **Change Created Event**: a source code change was created and submitted to a repository specific branch. Examples: PullRequest sent to Github, MergeRequest sent to Gitlab, Change created in Gerrit
- **Change Reviewed Event**:  someone (user) or an automated system submitted an review to the source code change. A user or an automated system needs to be in charge of understanding how many approvals/rejections are needed for this change to be merged or rejected. The review event needs to include if the change is approved by the reviewer, more changes are needed or if the change is rejected.
- **Change Merged Event**: the change is merged to the target branch where it was submitted.
- **Change Abandoned Event**: a tool or a user decides that the change has been inactive for a while and it can be considered abandoned.
- **Change Updated**: the Change has been updated, for example a new commit is added or removed from an existing Change

Optional attributes for **Change** Events:

- (TBD)
