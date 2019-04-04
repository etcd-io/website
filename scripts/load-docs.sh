#!/bin/bash

git submodule update --recursive

ROOT=$(git rev-parse --show-toplevel)
ORIGINAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)

RELEASES=$(cat ${ROOT}/RELEASES)

for release in ${RELEASES}; do
    release_target_dir=${ROOT}/content/docs/v${release}
    echo "Loading release v${release}"
    cd ${ROOT}/etcd
    git checkout v${release}
    cp -rf Documentation ${release_target_dir}
    cp Documentation/docs.md ${release_target_dir}/_index.md
    rm ${release_target_dir}/docs.md
done

cd ${ROOT}
git checkout ${ORIGINAL_BRANCH}
