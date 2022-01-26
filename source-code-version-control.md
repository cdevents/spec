# Source Code Version Control Events

__Note:__ This is a work-in-progress draft version and is being worked on by members of the Events SIG. You are very welcome to join the work and the discussions!

This phase includes events related to changes in Source Code repositories that are relevant from a Continuous Delivery perspective.

## Repository Events

These events are related to Source Code repositories

- **Repository Created Event**: a new Source Code Repository was created to host source code for a project

  Example:
  ```json
  {
    "data": {
      "otherrepositorydata": "data",
      "repositoryid": "repository_id",
      "repositoryname": "Name of repository",
      "repositoryurl": "http://my-repository",
    },
    "datacontenttype": "application/json",
    "id": "15929a3b-09c9-42ee-a48d-32c17d9e8621",
    "source": "cde-cli",
    "specversion": "1.0",
    "time": "2021-07-20T13:36:12.6814715Z",
    "type": "cd.repository.created.v1"
  }
  ```

- **Repository Modified Event**: a Source Code Repository modified some of its attributes, like location, or owner

  Example:
  ```json
  {
    "data": {
      "otherrepositorydata": "data",
      "repositoryid": "repository_id",
      "repositoryname": "Name of repository",
      "repositoryurl": "http://my-repository",
    },
    "datacontenttype": "application/json",
    "id": "7bdc0e0e-a080-4da4-b709-643a8706be22",
    "source": "cde-cli",
    "specversion": "1.0",
    "time": "2021-07-20T13:36:42.2070274Z",
    "type": "cd.repository.modified.v1"
  }
  ```

- **Repository Deleted Event**: a Source Code Repository was deleted and it is not longer available

  Example:
  ```json
  {
    "data": {
      "otherrepositorydata": "data",
      "repositoryid": "repository_id",
      "repositoryname": "Name of repository",
      "repositoryurl": "http://my-repository",
    },
    "datacontenttype": "application/json",
    "id": "465d1142-5bbd-44f5-bad3-6605c5f0cb5a",
    "source": "cde-cli",
    "specversion": "1.0",
    "time": "2021-07-20T13:38:29.7678693Z",
    "type": "cd.repository.deleted.v1"
  }
  ```

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
