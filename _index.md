<!--
---
title: "CDEvents Documentation"
linkTitle: "Documentation"
weight: 10
menu:
  main:
    weight: 20
    pre: <i class='fas fa-book'></i>
---
-->
<!-- markdownlint-disable-file MD041 -->
<!-- cSpell:locale en-US -->
Welcome to the CDEvents specification documentation for release {{< param "version" >}}. Here, you can find all the information necessary to understand and implement CDEvents within your application. For those new to CDEvents, we recommend starting with the [White Paper](wpaper/) and the [Primer](primer/), to help you rapidly understand the concepts.

Note that CDEvents builds upon <a href="https://cloudevents.io/" target="_blank">CloudEvents</a>, so it may be helpful to have some understanding of that specification first.

To help you get up to speed quickly, we have broken the specification down into bite-sized chunks. The sections below will help you navigate to the information that you need.
<br><br>

{{% blocks/section type="section" color="white" %}}
{{% cardpane %}}
{{< blocks/feature icon="fa-solid fa-file-word" title="[White Paper](wpaper/)" >}}
The Continuous Delivery Foundation White Paper on CDEvents<br><br>
{{< /blocks/feature >}}
{{< blocks/feature icon="fa-solid fa-graduation-cap" title="[Primer](primer/)" >}}
An introduction to CDEvents and associated concepts<br><br>
{{< /blocks/feature >}}
{{< blocks/feature icon="fas fa-info-circle" title="[Common Metadata](spec/)" >}}
An overview of Metadata common across the CDEvents Specification<br><br>
{{< /blocks/feature >}}
{{< blocks/feature icon="fa-solid fa-bars-staggered" title="[Core Events](core/)" >}}
Definition of specific events that are fundamental to pipeline execution and orchestration<br><br>
{{< /blocks/feature >}}
{{< blocks/feature icon="fa-solid fa-code-branch" title="[Source Code Control Events](source-code-version-control/)" >}}
Handling Events relating to changes in version management of Source Code and related assets<br><br>
{{< /blocks/feature >}}
{{< blocks/feature icon="fa-solid fa-network-wired" title="[Continuous Integration Events](continuous-integration-pipeline-events/)" >}}
Handling Events associated with Continuous Integration activities, typically involving build and test<br><br>
{{< /blocks/feature >}}
{{< blocks/feature icon="fa-solid fa-satellite-dish" title="[Continuous Deployment Events](continuous-deployment-pipeline-events/)" >}}
Handling Events associated with Continuous Deployment activities<br><br>
{{< /blocks/feature >}}
{{< blocks/feature icon="fa-solid fa-arrow-right-arrow-left" title="[CloudEvents Binding and Transport](cloudevents-binding/)" >}}
Defining how CDEvents are mapped to CloudEvents for transportation and delivery<br><br>
{{< /blocks/feature >}}
{{< blocks/feature icon="fa-solid fa-rocket-launch" >}}
[<img src="https://raw.githubusercontent.com/cdfoundation/artwork/main/cdevents/horizontal/color/cdevents_horizontal-color.svg" alt="CDEvents logo"/>](/)
{{< /blocks/feature >}}
{{% /cardpane %}}
{{% /blocks/section %}}

