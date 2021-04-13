# etcd.io

This repository houses all of the assets used to build the etcd docs and website available at https://etcd.io.

## Run the site locally

### Prerequisites

To build and serve the site, you'll need these tools:

- **[Hugo, extended edition][hugo-install]**; match the version specified in
  [netlify.toml](netlify.toml)
- **Node**, the latest [LTS release][]. Like Netlify, we use **[nvm][]**, the
  Node Version Manager, to install and manage Node versions:
  ```console
  $ nvm install --lts
  $ nvm use --lts
  ```

### Setup

Once you've installed the [prerequisites](#prerequisites), get local packages:

```bash
npm install
```

### Running

Once the [setup](#setup) has completed, you can locally serve the site:

```bash
npm run serve
```

#### Docker

You can also run the site locally using [Docker](https://docker.com):

```bash
make docker-serve
```

## Publishing the site

The site is published automatically by [Netlify](https://netlify.com). Any time
changes are pushed to the main branch, the site is built and deployed.

### Preview builds

Any time you submit a pull request to this repository, Netlify will publish a
[preview
build](https://www.netlify.com/blog/2016/07/20/introducing-deploy-previews-in-netlify/)
of the changes in that pull request. You can find a link to the preview build in
the checks section of the pull request, under **netlify/etcd/deploy-preview**.

## Releasing a new version of the etcd documentation

Follow these steps to add documentation for a newly released version of etcd, vX.Y:

* Recursively copy [content/docs/current](content/docs/current) into
  `content/docs/vX.Y`, where `vX.Y` is the newly released version of etcd. For example:

    ```bash
    cp -r content/docs/current content/docs/v3.5
    ```

* In the `_index.md` file at the root of the new directory, update the `title`
  metadata to reflect the new version. The title should read `etcd version
  <new-version>`.
* Add the version to the `params.versions.all` array in the
  [config.toml](config.toml) configuration file.
* If the version is meant to be the latest version of etcd, change the
  `params.versions.latest` parameter to the desired new version.
* Submit a pull request with the changes.

## Troubleshooting

If you have an issue with updating the documentation, file an issue against this
repo.

# License

etcd.io is licensed under an [Apache 2.0 license](./LICENSE).

The etcd documentation (e.g., `.md` files in the `/content/docs` folder) is licensed under a [CC-BY-4.0 license](https://creativecommons.org/licenses/by/4.0/). 

[hugo-install]: https://gohugo.io/getting-started/installing
[LTS release]: https://nodejs.org/en/about/releases/
[nvm]: https://github.com/nvm-sh/nvm/blob/master/README.md#installing-and-updating
