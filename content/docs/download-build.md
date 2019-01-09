---
title: Download and build etcd
---

{{< requirement title="System requirements" >}}
The etcd performance benchmarks run etcd on:

* 8 vCPU
* 16GB RAM
* 50GB SSD [Google Compute Engine](https://cloud.google.com/compute/) (GCE)

Any relatively modern machine with low latency storage and a few gigabytes of memory, however, should suffice for most use cases. Applications with large v2 data stores will require more memory than a large v3 data store since data is kept in anonymous memory instead of memory mapped from a file. For running etcd on a cloud provider, we suggest at least a medium instance on AWS or a [standard-1](https://cloud.google.com/compute/docs/machine-types#standard_machine_types) instance on GCE.
{{< /requirement >}}
