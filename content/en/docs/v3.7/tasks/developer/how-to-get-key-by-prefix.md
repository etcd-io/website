---
title: How to get keys by prefix
description: Guide to extracting etcd keys by their prefix
weight: 300
---

## Prerequisites

* Install [`etcd` and `etcdctl`]({{% relref "../../install/" %}})
* [Set up a local cluster]({{% relref "../../dev-guide/local_cluster/" %}})

The examples below pass the cluster address in the `ENDPOINTS` environment
variable. For a single local member, set it to the default client address:

```shell
export ENDPOINTS=localhost:2379
```

## Get keys by prefix with etcdctl

etcd stores keys in a flat, sorted keyspace. Applications usually give their
keys a path-like structure, such as `/app/config/database`, so that related
keys share a common prefix. A prefix query returns every key that starts with
the given string, which makes it easy to read a whole "directory" of keys at
once.

```shell
etcdctl --endpoints=$ENDPOINTS get PREFIX --prefix
```

### Global options

```text
--endpoints=[127.0.0.1:2379]  gRPC endpoints
```

### Options

```text
--prefix      Get keys with matching prefix
--keys-only   Get only the keys
--limit       Maximum number of results
```

### Examples

Kubernetes is a well-known user of this pattern: it stores namespaced objects,
such as pods, under keys like `/registry/<resource>/<namespace>/<name>`. The
following examples use keys with the same layout. (Real Kubernetes values are
protobuf-encoded, and may be encrypted; plain JSON strings are used here to
keep the output readable.)

First, write a few keys:

```shell
etcdctl --endpoints=$ENDPOINTS put /registry/pods/default/nginx '{"image": "nginx:1.27"}'
etcdctl --endpoints=$ENDPOINTS put /registry/pods/default/redis '{"image": "redis:7.4"}'
etcdctl --endpoints=$ENDPOINTS put /registry/pods/kube-system/coredns '{"image": "coredns:1.11"}'
etcdctl --endpoints=$ENDPOINTS put /registry/services/default/nginx '{"port": 80}'
```

Get all pods in the `default` namespace, with their values. Each key is
printed on one line and its value on the next:

```shell
etcdctl --endpoints=$ENDPOINTS get /registry/pods/default/ --prefix
```

```text
/registry/pods/default/nginx
{"image": "nginx:1.27"}
/registry/pods/default/redis
{"image": "redis:7.4"}
```

Get the names of all pods in every namespace. The service key is not
returned, because it does not start with `/registry/pods/`. With
`--keys-only`, `etcdctl` prints an empty line where the value would be:

```shell
etcdctl --endpoints=$ENDPOINTS get /registry/pods/ --prefix --keys-only
```

```text
/registry/pods/default/nginx

/registry/pods/default/redis

/registry/pods/kube-system/coredns

```

By default, results are returned in ascending key order (use `--sort-by` and
`--order` to change this). Use `--limit` to return only the first few:

```shell
etcdctl --endpoints=$ENDPOINTS get /registry/pods/ --prefix --keys-only --limit=2
```

```text
/registry/pods/default/nginx

/registry/pods/default/redis

```

### End prefixes with a separator

A prefix is matched as a plain string, not as a path. If you leave off the
trailing `/`, keys that only begin with the same characters also match. For
example, after adding a pod in a `default-staging` namespace:

```shell
etcdctl --endpoints=$ENDPOINTS put /registry/pods/default-staging/web '{"image": "web:2.0"}'
etcdctl --endpoints=$ENDPOINTS get /registry/pods/default --prefix --keys-only
```

```text
/registry/pods/default-staging/web

/registry/pods/default/nginx

/registry/pods/default/redis

```

Using `/registry/pods/default/` (with the trailing `/`) returns only the pods
in the `default` namespace.

## Get keys by prefix with the Go client

The Go client, [`go.etcd.io/etcd/client/v3`](https://pkg.go.dev/go.etcd.io/etcd/client/v3),
performs a prefix query by passing the `clientv3.WithPrefix()` option to `Get`.

Create a module and add the client:

```shell
mkdir prefix-example && cd prefix-example
go mod init example.com/prefix-example
go get go.etcd.io/etcd/client/v3
```

Save the following as `main.go`. Change `localhost:2379` if your `ENDPOINTS`
differ:

```go
package main

import (
    "context"
    "fmt"
    "log"
    "time"

    clientv3 "go.etcd.io/etcd/client/v3"
)

func main() {
    cli, err := clientv3.New(clientv3.Config{
        Endpoints:   []string{"localhost:2379"},
        DialTimeout: 5 * time.Second,
    })
    if err != nil {
        log.Fatal(err)
    }
    defer cli.Close()

    ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
    defer cancel()

    // Get every key that starts with "/registry/pods/default/".
    resp, err := cli.Get(ctx, "/registry/pods/default/", clientv3.WithPrefix())
    if err != nil {
        log.Fatal(err)
    }

    for _, kv := range resp.Kvs {
        fmt.Printf("%s = %s\n", kv.Key, kv.Value)
    }
}
```

Run it against the keys written above:

```shell
go run .
```

```text
/registry/pods/default/nginx = {"image": "nginx:1.27"}
/registry/pods/default/redis = {"image": "redis:7.4"}
```

A single `Get` returns the whole range in one response. For prefixes that
hold many keys, add `clientv3.WithKeysOnly()` if you only need the keys, or
read the range in pages with `clientv3.WithLimit()`, using `resp.More` to
check whether more keys remain.

## Clean up

To remove the example keys when you are done:

```shell
etcdctl --endpoints=$ENDPOINTS del /registry/ --prefix
```
