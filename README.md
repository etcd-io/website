# etcd.io

This repository houses all of the assets used to build the future website and documentation at https://etcd.netlify.com. The site will eventually be available at https://etcd.io.

## Run the site locally

### Prerequisites

In order to run the site locally, you need to have the following installed:

* The [Yarn](https://yarnpkg.com/en/) package manager
* The [Hugo](https://gohugo.io) static site generator. Check the [`netlify.toml`](./netlify.toml) configuration file to see which version of Hugo you need to install.

    > **Note**: You need to install the "extended" version of Hugo with support for [Sass](https://sass-lang.com/).

### Setup

Once you've installed the [prerequisites](#prerequisites):

```bash
make setup
```

### Running

Once the [setup](#setup) has completed, you can run the site in your local environment:

```bash
make serve
```

#### Docker

You can also run the site locally using [Docker](https://docker.com):

```bash
make docker-serve
```

## Publishing the site

The site is published automatically by [Netlify](https://netlify.com). Any time 
changes are pushed to the `master` branch, the site is rebuilt and redeployed.

### Preview builds

Any time you submit a pull request to this repository, Netlify will publish a [preview build](https://www.netlify.com/blog/2016/07/20/introducing-deploy-previews-in-netlify/) of the changes in that pull request. You can find a link to the preview build in the checks section of the pull request, under **netlify/etcd/deploy-preview**.

## Releasing a new version of the etcd documentation

In order to add documentation for a version of etcd, you need to:

* Navigate to the `etcd-io/etcd` repo and checkout the tag for the version, for example `git checkout v3.3.12`.
* Copy the `Documentation` directory from the main `etcd` repo into the `content/docs` directory of this repository, renaming the directory to match the version. Here's an example for (non-existing) version 4.3.2:

    ```bash
    cp -rf /path/to/etcd-io/etcd/Documentation /path/to/etcd-io/website/content/docs/v4.3.2
    ```

* In the `_index.md` file at the root of the new directory, update the `title` metadata to reflect the new version. The title should read `etcd version <new-version>`.
* Add the version to the `params.versions.all` array in the [`config.toml`](./config.toml) configuration file.
* If the version is meant to be the latest version of etcd, change the `params.versions.latest` parameter to the desired new version.
* Submit a pull request with the changes.

## Troubleshooting

If you have an issue with updating the documentation, file an issue against this repo and cc [lucperkins](https://github.com/lucperkins).
