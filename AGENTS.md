# AGENTS.md

This file provides guidance to AI coding agents when working with code in this repository.

## What this is

The source for [etcd.io](https://etcd.io) — a [Hugo](https://gohugo.io) static site using the
[Docsy](https://www.docsy.dev) theme, hosted on Netlify. This repo is **content + theme config only**; the
etcd source code lives in the separate [etcd-io/etcd](https://github.com/etcd-io/etcd) repo. Most work here
is editing Markdown under `content/en/`.

## Commands

```bash
npm install            # installs deps; Docsy theme is an npm package (devDependencies), NOT a git submodule
npm run serve          # local dev server via `netlify dev` -> hugo serve, http://localhost:8888
npm run build          # hugo build into public/ (dev env)
npm run check-links    # htmltest over public/ (run after a build; skips external links by default)
npm run check-links:all # include external links
make markdown-diff-lint # markdownlint-cli2 on files changed vs main (PULL_BASE_SHA); same check CI runs
```

- Node version: nvm `lts/*` (`.nvmrc`). Hugo is pinned via the `hugo-extended` npm package (do not rely on a
  system Hugo).
- `make check-links` auto-downloads `htmltest` if not on PATH. Link-check requires a fresh `public/` build.
- `markdownlint` config (`.markdownlint-cli2.yaml`) disables line-length and MD052; CI lints **only changed
  line ranges**, so pre-existing violations outside your diff won't fail.

## Content structure

- `content/en/` is the site root (`contentDir`). Everything is English-only; no other language dirs.
- `content/en/docs/vX.Y/` — one tree per etcd minor version. `latest_stable_version` (in `config.yaml`)
  controls what `/docs/latest/` resolves to.
- `content/en/blog/<year>/` — blog posts, one file each. Copy front matter from a recent post
  (`title`, `author`, `date`, `draft`). `archetypes/blog.md` is the `hugo new` template but existing posts use
  a simpler `author:` string rather than the archetype's `authors:` list.
- `data/used_by.yaml`, `static/`, `assets/` — adopters list, static files, and SCSS/JS pipeline inputs.
- `layouts/` overrides Docsy partials/shortcodes (e.g. `layouts/shortcodes/`, `layouts/partials/version-banner.html`).

## Conventions that bite

- **Config is `config.yaml`, not `config.toml`.** The README still references `config.toml` and a
  `content/en/docs/next` directory — both are stale (see the README's own note pointing to issue #406). Trust
  `config.yaml` and the actual tree.
- Adding a new docs version: copy an existing `content/en/docs/vX.Y` tree, set the `_index.md` front matter
  (`title`, `weight`, `cascade.version`), then add the version to `params.versions` in `config.yaml`. Bump
  `latest_stable_version` only if it's the new stable.
- `scripts/update_release_version.sh` (driven by `make update-release-version LATEST_VERSION=vX.Y.Z` and the
  `.github/workflows/update-release-version*.yaml`) automates bumping `git_version_tag` in a version's
  `_index.md` — used when etcd cuts a patch release. Don't hand-edit that field if the automation covers it.
- Docsy shortcodes are available in Markdown, e.g. `{{%/* alert title="Note" color="info" */%}}...{{%/* /alert */%}}`.
- Goldmark runs with `unsafe: true` (raw HTML allowed) and a typographer that renders `--` as an en dash.

## Contributing

All commits must be signed off under the [Developer Certificate of Origin][dco] — every commit message needs a
`Signed-off-by` trailer:

```
Signed-off-by: Author Name <authoremail@example.com>
```

Add it automatically with `git commit -s`. PRs with unsigned commits are blocked by the DCO check.

Netlify posts a deploy preview on each PR. Merges to `main` auto-deploy to production.

[dco]: https://developercertificate.org/

### AI assistance

This project follows the [Kubernetes AI Guidance for pull requests][k8s-ai]. In short:

- Using AI tools is fine, but **you** are responsible for understanding every change.
- **Disclose** AI use in the PR description (e.g. "This PR was written in part with the assistance of
  generative AI").
- Do **not** list AI tooling as a co-author, co-sign commits with an AI tool, or use `assisted-by` /
  `co-developed` / similar commit trailers. AI-generated commit messages and large auto-generated PRs are not
  allowed.

[k8s-ai]: https://github.com/kubernetes/community/blob/main/contributors/guide/pull-requests.md#ai-guidance
