---
title: Quickstart
weight: 900
description: Get etcd up and running in less than 5 minutes!
---

Follow these instructions to locally install, run, test and set up user authentication in a single-member cluster of etcd:

 1. Install etcd from pre-built binaries or from source. For details, see
    [Install][].

    {{% alert color="warning" %}}**Important**: Ensure that you perform the last
    step of the installation instructions to verify that `etcd` is in your path.
    {{% /alert %}}

 2. Launch `etcd`:

    ```
    $ etcd
    {"level":"info","ts":"2021-09-17T09:19:32.783-0400","caller":"etcdmain/etcd.go:72","msg":"Running: ","args":["etcd"]}
    ⋮
    ```

    {{% alert color="info" %}}**Note**: The output produced by `etcd` are
    [logs](../op-guide/configuration/#logging-flags) &mdash; info-level logs can
    be ignored. {{% /alert %}}

 3. From **another terminal**, use `etcdctl` to set a key:

    ```
    $ etcdctl put greeting "Hello, etcd"
    OK
    ```

 4. From the same terminal, retrieve the key:

    ```
    $ etcdctl get greeting
    greeting
    Hello, etcd
    ```
 5. To enable the root user to authenticate new users and set up their respective roles, the root user must be created and also authenctication must be enabled by using the following commands:

    ```
    $ etcdctl user add root
    $ etcdctl auth enable
    ```
 6. To add a new user:
    ```
    $ etcdctl user add myusername
    ```
 7. To create a new role:
    ```
    $ etcdctl role add myrolename
    ```
 8. To assign or revoke a role from a user:
    ```
    $ etcdctl user grant-role myusername keyname
    $ etcdctl user revoke-role myusername keyname
    ```
    For more details on authentication and role-based access control, see [Role-based Access Control][].

## What's next?

Learn about more ways to configure and use etcd from the following pages:

- Explore the gRPC [API][].
- Set up a [multi-machine cluster][clustering].
- Learn how to [configure][] etcd.
- Find [language bindings and tools][integrations].
- Use TLS to [secure an etcd cluster][security].
- [Tune etcd][tuning].

[api]: /docs/{{< param version >}}/learning/api
[clustering]: /docs/{{< param version >}}/op-guide/clustering
[configure]: /docs/{{< param version >}}/op-guide/configuration
[integrations]: /docs/{{< param version >}}/integrations
[security]: /docs/{{< param version >}}/op-guide/security
[tuning]: /docs/{{< param version >}}/tuning
[Install]: ../install/
[Role-based Access Control]: ../op-guide/authentication/
