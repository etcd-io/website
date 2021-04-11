---
title: etcd发布指南
weight: 1550
description: 如何发布新版本的etcd
---

该指南讨论了如何发布etcd的新版本。

该过程包括一些用于完整性检查的手动步骤，但是可能可以进一步编写脚本。如果对发布过程进行更改，请保持此文档为最新。

## 发布管理

分配了etcd社区成员来管理每个etcd主要/次要版本的发行版，以及管理补丁程序和每个稳定发行版的分支。管理人员负责传达每个发布的时间表和状态，并确保发布分支的稳定性。

| 发行版 | 管理者 |
| -------- | ------- |
| 3.1 patch (post 3.1.0) | Joe Betz [@jpbetz](https://github.com/jpbetz) |
| 3.2 patch (post 3.2.0) | Joe Betz [@jpbetz](https://github.com/jpbetz) |
| 3.3 patch (post 3.3.0) | Gyuho Lee [@gyuho](https://github.com/gyuho) |

## 准备发布

将所需版本设置为环境变量，以进行以下步骤。以下是发布2.3.0的示例：

```
export VERSION=v2.3.0
export PREV_VERSION=v2.2.5
```

所有发行版本号都遵循[2.0.0语义版本](http://semver.org/)的格式。

### 主要版本，次要版本或其预发行版

- 确保GitHub上的相关里程碑已完成。所有相关的问题均应关闭，或移至其他位置。
- 如有必要，请从[里程碑](https://github.com/etcd-io/etcd/blob/master/ROADMAP.md)删除此发行版本。
- 确保最新的升级文档可用。
- 如有必要，点击[仓库中最小集群版本的硬编码](https://github.com/etcd-io/etcd/blob/master/version/version.go#L29)
- 如有必要，为新版本添加功能映射。

### 补丁版本发布


- 为了向后兼容，开发者提交针对发行分支提交。提交不应包括合并提交。提交应仅限于错误修复和安全补丁。
- 可提交的分支应当针对适当的发行分支(`base:release-<major>-<minor>`). `hack/patch/cherrypick.sh` 可用于自动生成可合并的提交.
- 发行补丁程序管理器检查提交的拉取请求。请仔细讨论将什么反向移植到该修补程序版本中。每个补丁程序发行版都应严格比其先前版本更好。
- 发行补丁程序管理器将从最旧的提交开始将这些提交挑选到稳定的分支中。

## Write release note

- Write introduction for the new release. For example, what major bug we fix, what new features we introduce or what performance improvement we make.
- Put `[GH XXXX]` at the head of change line to reference Pull Request that introduces the change. Moreover, add a link on it to jump to the Pull Request.
- Find PRs with `release-note` label and explain them in `NEWS` file, as a straightforward summary of changes for end-users.

## Tag version

- Bump [hardcoded Version in the repository](https://github.com/etcd-io/etcd/blob/master/version/version.go#L30) to the latest version `${VERSION}`.
- Ensure all tests on CI system are passed.
- Manually check etcd is buildable in Linux, Darwin and Windows.
- Manually check upgrade etcd cluster of previous minor version works well.
- Manually check new features work well.
- Add a signed tag through `git tag -s ${VERSION}`.
- Sanity check tag correctness through `git show tags/$VERSION`.
- Push the tag to GitHub through `git push origin tags/$VERSION`. This assumes `origin` corresponds to "https://github.com/etcd-io/etcd".

## Build release binaries and images

- Ensure `docker` is available.

Run release script in root directory:

```
TAG=gcr.io/etcd-development/etcd ./scripts/release.sh ${VERSION}
```

It generates all release binaries and images under directory ./release.

## Sign binaries, images, and source code

etcd project key must be used to sign the generated binaries and images.`$SUBKEYID` is the key ID of etcd project Yubikey. Connect the key and run `gpg2 --card-status` to get the ID.

The following commands are used for public release sign:

```
cd release
for i in etcd-*{.zip,.tar.gz}; do gpg2 --default-key $SUBKEYID --armor --output ${i}.asc --detach-sign ${i}; done
for i in etcd-*{.zip,.tar.gz}; do gpg2 --verify ${i}.asc ${i}; done

# sign zipped source code files
wget https://github.com/etcd-io/etcd/archive/${VERSION}.zip
gpg2 --armor --default-key $SUBKEYID --output ${VERSION}.zip.asc --detach-sign ${VERSION}.zip
gpg2 --verify ${VERSION}.zip.asc ${VERSION}.zip

wget https://github.com/etcd-io/etcd/archive/${VERSION}.tar.gz
gpg2 --armor --default-key $SUBKEYID --output ${VERSION}.tar.gz.asc --detach-sign ${VERSION}.tar.gz
gpg2 --verify ${VERSION}.tar.gz.asc ${VERSION}.tar.gz
```

The public key for GPG signing can be found at [CoreOS Application Signing Key](https://coreos.com/security/app-signing-key)


## Publish release page in GitHub

- Set release title as the version name.
- Follow the format of previous release pages.
- Attach the generated binaries and signatures.
- Select whether it is a pre-release.
- Publish the release!

## Publish docker image in gcr.io

- Push docker image:

```
gcloud docker -- login -u _json_key -p "$(cat /etc/gcp-key-etcd.json)" https://gcr.io

for TARGET_ARCH in "-arm64" "-ppc64le" ""; do
  gcloud docker -- push gcr.io/etcd-development/etcd:${VERSION}${TARGET_ARCH}
done
```

- Add `latest` tag to the new image on [gcr.io](https://console.cloud.google.com/gcr/images/etcd-development/GLOBAL/etcd?project=etcd-development&authuser=1) if this is a stable release.

## Publish docker image in Quay.io

- Build docker images with quay.io:

```
for TARGET_ARCH in "amd64" "arm64" "ppc64le"; do
  TAG=quay.io/coreos/etcd GOARCH=${TARGET_ARCH} \
    BINARYDIR=release/etcd-${VERSION}-linux-${TARGET_ARCH} \
    BUILDDIR=release \
    ./scripts/build-docker ${VERSION}
done
```

- Push docker image:

```
docker login quay.io

for TARGET_ARCH in "-arm64" "-ppc64le" ""; do
  docker push quay.io/coreos/etcd:${VERSION}${TARGET_ARCH}
done
```

- Add `latest` tag to the new image on [quay.io](https://quay.io/repository/coreos/etcd?tag=latest&tab=tags) if this is a stable release.

## Announce to the etcd-dev Googlegroup

- Follow the format of [previous release emails](https://groups.google.com/forum/#!forum/etcd-dev).
- Make sure to include a list of authors that contributed since the previous release - something like the following might be handy:

```
git log ...${PREV_VERSION} --pretty=format:"%an" | sort | uniq | tr '\n' ',' | sed -e 's#,#, #g' -e 's#, $##'
```

- Send email to etcd-dev@googlegroups.com

## Post release

- Create new stable branch through `git push origin ${VERSION_MAJOR}.${VERSION_MINOR}` if this is a major stable release. This assumes `origin` corresponds to "https://github.com/etcd-io/etcd".
- Bump [hardcoded Version in the repository](https://github.com/etcd-io/etcd/blob/master/version/version.go#L30) to the version `${VERSION}+git`.
