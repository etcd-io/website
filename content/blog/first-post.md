---
title: First post
draft: true
date: 2019-12-01
authors:
- name: Luc Perkins
  twitter: lucperkins
---

Here is some blog post text that goes in the summary.

<!--more-->

This text will not go in the summary.

## Client architecture

Below is a diagram:

{{< figure src="/img/client-architecture-balancer-figure-01.png" >}}

Here is a code sample:

```python
class EtcdClient(object):
    def __init__(self, url):
        self.url = url

client = EtcdClient("localhost:1234")
```
