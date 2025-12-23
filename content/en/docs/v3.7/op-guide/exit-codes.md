---
title: Exit codes
weight: 4400
description: Understanding etcd exit codes for troubleshooting startup and runtime failures
---

etcd uses standard Unix exit codes to indicate why the process terminated. This reference documents exit codes and common scenarios that trigger them.

## Scope

This document covers exit codes for the **etcd server** binary. For etcdctl client exit codes, see [etcdctl documentation](../dev-guide/interacting_v3/).

## Exit code summary

| Code | Meaning |
|:----:|---------|
| 0 | Successful exit (`--help`, `--version`, graceful shutdown) |
| 1 | Fatal error (configuration, network, data directory, TLS) |
| 2 | Invalid command-line arguments |

## Exit code 0: Success

Exit code 0 indicates normal termination:

- Graceful shutdown via SIGTERM or SIGINT
- Help requested with `--help` flag
- Version information requested with `--version` flag

**Code references:** `server/etcdmain/config.go:131`, `config.go:144`, `etcd.go:176`

## Exit code 1: Fatal errors

Exit code 1 is used for all fatal errors that prevent etcd from starting or continuing operation. Check logs for the specific error message.

### Cluster configuration errors

Discovery token reused or cluster configuration missing:

**Common log messages:**
- `"do not reuse discovery token; generate a new one to bootstrap a cluster"`
- `"forgot to set --initial-cluster?"`
- `"forgot to set --initial-advertise-peer-urls?"`

**Code references:** `server/etcdmain/etcd.go:139-156`

### Network listener failures

Port conflicts or permission issues:

**Common log message:**
- `"listener failed"`

**Code reference:** `server/etcdmain/etcd.go:172`

### Data directory errors

Cannot access or read data directory:

**Common log messages:**
- `"failed to list data directory"`
- `"invalid datadir; both member and proxy directories exist"`

**Code references:** `server/etcdmain/etcd.go:201`, `etcd.go:221`

### Discovery service failures

Cannot contact or use discovery service:

**Common log message:**
- `"discovery failed"`

**Code reference:** `server/etcdmain/etcd.go:157`

### TLS configuration errors

Certificate or key file issues in gRPC proxy:

**Common log messages:**
- `"failed to create TLS listener"`
- `"failed to set up TLS"`

**Code references:** `server/etcdmain/grpc_proxy.go:460`, `grpc_proxy.go:582`

### Unsupported platform

Running on an unsupported CPU architecture:

**Common log message:**
- `"Refusing to run etcd on unsupported architecture since ETCD_UNSUPPORTED_ARCH is not set"`

Set `ETCD_UNSUPPORTED_ARCH` environment variable to override (not recommended for production).

**Code reference:** `server/etcdmain/etcd.go:250-252`

### Logger creation failure

Cannot create default zap logger:

**Code reference:** `server/etcdmain/etcd.go:60`

### Flag verification failure

Invalid configuration flags detected:

**Code reference:** `server/etcdmain/etcd.go:69`

## Exit code 2: Invalid arguments

Exit code 2 indicates command-line parsing errors.

**Code reference:** `server/etcdmain/config.go:133`

## Troubleshooting exit code 1

When etcd exits with code 1, follow these steps:

### 1. Check the logs

**For systemd:**
```bash
journalctl -u etcd -n 50
```

**For Docker:**
```bash
docker logs <container-id> --tail 50
```

**For direct execution:**
Check stderr output or log files specified with `--log-outputs`.

### 2. Match error messages

Search logs for these common patterns:

| Log Message | Likely Cause |
|-------------|--------------|
| `discovery token` | Token reused or discovery service issue |
| `listener failed` | Port conflict (2379, 2380) or permissions |
| `failed to list data directory` | Permission or path issue |
| `invalid datadir` | Corrupted state - both member and proxy directories exist |
| `TLS` or `certificate` | Certificate/key file issues |
| `unsupported architecture` | Running on 32-bit or unsupported platform |


## Developer notes

All `os.Exit()`, `osutil.Exit()`, and `lg.Fatal()` calls can be found in:

- Main server: `server/etcdmain/*.go`
- Embedded config: `server/embed/config.go`
- OS utilities: `pkg/osutil/interrupt_{unix,windows}.go`

Search pattern:
```bash
grep -rn "os\.Exit\|osutil\.Exit\|lg\.Fatal\|lg\.Panic" server/etcdmain/ server/embed/
```

Exit mechanisms:
- `os.Exit(code)` - Direct exit with specified code
- `osutil.Exit(0)` - Graceful shutdown with cleanup
- `lg.Fatal(...)` - Logs error message then calls `os.Exit(1)`
- `lg.Panic(...)` - Logs error message then panics

## Related documentation

- [Configuration options](../configuration/) - All etcd flags and environment variables
