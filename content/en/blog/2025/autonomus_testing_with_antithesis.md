---
title: Autonomous Testing of etcd's Robustness
author: "Marek Siarkowicz (Google)"
date: 2025-10-03
draft: false
---

*This is a post from the [CNCF blog](https://www.cncf.io/blog/2025/09/25/autonomous-testing-of-etcds-robustness/) which we are sharing with our community as well.*

As a critical component of many production systems, including Kubernetes, the etcd project's first priority is reliability.
Ensuring consistency and data safety requires our project contributors to continuously improve testing methodologies.
In this article, we will describe how we used advanced simulation testing to uncover subtle bugs,
validate the robustness of our releases, and increase our confidence in etcd's stability.
We'll share our key findings and how they have improved etcd.

## Enhancing etcd's Robustness Testing

Many critical software systems depend on etcd to be correct and consistent, most notably as the primary datastore for Kubernetes.
After some issues with the v3.5 release,
the etcd maintainers developed a new [robustness testing framework](https://github.com/etcd-io/etcd/issues/14045)
to better test for correctness under various failure scenarios. To further enhance our testing capabilities,
we integrated a deterministic simulation testing platform from [Antithesis](https://antithesis.com/) into our workflow.

The platform works by running the entire etcd cluster inside a deterministic hypervisor.
This specialized environment gives the testing software complete control over every source of non-determinism,
such as network behavior, thread scheduling, and system clocks.
This means any bug it discovers can be perfectly and reliably reproduced.

Within this simulated environment, the testing methodology shifts away from traditional, scenario-based tests.
Instead of writing tests imperatively with strict assertions for one specific outcome, this approach uses declarative, property-based assertions about system behavior.
These properties are high-level invariants about the system that must always hold true. For example,
"data consistency is never violated" or "a watch event is never dropped."

The platform then treats these properties not as passive checks, but as targets to break.
It combines automated exploration with targeted fault injection,
actively searching for the precise sequence of events and failures that will cause a property to be violated.
This active search for violations is what allows the platform to uncover subtle bugs that result from complex combinations of factors.
Antithesis refers to this approach as Autonomous Testing.

This builds upon etcd's existing robustness tests, which also use a property-based approach.
However, without a deterministic environment or automated exploration,
the original framework resembled throwing darts while blindfolded and hoping to hit the bullseye.
A bug might be found, but the process relies heavily on random chance and is difficult to reproduce.
Antithesis's deterministic simulation and active exploration
removes the blindfold, enabling a systematic and reproducible search for bugs.

## How We Tested

Our goals for this testing effort were to:

1. **Validate the robustness of etcd v3.6.**
2. **Improve etcd's software quality by finding and fixing bugs.**
3. **Enhance our existing testing framework with autonomous testing.**

We ran our existing robustness tests on the Antithesis simulation platform, testing a 3-node and a 1-node etcd cluster against a variety of faults, including:

* **Network faults:** latency, congestion, and partitions.
* **Container-level faults:** thread pauses, process kills, clock jitter, and CPU throttling.

We tested older versions of etcd with known bugs to validate the testing methodology, as well as our stable releases (3.4, 3.5, 3.6) and the main development branch. In total, we ran 830 wall-clock hours of testing, which simulated 4.5 years of usage.

## What We Found

The results were impressive. The simulation testing not only found all the known bugs we tested for but also uncovered several new issues in our main development branch.

Here are some of the key findings:

* **A critical watch bug was discovered** that our existing tests had missed. This bug was present in all stable releases of etcd.
* **All known bugs were found**, giving us confidence in the ability of the combined testing approach to find regressions.
* **Our own testing was improved** by revealing a flaw in our linearization checker model.

### Issues in the Main Development Branch

| Description                                                             | Report Link                   | Status                                           | Impact | Details                                                    |
| :---------------------------------------------------------------------- | :---------------------------- | :----------------------------------------------- | :------| :--------------------------------------------------------- |
| [Watch on future revision might receive old events][bug-1-issue]        | [Triage Report][bug-1-report] | Fixed in 3.6.2 ([\#20281][bug-1-fix])            | Medium | New bug discovered by Atithesis                            |
| [Watch on future revision might receive old notifications][bug-2-issue] | [Triage Report][bug-2-report] | Fixed in 3.6.2 ([\#20221][bug-2-fix])            | Medium | New bug discovered by both Antithesis and robustness tests |
| [Panic when two snapshots are received in short period][bug-3-issue]    | [Triage Report][bug-3-report] | Open                                             | Low    | Previously discovered by robustness                        |
| [Panic from db page expected to be 5][bug-4-issue]                      | [Triage Report][bug-4-report] | Fixed in 3.6.5 ([\#20553][bug-4-fix])            | Low    | New bug discovered by Antithesis                           |
| [Operation time based on watch response is incorrect][bug-5-issue]      | [Triage Report][bug-5-report] | Fixed test on main branch ([\#19998][bug-5-fix]) | Low    | Bug in robustness tests discovered by Antithesis           |

[bug-1-issue]: https://github.com/etcd-io/etcd/issues/20221
[bug-1-report]: https://linuxfoundation.antithesis.com/report/LAbnx9WBHxp0BPeEDSFrTxl3/798H3lSB7pQb6x2LYB65zGlNhM_OmxZAza0PfRbjpQo.html?auth=v2.public.eyJzY29wZSI6eyJSZXBvcnRTY29wZVYxIjp7ImFzc2V0IjoiNzk4SDNsU0I3cFFiNngyTFlCNjV6R2xOaE1fT214WkF6YTBQZlJianBRby5odG1sIiwicmVwb3J0X2lkIjoiTEFibng5V0JIeHAwQlBlRURTRnJUeGwzIn19LCJuYmYiOiIyMDI1LTA3LTAyVDA2OjI2OjA5Ljc5MjM0NTQ2OVoifaf6ZskL_GQSGDCZ7ESxV5SbygmAq_NiZZ9Oj2wcMnFOZlEjL5QEfgxM1zjSkF20PrjCjrmKzr4U7fJVJOPT3Qo#/run/e3a65c762111a06ab412abbdec1e3a73-32-6/finding/984b7ce364030642155dcd71d492711c9f9f73a9
[bug-1-fix]: https://github.com/etcd-io/etcd/pull/20281
[bug-2-issue]: https://github.com/etcd-io/etcd/issues/20221
[bug-2-report]: https://linuxfoundation.antithesis.com/report/UZjUP_KGxboJepL7k1q_8pa4/ZqL0Vt9a7YESiiBmGecPMkBP8YgM1IwlTZJ4dcYjmZ8.html?auth=v2.public.eyJuYmYiOiIyMDI1LTA2LTI1VDAzOjE4OjIzLjM4MDU2MDQwMFoiLCJzY29wZSI6eyJSZXBvcnRTY29wZVYxIjp7ImFzc2V0IjoiWnFMMFZ0OWE3WUVTaWlCbUdlY1BNa0JQOFlnTTFJd2xUWko0ZGNZam1aOC5odG1sIiwicmVwb3J0X2lkIjoiVVpqVVBfS0d4Ym9KZXBMN2sxcV84cGE0In19feIAsYO4-UIigcL4eMu7QUqA6XFbCU3Hnw7BeyZW06o9x11mFqleHbSbRWdIcLdTH2Xzx42DXNB7dBqYq25Ujg4#/run/e35cadd61e2b01c494095b06141fcc8b-32-6/finding/984b7ce364030642155dcd71d492711c9f9f73a9
[bug-2-fix]: https://github.com/etcd-io/etcd/issues/20221
[bug-3-issue]: https://github.com/etcd-io/etcd/issues/18055
[bug-3-report]: https://linuxfoundation.antithesis.com/report/HqTiW-VhiXU25CCPP8vkSUPB/3Q73gnvlcEpEb6XVWcl4H3qTOnXZ7pFAdkpbpHr8mMI.html?auth=v2.public.eyJzY29wZSI6eyJSZXBvcnRTY29wZVYxIjp7ImFzc2V0IjoiM1E3M2dudmxjRXBFYjZYVldjbDRIM3FUT25YWjdwRkFka3BicEhyOG1NSS5odG1sIiwicmVwb3J0X2lkIjoiSHFUaVctVmhpWFUyNUNDUFA4dmtTVVBCIn19LCJuYmYiOiIyMDI1LTA2LTA2VDAxOjA5OjE5Ljc1MDg1NDI2NVoifW8RMYqVcS2V3idTzyvalEO2SnPqycds-Cn710lY-wlfqYPe1MAb2U0R2wEKVwPtSsr79WcnR8yYCyZyCQNqhAc#/run/31f74082d85b5ffdaf9f34ed37480bbd-32-6/finding/138fa550c81efa6efc7170191b75c4a22caea51f
[bug-4-report]: https://linuxfoundation.antithesis.com/report/G-9rIjiZJiwodTEN5avQ7wgK/u_uFsWOwZSxS5mOmbEprwMUijNhsWdV6mfde_CT-y4k.html?auth=v2.public.eyJuYmYiOiIyMDI1LTA3LTAzVDA3OjMxOjUyLjQzMzQ2ODk3NFoiLCJzY29wZSI6eyJSZXBvcnRTY29wZVYxIjp7ImFzc2V0IjoidV91RnNXT3daU3hTNW1PbWJFcHJ3TVVpak5oc1dkVjZtZmRlX0NULXk0ay5odG1sIiwicmVwb3J0X2lkIjoiRy05cklqaVpKaXdvZFRFTjVhdlE3d2dLIn19fUHU0wnVRoDtfilwOCROUiDTtcOlIZkrVaddCqjorH3utgcIEPIzlsrMAJGXFC6NTZMneLqAWWU_lq-9prD_tQc#/run/9088730ba7972869a3e2b68b66708b55-32-6/finding/b9cbdf1bc8bd74cab1388e30ebdbf0b37c6f1420
[bug-4-issue]: https://github.com/etcd-io/etcd/issues/20271
[bug-4-fix]: https://github.com/etcd-io/etcd/pull/20553
[bug-5-report]: https://linuxfoundation.antithesis.com/report/IVzVnBQKQ0aInboRbRdsVDIE/xlfYJ3eyHooIxRJqHjimRYPrnttrULyr8PqOfRD0pS8.html?auth=v2.public.eyJuYmYiOiIyMDI1LTA1LTIxVDA5OjMzOjUzLjcyODgwNTA4MVoiLCJzY29wZSI6eyJSZXBvcnRTY29wZVYxIjp7ImFzc2V0IjoieGxmWUozZXlIb29JeFJKcUhqaW1SWVBybnR0clVMeXI4UHFPZlJEMHBTOC5odG1sIiwicmVwb3J0X2lkIjoiSVZ6Vm5CUUtRMGFJbmJvUmJSZHNWRElFIn19fc8p5s8qWPm5KxSC8oqMFj8HzTze7dxXhyPVt3l-GLwxSHIsuAIk1-2W7tgrh9mNXpZkFRhedvGSYNyhZ272kAo#/run/2e0ec6758e3603c3e4f5fd43dd26ffab-31-8/finding/5a95b2983bca202814eaa6a3fe594910a72cd2c6
[bug-5-issue]: https://github.com/etcd-io/etcd/issues/19998
[bug-5-fix]: https://github.com/etcd-io/etcd/issues/19998

### Known Issues

Antithesis also successfully found and reproduced these known issues in older releases – the “[Brown M&M](https://www.safetydimensions.com.au/van-halen/)s” set by the etcd maintainers.

| Description                                                            | Report Link                     |
| :--------------------------------------------------------------------- | :------------------------------ |
| [Watch dropping an event when compacting on delete][known-1-issue]     | [Triage Report][known-1-report] |
| [Revision decreasing caused by crash during compaction][known-2-issue] | [Triage Report][known-2-report] |
| [Watch progress notification not synced with stream][known-3-issue]    | [Triage Report][known-3-report] |
| [Inconsistent revision caused by crash during defrag][known-4-issue]   | [Triage Report][known-4-report] |
| [Watchable runlock bug][known-5-issue]                                 | [Triage Report][known-5-report] |

[known-1-issue]: https://github.com/etcd-io/etcd/issues/18089
[known-1-report]: https://linuxfoundation.antithesis.com/report/eYAhUOXW751VmJwPvGPa6R52/SFgfiy4PFXUGW5JkKt-uOnLFUVk9ZDIxFNQDRIS-eLE.html?auth=v2.public.eyJuYmYiOiIyMDI1LTA2LTAyVDIxOjI5OjMwLjAxNjk5OTQ5NloiLCJzY29wZSI6eyJSZXBvcnRTY29wZVYxIjp7ImFzc2V0IjoiU0ZnZml5NFBGWFVHVzVKa0t0LXVPbkxGVVZrOVpESXhGTlFEUklTLWVMRS5odG1sIiwicmVwb3J0X2lkIjoiZVlBaFVPWFc3NTFWbUp3UHZHUGE2UjUyIn19feadk3puhf0lkOv5k8GN_uQ74jb64WhykomO8nUZVBbUqRC-dLOnb7ENYLEjLW_rConu9ADWMFK_WVX7_zpX-wE#/run/6f713ca33a385cfa6d1987f125cbd951-31-8/finding/984b7ce364030642155dcd71d492711c9f9f73a9
[known-2-issue]: https://github.com/etcd-io/etcd/issues/17780
[known-2-report]: https://linuxfoundation.antithesis.com/report/aRbi2JR9dqoXK2xvN-DfZi9S/r4GRi-BLXj6-kpaqz5fo8j8W-qUV1diKw6_x8vonLNk.html?auth=v2.public.eyJuYmYiOiIyMDI1LTA2LTAyVDIxOjMyOjQ5LjU1OTQ3Nzg2MFoiLCJzY29wZSI6eyJSZXBvcnRTY29wZVYxIjp7ImFzc2V0IjoicjRHUmktQkxYajYta3BhcXo1Zm84ajhXLXFVVjFkaUt3Nl94OHZvbkxOay5odG1sIiwicmVwb3J0X2lkIjoiYVJiaTJKUjlkcW9YSzJ4dk4tRGZaaTlTIn19fR5EmgiseZ02ngQHRC5uYXTIekPT7Z9Ta903abbN1xq-t2XYheG4YSlJFDdRIfyMpKKclB_uZGQOPd2kXKeutwM#/run/6a08b1cd0efe3d19b9bd89c6815e84e4-31-8/finding/5a95b2983bca202814eaa6a3fe594910a72cd2c6
[known-3-issue]: https://github.com/etcd-io/etcd/issues/15220
[known-3-report]: https://linuxfoundation.antithesis.com/report/ymTYOGwzB-UwlmrjT8VrC_Kn/Y-D2b7S_BKdIl67UqZtXafn0xPhbRulSZVQvPqsBZak.html?auth=v2.public.eyJuYmYiOiIyMDI1LTA1LTI5VDEyOjAyOjIzLjUzMTc3MTg2MloiLCJzY29wZSI6eyJSZXBvcnRTY29wZVYxIjp7ImFzc2V0IjoiWS1EMmI3U19CS2RJbDY3VXFadFhhZm4weFBoYlJ1bFNaVlF2UHFzQlphay5odG1sIiwicmVwb3J0X2lkIjoieW1UWU9Hd3pCLVV3bG1yalQ4VnJDX0tuIn19fRmIEwPnKRaq1qnN9tKlGw0m--zs7uFUMMi3AaZM_Kz6Uy0IzsO-af3D1DDBFzSyclF13rqyjI-3ki2d9ufDNQk#/run/fa475411ad6b37641065963bc37b5dd4-31-8/finding/984b7ce364030642155dcd71d492711c9f9f73a9
[known-4-issue]: https://github.com/etcd-io/etcd/pull/14685
[known-4-report]: https://linuxfoundation.antithesis.com/report/kuUVd-WEW4jkcEp7Uzsh-649/doX_RaZAkZxIOxxBn51bdhfjFzrV5ipnJYAQUAT2454.html?auth=v2.public.eyJuYmYiOiIyMDI1LTA2LTE5VDAxOjM3OjAxLjYyODQzMjM4OVoiLCJzY29wZSI6eyJSZXBvcnRTY29wZVYxIjp7ImFzc2V0IjoiZG9YX1JhWkFrWnhJT3h4Qm41MWJkaGZqRnpyVjVpcG5KWUFRVUFUMjQ1NC5odG1sIiwicmVwb3J0X2lkIjoia3VVVmQtV0VXNGprY0VwN1V6c2gtNjQ5In19fW1TcMbQfba6iffW4KX_yGOjmwg2qHbRsqzxhJOh8ywc6fxgJa8Lemw1ShkuhQs3caqWHlEEojyAEMVjlLPK4Ac#/run/8b12e3b98a5b206e30c5d0067746083e-32-6/finding/5a95b2983bca202814eaa6a3fe594910a72cd2c6
[known-5-issue]: https://github.com/etcd-io/etcd/pull/13505
[known-5-report]: https://linuxfoundation.antithesis.com/report/6zkMqkEjjJuinArwLZTkJehM/7h42qHA5soBgxYPsMiDa4dSbA-O_g2SL9vkJqxvGON8.html?auth=v2.public.eyJzY29wZSI6eyJSZXBvcnRTY29wZVYxIjp7ImFzc2V0IjoiN2g0MnFIQTVzb0JneFlQc01pRGE0ZFNiQS1PX2cyU0w5dmtKcXh2R09OOC5odG1sIiwicmVwb3J0X2lkIjoiNnprTXFrRWpqSnVpbkFyd0xaVGtKZWhNIn19LCJuYmYiOiIyMDI1LTA1LTMwVDAwOjUyOjM2LjUwMjc3MTMyNFoifSYHsw1ZLCSfxME2keN58uGgi2yHTLvlg5_mFLkmePovjDjan-8SH72WdrmeWc4OMoRR-F3Pmi9UkU546_rtkgI#/run/8b82751143d9baaf98535089301d7af4-31-8/finding/984b7ce364030642155dcd71d492711c9f9f73a9

## Conclusion

The integration of this advanced simulation testing into our development workflow has been a success.
It has allowed us to find and fix critical bugs, improve our existing testing framework,
and increase our confidence in the reliability of etcd. We will continue to leverage this technology
to ensure that etcd remains a stable and trusted distributed key-value store for the community.
