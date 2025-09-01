---
title: Writing to etcd
description: Adding a KV pair to an etcd cluster
weight: 250
---

## Prerequisites

- Install `etcdctl`

## Procedure

Use the `put` subcommand to write a key-value pair:

```shell
etcdctl --endpoints=$ENDPOINTS put foo "Hello World!"
```
where:
- `foo` is the key name
- `"Hello World!"` is the quote-delimited value
