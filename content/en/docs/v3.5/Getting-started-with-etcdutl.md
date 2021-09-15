---
title: Getting started with etcdutl
weight: 3250
description: "etcdutl: a command line administration utility for etcd"
---

**Note**: etcdutl is designed to operate on [etcd][etcd] data files. For operations over a network, please use [etcdctl](../../../docs/v3.5/getting-started-with-etcdctl).

## Synopsis of commands

### **DEFRAG [options]**

DEFRAG directly defragments an etcd data directory while etcd is not running. When an etcd member reclaims storage space from deleted and compacted keys, the space is kept in a free list and the database file remains the same size. By defragmenting the database, the etcd member releases this free space back to the file system.

In order to defrag a live etcd instances over the network, please use `etcdctl defrag` instead.

+ **Options**: 
    + data-dir -- Optional. If present, defragments a data directory not in use  by etcd.

+ **Output**: Exit status '0' when the process was successful.

To defragment a data direcrory directly, use the `data-dir` flag:

``` bash
# Defragment while etcd is not running
./etcdutl defrag --data-dir default.etcd
# success (exit status 0)
# Error: cannot open database at default.etcd/member/snap/db
```

### **SNAPSHOT RESTORE [options] \<filename\>**

**SNAPSHOT RESTORE** creates an etcd data directory for an etcd cluster member from a backend database snapshot and a new cluster configuration. Restoring the snapshot into each member for a new cluster configuration will initialize a new etcd cluster preloaded by the snapshot data.

+ **Options**: 
    + data-dir -- Path to the data directory. Uses <name>.etcd if none given.
    + wal-dir -- Path to the WAL directory. Uses data directory if none given.
    + initial-cluster -- The initial cluster configuration for the restored etcd cluster.
    + initial-cluster-token -- Initial cluster token for the restored etcd cluster.
    + initial-advertise-peer-urls -- List of peer URLs for the member being restored.
    + name -- Human-readable name for the etcd cluster member being restored.
    + skip-hash-check -- Ignore snapshot integrity hash value (required if copied from data directory)

+ **Output**: A new etcd data directory initialized with the snapshot.

The code below saves a snapshot, restore into a new 3-node cluster and starts the cluster:

```bash
./etcdutl snapshot save snapshot.db

# restore members
bin/etcdutl snapshot restore snapshot.db --initial-cluster-token etcd-cluster-1 --initial-advertise-peer-urls http://127.0.0.1:12380  --name sshot1 --initial-cluster 'sshot1=http://127.0.0.1:12380,sshot2=http://127.0.0.1:22380,sshot3=http://127.0.0.1:32380'
bin/etcdutl snapshot restore snapshot.db --initial-cluster-token etcd-cluster-1 --initial-advertise-peer-urls http://127.0.0.1:22380  --name sshot2 --initial-cluster 'sshot1=http://127.0.0.1:12380,sshot2=http://127.0.0.1:22380,sshot3=http://127.0.0.1:32380'
bin/etcdutl snapshot restore snapshot.db --initial-cluster-token etcd-cluster-1 --initial-advertise-peer-urls http://127.0.0.1:32380  --name sshot3 --initial-cluster 'sshot1=http://127.0.0.1:12380,sshot2=http://127.0.0.1:22380,sshot3=http://127.0.0.1:32380'

# launch members
bin/etcd --name sshot1 --listen-client-urls http://127.0.0.1:2379 --advertise-client-urls http://127.0.0.1:2379 --listen-peer-urls http://127.0.0.1:12380 &
bin/etcd --name sshot2 --listen-client-urls http://127.0.0.1:22379 --advertise-client-urls http://127.0.0.1:22379 --listen-peer-urls http://127.0.0.1:22380 &
bin/etcd --name sshot3 --listen-client-urls http://127.0.0.1:32379 --advertise-client-urls http://127.0.0.1:32379 --listen-peer-urls http://127.0.0.1:32380 &
```

### **SNAPSHOT STATUS \<filename\>**

**SNAPSHOT STATUS** lists information about a given backend database snapshot file.

+ **Output**:
    + **Simple format**: Prints a humanized table of the database hash, revision, total keys, and size.
    + **JSON format**: Prints a line of JSON encoding the database hash, revision, total keys, and size.

Below shown are some of the examples of its usage:

```bash
./etcdutl snapshot status file.db
# cf1550fb, 3, 3, 25 kB
```

```bash
./etcdutl --write-out=json snapshot status file.db
# {"hash":3474280699,"revision":3,"totalKey":3,"totalSize":24576}
```

```bash
./etcdutl --write-out=table snapshot status file.db
+----------+----------+------------+------------+
|   HASH   | REVISION | TOTAL KEYS | TOTAL SIZE |
+----------+----------+------------+------------+
| cf1550fb |        3 |          3 | 25 kB      |
+----------+----------+------------+------------+
```

### **VERSION**

Prints the version of etcdutl.

+ **Output**: 
    + Prints etcd version and API version.

Below shown is the code for finding the version:
```bash
./etcdutl version
# etcdutl version: 3.5.0
# API version: 3.1
```

## Exit Codes
For all commands, a successful execution returns a zero exit code. All failures will return non-zero exit codes.

## Output Formats

All commands accept an output format by setting `-w` or `--write-out`. All commands default to the "simple" output format, which is meant to be human-readable. The simple format is listed in each command's output description since it is customized for each command. If a command has a corresponding RPC, it will respect all output formats.

If a command fails, returning a non-zero exit code, an error string will be written to standard error regardless of output format.

+ **Simple** : A format meant to be easy to parse and human-readable. Specific to each command.

+ **JSON** : The JSON encoding of the command's [RPC response][etcdrpc]. Since etcd's RPCs use byte strings, the JSON output will encode keys and values in base64.
Some commands without an RPC also support JSON; see the command's `output` description.

+ **Protobuf** : The protobuf encoding of the command's [RPC response][etcdrpc]. If an RPC is streaming, the stream messages will be concatenated. If an RPC is not given for a command, the protobuf output is not defined.

+ **Fields** : An output format similar to JSON but meant to parse with coreutils. For an integer field named `Field`, it writes a line in the format `"Field" : %d` where `%d` is go's integer formatting. For byte array fields, it writes `"Field" : %q` where `%q` is go's quoted string formatting (e.g., `[]byte{'a', '\n'}` is written as `"a\n"`).

## Compatibility Support

etcdutl is still in its early stage. We try our best to ensure fully compatible releases, however we might break compatibility to fix bugs or improve commands. If we intend to release a version of etcdutl with backward incompatibilities, we will provide notice prior to release and have instructions on how to upgrade.

+ **Input Compatibility** : Input includes the command name, its flags, and its arguments. We ensure backward compatibility of the input of normal commands in non-interactive mode.

+ **Output Compatibility** : Currently, we do not ensure backward compatibility of utility commands.


[etcd]: https://github.com/coreos/etcd
[etcdrpc]: ../api/etcdserverpb/rpc.proto
