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

The easiest way to install etcd is from pre-built binaries:

 1. Download the compressed archive file for your platform from [Releases][],
    choosing release [{{< param git_version_tag >}}][tagged-release] or later.
 2. Unpack the archive file. This results in a directory containing the binaries.
 3. Add the executable binaries to your path. For example, rename and/or move
    the binaries to a directory in your path (like `/usr/local/bin`), or add the
    directory created by the previous step to your path.
 4. From a shell, test that `etcd` is in your path:

    ```sh
    $ etcd --version
    etcd Version: {{< psubstr git_version_tag 1 >}}
    ...
    ```

## Build from source

If you have [Go version {{< param minGoVers >}}+][go], you can build etcd from
source by following these steps:

 1. [Download the etcd repo as a zip file][download] and unzip it, or clone the
    repo using the following command.

    ```sh
    $ git clone -b {{< param git_version_tag >}} https://github.com/etcd-io/etcd.git
    ```
    To build from `{{< param github_branch >}}@HEAD`, omit the `-b  {{< param
    git_version_tag >}}` flag.

 2. Change directory:

    ```sh
    $ cd etcd
    ```
 3. Run the build script:

    ```sh
    $ ./build.sh
    ```

    The binaries are under the `bin` directory.

 4. Add the full path to the `bin` directory to your path, for example:

    ```sh
    $ export PATH="$PATH:`pwd`/bin"
    ```

 5. Test that `etcd` is in your path:

    ```sh
    $ etcd --version
    ```

## Installation via OS packages
*Disclaimer: etcd installations through OS package managers can deliver outdated versions since they are not being automatically maintained nor officially supported by etcd project. Therefore use OS packages with caution.*

There are various ways of installing etcd on different operating systems and these are just some examples how it can be done.

### MacOS (Homebrew)

1. Update homebrew:
```sh
$ brew update
```

2. Install etcd:
```sh
$ brew install etcd
```

3. Verify install 
```sh
$ etcd --version
```

## Linux

TBD
## Installation as part of Kubernetes installation

TBD---Help Wanted

## Installation on Kubernetes, using a statefulset or helm chart

The etcd project does not currently maintain a helm chart, however you can follow the instructions provided by [Bitnami's etcd Helm chart].

## Installation check

For a slightly more involved sanity check of your installation, see
[Quickstart][].

[download]: https://github.com/etcd-io/etcd/archive/{{< param git_version_tag >}}.zip
[go]: https://golang.org/doc/install
[Hardware recommendations]: {{< relref "op-guide/hardware" >}}
[Quickstart]: {{< relref "quickstart" >}}
[releases]: https://github.com/etcd-io/etcd/releases/
[tagged-release]: https://github.com/etcd-io/etcd/releases/tag/{{< param git_version_tag >}}
[Supported platforms]: {{< relref "op-guide/supported-platform" >}}
[Bitnami's etcd Helm chart]: https://bitnami.com/stack/etcd/helm
