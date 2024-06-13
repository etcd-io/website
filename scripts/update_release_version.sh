#!/usr/bin/env bash
# This script updates the version of the release in the release file
# Usage: ./update_release_version.sh <new_version>

set -eo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <new_version>"
  exit 1
fi

new_version="$1"
release_minor=$(echo "$new_version" | cut -d. -f1-2)
index_file=content/en/docs/"$release_minor"/_index.md
git_remote="${GIT_REMOTE:-origin}"
branch="release-${release_minor}-update-latest-release-to-${new_version}"
current_branch=$(git symbolic-ref HEAD --short)

if [ -z "$GITHUB_ACTOR" ]; then
  git_author="$(git config user.name)"
  git_email="$(git config user.email)"
else
  git_author="$GITHUB_ACTOR"
  git_email="$GITHUB_ACTOR@users.noreply.github.com"
fi

# Check for prerequisites to run the script.
if ! which gh >/dev/null; then
  echo "gh needs to be installed for this script to work"
  exit 1
fi
if ! gh auth status >/dev/null; then
  echo "gh needs to be authenticated for this script to work"
  exit 1
fi
if ! grep git_version_tag "$index_file" | grep -v -e "$new_version\$" >/dev/null; then
  echo "nothing to do; file $index_file is already up to date with $new_version"
  exit 0
fi
if git ls-remote --exit-code "$git_remote" --heads refs/heads/"$branch" >/dev/null; then
  echo "nothing to do; branch $branch already exists"
  exit 0
fi

# Switch to a new branch.
git checkout -b "$branch"
trap 'git checkout "$current_branch"' EXIT

# Update the release version in the release file.
sed -i 's/git_version_tag:\sv\([0-9]\+\.\)\{2\}[0-9]\+/git_version_tag: '"$new_version"'/' "$index_file"

# Commit the changes, push and create a PR.
git add "$index_file"
git -c user.name="$git_author" -c user.email="$git_email" commit --file=- <<EOL
[${release_minor}] Update installation version to latest tag (${new_version})

Signed-off-by: ${git_author} <${git_email}>
EOL
git push "$git_remote" "$branch"
gh pr create --fill --body "Automated update for ${release_minor}: ${new_version}"
