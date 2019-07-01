#!/usr/bin/env bash

set -euo pipefail

: "${BLOBSTORE_ACCESS_KEY_ID:?"blobstore access key id missing"}"
: "${BLOBSTORE_SECRET_ACCESS_KEY:?"blobstore secret access key missing"}"

# shellcheck disable=SC1090
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/utils.sh"

cd bumped-crystal-release
git clone --quiet ../crystal-release .

cat >> config/private.yml <<EOF
---
blobstore:
  provider: s3
  options:
    access_key_id: "$BLOBSTORE_ACCESS_KEY_ID"
    secret_access_key: "$BLOBSTORE_SECRET_ACCESS_KEY"
EOF

set -x

crystal_filepath="$(readlink -f ../crystal/crystal-*-1-linux-x86_64.tar.gz)"
crystal_version="$(cat ../crystal/version)"

crystal_packagename="crystal-${crystal_version}"
test_packagename="${crystal_packagename}-test"

declare -a template_vars=(
  "crystal_version=$crystal_version"
  "crystal_blob=$(basename "$crystal_filepath")"
  "crystal_packagename=$crystal_packagename"
  "test_packagename=$test_packagename"
)


echo "-----> $(date): Rendering package and job templates"

git rm -r packages/crystal-* && :
git rm -r jobs/crystal-* && :

mkdir -p packages/{"$crystal_packagename","$test_packagename"}
mkdir -p "jobs/$test_packagename/templates"

erb "${template_vars[@]}" "ci/templates/packages/crystal/spec.erb" > "packages/$crystal_packagename/spec"
erb "${template_vars[@]}" "ci/templates/packages/crystal/packaging.erb" > "packages/$crystal_packagename/packaging"
erb "${template_vars[@]}" "ci/templates/packages/crystal-test/spec.erb" > "packages/$test_packagename/spec"
erb "${template_vars[@]}" "ci/templates/packages/crystal-test/packaging.erb" > "packages/$test_packagename/packaging"

erb "${template_vars[@]}" "ci/templates/jobs/crystal-test/monit.erb" > "jobs/$test_packagename/monit"
erb "${template_vars[@]}" "ci/templates/jobs/crystal-test/spec.erb" > "jobs/$test_packagename/spec"
erb "${template_vars[@]}" "ci/templates/jobs/crystal-test/templates/run.erb" > "jobs/$test_packagename/templates/run"

erb "${template_vars[@]}" "ci/templates/src/compile.env.erb" > "src/compile.env"
erb "${template_vars[@]}" "ci/templates/src/runtime.env.erb" > "src/runtime.env"

erb "${template_vars[@]}" "ci/templates/README.md.erb" > "README.md"


echo "-----> $(date): Syncing and uploading blobs to S3"

sync-blobs "$crystal_filepath" "$(pwd)"

# TODO: uncomment this
# bosh upload-blobs


echo "-----> $(date): Creating git commit"

export GIT_COMMITTER_NAME="Concourse"
export GIT_COMMITTER_EMAIL="concourse.ci@localhost"

git config --global user.email "${GIT_USER_EMAIL:-ci@localhost}"
git config --global user.name "${GIT_USER_NAME:-CI Bot}"

git add .
git --no-pager diff --cached

if [[ -n $(git status --porcelain) ]]; then
  git commit -m "Updating blobs via concourse"
fi
