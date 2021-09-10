---
title: Kubernetes Stateful Friend - What’s more to etcd?
spelling: cSpell:ignore Hrittik
author:  "[Hrittik Roy](https://github.com/hrittikhere), p3r.one"
date: 2021-09-11
---

*This post originally appeared on [p3r.one](https://www.p3r.one/etcd-and-kubernetes/), and is re-published with permission.* 

The Kubernetes control plane consists of various components, and one of such components is etcd. Anyone starting to learn k8s come across it and memorizes quickly that it’s a key-value pair for Kubernetes with persistence store.

But, what’s more to it? Why do we need it? All these questions are pretty scattered, and in this post, we would go through them in a beginner mindset. Nothing significantly advance, just enough for you to grasp the importance, features of etcd to go forward your cloud native journey.

*Let’s start!*

## What is etcd?

etcd (pronounced “et-cee-dee” and not “e-t-c-d”) is an open source distributed key-value store for storing and managing the important data that distributed systems require to function. It is most well-known for managing the configuration, state, and metadata for Kubernetes, a popular [container orchestration](https://www.p3r.one/container-orchestration/) technology.

> etcd is named after unix’s configuration directory, “etc” and “d” istributed system

### What is key-value store?

The data model of etcd is simple, relying on keys and values rather than arbitrary data associations. When compared to [standard SQL databases](https://www.p3r.one/the-full-stack-developers-roadmap-part-3-databases/), this helps to maintain relatively predictable performance.

## etcd and Kubernetes

If you spend time looking at the [Kubernetes control plane](https://www.p3r.one/kubernetes-from-google/), you’ll notice that etcd is where Kubernetes API maintains all of the information about a cluster’s state; in fact, it’s the sole stateful (doesn’t erase state or is persistence) element of the entire control plane.

![components-of-kubernetes](../etcd-and-kubernetes/components-of-kubernetes.svg "Kubernetes Components and etcd as persistence store")

*Kubernetes Components and etcd as persistence store (Image source: [Kubernetes.io](https://kubernetes.io/docs/concepts/overview/components/))*

So, Kubernetes monitors this data and uses etcd’s “watch” function to update itself when changes occur. The “watch” function can trigger a response when the values reflecting the cluster’s actual and ideal states diverge.

## Why Kubernetes uses etcd?

There are various databases in the ecosystem, but did you wonder why etcd fits so well. The primary reason is being in the CNCF ecosystem, and it has grown well to suit Kubernetes. [CNCF tools work well with each other.](https://www.p3r.one/cncf-cloud-native-computing-foundation/) But what else?

### Distributed Database

The main advantage of combining Kubernetes and etcd is that etcd is a distributed database that works in tandem with Kubernetes clusters. As a result, using etcd with Kubernetes is critical for cluster health. The Kubernetes community has widely leveraged it to give numerous benefits for managing cluster states, enabling more automation for dynamic workloads.

### Change Notification

Clients can subscribe to changes to a specific key or set of keys using etcd. Kubernetes makes great use of change alerts, and it’s one of the feature that Kubernauts love.

### Highly Available

With three or more odd number nodes, etcd is deployed in a highly available method. The etcd cluster is made up of nodes that share nothing. One node serves as the cluster’s leader, while the others serve as followers. At run-time, the leader node is determined using Raft algorithm. This eliminates single points of failure caused by network connectivity issues, power outages, hardware failures, unanticipated maintenance, and so on.

### Reliable

etcd immediately saves a request in a log file (write-ahead log using [gpRC request](https://grpc.io/)) and then creates a snapshot file to avoid the log file growing too large. The snapshot file is sorted by order of keys and contains key-value pairs arranged by the b+ tree structure.

The etcd cluster can restore data from log files and snapshots and resume the service if it crashes or stops due to a problem.

### Reliably consistent

Each data read from etcd returns the most up-to-date information from all clusters. When a request is received, the leader node casts votes against followers. The leader commits the request and asks followers to commit if the majority of nodes agree. Any node in the cluster can receive a request from an etcd client. If a client sends a request to a follower, the request will be forwarded to a leader node.

### Speed

The key-value store is benchmarked at 10,000 writes per second, but etcd’s performance relies primarily on storage disc speed, and SSDs are strongly recommended in etcd deployments.

### Security

Etcd stores secrets from Kubernetes and other highly sensitive configuration data, and it’s needed to be secure by design.  It has some excellent built-in security at it’s core to protect the data.

***Secure Transport***

etcd supports client certificate authentication using automated [Transport Layer Security (TLS)](https://en.wikipedia.org/wiki/Transport_Layer_Security) and optional Secure Socket Layer (SSL).

![figure-2](../etcd-and-kubernetes/figure-2.png "Etcd Access with mutually authenticated TLS")

*Etcd Access with mutually authenticated TLS* 

***RBACs (Role-Based Access Controls)***

Within the deployment, etcd enables role-based access controls, ensuring that team members dealing with it have the least-privileged level of access required to do their work.

***Isolation***

etcd supports serializable isolation by [MVCC (Multi-version Concurrency Control).](https://en.wikipedia.org/wiki/Multiversion_concurrency_control)

### Simple

Using standard HTTP/JSON tools, any program, from simple web apps to extremely complicated container orchestration engines like Kubernetes, can read or write data to etcd. It’s effortless to use, and you can play with it in the virtual lab [here](http://play.etcd.io/play).

## Final Thoughts

Etcd was released even before Kubernetes, but in 2014 Google adopted the database for configuration management. They are now a perfect fit, and you might have understood with your first contact with the orchestration tool. But, one thing to point out is etcd exists without Kubernetes, and it has more application than just being a part of the control plane like in Rook and CoreDNS.

I hope you enjoyed this article, and there are a few more introductory articles like [Helm: Why DevOps Engineers Love it?](https://www.p3r.one/helm-package-manager-kubernetes/), [Service Mesh: The Gateway to Happiness](https://www.p3r.one/service-mesh/) and [Turbo-charge with Container Orchestration](https://www.p3r.one/container-orchestration/) which you might want to go through.

*Happy Learning!*