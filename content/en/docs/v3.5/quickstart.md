---
title: Quick start
weight: 900
description: Get etcd up and running in less than 5 minutes!
---

## Prerequisites

Before you begin, ensure you have the following:

   1. **etcd Installed**  
      Build or download etcd from [Install][] and verify that the `etcd` binary is in your system’s PATH.
      {{% alert color="warning" %}}**Important**: Ensure that you perform the last
      step of the installation instructions to verify that `etcd` is in your path.
      {{% /alert %}}

   2. **Terminal Access**  
      You’ll need two terminal windows: one to run the etcd server and one to interact with it using `etcdctl`.

## Getting Started

Choose the workflow that best fits your role:

### Developer Workflow

**Objective:** Quickly set up a local etcd cluster for development and testing.

   1. **Set Up a Local Cluster**  
      Use our [Set up a local cluster][] page to quickly spin up an etcd instance. Follow along by first launching etcd:

      ```console
      $ etcd
      {"level":"info","ts":"2021-09-17T09:19:32.783-0400","caller":"etcdmain/etcd.go:72","msg":... }
      ⋮
      ```

      {{% alert color="info" %}}**Note**: The output produced by `etcd` are
      [logs](../op-guide/configuration/#logging) &mdash; info-level logs can
      be ignored. {{% /alert %}}

   2. **Interact with etcd**  
      In a separate terminal, run the following commands to set and retrieve a key:

      ```console
      $ etcdctl put greeting "Hello, etcd"
      OK
      ```

      ```console
      $ etcdctl get greeting
      greeting
      Hello, etcd
      ```

   3. **Explore the Developer Guide**
    Once your local cluster is running, refer to the [Developer guide][] for integration and development tips.

### Operator Workflow

**Objective:** Configure and manage an etcd cluster for production.

   1. **Install etcd**  
      Follow the detailed instructions in the [Install][] to install and configure etcd for production use.

   2. **Run and Monitor etcd**  
      Start etcd in one terminal and review the logs to confirm it’s running properly:

      ```console
      $ etcd
      {"level":"info","ts":"...","msg": "..."}
      ```

   3. **Configure and Secure etcd**  
      Check out the Operator Guide for steps on clustering, securing with TLS, and performance tuning.
   4. **Troubleshooting & Maintenance**  
      If issues arise, consult the Troubleshooting section for common problems and solutions.

## What's next?

Learn about more ways to configure and use etcd from the following pages:

- ### **Development:**

Continue with the [Developer guide][], which includes the [Set up a local cluster][] page, [API][] references, and integration examples.

- #### Explore the gRPC [API][]

- #### Find [language bindings and tools][integrations]

- ### **Operations:**

Proceed to the [Operations guide][] for advanced configuration, clustering, security, and performance tuning.

- #### Set up a [multi-machine cluster][clustering]

- #### Use TLS to [secure an etcd cluster][security]

- #### [Tune etcd][tuning]

- #### Learn how to [configure][] etcd

[api]: /docs/{{< param version >}}/learning/api
[clustering]: /docs/{{< param version >}}/op-guide/clustering
[configure]: /docs/{{< param version >}}/op-guide/configuration
[integrations]: /docs/{{< param version >}}/integrations
[security]: /docs/{{< param version >}}/op-guide/security
[tuning]: /docs/{{< param version >}}/tuning
[Install]: ../install/
