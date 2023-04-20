---
title: Deployment of etcd on AWS EC2
date: 2017-04-10
---

---

_This is an adaptation of a page previously found in the Platforms section of the documentation which described etcd deployments on various platform services.
The original page was authored by [**Caleb Miles** and others](https://github.com/etcd-io/etcd/commits/6c08437ec330f84f78a59f7772884c7ef5374247/Documentation/platforms/aws.md)._

---

This post provides an introduction to design considerations when designing an etcd deployment on AWS EC2 and how AWS specific features may be utilized in that context.
Also, this post assumes operational knowledge of Amazon Web Services (AWS), specifically Amazon Elastic Compute Cloud (EC2).

#### Table of Contents

* [Capacity Planning](#capacity-planning)
* [Cluster Design](#cluster-design)
* [Availability](#availability)
* [Data durability after member failure](#data-durability-after-member-failure)
* [Performance/Throughput](#performancethroughput)
* [Network](#network)
* [Disk](#disk)
* [Self-healing](#self-healing)
* [Next Steps](#next-steps)

## Capacity Planning

As a critical building block for distributed systems it is crucial to perform adequate capacity planning in order to support the intended cluster workload.
As etcd is a highly available and strongly consistent data store, so increasing the number of nodes in an etcd cluster will generally affect performance adversely.
This makes sense intuitively, as more nodes means more members for the leader to coordinate state across.
The most direct way to increase throughput and decrease latency of an etcd cluster is allocate more disk I/O, network I/O, CPU, and memory to the cluster members.
In this scenario, it is impossible to temporarily divert incoming requests to the cluster, though scaling the EC2 instances which comprise the etcd cluster members one at a time may improve performance.
It is, however, best to avoid bottlenecks through capacity planning.

The etcd team has produced a [hardware recommendation guide](../../../docs/v3.5/op-guide/hardware/) which is very useful for "ballparking" how many nodes and what instance type are necessary for a cluster.

AWS provides a service for creating groups of EC2 instances which are dynamically sized to match load on the instances.
Using an Auto Scaling Group ([ASG](http://docs.aws.amazon.com/autoscaling/latest/userguide/AutoScalingGroup.html)) to dynamically scale an etcd cluster, is not recommended for several reasons including the following:

* etcd performance is generally inversely proportional to the number of members in a cluster due to the synchronous replication which provides strong consistency of data stored in etcd.

* The operational complexity of adding [lifecycle hooks](http://docs.aws.amazon.com/autoscaling/latest/userguide/lifecycle-hooks.html) to properly add and remove members from an etcd cluster by modifying the [runtime configuration](../../../docs/v3.5/op-guide/runtime-configuration/).

Auto Scaling Groups do provide a number of benefits besides cluster scaling which include:

* distribution of EC2 instances across Availability Zones (AZs)
* EC2 instance fail over across AZs
* consolidated monitoring and life cycle control of instances within an ASG

The use of an ASG to create a self healing etcd cluster is one of the design considerations when deploying an etcd cluster to AWS.


## Cluster design

The purpose of this section is to provide foundational guidance for deploying etcd on AWS. The discussion will be framed by the following three critical design criteria about the etcd cluster itself:

* **Block device provider**: Limited to the tradeoffs between EBS or instance storage (InstanceStore)
* **Cluster topology**: Number of nodes that should make up an etcd cluster and whether these nodes should be distributed over multiple AZs
* **Managing etcd members**: Creating a static cluster of EC2 instances or using an ASG.

The intended cluster workload should dictate the cluster design.
A configuration store for microservices may require different design considerations than a distributed lock service, a secrets store, or a Kubernetes control plane.
Cluster design tradeoffs include considerations such as:

* Availability
* Sata durability after member failure
* Performance/throughput
* Self-healing

## Availability

Instance availability on AWS is ultimately determined by the Amazon EC2 Region Service Level Agreement ([SLA](https://aws.amazon.com/ec2/sla/)) which is the policy by which Amazon describes their precise definition of a regional outage.

In the context of an etcd cluster, this means that a cluster must contain a minimum of three members where EC2 instances are spread across at least two AZs in order for an etcd cluster to be considered highly available at a Regional level.

For most usecases, the additional latency that associated with a cluster spanning across Availability Zones, will introduce a negligible performance impact.

Availability considerations apply to all components of an application; if the application which is accessing the etcd cluster is only be deployed to a single Availability Zone, then it may not make sense to make the etcd cluster highly available across zones.

## Data durability after member failure

A highly available etcd cluster is resilient to member loss, however, it is important to consider data durability in the event of a disaster when designing an etcd deployment.
Deploying etcd on AWS supports multiple mechanisms for data durability. These mechanisms are:

* **Replication**: etcd replicates all data to all members of the etcd cluster.
Therefore, given more members in the cluster and more independent failure domains, the more less-likely it is that the data stored in an etcd cluster will be permanently lost in the event of a disaster.

* **Point in time etcd snapshotting**: The etcd v3 API introduced support for snapshotting clusters.
The operation is cheap enough (completing in the order of minutes) to run quite frequently and the resulting archives can be archived in a storage service like Amazon Simple Storage Service (S3).

* **Amazon Elastic Block Storage (EBS)**: An EBS volume is a replicated, network attached block device which have stronger storage safety guarantees than InstanceStore, which in turn, has a life cycle associated with the life cycle of the attached EC2 instance.
The life cycle of an EBS volume is not necessarily tied to an EC2 instance and can be detached and snapshotted independently which means that a single node etcd cluster backed by an EBS volume can provide a fairly reasonable level of data durability.

## Performance/Throughput

The performance of an etcd cluster is roughly quantifiable through latency and throughput metrics which are primarily affected by disk and network performance. Detailed performance planning information is provided in the [performance section](../../../docs/v3.5/op-guide/performance/) of the etcd operations guide.

## Network

AWS offers EC2 Placement Groups which allow the collocation of EC2 instances within a single Availability Zone which can be utilized in order to minimize network latency between etcd members in the cluster.
It is important to remember that collocation of etcd nodes within a single AZ will provide weaker fault tolerance than distributing members across multiple AZs.
[Enhanced networking for EC2 instances](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/enhanced-networking.html) may also improve network performance of individual EC2 instances.

## Disk

AWS provides two basic types of block storage: [EBS volumes](https://aws.amazon.com/ebs/) and [EC2 Instance Store](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/InstanceStorage.html).
As mentioned, an EBS volume is a network attached block device while instance storage is directly attached to the hypervisor of the EC2 host.
EBS volumes will generally have higher latency, lower throughput, and greater performance variance than Instance Store volumes.
If performance, rather than data safety, is the primary concern, then it is highly recommended that instance storage on the EC2 instances be utilized.
Remember that the amount of available instance storage varies by EC2 [instance types](https://aws.amazon.com/ec2/instance-types/) which may impose additional performance considerations.

Inconsistent EBS volume performance can introduce etcd cluster instability.
[Provisioned IOPS](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSVolumeTypes.html#EBSVolumeTypes_piops) can provide more consistent performance than general purpose SSD EBS volumes.
More information about EBS volume performance is available [from AWS](https://aws.amazon.com/ebs/details/) and also Datadog has shared their experience with [getting optimal performance with AWS EBS Provisioned IOPS](https://www.datadoghq.com/blog/aws-ebs-provisioned-iops-getting-optimal-performance/) in their engineering blog.

## Self-healing

While using an ASG to scale the size of an etcd cluster is not recommended, an ASG can be used effectively to maintain the desired number of nodes in the event of node failure.
The maintenance of a stable number of etcd nodes will provide the etcd cluster with a measure of self-healing.

## Next steps

The operational life cycle of an etcd cluster can be greatly simplified through the use of the etcd-operator.
The open source etcd operator is a Kubernetes control plane operator which deploys and manages etcd clusters atop Kubernetes.
While still in its early stages the etcd-operator already offers periodic backups to S3, detection and replacement of failed nodes, and automated disaster recovery from backups in the event of permanent quorum loss.
