---
title: System limits
weight: 3625
description: "etcd limits: requests and storage"
---

## Request size limit

etcd is designed to handle small key value pairs typical for metadata. Larger requests will work, but may increase the latency of other requests. By default, the maximum size of any request is 1.5 MiB. This limit is configurable through `--max-request-bytes` flag for etcd server.

## Storage size limit

The default storage size limit is 2 GiB, configurable with `--quota-backend-bytes` flag. 100GB is a suggested maximum size for normal environments and etcd warns at startup if the configured value exceeds it. Read this [blog](https://www.cncf.io/blog/2019/05/09/performance-optimization-of-etcd-in-web-scale-data-scenario/) to further understand how the 100GB was obtained.
