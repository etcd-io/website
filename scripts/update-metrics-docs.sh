#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
website_root="$(cd "${script_dir}/.." && pwd)"
etcd_repo_url="${ETCD_REPO_URL:-https://github.com/etcd-io/etcd.git}"
etcd_source="${ETCD_SOURCE:-}"

usage() {
  echo "Usage: $0 --version <vX.Y> [--tag <tag-or-branch>] [--name <slug>] [--verify]"
  exit 1
}

doc_tag() {
  sed -n 's/^[[:space:]]*git_version_tag:[[:space:]]*//p' "${website_root}/content/en/docs/${version}/_index.md" | head -n1
}

version=""
tag=""
name="etcd-metrics-latest"
verify=false
while [ "$#" -gt 0 ]; do
  case "$1" in
    --version) version="$2"; shift 2 ;;
    --tag) tag="$2"; shift 2 ;;
    --name) name="$2"; shift 2 ;;
    --verify) verify=true; shift ;;
    *) usage ;;
  esac
done

[ -n "${version}" ] || usage
if [ -z "${tag}" ]; then
  tag="$(doc_tag)"
fi
[ -n "${tag}" ] || { echo "error: could not resolve git_version_tag for ${version}" >&2; exit 1; }
if [ "${tag}" = "main" ] || [ "${tag}" = "master" ]; then
  echo "error: metrics docs can only be generated for released etcd tags" >&2
  exit 1
fi

output_dir="${website_root}/content/en/docs/${version}/metrics"
output_file="${output_dir}/${name}.txt"
[ -d "${output_dir}" ] || { echo "error: output directory '${output_dir}' missing" >&2; exit 1; }

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

if [ -z "${etcd_source}" ]; then
  etcd_source="${tmpdir}/etcd"
  git clone --depth 1 --branch "${tag}" "${etcd_repo_url}" "${etcd_source}" >/dev/null
elif [ -d "${etcd_source}/.git" ]; then
  tagged_source="${tmpdir}/etcd-${tag}"
  mkdir -p "${tagged_source}"
  git -C "${etcd_source}" archive "${tag}" | tar -x -C "${tagged_source}"
  etcd_source="${tagged_source}"
fi

generated="${output_file}"
if [ "${verify}" = true ]; then
  generated="${tmpdir}/${name}.txt"
fi

(cd "${etcd_source}" && go run ./tools/etcd-dump-metrics --download-ver "${tag}") >"${generated}"

if [ "${verify}" = true ]; then
  diff -u "${output_file}" "${generated}"
else
  echo "Generated ${output_file}"
fi
