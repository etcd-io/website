---
title: etcd Integrates Continuous Fuzzing
spelling: cSpell:ignore Gyuho
author:  "[Adam Korczynski](https://twitter.com/AdamKorcz4), [David Korczynski](https://twitter.com/Davkorcz), [Sahdev Zala](https://twitter.com/sp_zala)"
date: 2022-03-11
draft: false
---

In the last few months, the team at [Ada Logics](https://adalogics.com) has worked on integrating continuous fuzzing into the etcd project. This was an effort focused on improving the security posture of etcd and ensuring a continued good experience for etcds users. The fuzzing integration involved enrolling etcd in the OSS-Fuzz project and writing a set of fuzzers that would bring the test coverage of etcd up to a mature level. In total, 18 fuzzers were written, and eight bugs were found, demonstrating the work’s value for etcd both short term and long term. All fuzzers were implemented by way of go-fuzz and when running in OSS-Fuzz instrumented by way of libFuzzer, and as such, etcd uses state-of-the-art open source fuzzing capabilities. 
The full report of the engagement can be found [here](https://github.com/etcd-io/etcd/blob/main/security/FUZZING_AUDIT_2022.PDF). 

The etcd project was created at CoreOS in 2013 and later joined the CNCF in 2018, from which it [graduated](https://www.cncf.io/announcements/2020/11/24/cloud-native-computing-foundation-announces-etcd-graduation/) in 2020. It is an open source, strongly consistent, distributed key-value store to reliably store data that a distributed system or cluster of machines needs to be accessed. It also provides highly desirable features like Watches to monitor changes to keys. etcd is a critical component of Kubernetes where it is used as the primary data store for cluster data such as the clusters state data and its data related to its desired state. Besides being a key component in Kubernetes, etcd is also used by [many other distributed systems](https://etcd.io/docs/v3.5/integrations/#projects-using-etcd). Because of its wide usage, etcd is a critical part of the open source ecosystem to fuzz for reliability bugs and security vulnerabilities. [The CNCF annual survey of 2021](https://www.cncf.io/reports/cncf-annual-survey-2021) found that 96% of companies are either using or evaluating Kubernetes, and etcd’s performance and security are important to continued business operations of these users. 

## What is fuzzing?

Fuzzing is a technique used to automate parts of the software testing process by way of a form of stress testing. The key idea is to write a fuzzing harness similar to a unit—or integration—test that will execute the application under test with some arbitrary input. The fuzzing engine that will run the fuzzing harness then uses genetic algorithms to extrapolate inputs that will cause the code under test to execute uniquely, i.e., generate inputs that trigger new code execution paths. The goal is then to observe if the code under test misbehaves in the event of any of the generated inputs. Fuzzing has been effective in uncovering reliability bugs and vulnerabilities in software for more than two decades, and open source software is increasingly adopting the technique. 

## Etcd fuzzing overview

In this engagement, the goal was to write a set of fuzzers that would cover a lot of the etcd codebase and integrate the setup into the open source fuzzing service OSS-Fuzz. OSS-Fuzz is a free service offered by Google for critical open source projects to run their fuzzers continuously and report any crashes. Continuous analysis is important due to fuzzing relying on genetic algorithms, which effectively means the fuzzers will improve over time, and OSS-Fuzz will run the fuzzers daily indefinitely. In addition to this, continuous analysis is crucial for capturing any regressions.

Etcd is written in the Go programming language, making it safe from memory-corruptions. Fuzzing Go will find panics such as slice/index out of range, nil-pointer dereferences, invalid type assertions, timeouts, out of memory. At the end of this engagement, eight issues were found, all of which were fixed. They are broken down as such:

![figure-1](../etcd-integrates-continuous-fuzzing/etcd-fuzzing-found-bugs.png "The fuzzing engagement found 2 nil-pointer dereference, 2 slice/index out of range, 2 panics from invalid utf-8 strings, and 2 type confusions.")

At the end of this engagement, the fuzzers provide significant coverage of the etcd project, including critical parts such as the etcd server, WAL, the auth store, and the raft package.
During the engagement, Ada Logics found that only a few of the critical parts of etcd would be accessible with a byte slice or string but instead accepted complex types such as structs. An example of this is [the fuzzers for the etcd server](https://github.com/cncf/cncf-fuzzing/blob/main/projects/etcd/etcdserver_fuzzer.go), which configures and sets up an etcd server and then creates a series of pseudo-randomized structs representing different requests sent to the server. To write these fuzzers, Ada Logics used [go-fuzz-headers](https://github.com/AdaLogics/go-fuzz-headers) to deterministically create pseudo-random structs from the data provided by libFuzzer.

## Closing thoughts

The etcd team is thankful to CNCF and Chris Aniszczyk for providing the opportunity to work with Ada Logics to develop new fuzzers for etcd. The software security is taken seriously by the CNCF, and it earlier funded the etcd project for a [third-party security audit](https://www.cncf.io/blog/2020/08/05/etcd-security-audit/). We also want to thank all the etcd maintainers and reviewers, especially Marek Siarkowicz, Piotr Tabor, and Benjamin Wang, for their quick reviews of the fixes. The fuzzing findings and fixes are valuable add-ons to the previous conclusions of the security audit. etcd project has efficient test suites, and code changes are backed by tests, but the newly developed fuzzers and findings have provided significant value to the project. During the fuzzing, only eight issues were found, which revalidated the high quality of the etcd code. The etcd team should maintain the newly developed fuzzers and build on them to continue code quality and security.
