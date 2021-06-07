---
title: Quickstart
weight: 900
description: Get etcd up and running in less than 5 minutes!
---

Follow the instructions below to locally install, run, and test a simple
single-member cluster of etcd.

## Install etcd

Download and install etcd on Linux from pre-built binaries:

```
ETCD_VER={{< param git_version_tag >}}
ETCD_BIN=/tmp/test-etcd

DOWNLOAD_URL=https://storage.googleapis.com/etcd

rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
rm -rf $ETCD_BIN
mkdir -p $ETCD_BIN

curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz

tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C $ETCD_BIN --strip-components=1
```

{{% alert title="Note" color="info" %}}
To work with the latest version, learn how to
[build from the main branch](/docs/{{< param version >}}/install/#build-from-source).

etcd is installable on a variety of platforms, including macOS and Windows. See
the [Install page](/docs/{{< param version >}}/install/) to find out how to
install etcd on your preferred Operating System.
{{% /alert %}}

## Launch etcd

```
$ $ETCD_BIN/etcd
{"level":"warn","ts":"2021-05-12T11:03:01.247-0700","caller":"etcdmain/etcd.go:119","msg":"'data-dir' was empty; using default","data-dir":"default.etcd"}
⋮
```

## Set and get a key

From another terminal, use etcdctl to set a key:

```
$ $ETCD_BIN/etcdctl put greeting "Hello, etcd"
OK
```

Now that a key has been set, retrieve it:

```
$ $ETCD_BIN/etcdctl get greeting
greeting
Hello, etcd
```

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

