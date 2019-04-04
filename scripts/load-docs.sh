#!/bin/bash

git submodule update --recursive

ROOT=$(git rev-parse --show-toplevel)
ORIGINAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)

RELEASES=$(cat ${ROOT}/RELEASES)

for release in ${RELEASES}; do
    echo "Loading release v${release}"
    cd ${ROOT}/etcd
    git checkout v${release}
    cp -rf Documentation ${ROOT}/content/docs/v${release}
done

cd ${ROOT}
git checkout ${ORIGINAL_BRANCH}
