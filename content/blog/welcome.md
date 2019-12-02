---
title: Welcome to the etcd blog!
date: 2019-12-05
authors:
- name: Luc Perkins
  twitter: lucperkins
---

Hello everyone! This is the first post on the etcd blog... at least in its new home.

<!--more-->

There *are* etcd-related posts on the [CoreOS](https://coreos.com/blog/etcd) blog but the etcd project moving under the neutral auspices of the [Cloud Native Computing Foundation](https://cncf.io) means that there was a need for a new place to present project updates, announcements, feature posts, and the like.

If you'd like to contribute to the blog, [pull requests](https://github.com/etcd/website/pulls) are open for [submitting your own post](#submit).

## Submitting a blog post {#submit}

To submit a post to the etcd blog:

1. Fork the [website repo](https://github.com/etcd-io/website)
1. Clone the repo locally:

    ```bash
    git clone https://github.com/YOUR_USERNAME/website && cd website
    ```

1. Create a new [Markdown](https://www.markdownguide.org) file under `content/blog`:

    ```bash
    touch content/blog/my-post.md
    ```

1. Add descriptive metadata to the file:

    ```yaml
    ---
    title: My post
    date: 2020-02-01
    authors:
    - name: Chan Marshall
      twitter: catpower
    ---
    ```

    The `title`, `date` (in `YYYY-MM-DD` format), and `authors` fields are necessary. You do *not* need to specify a Twitter account for the authors.

1. Write!

1. Submit a [pull request](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/about-pull-requests) to the website repo. And make sure each commit includes a [Developer Certificate of Origin](https://github.com/probot/dco)!

1. When you've submitted a pull request, you'll see a link for a [Netlify](https://netlify.com) deploy preview (under **netlify/etcd/deploy-preview**). Click on this link to see a live version of the site that includes your changes. Make sure that everything looks the way you want it to; if not, make and submit changes.

1. Once the post is approved, your pull request will be merged and the post will go live within just a few minutes!
