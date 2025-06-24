---
title: How to migrate etcd from v2 to v3
description: etcd v2 to v3 migration guide
weight: 1200
---

`migrate` to transform etcd v2 to v3 data:

![12_etcdctl_migrate_2016061602](https://storage.googleapis.com/etcd/demo/12_etcdctl_migrate_2016061602.gif)


```shell
# write key in etcd version 2 store
export ETCDCTL_API=2
etcdctl --endpoints=http://$ENDPOINT set foo bar

# read key in etcd v2
etcdctl --endpoints=$ENDPOINTS --output="json" get foo

# stop etcd node to migrate, one by one

# migrate v2 data
export ETCDCTL_API=3
etcdctl --endpoints=$ENDPOINT migrate --data-dir="default.etcd" --wal-dir="default.etcd/member/wal"

# restart etcd node after migrate, one by one

# confirm that the key got migrated
etcdctl --endpoints=$ENDPOINTS get /foo
```
