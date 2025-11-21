---
title: Logging conventions
weight: 1600
description: Logging level categories
---

etcd uses the [zap][zap] library for logging application output categorized into *levels*. A log message's level is determined according to these conventions:

* DebugLevel logs are typically voluminous, and are usually disabled in production.
  * Examples:
    * Send a normal message to a remote peer
    * Write a log entry to disk

* InfoLevel is the default logging priority.
  * Examples:
    * Startup configuration
    * Start to do snapshot
    * Add a new node into the cluster
    * Add a new user into auth subsystem

* WarnLevel logs are more important than Info, but don't need individual human review.
  * Examples:
    * Failure to send Raft message to a remote peer
    * Failure to receive heartbeat message within the configured election timeout

* ErrorLevel logs are high-priority. If an application is running smoothly, it shouldn't generate any error-level logs.
  * Examples:
    * Failure to allocate disk space for WAL

* PanicLevel logs a message, then panics.
  * Examples:
    * Failure to encode Raft messages

* FatalLevel logs a message, then calls os.Exit(1).
  * Examples:
    * Failure to save Raft snapshot

[zap]: https://github.com/uber-go/zap
