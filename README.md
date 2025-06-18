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

* Recursively copy [content/docs/next](content/docs/next) into
  `content/docs/vX.Y`, where `vX.Y` is the newly released version of etcd. For example:

    ```bash
    cp -r content/en/docs/next content/en/docs/v3.6
    ```

* In the `_index.md` file at the root of the new directory, update the frontmatter
  to reflect the new version:
  ```
  ---
  title: etcd version X.Y
  weight: 1000
  cascade:
    version: vX.Y
  ---
  ```
* Add the version to the `params.versions.all` array in the
  [config.toml](config.toml) configuration file.
* If the version is meant to be the latest version of etcd, change the
  `params.latest_stable_version` parameter to the desired new version.
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
