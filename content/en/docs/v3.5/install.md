---
title: Install
weight: 1150
description: Instructions for installing etcd from pre-built binaries or from source.
minGoVers: 1.20
---

## Requirements

Before installing etcd, see the following pages:

- [Supported platforms][]
- [Hardware recommendations][]

## Install pre-built binaries

Install `etcd` from pre-built binaries.

   ```bash
   # Download and extract the latest release using cURL. For example, download v3.5.21 as below.
   curl -L https://github.com/etcd-io/etcd/releases/download/v3.5.21/etcd-v3.5.21-linux-arm64.tar.gz \
   -o etcd.tar.gz
   tar -xvf etcd.tar.gz
   cd etcd-v3.5.21-linux-arm64

   ```

   Move binaries to `/usr/local/bin`:

   ```bash
   sudo mv etcd etcdctl etcdutl /usr/local/bin
   ```

   Confirm installation:

   ```bash
   etcd --version
   etcdctl version
   ```

   Output:

   ```bash
   etcd Version: 3.5.21
   Git SHA: a17edfd
   Go Version: go1.23.7
   Go OS/Arch: linux/arm64


   etcdctl version: 3.5.21
   API version: 3.5

   ```

### 2. Start `etcd`

   In a new terminal window, start etcd with the default configuration:

   ```bash
    etcd
   ```

   You should see logs indicating etcd has started and is listening on `localhost:2379`.

### 3. From another terminal, use `etcdctl` to set a key

   ```bash
      etcdctl put greeting "Hello, etcd"
   ```

   where:

- `put`: Puts the given key into the store

   Ouput:

   ```bash
   OK
   ```

### 4. From the same terminal, retrieve the key

   ```bash
      etcdctl get greeting
   ```

   where:

- `get`: gets the key or range of keys.

   Output:

   ```bash
   greeting
   Hello, etcd
   ```

### 5. Shut down `etcd`

To stop etcd, press `Ctrl+C` in the terminal where it is running.

## Build from source

With Go [installed](https://go.dev/doc/install), you can build etcd from source by following these steps:

 1. [Download the etcd repo as a zip file](https://github.com/etcd-io/etcd) and unzip it, or clone the
    repo using the following command.

    ```sh
    git clone -b {{< param git_version_tag >}} https://github.com/etcd-io/etcd.git
    ```

    To build from `{{< param github_branch >}}@HEAD`, omit the `-b  {{< param
    git_version_tag >}}` flag.

 2. Change directory:

    ```sh
    cd etcd
    ```

 3. Run the build script:

    ```sh
    ./build.sh
    ```

    The binaries are under the `bin` directory.

 4. Add the full path to the `bin` directory to your path, for example:

    ```sh
    export PATH="$PATH:`pwd`/bin"
    ```

 5. Test that `etcd` is in your path:

    ```sh
    etcd --version
    ```

## Installation via OS packages

*Disclaimer: etcd installations through OS package managers can deliver outdated versions since they are not being automatically maintained nor officially supported by etcd project. Therefore use OS packages with caution.*

There are various ways of installing etcd on different operating systems and these are just some examples how it can be done.

### MacOS (Homebrew)

1. Update homebrew:

```sh
brew update
```

2.Install etcd

```sh
brew install etcd
```

3.Verify install

```sh
etcd --version
```

## Linux

Although installing etcd through many major Linux distributions' official repositories and package managers is possible, the published versions can be significantly outdated. So, installing this way is strongly discouraged.

The recommended way to install etcd on Linux is either through [pre-built binaries](#install-pre-built-binaries) or by using Homebrew.

### Homebrew on Linux

[Homebrew can run on Linux], and can provide recent software versions.

- Prerequisites
  - Update Homebrew:

    ```sh
    brew update
    ```

- Procedure
  - Install using `brew`:

    ```sh
    brew install etcd
    ```

- Result
  - Verify installation by getting the version:

    ```sh
    $ etcd --version
    etcd Version: {{< psubstr git_version_tag 1 >}}
    ...
    ```

## Installation as part of Kubernetes installation

- [Running etcd as a Kubernetes StatefulSet][]

## Installation on Kubernetes, using a statefulset or helm chart

The etcd project does not currently maintain a helm chart, however you can follow the instructions provided by [Bitnami's etcd Helm chart].

## Installation check

For a slightly more involved sanity check of your installation, see
[Quickstart][].

[download]: https://github.com/etcd-io/etcd/archive/{{< param git_version_tag >}}.zip
[go]: https://golang.org/doc/install
[Hardware recommendations]: {{< relref "op-guide/hardware" >}}
[Quickstart]: {{< relref "quickstart" >}}
[Running etcd as a Kubernetes StatefulSet]: {{< relref "op-guide/kubernetes" >}}
[releases]: https://github.com/etcd-io/etcd/releases/
[tagged-release]: https://github.com/etcd-io/etcd/releases/tag/{{< param git_version_tag >}}
[Supported platforms]: {{< relref "op-guide/supported-platform" >}}
[Bitnami's etcd Helm chart]: https://bitnami.com/stack/etcd/helm
[Homebrew can run on Linux]: <https://docs.brew.sh/Homebrew-on-Linux>