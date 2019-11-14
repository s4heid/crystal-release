#!/usr/bin/env bash

set -eux

# shellcheck disable=SC1090
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/utils.sh"

cp -rfp ./crystal-release/. finalized-release

commits=$(git -C finalized-release log --oneline origin/master..HEAD | wc -l)
if [[ "$commits" == "0" ]]; then
  :> version-tag/tag-name
  :> version-tag/annotate-msg
  exit 0
fi

export full_version=$(cat semver/version)

pushd finalized-release
  git status

  configure-git
  prepare-credentials

  bosh create-release --tarball=/tmp/crystal-release.tgz --timestamp-version --force
  bosh finalize-release --version "$full_version" /tmp/crystal-release.tgz

  git add -A
  git status

  git commit -m "Final release $full_version via concourse"
popd

echo "v${full_version}" > version-tag/tag-name
echo "Final release $full_version tagged via concourse" > version-tag/annotate-msg
