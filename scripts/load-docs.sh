#!/bin/bash

git submodule update --recursive

ROOT=$(git rev-parse --show-toplevel)

RELEASES=$(cat ${ROOT}/RELEASES)

for release in ${RELEASES}; do
    echo "Loading release v${release}"
    cd ${ROOT}/etcd
    git checkout v${release}
    cp -rf Documentation ${ROOT}/content/docs/v${release}
done
