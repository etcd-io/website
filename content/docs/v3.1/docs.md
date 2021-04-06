# Documentation

etcd is a distributed key-value store designed to reliably and quickly preserve and provide access to critical data. It enables reliable distributed coordination through distributed locking, leader elections, and write barriers. An etcd cluster is intended for high availability and permanent data storage and retrieval.

## Getting started

New etcd users and developers should get started by [downloading and building][download_build] etcd. After getting etcd, follow this [quick demo][demo] to see the basics of creating and working with an etcd cluster.

## Developing with etcd

The easiest way to get started using etcd as a distributed key-value store is to [set up a local cluster][local_cluster].

 - [Setting up local clusters][local_cluster]
 - [Interacting with etcd][interacting]
 - [API references][api_ref]
 - [gRPC gateway][api_grpc_gateway]
 - [gRPC naming and discovery][grpc_naming]
 - [Embedding etcd][embed_etcd]
 - [Experimental features and APIs][experimental]
 - [System limits][system-limit]

## Operating etcd clusters

Administrators who need to create reliable and scalable key-value stores for the developers they support should begin with a [cluster on multiple machines][clustering].

 - [Setting up etcd clusters][clustering]
 - [Setting up etcd gateways][gateway]
 - [Setting up etcd gRPC proxy (pre-alpha)][grpc_proxy]
 - [Run etcd clusters inside containers][container]
 - [Hardware recommendations][hardware]
 - [Configuration][conf]
 - [Security][security]
 - [Monitoring][monitoring]
 - [Maintenance][maintenance]
 - [Understand failures][failures]
 - [Disaster recovery][recovery]
 - [Performance][performance]
 - [Versioning][versioning]
 - [Supported platform][supported_platform]

## Learning

To learn more about the concepts and internals behind etcd, read the following pages:

 - [Why etcd][why] (TODO)
 - [Understand data model][data_model]
 - [Understand APIs][understand_apis]
 - [Glossary][glossary]
 - Internals (TODO)

## Upgrading and compatibility

 - [Migrate applications from using API v2 to API v3][v2_migration]
 - [Updating v2.3 to v3.0][v3_upgrade]
 - [Updating v3.0 to v3.1][v31_upgrade]

## Frequently Asked Questions (FAQ)

Answers to [common questions] about etcd.

[api_ref]: dev-guide/api_reference_v3
[api_grpc_gateway]: dev-guide/api_grpc_gateway
[clustering]: op-guide/clustering
[conf]: op-guide/configuration
[system-limit]: dev-guide/limit
[common questions]: faq
[why]: learning/why
[data_model]: learning/data_model
[demo]: demo
[download_build]: dl_build
[embed_etcd]: https://godoc.org/github.com/coreos/etcd/embed
[grpc_naming]: dev-guide/grpc_naming
[failures]: op-guide/failures
[gateway]: op-guide/gateway
[glossary]: learning/glossary
[grpc_proxy]: op-guide/grpc_proxy
[hardware]: op-guide/hardware
[interacting]: dev-guide/interacting_v3
[local_cluster]: dev-guide/local_cluster
[performance]: op-guide/performance
[recovery]: op-guide/recovery
[maintenance]: op-guide/maintenance
[security]: op-guide/security
[monitoring]: op-guide/monitoring
[v2_migration]: op-guide/v2-migration
[container]: op-guide/container
[understand_apis]: learning/api
[versioning]: op-guide/versioning
[supported_platform]: op-guide/supported-platform
[experimental]: dev-guide/experimental_apis
[v3_upgrade]: upgrades/upgrade_3_0
[v31_upgrade]: upgrades/upgrade_3_1
