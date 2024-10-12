---
title: How to make multiple writes in a transaction
description: Guide to making transactional writes
weight: 500
---

`txn` to wrap multiple requests into one transaction:

![05_etcdctl_transaction_2016050501](https://storage.googleapis.com/etcd/demo/05_etcdctl_transaction_2016050501.gif)

```shell
etcdctl --endpoints=$ENDPOINTS put user1 bad
etcdctl --endpoints=$ENDPOINTS txn --interactive

compares:
value("user1") = "bad"

success requests (get, put, delete):
del user1

failure requests (get, put, delete):
put user1 good
```

### Transaction for multiple writes

A transaction is an atomic If/Then/Else construct over the key-value store. It provides a primitive for grouping requests together in atomic blocks (i.e., then/else) whose execution is guarded (i.e., if) based on the contents of the key-value store. Transactions can be used for protecting keys from unintended concurrent updates, building compare-and-swap operations, and developing higher-level concurrency control. However, modifications to the same key multiple times within a single transaction are forbidden.

```shell
etcdctl --endpoints=$ENDPOINTS put user1 bad

etcdctl --endpoints=$ENDPOINTS txn --interactive
compares:
value("user1") = "bad"

success requests (get, put, del):
put user test
put user2 testing3
get user1

failure requests (get, put, del):
put user1 bad
```

{{< figure src="/img/transaction-multiple-writes.gif" >}}
