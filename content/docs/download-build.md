---
title: Download and build etcd
---

There are two main ways to install etcd and etcdctl:

* From [static binaries](#binary)
* By building [from source](#source)

{{< info >}}
The instructions in this document are for the latest version of etcd, version **{{< latest >}}**.
{{< /info >}}

{{< requirement title="System requirements" >}}
The etcd performance benchmarks run etcd on:

* 8 vCPU
* 16GB RAM
* 50GB SSD [Google Compute Engine](https://cloud.google.com/compute/) (GCE)

Any relatively modern machine with low latency storage and a few gigabytes of memory, however, should suffice for most use cases. Applications with large v2 data stores will require more memory than a large v3 data store since data is kept in anonymous memory instead of memory mapped from a file. For running etcd on a cloud provider, we suggest at least a medium instance on AWS or a [standard-1](https://cloud.google.com/compute/docs/machine-types#standard_machine_types) instance on GCE.
{{< /requirement >}}

## Installing from a pre-built binary {#binary}

The easiest way to install etcd is by fetching one of the binaries available for [Linux](#linux), [macOS](#macos), and [Docker](#docker).

### Linux

```bash
ETCD_VER=v{{< latest >}}

# choose either URL
GOOGLE_URL=https://storage.googleapis.com/etcd
GITHUB_URL=https://github.com/etcd-io/etcd/releases/download
ROOT_URL=${GOOGLE_URL} # or set to GITHUB_URL
DOWNLOAD_URL=${ROOT_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz

rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
rm -rf /tmp/etcd-download-test && mkdir -p /tmp/etcd-download-test

curl -L ${DOWNLOAD_URL} -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /tmp/etcd-download-test --strip-components=1
rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz

/tmp/etcd-download-test/etcd --version
# should return "etcd Version: {{< latest >}}"

ETCDCTL_API=3 /tmp/etcd-download-test/etcdctl version
# should return "etcd Version: {{< latest >}}"
```

### macOS

The following will install two executables, `etcd` and `etcdctl`, in the `/tmp/etcd-download-test` directory:

```bash
ETCD_VER=v{{< latest >}}

# choose either URL
GOOGLE_URL=https://storage.googleapis.com/etcd
GITHUB_URL=https://github.com/etcd-io/etcd/releases/download
ROOT_URL=${GOOGLE_URL} # or set to GITHUB_URL
DOWNLOAD_URL=${ROOT_URL}/${ETCD_VER}/etcd-${ETCD_VER}-darwin-amd64.zip

rm -f /tmp/etcd-${ETCD_VER}-darwin-amd64.zip
rm -rf /tmp/etcd-download-test && mkdir -p /tmp/etcd-download-test

curl -L ${DOWNLOAD_URL} -o /tmp/etcd-${ETCD_VER}-darwin-amd64.zip
unzip /tmp/etcd-${ETCD_VER}-darwin-amd64.zip -d /tmp && rm -f /tmp/etcd-${ETCD_VER}-darwin-amd64.zip
mv /tmp/etcd-${ETCD_VER}-darwin-amd64/* /tmp/etcd-download-test && rm -rf mv /tmp/etcd-${ETCD_VER}-darwin-amd64

/tmp/etcd-download-test/etcd --version
# should return "etcd Version: {{< latest >}}"

ETCDCTL_API=3 /tmp/etcd-download-test/etcdctl version
# should return "etcd Version: {{< latest >}}"
```

### Docker

[Docker](https://docker.com) images for etcd are hosted in [Google Container Registry](https://gcr.io), under the [etcd-development/etcd](https://gcr.io/etcd-development/etcd) project.

The image for the latest version of etcd is `gcr.io/etcd-development/etcd:v{{< latest >}}`.

To run the locally (applying the name `etcd` to the image):

```bash
docker run --name etcd \
  gcr.io/etcd-development/etcd:{{< latest >}}
```

Here are some example commands to execute against the running container:

```bash
docker exec etcd /bin/sh -c "/usr/local/bin/etcd --version"
docker exec etcd /bin/sh -c "ETCDCTL_API=3 /usr/local/bin/etcdctl version"
docker exec etcd /bin/sh -c "ETCDCTL_API=3 /usr/local/bin/etcdctl endpoint health"
docker exec etcd /bin/sh -c "ETCDCTL_API=3 /usr/local/bin/etcdctl put foo bar"
docker exec etcd /bin/sh -c "ETCDCTL_API=3 /usr/local/bin/etcdctl get foo"
```

## Building etcd from source {#source}

In addition to installing etcd from [static binaries](#binary), you can also build etcd from source using the [etcd-io/etcd](https://github.com/etcd-io/etcd) repository on [GitHub](https://github.com).

{{< requirement title="Install Go first" >}}
In order to install etcd from source, you'll need to install [Go](https://golang.org) version **1.8 or above**.
{{< /requirement >}}

### Outside of `GOPATH`

```bash
git clone https://github.com/etcd-io/etcd.git
cd etcd
./build

# run the resulting executable
./bin/etcd
```

### Using `go get`

If you have `GOPATH` set:

```bash
echo $GOPATH

go get github.com/etcd-io/etcd/cmd/etcd

# run the resulting executable
$GOPATH/bin/etcd
```

## 
