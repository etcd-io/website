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
