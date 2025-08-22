---
title: Autonomous Testing of etcd's Robustness
author: "Marek Siarkowicz, Google & Craig Alfieri, Antithesis"
date: 2025-08-13
draft: false
---

Ensuring the reliability of etcd is our top priority. As a critical component of many production systems, we are continuously improving our testing methodologies. This blog post describes how we used autonomous testing to uncover subtle bugs, validate the robustness of our releases, and increase our confidence in etcd's stability. We'll share our key findings and how they have improved etcd.

## Enhancing etcd's Robustness Testing

Etcd is a critical component in many production systems, most notably as the primary datastore for Kubernetes. After some issues with the v3.5 release, the etcd maintainers developed a new [robustness testing framework](https://github.com/etcd-io/etcd/issues/14045) to better test for correctness under various failure scenarios. To further enhance our testing capabilities, we integrated an autonomous testing platform from [Antithesis](https://antithesis.com/) into our workflow. This allowed us to perform deterministic simulation testing for our distributed system.

Our goals for this testing effort were to:

1. **Validate the robustness of etcd v3.6.**
2. **Improve etcd's software quality by finding and fixing bugs.**
3. **Enhance our existing testing framework with autonomous testing.**

## How We Tested

We ran our existing robustness tests on an autonomous testing platform, testing a 3-node and a 1-node etcd cluster against a variety of faults, including:

* **Network faults:** latency, congestion, and partitions.
* **Container-level faults:** node pauses, node kills, clock jitter, and CPU throttling.

We tested older versions of etcd with known bugs to validate the testing methodology, as well as our stable releases (3.4, 3.5, 3.6) and the main development branch. In total, we ran 830 wall-clock hours of testing, which simulated 4.5 years of usage.

## What We Found

The results were impressive. The autonomous testing not only found all the known bugs we tested for but also uncovered several new issues in our main development branch.

Here are some of the key findings:

* **A critical watch bug was discovered** that our existing tests had missed. This bug was present in all stable releases of etcd.
* **All known bugs were found**, giving us confidence in the ability of the combined testing approach to find regressions.
* **Our own testing was improved** by revealing a flaw in our linearization checker model.

### Issues in the Main Development Branch

| # | Description | Affected code | Report Link | Status | Impact | Details |
| :---- | :---- | :---- | :---- | :---- | :---- | :---- |
| **1** | Watch on future revision might receive old events | server/storage/mvcc/watchable_store.go | [Triage Report](https://linuxfoundation.antithesis.com/report/LAbnx9WBHxp0BPeEDSFrTxl3/798H3lSB7pQb6x2LYB65zGlNhM_OmxZAza0PfRbjpQo.html?auth=v2.public.eyJzY29wZSI6eyJSZXBvcnRTY29wZVYxIjp7ImFzc2V0IjoiNzk4SDNsU0I3cFFiNngyTFlCNjV6R2xOaE1fT214WkF6YTBQZlJianBRby5odG1sIiwicmVwb3J0X2lkIjoiTEFibng5V0JIeHAwQlBlRURTRnJUeGwzIn19LCJuYmYiOiIyMDI1LTA3LTAyVDA2OjI2OjA5Ljc5MjM0NTQ2OVoifaf6ZskL_GQSGDCZ7ESxV5SbygmAq_NiZZ9Oj2wcMnFOZlEjL5QEfgxM1zjSkF20PrjCjrmKzr4U7fJVJOPT3Qo#/run/e3a65c762111a06ab412abbdec1e3a73-32-6/finding/984b7ce364030642155dcd71d492711c9f9f73a9) | Fixed in 3.6.2 ([Github issue](https://github.com/etcd-io/etcd/pull/20281)) | Medium / High | Only found in Antithesis; present in all releases of etcd |
| **2** | Watch on future revision might receive old notifications | server/storage/mvcc/watchable_store.go | [Triage Report](https://linuxfoundation.antithesis.com/report/UZjUP_KGxboJepL7k1q_8pa4/ZqL0Vt9a7YESiiBmGecPMkBP8YgM1IwlTZJ4dcYjmZ8.html?auth=v2.public.eyJuYmYiOiIyMDI1LTA2LTI1VDAzOjE4OjIzLjM4MDU2MDQwMFoiLCJzY29wZSI6eyJSZXBvcnRTY29wZVYxIjp7ImFzc2V0IjoiWnFMMFZ0OWE3WUVTaWlCbUdlY1BNa0JQOFlnTTFJd2xUWko0ZGNZam1aOC5odG1sIiwicmVwb3J0X2lkIjoiVVpqVVBfS0d4Ym9KZXBMN2sxcV84cGE0In19feIAsYO4-UIigcL4eMu7QUqA6XFbCU3Hnw7BeyZW06o9x11mFqleHbSbRWdIcLdTH2Xzx42DXNB7dBqYq25Ujg4#/run/e35cadd61e2b01c494095b06141fcc8b-32-6/finding/984b7ce364030642155dcd71d492711c9f9f73a9) | Fixed in 3.6.2 ([Github issue](https://github.com/etcd-io/etcd/issues/20221)) | Medium / High | Present in all releases of etcd; found immediately upon introduction by both Antithesis and the etcd robustness testing framework |
| **3** | Panic when two snapshots are received in short period | **Reported Issue Unable to be Reproduced, Found by Antithesis** | [Triage Report](https://linuxfoundation.antithesis.com/report/HqTiW-VhiXU25CCPP8vkSUPB/3Q73gnvlcEpEb6XVWcl4H3qTOnXZ7pFAdkpbpHr8mMI.html?auth=v2.public.eyJzY29wZSI6eyJSZXBvcnRTY29wZVYxIjp7ImFzc2V0IjoiM1E3M2dudmxjRXBFYjZYVldjbDRIM3FUT25YWjdwRkFka3BicEhyOG1NSS5odG1sIiwicmVwb3J0X2lkIjoiSHFUaVctVmhpWFUyNUNDUFA4dmtTVVBCIn19LCJuYmYiOiIyMDI1LTA2LTA2VDAxOjA5OjE5Ljc1MDg1NDI2NVoifW8RMYqVcS2V3idTzyvalEO2SnPqycds-Cn710lY-wlfqYPe1MAb2U0R2wEKVwPtSsr79WcnR8yYCyZyCQNqhAc#/run/31f74082d85b5ffdaf9f34ed37480bbd-32-6/finding/138fa550c81efa6efc7170191b75c4a22caea51f) | Open | Low | First found in May 2024 |
| **4** | Panic from db page expected to be 5 but identifies as 0 | **Reported Issue Unable to be Reproduced, Found by Antithesis** | [Triage Report](https://linuxfoundation.antithesis.com/report/G-9rIjiZJiwodTEN5avQ7wgK/u_uFsWOwZSxS5mOmbEprwMUijNhsWdV6mfde_CT-y4k.html?auth=v2.public.eyJuYmYiOiIyMDI1LTA3LTAzVDA3OjMxOjUyLjQzMzQ2ODk3NFoiLCJzY29wZSI6eyJSZXBvcnRTY29wZVYxIjp7ImFzc2V0IjoidV91RnNXT3daU3hTNW1PbWJFcHJ3TVVpak5oc1dkVjZtZmRlX0NULXk0ay5odG1sIiwicmVwb3J0X2lkIjoiRy05cklqaVpKaXdvZFRFTjVhdlE3d2dLIn19fUHU0wnVRoDtfilwOCROUiDTtcOlIZkrVaddCqjorH3utgcIEPIzlsrMAJGXFC6NTZMneLqAWWU_lq-9prD_tQc#/run/9088730ba7972869a3e2b68b66708b55-32-6/finding/b9cbdf1bc8bd74cab1388e30ebdbf0b37c6f1420) | Open | Low | Previously reported; maintainers closed issue without fixing |
| **5** | Determining operation time based on watch response is incorrect | tests/robustness/validate **Exposed failed logic in linearizability checking model.** | [Triage Report](https://linuxfoundation.antithesis.com/report/IVzVnBQKQ0aInboRbRdsVDIE/xlfYJ3eyHooIxRJqHjimRYPrnttrULyr8PqOfRD0pS8.html?auth=v2.public.eyJuYmYiOiIyMDI1LTA1LTIxVDA5OjMzOjUzLjcyODgwNTA4MVoiLCJzY29wZSI6eyJSZXBvcnRTY29wZVYxIjp7ImFzc2V0IjoieGxmWUozZXlIb29JeFJKcUhqaW1SWVBybnR0clVMeXI4UHFPZlJEMHBTOC5odG1sIiwicmVwb3J0X2lkIjoiSVZ6Vm5CUUtRMGFJbmJvUmJSZHNWRElFIn19fc8p5s8qWPm5KxSC8oqMFj8HzTze7dxXhyPVt3l-GLwxSHIsuAIk1-2W7tgrh9mNXpZkFRhedvGSYNyhZ272kAo#/run/2e0ec6758e3603c3e4f5fd43dd26ffab-31-8/finding/5a95b2983bca202814eaa6a3fe594910a72cd2c6) | Fixed ([Github issue](https://github.com/etcd-io/etcd/issues/19998)) | Low | Only found in Antithesis; this was a bug in the test harness |

### Known Issues

Antithesis also successfully found and reproduced these known issues in older releases – the “[Brown M&M](https://www.safetydimensions.com.au/van-halen/)s” set by the etcd team.

| # | Description | Affected code | Report Link |
| :---- | :---- | :---- | :---- |
| **1** | [Watch dropping an event when compacting on delete](https://github.com/etcd-io/etcd/issues/18089) | server/storage/mvcc/kvstore.go | [Triage Report](https://linuxfoundation.antithesis.com/report/eYAhUOXW751VmJwPvGPa6R52/SFgfiy4PFXUGW5JkKt-uOnLFUVk9ZDIxFNQDRIS-eLE.html?auth=v2.public.eyJuYmYiOiIyMDI1LTA2LTAyVDIxOjI5OjMwLjAxNjk5OTQ5NloiLCJzY29wZSI6eyJSZXBvcnRTY29wZVYxIjp7ImFzc2V0IjoiU0ZnZml5NFBGWFVHVzVKa0t0LXVPbkxGVVZrOVpESXhGTlFEUklTLWVMRS5odG1sIiwicmVwb3J0X2lkIjoiZVlBaFVPWFc3NTFWbUp3UHZHUGE2UjUyIn19feadk3puhf0lkOv5k8GN_uQ74jb64WhykomO8nUZVBbUqRC-dLOnb7ENYLEjLW_rConu9ADWMFK_WVX7_zpX-wE#/run/6f713ca33a385cfa6d1987f125cbd951-31-8/finding/984b7ce364030642155dcd71d492711c9f9f73a9) |
| **2** | [Revision decreasing caused by crash during compaction](https://github.com/etcd-io/etcd/issues/17780) | server/storage/mvcc/kvstore.go | [Triage Report](https://linuxfoundation.antithesis.com/report/aRbi2JR9dqoXK2xvN-DfZi9S/r4GRi-BLXj6-kpaqz5fo8j8W-qUV1diKw6_x8vonLNk.html?auth=v2.public.eyJuYmYiOiIyMDI1LTA2LTAyVDIxOjMyOjQ5LjU1OTQ3Nzg2MFoiLCJzY29wZSI6eyJSZXBvcnRTY29wZVYxIjp7ImFzc2V0IjoicjRHUmktQkxYajYta3BhcXo1Zm84ajhXLXFVVjFkaUt3Nl94OHZvbkxOay5odG1sIiwicmVwb3J0X2lkIjoiYVJiaTJKUjlkcW9YSzJ4dk4tRGZaaTlTIn19fR5EmgiseZ02ngQHRC5uYXTIekPT7Z9Ta903abbN1xq-t2XYheG4YSlJFDdRIfyMpKKclB_uZGQOPd2kXKeutwM#/run/6a08b1cd0efe3d19b9bd89c6815e84e4-31-8/finding/5a95b2983bca202814eaa6a3fe594910a72cd2c6) |
| **3** | [Watch progress notification not synced with stream](https://github.com/etcd-io/etcd/issues/15220) | server/storage/mvcc & server/etcdserver/api/v3rpc | [Triage Report](https://linuxfoundation.antithesis.com/report/ymTYOGwzB-UwlmrjT8VrC_Kn/Y-D2b7S_BKdIl67UqZtXafn0xPhbRulSZVQvPqsBZak.html?auth=v2.public.eyJuYmYiOiIyMDI1LTA1LTI5VDEyOjAyOjIzLjUzMTc3MTg2MloiLCJzY29wZSI6eyJSZXBvcnRTY29wZVYxIjp7ImFzc2V0IjoiWS1EMmI3U19CS2RJbDY3VXFadFhhZm4weFBoYlJ1bFNaVlF2UHFzQlphay5odG1sIiwicmVwb3J0X2lkIjoieW1UWU9Hd3pCLVV3bG1yalQ4VnJDX0tuIn19fRmIEwPnKRaq1qnN9tKlGw0m--zs7uFUMMi3AaZM_Kz6Uy0IzsO-af3D1DDBFzSyclF13rqyjI-3ki2d9ufDNQk#/run/fa475411ad6b37641065963bc37b5dd4-31-8/finding/984b7ce364030642155dcd71d492711c9f9f73a9) |
| **4** | [Inconsistent revision caused by crash during defrag](https://github.com/etcd-io/etcd/pull/14685) | server/storage/backend/batch_tx.go | [Triage Report](https://linuxfoundation.antithesis.com/report/kuUVd-WEW4jkcEp7Uzsh-649/doX_RaZAkZxIOxxBn51bdhfjFzrV5ipnJYAQUAT2454.html?auth=v2.public.eyJuYmYiOiIyMDI1LTA2LTE5VDAxOjM3OjAxLjYyODQzMjM4OVoiLCJzY29wZSI6eyJSZXBvcnRTY29wZVYxIjp7ImFzc2V0IjoiZG9YX1JhWkFrWnhJT3h4Qm41MWJkaGZqRnpyVjVpcG5KWUFRVUFUMjQ1NC5odG1sIiwicmVwb3J0X2lkIjoia3VVVmQtV0VXNGprY0VwN1V6c2gtNjQ5In19fW1TcMbQfba6iffW4KX_yGOjmwg2qHbRsqzxhJOh8ywc6fxgJa8Lemw1ShkuhQs3caqWHlEEojyAEMVjlLPK4Ac#/run/8b12e3b98a5b206e30c5d0067746083e-32-6/finding/5a95b2983bca202814eaa6a3fe594910a72cd2c6) |
| **5** | [Watchable runlock bug](https://github.com/etcd-io/etcd/pull/13505) | server/storage/backend/batch_tx.go | [Triage Report](https://linuxfoundation.antithesis.com/report/6zkMqkEjjJuinArwLZTkJehM/7h42qHA5soBgxYPsMiDa4dSbA-O_g2SL9vkJqxvGON8.html?auth=v2.public.eyJzY29wZSI6eyJSZXBvcnRTY29wZVYxIjp7ImFzc2V0IjoiN2g0MnFIQTVzb0JneFlQc01pRGE0ZFNiQS1PX2cyU0w5dmtKcXh2R09OOC5odG1sIiwicmVwb3J0X2lkIjoiNnprTXFrRWpqSnVpbkFyd0xaVGtKZWhNIn19LCJuYmYiOiIyMDI1LTA1LTMwVDAwOjUyOjM2LjUwMjc3MTMyNFoifSYHsw1ZLCSfxME2keN58uGgi2yHTLvlg5_mFLkmePovjDjan-8SH72WdrmeWc4OMoRR-F3Pmi9UkU546_rtkgI#/run/8b82751143d9baaf98535089301d7af4-31-8/finding/984b7ce364030642155dcd71d492711c9f9f73a9) |

## Conclusion

The integration of autonomous testing into our development workflow has been a success. It has allowed us to find and fix critical bugs, improve our existing testing framework, and increase our confidence in the reliability of etcd. We will continue to leverage this technology to ensure that etcd remains a stable and trusted distributed key-value store for the community.
