<!--
---
linkTitle: "Contribution Guidelines"
weight: 20
icon: "fa-solid fa-hand-holding-heart"
hide_summary: true
toc_hide: true
description: >
    Contribution Guidelines
---
-->
<!-- markdownlint-disable-file MD013 -->
<!-- cSpell:locale en-US -->
# Contribution Guidelines

Thank you for contributing your time and expertise to CDEvents. This document describes the contribution guidelines for the project.

**Note:** Before you start contributing, you must read and abide by our **[Code of Conduct](https://github.com/cdevents/.github/blob/main/docs/CODE_OF_CONDUCT.md)**.

## Contributing prerequisites (CLA/DCO)

The project does not yet define a Contributor License Agreement or
[Developer Certificate of Origin (DCO)](https://wiki.linuxfoundation.org/dco).
By submitting pull requests submitters acknowledge they grant the
[Apache License v2](./LICENSE) to the code and that they are eligible to grant this license for all commits submitted in their pull requests.

## How to contribute

CDEvents welcomes all of contributions! We encourage you to engage with the
[CDEvents community](https://github.com/cdevents/spec/blob/main/README.md#community).

Resources for contributors:

* [Project Roadmap](/docs/roadmap)
* [Specification v0.1 Roadmap](https://github.com/orgs/cdevents/projects/1/views/1)
* [GitHub Issues](https://github.com/cdevents/spec/issues)
* [Communication Channels](https://github.com/cdevents/spec/blob/main/README.md#community)

## Overview

Documentation is published at the [CDEvents website](https://cdevents.dev) and the source for this site may be found in this [GitHub repo](https://github.com/cdevents/cdevents.dev).

The specification itself is maintained in this [GitHub repo](https://github.com/cdevents/spec) and releases are managed as git submodules under the docs folder of cdevents.dev.

## Getting set up

To contribute to the documentation, start by forking [GitHub repo](https://github.com/cdevents/cdevents.dev)

Clone a local copy of your fork with:

```bash
git clone https://github.com/your-fork/cdevents.dev
cd cdevents.dev
git submodule update --init --recursive
```

This gets you a local copy of your fork of the website, but the latest release of the specification, under `content/en/docs`.

If you want to be able to contribute to the spec itself, and see how your contributions render on the website, use the following approach:

First, move the `content/en/docs` folder to another location. A folder parallel to this repo, for example.

Fork the specification [GitHub repo](https://github.com/cdevents/spec)

Get a local copy, in another location, parallel to your local copy of the website repo above, with `git clone https://github.com/your-fork/spec`

Now, in the `content/en/docs` folder in the cdevents.dev fork, make a symbolic link to your fork of the spec folder:

```bash
 ln -svi <your path>/spec docs
 ```

 This will allow you to make changes in the spec and to render them locally for testing.

 **DO NOT commit your changes to `content/en/docs` in the cdevents.dev fork!**

Make edits to the specification in your spec fork and contribute them as PRs to the upstream repo. Please squash commits using `git rebase -i` before creating a PR.

Similarly, you can make edits to any files in the cdevents.dev fork **other than those under `content/en/docs`** and contribute as PRs to the upstream of this repo. Again, squash first, if you have multiple commits.

Under most circumstances, **you should not make any commits to cdevents.dev repo that include changes in `content/en/docs`** and you should not run any actions that update this submodule in your fork.

If you are a maintainer who is explicitly nominated to manually release changes to the spec, in the website, you must either change `content/en/docs` in your local copy to point back to the original submodule content before issuing any submodule commands locally, or create a fresh local copy of your cdevents.dev fork somewhere else on your machine for this activity.

Remember to merge PRs for the spec repo, tag them, and then update the cdevents.dev repo to point to the new release of the spec.

## Viewing your edits

Install a copy of [Hugo](https://gohugo.io) in your dev environment. You will need a version >= that specified in HUGO_VERSION in [the config](https://github.com/cdevents/cdevents.dev/blob/main/netlify.toml)

From within your local copy of your cdevents.dev fork, start the Hugo server with the following:

```bash
 hugo server --printI18nWarnings --bind 0.0.0.0 --baseURL http://<your-local-ip-address>:1313
 ```
<!-- markdownlint-disable-next-line MD034 -->
 This will allow you to browse your copy of the website at [http://localhost:1313](http://localhost:1313) and also use a phone or tablet to check mobile rendering by navigating to http://your-dev-ip-address:1313 from the device.

 Edits to the local copy of the site should be rendered automatically, but if something seems wrong, you may need to restart the server under some circumstances.

## Signing your commits

Please ensure that you cryptographically sign your commits before creating a PR. If you forget, you can use the following command to add this:

```bash
git commit -S --amend
```

## Style Guide

Style should broadly follow the [Google Style Guide](https://developers.google.com/style), as implemented within [Docsy](https://docsy.dev).

Consideration should always be given to the long-term costs of maintenance to documentation. Preference should be given to minimizing customization away from Docsy defaults, in order to simplify future upgrades. Use markdown over HTML notation, where possible, in order to simplify editing and maintenance.

Spellings should be in US English form.

Narrative pages should render in a comfortably readable form on mobile devices as a priority. It is however expected that technical specifications and schema files are most likely to be accessed from devices with larger screens, so these should be optimized for ease of comprehension on these devices.

## Audience Personas

When writing content for cdevents.dev, it is important to understand who this site is intended to serve and to ensure that the needs of each group are being addressed with appropriate information.

The primary purposes of cdevents.dev site are:

* As a "Storefront", to present what CDEvents is, in as simple, intuitive and convincing terms as possible, attracting potential users/adopters of CDEvents

* Serving as a portal for all CDEvents information needs, such as a link to the spec (with links to all supported versions), information about existing SDKs, PoCs and other CDEvents supported tools/components (i.e. CDEvents landscape)

We anticipate that the primary audiences for this site are:

* CI/CD Tool Maintainers (Vendors / FOSS project members)
* Decision-makers, evaluating CI/CD tooling
* End-User Engineers, implementing CI/CD instances
* Browsing audience, looking to understand more about best practice

Let's understand the needs of each group in more detail.

### CI/CD Tool Maintainers

As a CI/CD Tool Maintainer, I work for a commercial CI/CD Tool Vendor, or am a contributor to a FOSS project that maintains a CI/CD tool.

I am highly technical and understand the benefits of standardization and interoperability.

My primary interest is in understanding the specification so that I can implement functionality in my product correctly.

I may be a producer of events who is maintaining a CI/CD platform tool, or I may be a consumer of events who maintains an associated CI/CD product such as a metrics collection system or visualizer.

### Decision-makers

I work at an End-User organization and am currently evaluating CI/CD tooling options in order to support our transition to Continuous Delivery.

I may come from a technical or a commercial background and am at an early stage of familiarity with the challenges associated with Continuous Delivery.

I need help to understand how best to differentiate between all the tooling options available to me.

### End-User Engineers

I work at an End-User organization and am responsible for implementing our internal CI/CD instances.

I am technical and understand some of the challenges in the Continuous Delivery space but want to learn more about how CDEvents make my life easier.

### Browsing audience

I am interested in CI/CD and Continuous Delivery and am looking to understand more about best practice in this space.

I have been reading the CDF Best Practices Guide and was referred here from there. I may be more or less technical in background and would like to understand where the value in CDEvents lies for me.

## Audience Strategy

By looking at our personas, we can see that we have two basic narrative tracks that we must cater for:

* There is a highly technical subset of the audience that needs very detailed and accurate specifications
* The remainder of the audience remains to be convinced and will need a story that they can follow to their satisfaction

The priority should always be to communicate plainly to the latter, assuming minimal pre-existing knowledge, whilst providing quick access to more technical resources for the former.

CI/CD Tool Maintainers and a large proportion of the End-Customer Engineers will want to approach the site as reference documentation. For this audience, we need clear links that take them immediately to the detail, structured in such a way that they can find what they need, but also have visibility of the full scope of the information available, to help them to size the effort facing them.

The intent is for this audience to have a pleasant experience, implementing CDEvents.

Decision-makers and the browsing audience are likely not bought into the content upon first arrival, so we have perhaps ten to twenty seconds to persuade them to invest more time in order to learn what is of value to them in the content. This requires a succinct and friendly landing page that pitches a clear message above the fold. This should then expand into a non-technical narrative providing the basic concepts before leading into the detail, with the expectation that few from this audience will consume all of the information themselves.

The intent is for this audience to take away key learnings that they will use to support future decisions, and to direct others to visit to access the details.

It is additionally expected that some CI/CD Tool Maintainers and End-User Engineers will benefit from the conceptual narrative that will enable them to easily become evangelists for the CDEvents approach. CI/CD Tool Maintainers may need help in communicating to their own customers the value-add of CDEvents support in their systems. End-User Engineers are often in a situation where they have to pitch a technology to their Decision-makers to get buy-in for a given approach, so simple explanations of commercial value can be very helpful to this audience.

This strategy must extend beyond the learning journey into the community space. Once we have explained the specification to the CI/CD Tool Maintainers, this must be reinforced with a call to action to implement the spec within their product and connection to appropriate additional support and community resources to help make this as easy as possible.

For all of our audience, we would additionally like to create a call to action to become contributors themselves and to add to the shared value.

## User Journey

The primary user journey requires that we engage the reader's attention with a succinct statement of value to them on the landing page, then provide an easily navigated narrative that evidences this statement, leading into the detailed content of the specification itself. It is expected that readers will self-pace, exiting the site when they have consumed sufficient detail for their needs.

We should, therefore, provide access to community resources from each page, to allow people to connect with additional support at whatever level of detail suits their needs.

For our technical narrative track, it must be obvious how to reach the reference section of the site directly from the landing page, allowing this audience to get quickly to the detail that they require.

The specification must be unambiguous, minimizing opportunities for multiple interpretations to hold true.

It must be obvious which version of the specification is referenced in the documentation and difficult to accidentally navigate between different versions whilst browsing. The specification should therefore be sandboxed within a consistent namespace so that relative links remain within the same version by default.

The default behavior should be to direct the reader to the latest version of the specification. Links should be provided to the specification GitHub repo to access historical releases of the spec.

The landing page shall present the key statement of value and a shortcut to the reference documentation above the fold. The remainder of the narrative introduction should sit below this on the same page, with jumping off points to details. Where detail sits within the specification or other versioned reference documentation, the landing page should always reference the latest version of these resources.

The user experience should strive for simplicity, consistency and coherency. As a reference work, it should be possible to navigate forwards and backwards through the site in a predictable manner without being redirected to an unexpected point in the content.

Active page elements such as pop-ups should be avoided. There is no requirement to collect data from the reader, nor to embed advertising or promotions within the site.

## Internationalization

Versions of the cdevents.dev narrative content in other languages can be added at any time by adding a new, language-specific content root under the `content` folder in this repo and providing translated duplicates of the files found in `content/en`.

The `[languages]` section of `config.toml` should be updated as documented in [https://www.docsy.dev/docs/language/](https://www.docsy.dev/docs/language/)

UI strings are maintained in the `i18n` folder. You may need to update these if the desired language is not already supported.

In development, run `hugo server --printI18nWarnings` when doing translation work, as it will give you warnings on what strings are missing.

Translations of the specification documentation will require language-specific forks of the spec repo. The `docs` subfolder of the `content/<new language>/` folder should be linked as a git submodule to the appropriate fork. Note the need to manually maintain and synchronize the releases of translated versions of the spec.

## Versioning and Releases

Points to note:

* `main` of the spec repo is *always* a draft
* `main` of the website repo *always* the live website

There is a Releases drop-down on the main menu, which allows you to select prior versions of the specification to browse. A version indicator has been added to the root of the breadcrumb trail, so you can see which version the displayed docs relate to.

*If you are a repository maintainer, you must understand the release processes.*

For versions up to and including v1.x.x, the process to make a new release is as follows:

1. In Specification GitHub repo, merge changes to spec and tag a numbered release.
2. In cdevents.dev repo, sync docs git submodule with tagged release of spec repo.
3. In cdevents.dev repo, edit `config.toml` file. In the `[params]` section, update `version` variable to match tagged version. Edit `[[params.versions]]` section to add link to historical docs.
4. Merge and publish changes to cdevents.dev

Note that prior to a formal, semantic v1.0.0 release, historical links point to the associated tagged version of the spec repo.

From release v2.0.0 onward, the following revised process should be used:

1. In Specification GitHub repo, merge changes to spec and tag a numbered release.
2. Branch cdevents.dev repo to create a clone of the current release docs. In the netlify config, set this branch to deploy to 'v1.cdevents.dev' (or other appropriate historical version number). In `config.toml` file, in the `[params]` section, edit `archived_version` to be `true`.
3. In cdevents.dev repo, sync docs git submodule with tagged release of spec repo.
4. In cdevents.dev repo, edit `config.toml` file. In the `[params]` section, update `version` variable to match tagged version. Edit `[[params.versions]]` section to add link to historical docs.
5. Merge and publish changes to cdevents.dev

The first time this is done, you will need to edit the `[[params.versions]]` section to redirect the historical link to 'v1.cdevents.dev' version of the site instead of the spec repo tag, as currently.
