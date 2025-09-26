---
title: Reading from etcd
description: Reading a value in an etcd cluster
weight: 200
---

## Prerequisites

- Install `etcdctl`


## Procedure

Use the `get` subcommand to read from etcd:

```shell
$ etcdctl --endpoints=$ENDPOINTS get foo
foo
Hello World!
$
```

where:
- `foo` is the requested key
- `Hello World!` is the retrieved value

Or, for formatted output:

```
$ etcdctl --endpoints=$ENDPOINTS --write-out="json" get foo
{"header":{"cluster_id":289318470931837780,"member_id":14947050114012957595,"revision":3,"raft_term":4,
"kvs":[{"key":"Zm9v","create_revision":2,"mod_revision":3,"version":2,"value":"SGVsbG8gV29ybGQh"}]}}
$
```

where `write-out="json"` causes the value to be output in JSON format (note that the key is not returned).
