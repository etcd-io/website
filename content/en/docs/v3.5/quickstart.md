---
title: Quickstart
weight: 900
description: Run etcd Locally Under 5 minutes!
---

This guide walks through installing and running a single-node etcd cluster locally using pre-built binaries - no containers or cloud set up required.

## Requirements

Make sure you're on a supported platform before getting started:

- Operating System: Ubuntu 22.04+ or macOS 11+. Windows users can use WSL2.
- [Supported platforms architecture](/docs/v3.5/op-guide/)
- Tools installed:
  - `curl` and `tar`
  - Internet connection to download the latest etcd [release](https://github.com/etcd-io/etcd/releases/).
  - `sudo` access to install binaries.

## Steps

### 1. Installation

Install `etcd` from pre-built binaries using cURL.

   ```bash
   # Download and extract the latest release using cURL
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

## What's next?

Learn about more ways to configure and use etcd from the following pages:

- Explore the gRPC [API](/docs/v3.5/learning/api).
- Set up a [multi-machine cluster](/docs/v3.5/op-guide/clustering).
- Learn how to [configure](/docs/v3.5/op-guide/configuration) etcd.
- Find language [bindings and tools](/docs/v3.5/integrations).
- Use TLS to [secure](/docs/v3.5/op-guide/security) an etcd cluster.
- [Tune etcd](/docs/v3.5/tuning).