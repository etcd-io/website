---
title: Announcing etcd v3.7.0
author:  "SIG-Etcd Leads"
date: 2026-07-01
draft: false
---

<!-- TODO(release-team): set the `date` above to the actual GA release date.
     Placeholder is 2026-07-01; the release is expected late June to early July. -->

{{% alert title="TODO: fix release date" color="warning" %}}
The `date` in this post's front matter is a **placeholder** (2026-07-01). Update it to the
actual etcd v3.7.0 GA date before publishing, then remove this callout.
{{% /alert %}}

## Table of Contents

- **[Introduction](#introduction)**
- **[Major features](#major-features)**
- **[Features](#features)**
  - [RangeStream](#rangestream)
  - [Keys-only range optimization](#keys-only-range-optimization)
  - [Faster, more reliable leases](#faster-more-reliable-leases)
  - [Interval splitting](#interval-splitting)
  - [Unix socket support](#unix-socket-support)
  - [Bootstrap from v3store](#bootstrap-from-v3store)
  - [etcdutl timeouts](#etcdutl-timeouts)
  - [Setting the JWT directly](#setting-the-jwt-directly)
  - [ClientLogLevel](#clientloglevel)
  - [New watch metrics](#new-watch-metrics)
- **[Performance improvements](#performance-improvements)**
- **[Upgrading](#upgrading)**
  - [Deprecating experimental features](#deprecating-experimental-features)
  - [v2store completely gone](#v2store-completely-gone)
  - [Protobuf overhaul](#protobuf-overhaul)
- **[Dependencies](#dependencies)**
- **[Contributors](#contributors)**

## Introduction

Today, SIG-Etcd is releasing [etcd v3.7.0][], the latest minor release of the popular distributed
key-value store and core Kubernetes component. v3.7 ships the long-requested RangeStream feature, removes
the last remnants of the legacy v2store, completes a major protobuf overhaul, and delivers a range of
performance improvements for large read workloads and lease operations.

You can download etcd v3.7.0 here:

* [Source code](https://github.com/etcd-io/etcd/archive/refs/tags/v3.7.0.tar.gz)
* [Binaries](https://github.com/etcd-io/etcd/releases/tag/v3.7.0)
* [Official container images](https://gcr.io/etcd-development/etcd)

This release also includes new versions of the two core etcd dependencies, [bbolt v1.5.0][] and
[raft v3.7.0][].

For instructions on installing etcd, see the [install documentation][]. For the full list of changes,
see the [etcd v3.7 changelog][].

A heartfelt thank you to all the contributors who made this release possible!

## Major features

The headline changes in v3.7.0:

- **[RangeStream](#rangestream)** — stream large result sets in chunks instead of buffering the whole response.
- **[Keys-only range optimization](#keys-only-range-optimization)** — serve `--keys-only` ranges from the in-memory index, skipping backend reads.
- **Faster, more reliable leases** and a range of **[performance improvements](#performance-improvements)**.
- **[v2store is completely gone](#v2store-completely-gone)** — v3.7 is the first release running 100% on v3store.
- A completed **[protobuf overhaul](#protobuf-overhaul)**, replacing outdated protobuf libraries with fully supported ones.

## Features

### RangeStream

In etcd v3.6 and earlier, it is challenging to work with requests that return large result sets. The client
or requesting application is forced to wait for the full result set, leading to unpredictable latency and
memory usage. [The RangeStream RPC][] lets calling applications accept result sets in chunks, reducing latency
and making buffering memory usage more predictable.

Much of the work on RangeStream was done by a relatively new contributor to etcd, [Jeffrey Ying][], a software
engineer at Google. New contributors can have a substantial impact on etcd development.

"I've always been fascinated by database internals, and building RangeStream was a great opportunity to solve
a bottleneck we were hitting in production with Kubernetes. It was the perfect opportunity to collaborate
across projects and improve the ecosystem as a whole. Jumping into etcd as a new contributor had a bit of a
learning curve, but the community is incredibly welcoming. The leads were very receptive to my ideas and
helped me iterate quickly, while maintaining the project's high bar for reliability and code quality," said Jeffrey.

Instructions on how to use RangeStream [in gRPC calls](https://etcd.io/docs/v3.7/learning/api/#rangestream) and
[in etcdctl](https://etcd.io/docs/v3.7/dev-guide/interacting_v3/#read-keys) can be found in the etcd
documentation. Users should try it out for their own applications.

### Keys-only range optimization

etcd v3.7.0 includes a keys-only Range optimization ([#21791: keys-only Range optimization](https://github.com/etcd-io/etcd/pull/21791)). When a Range request uses `--keys-only`,
etcd can avoid reading values from bbolt in cases where values are not needed, and return keys using data
already available from the in-memory index.

This reduces unnecessary backend reads and memory use for workloads that only need key names, making large
keys-only range requests more efficient.

### Faster, more reliable leases

v3.7 improves lease expiration and renewal:

- LeaseRevoke requests are now prioritized to ensure timely lease expiration during overload ([#20492: stability enhancement during overload conditions](https://github.com/etcd-io/etcd/pull/20492)).
- The new `FastLeaseKeepAlive` feature enables faster lease renewal by skipping the wait for the applied
  index ([#20589: etcdserver: improve linearizable renew lease](https://github.com/etcd-io/etcd/pull/20589)).

### Interval splitting

Find performance is improved by splitting intervals that share the same left endpoint by their right
endpoints ([#19768: adt: split interval tree by right endpoint on matched left endpoints](https://github.com/etcd-io/etcd/pull/19768)).

### Unix socket support

etcd now supports Unix socket endpoints ([#19760: Add Support for Unix Socket endpoints](https://github.com/etcd-io/etcd/pull/19760)), enabling local communication without a TCP port.

### Bootstrap from v3store

Building on the v2store removal, etcd now bootstraps from the v3store. It stops loading v2 snapshot files
([#21107: Do not load v2 snapshot on bootstrap](https://github.com/etcd-io/etcd/pull/21107)) and initializes `confState` from the v3 store on bootstrap ([#21138: Initialize confState from v3 store on bootstrap](https://github.com/etcd-io/etcd/pull/21138)). The `--snapshot-count`
flag is kept ([#21162: Keep the --snapshot-count flag](https://github.com/etcd-io/etcd/pull/21162)), and removal of `--max-snapshots` has been deferred to v3.8 ([#21160: Remove flag --max-snapshots in 3.8 rather than 3.7](https://github.com/etcd-io/etcd/pull/21160)).

### etcdutl timeouts

A timeout flag has been added to all `etcdutl` commands for file lock acquisition ([#20708: etcdutl: enable timeout functionality for all commands](https://github.com/etcd-io/etcd/pull/20708)), so offline
utility commands no longer block indefinitely when a lock is held.

### Setting the JWT directly

clientv3 now allows users to set the JWT directly ([#16803: clientv3: allow setting JWT directly](https://github.com/etcd-io/etcd/pull/16803), [#20747: clientv3: disable auth retry when token is set](https://github.com/etcd-io/etcd/pull/20747)), and clients can retrieve
`AuthStatus` without authentication ([#20802: etcdserver: remove permission check on AuthStatus api](https://github.com/etcd-io/etcd/pull/20802)).

### ClientLogLevel

The function `etcdClientDebugLevel` has been renamed to `ClientLogLevel` and made public ([#20006: Client: Rename etcdClientDebugLevel function to the ClientLogLevel](https://github.com/etcd-io/etcd/pull/20006)),
giving consumers of the client a supported way to control client log verbosity.

### New watch metrics

v3.7 adds watch send-loop metrics ([#21030: Instrument watchstream send loop](https://github.com/etcd-io/etcd/pull/21030)) for better observability of the watch path:

- `etcd_debugging_server_watch_send_loop_watch_stream_duration_seconds`
- `etcd_debugging_server_watch_send_loop_watch_stream_duration_per_event_seconds`
- `etcd_debugging_server_watch_send_loop_control_stream_duration_seconds`
- `etcd_debugging_server_watch_send_loop_progress_duration_seconds`

A new `etcd_server_request_duration_seconds` metric was also added ([#21038: Add metric etcd_server_request_duration_seconds](https://github.com/etcd-io/etcd/pull/21038)).

In addition, `etcdctl` commands have been reorganized for clarity ([#20162: etcdctl: organize etcdctl subcommand](https://github.com/etcd-io/etcd/pull/20162)) and global flags hidden to
streamline help output ([#20493: etcdctl: hide global flags](https://github.com/etcd-io/etcd/pull/20493)).

## Performance improvements

Beyond the keys-only and lease improvements above, v3.7 includes:

- Lease and user/role operations are up to 2x faster, by updating `(*readView) Rev()` to use
  `SharedBufReadTxMode` ([#20411: Use SharedBufReadTxMode for (*readView) Rev() and FirstRev()](https://github.com/etcd-io/etcd/pull/20411)).
- A correctness fix for data inconsistency when a transaction includes a range request with a specified
  revision ([#21432: Fix data inconsistency when a transaction includes a range request with a specified revision](https://github.com/etcd-io/etcd/pull/21432)).
- Refactored IPv6 address comparison logic ([#20365: netutil: Refactor IPv6 address comparison logic](https://github.com/etcd-io/etcd/pull/20365)).

## Upgrading

This release contains breaking changes, particularly around the removal of legacy v2 components. Users
should review the [upgrade guide][] before upgrading their nodes. As with all minor releases, perform a
rolling upgrade one member at a time and confirm cluster health between steps.

### Deprecating experimental features

All deprecated experimental flags have been removed ([#19959: Cleanup the deprecated experimental flags](https://github.com/etcd-io/etcd/pull/19959)). Features in etcd now follow the
Kubernetes-style feature-gate lifecycle (Alpha → Beta → GA) introduced in v3.6, rather than the old
`--experimental` flag prefix. If your configuration still relies on `--experimental-*` flags, migrate to the
corresponding feature gates or stable flags before upgrading.

### v2store completely gone

The last vestiges of etcd v2store have been removed in v3.7, making this the first release that is 100% on
v3store. This includes [v2 discovery][] ([#20109: Remove v2discovery](https://github.com/etcd-io/etcd/pull/20109)), bootstrap, [v2 requests][] ([#21263: Remove v2 Request and apply_v2.go](https://github.com/etcd-io/etcd/pull/21263)), and the
[v2 client][] ([#20117: Remove client/internal/v2](https://github.com/etcd-io/etcd/pull/20117)).

These changes may create some breakage for users, particularly those who have not already updated to
v3.6.11. Users should report any blockers encountered, or cases that need better upgrade documentation.

### Protobuf overhaul

v3.7 migrates and replaces multiple outdated protobuf libraries with fully supported dependencies. This
includes replacing `github.com/golang/protobuf` and `github.com/gogo/protobuf` with the
fully-supported `google.golang.org/protobuf` ([#14533: Protobuf: cleanup both golang/protobuf and gogo/protobuf](https://github.com/etcd-io/etcd/issues/14533)), and migrating grpc-logging to grpc-middleware v2
([#20420: Migrate grpc-logging to grpc-middleware v2](https://github.com/etcd-io/etcd/pull/20420)).

While these changes are not expected to directly affect users running etcd via official binaries or container
images, they may affect users who depend on etcd Go modules, such as the client SDK or packages under `api/`
or `pkg/`. These consumers may need to update their code or dependencies due to protobuf and related API
changes introduced in this release. More detailed information is available from [the API change tracking
issue][].

## Dependencies

[bbolt][] and [raft][] are the two core dependencies of etcd. etcd v3.7.0 depends on [bbolt v1.5.0][] and
[raft v3.7.0][].

| etcd versions | bbolt versions | raft versions |
|---------------|----------------|---------------|
| 3.5.x         | v1.3.x         | N/A           |
| 3.6.x         | v1.4.x         | v3.6.x        |
| 3.7.x         | v1.5.x         | v3.7.x        |

Note that for v3.7, only [multi-arch container images][] will be available. We will no longer be releasing
container images with architecture tags in their names. Please adjust your pull commands accordingly.

Other dependency updates include a bump to `golang.org/x/crypto` v0.52.0 for CVE resolution ([#21903: [release-3.7] Bump golang.org/x/crypto to v0.52.0](https://github.com/etcd-io/etcd/pull/21903)),
an OpenTelemetry contrib update to v0.61.0 ([#20017: Update otelgrpc to v0.61.0](https://github.com/etcd-io/etcd/pull/20017)), and compilation with Go 1.26.4 ([#21891: [release-3.7] Update Go to 1.26.4](https://github.com/etcd-io/etcd/pull/21891)).

## Contributors

etcd v3.7.0 is the product of more than 100 contributors across the community. Thank you to everyone who
wrote code, reviewed PRs, filed and triaged issues, and helped test the alpha, beta, and release candidates.

### Leads

The v3.7 release was led by the SIG-etcd release team, [ivanvc][] and [jmhbnz][].

### Other contributors

[ah8ad3](https://github.com/ah8ad3), [ahrtr](https://github.com/ahrtr), [ajaysundark](https://github.com/ajaysundark), [aladesawe](https://github.com/aladesawe), [amosehiguese](https://github.com/amosehiguese), [ArkaSaha30](https://github.com/ArkaSaha30), [ashikjm](https://github.com/ashikjm), [AwesomePatrol](https://github.com/AwesomePatrol), [dims](https://github.com/dims), [fuweid](https://github.com/fuweid), [gangli113](https://github.com/gangli113), [henrybear327](https://github.com/henrybear327), [hwdef](https://github.com/hwdef), [Jille](https://github.com/Jille), [joshuazh-x](https://github.com/joshuazh-x), [liggitt](https://github.com/liggitt), [miancheng7](https://github.com/miancheng7), [mmorel-35](https://github.com/mmorel-35), [mrueg](https://github.com/mrueg), [purpleidea](https://github.com/purpleidea), [qsyqian](https://github.com/qsyqian), [redwrasse](https://github.com/redwrasse), [rsafonseca](https://github.com/rsafonseca), [serathius](https://github.com/serathius), [siyuanfoundation](https://github.com/siyuanfoundation), [skitt](https://github.com/skitt), [tcchawla](https://github.com/tcchawla), [tjungblu](https://github.com/tjungblu), [vivekpatani](https://github.com/vivekpatani), [wenjiaswe](https://github.com/wenjiaswe)

### New contributors

A special welcome to the contributors who made their first etcd contribution in this cycle — including
[Jeffrey Ying](https://github.com/jefftree), whose work drove the RangeStream feature. New contributors can
have a substantial impact on etcd; if you'd like to get involved, see the [contributor guide][].

[4rivappa](https://github.com/4rivappa), [abdurrehman107](https://github.com/abdurrehman107), [akstron](https://github.com/akstron), [alliasgher](https://github.com/alliasgher), [aojea](https://github.com/aojea), [apullo777](https://github.com/apullo777), [AR21SM](https://github.com/AR21SM), [asttool](https://github.com/asttool), [BBQing](https://github.com/BBQing), [beforetech](https://github.com/beforetech), [boqishan](https://github.com/boqishan), [caltechustc](https://github.com/caltechustc), [carsontham](https://github.com/carsontham), [chuanye-gao](https://github.com/chuanye-gao), [cuiweixie](https://github.com/cuiweixie), [Deln0r](https://github.com/Deln0r), [dmvolod](https://github.com/dmvolod), [Dogacel](https://github.com/Dogacel), [dongjiang1989](https://github.com/dongjiang1989), [EduardoVega](https://github.com/EduardoVega), [evertrain](https://github.com/evertrain), [eyupcanakman](https://github.com/eyupcanakman), [gaganhr94](https://github.com/gaganhr94), [goingforstudying-ctrl](https://github.com/goingforstudying-ctrl), [Himanshu-370](https://github.com/Himanshu-370), [HossamSaberX](https://github.com/HossamSaberX), [huajianxiaowanzi](https://github.com/huajianxiaowanzi), [jihogh](https://github.com/jihogh), [jonathan-albrecht-ibm](https://github.com/jonathan-albrecht-ibm), [joshjms](https://github.com/joshjms), [kairosci](https://github.com/kairosci), [kishen-v](https://github.com/kishen-v), [kjgorman](https://github.com/kjgorman), [kstrifonoff](https://github.com/kstrifonoff), [letreturn](https://github.com/letreturn), [lorenz](https://github.com/lorenz), [madhav-murali](https://github.com/madhav-murali), [majiayu000](https://github.com/majiayu000), [marcus-hodgson-antithesis](https://github.com/marcus-hodgson-antithesis), [mcrute](https://github.com/mcrute), [mingl1](https://github.com/mingl1), [MohanadKh03](https://github.com/MohanadKh03), [NAM-MAN](https://github.com/NAM-MAN), [nihalmaddala](https://github.com/nihalmaddala), [notandruu](https://github.com/notandruu), [nwnt](https://github.com/nwnt), [pjsharath28](https://github.com/pjsharath28), [ravisastryk](https://github.com/ravisastryk), [robin-vidal](https://github.com/robin-vidal), [rockswe](https://github.com/rockswe), [ronaldngounou](https://github.com/ronaldngounou), [sahilpatel09](https://github.com/sahilpatel09), [SalehBorhani](https://github.com/SalehBorhani), [SebTardif](https://github.com/SebTardif), [seshachalam-yv](https://github.com/seshachalam-yv), [shashwat010](https://github.com/shashwat010), [shivamgcodes](https://github.com/shivamgcodes), [shuan1026](https://github.com/shuan1026), [silentred](https://github.com/silentred), [sneaky-potato](https://github.com/sneaky-potato), [srri](https://github.com/srri), [subrajeet-maharana](https://github.com/subrajeet-maharana), [tchap](https://github.com/tchap), [tsujiri](https://github.com/tsujiri), [upamanyus](https://github.com/upamanyus), [varunu28](https://github.com/varunu28), [xiaoxiangirl](https://github.com/xiaoxiangirl), [xigang](https://github.com/xigang), [xUser5000](https://github.com/xUser5000), [yagikota](https://github.com/yagikota), [yajianggroup](https://github.com/yajianggroup), [yedou37](https://github.com/yedou37), [Zanda256](https://github.com/Zanda256), [zechariahkasina](https://github.com/zechariahkasina), [zhijun42](https://github.com/zhijun42), [zhoujiaweii](https://github.com/zhoujiaweii)

Feedback can be shared through:

* [GitHub issues](https://github.com/etcd-io/etcd/issues)
* [#SIG-etcd slack channel](https://kubernetes.slack.com/archives/C3HD8ARJ5) in [Kubernetes Slack](https://www.kubernetes.dev/docs/comms/slack/#joining-slack)
* [etcd-dev mailing list](https://groups.google.com/g/etcd-dev)

[etcd v3.7.0]: https://github.com/etcd-io/etcd/releases/tag/v3.7.0
[etcd v3.7 changelog]: https://github.com/etcd-io/etcd/blob/main/CHANGELOG/CHANGELOG-3.7.md
[install documentation]: https://etcd.io/docs/v3.7/install/
[upgrade guide]: https://etcd.io/docs/v3.7/upgrades/upgrade_3_7/
[The RangeStream RPC]: https://github.com/kubernetes/enhancements/tree/master/keps/sig-etcd/5966-etcd-range-stream
[Jeffrey Ying]: https://github.com/jefftree
[multi-arch container images]: https://github.com/etcd-io/etcd/pull/21840
[v2 discovery]: https://github.com/etcd-io/etcd/pull/20109
[v2 requests]: https://github.com/etcd-io/etcd/pull/21263
[v2 client]: https://github.com/etcd-io/etcd/pull/20117
[the API change tracking issue]: https://github.com/etcd-io/website/issues/1162
[contributor guide]: https://github.com/etcd-io/etcd/blob/main/CONTRIBUTING.md
[bbolt]: https://github.com/etcd-io/bbolt
[raft]: https://github.com/etcd-io/raft
[bbolt v1.5.0]: https://github.com/etcd-io/bbolt/releases/tag/v1.5.0
[raft v3.7.0]: https://github.com/etcd-io/raft/releases/tag/v3.7.0
[ivanvc]: https://github.com/ivanvc
[jmhbnz]: https://github.com/jmhbnz
