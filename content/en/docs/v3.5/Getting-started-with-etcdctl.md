---
title: Getting started with etcdctl
weight: 3250
description: "etcdctl: a command line tool for interacting with the etcd server"
---
Users mostly interact with etcd by putting or getting the value of a key. This page describes how to do that by using etcdctl, a command line tool for interacting with etcd server and also points to various links for more detailed explanations on important/advanced topics. The concepts described here should apply to the gRPC APIs or client library APIs.

The API version used by etcdctl to speak to etcd may be set to version `2` or `3` via the `ETCDCTL_API` environment variable. By default, etcdctl on master (3.4) uses the v3 API and earlier versions (3.3 and earlier) default to the v2 API.

Note that any key that was created using the v2 API will not be able to be queried via the v3 API.  A v3 API ```etcdctl get``` of a v2 key will exit with 0 and no key data, this is the expected behaviour.


```bash
export ETCDCTL_API=3
```

+ To get started with installing and setting up an etcd cluster, follow the instructions in **[Install]( ../../../docs/v3.5/install)** page of the documentation.

+ To configure local etcd cluster for testing and development purposes, visit **[Set up a local cluster](../../../docs/v3.5/dev-guide/local_cluster)** for more details.

Once the etcd cluster is set up and running, it might be a good option to know the versions of etcdctl and Server API in order to find the appropriate commands to be used for performing various operations on etcd.

Here is the command to find the versions:

```bash
$ etcdctl version
etcdctl version: 3.1.0-alpha.0+git
API version: 3.1
```
To **write a key** to be stored into the etcd cluster, below is the command to set the value of a key `foo` to `bar`:

```bash
$ etcdctl put foo bar
OK
```

Similarly, to **read the values of keys** from an etcd cluster, here is the command to read the value of the key `foo`:

```bash
$ etcdctl get foo
foo
bar
```

To know more about all the functionalities that etcdctl offers, visit **[Interacting with etcd](../../../docs/v3.5/dev-guide/interacting_v3)** for more details.
