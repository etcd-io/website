# etcd.io

The [etcd.io][] website, built using [Hugo][] and hosted on [Netlify][].

## Cloud build

Visit [https://gitpod.io/#https://github.com/etcd-io/website](https://gitpod.io/#https://github.com/etcd-io/website) to launch a [Gitpod.io](https://gitpod.io) IDE that will allow you to build, preview and make changes to this repo.

## Local build

To build and serve the site, you'll need the latest [LTS release][] of **Node**.
Like Netlify, we use **[nvm][]**, the Node Version Manager, to install and
manage Node versions:

```console
$ nvm install --lts
```

### Setup

 1. Clone this repo.
 2. From a terminal window, change to the cloned repo directory.
 3. Get NPM packages and git submodules, including the the [Docsy][] theme:
    ```console
    $ npm install
    ```

### Build or serve the site

To locally serve the site at [localhost:8888][], run the following command:

```console
$ npm run serve
```

> **NOTE:** If you want to **check links** locally, you (temporarily) might have
> some extra setup to do. For details, see issue
> [#459](https://github.com/etcd-io/website/issues/459).

To build and check links, run these commands:

```console
$ npm run build
$ npm run check-links
```

## Contributing

We welcome issues and PRs! For details, see [Contributing][].

If you submit a PR, Netlify will automatically create a [deploy preview][] so
that you can view your changes. Once merged, Netlify automatically deploys to
the production site [etcd.io][].

## Releasing a new version of the etcd documentation

> **IMPORTANT**: this section is out-of-date, see issue [#406][].

Follow these steps to add documentation for a newly released version of etcd, vX.Y:

* Recursively copy the most recent existing version directory under
  [content/en/docs](content/en/docs) into `content/en/docs/vX.Y`, where `vX.Y`
  is the new version of etcd. For example, to create `v3.9` from `v3.8`:

    ```bash
    cp -r content/en/docs/v3.8 content/en/docs/v3.9
    ```

* In the `_index.md` file at the root of the new directory, update the front matter
  to reflect the new version. For example, for a draft version (see
  [content/en/docs/v3.8/_index.md](content/en/docs/v3.8/_index.md)):
  ```yaml
  ---
  title: vX.Y docs
  cascade:
    version: vX.Y
    versName: &name vX.Y-DRAFT
    git_version_tag: main
    exclude_search: true
    page_warning: the documentation is in **DRAFT** status.
  linkTitle: *name
  simple_list: true
  weight: -XY0 # Weight for doc version vX.Y should be -XY0
  ---
  ```
  When the version is released, set `versName` to `vX.Y`, set
  `git_version_tag` to the release tag (for example `vX.Y.0`), set
  `exclude_search` to `false`, and remove `page_warning`. See
  [content/en/docs/v3.7/_index.md](content/en/docs/v3.7/_index.md) for a released version.
* Add the version to the `params.versions` list in the
  [config.yaml](config.yaml) configuration file, as a new `version`/`url`
  entry at the top of the list:
  ```yaml
  versions:
    - version: vX.Y
      url: /docs/vX.Y/
  ```
* If the version is meant to be the latest stable version of etcd, change the
  `params.latest_stable_version` parameter in `config.yaml` to the new version.
* Submit a pull request with the changes.

[#406]: https://github.com/etcd-io/website/issues/406
[Contributing]: https://etcd.io/community/#contributing
[deploy preview]: https://www.netlify.com/blog/2016/07/20/introducing-deploy-previews-in-netlify/
[Docsy]: https://www.docsy.dev
[etcd.io]: https://etcd.io
[Hugo]: https://gohugo.io
[localhost:8888]: http://localhost:8888
[LTS release]: https://nodejs.org/en/download/
[Netlify]: https://netlify.com
[nvm]: https://github.com/nvm-sh/nvm/blob/master/README.md#installing-and-updating
