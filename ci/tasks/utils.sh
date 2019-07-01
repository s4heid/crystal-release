#!/bin/bash

set -eu

release_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../.."

function sync-blobs() {
  if [[ $# -lt 1 ]] || [[ $# -gt 2 ]]; then
    echo "wrong number of arguments specified" 1>&2
    return
  fi

  local blob_location="$1"
  if [[ ! -e "$blob_location" ]]; then
    echo "file '${blob_location}' does not exist" 1>&2
    return
  fi

  cd "${2:-"$release_dir"}"
  bosh blobs

  local blobname=$( basename "$( dirname "$blob_location" )" )

  for blob in $( bosh blobs --column=path | grep "^$blobname/" ); do
    if ! grep -q -R "${blob##*/}" ./packages ; then
      echo "removing unused blob $blob"
      bosh remove-blob "$blob"
      continue
    fi

    new_digest="$( shasum -a 256 "$blob_location" | awk '{ print $1 }' )"
    existing_digest="$( bosh blobs --sha2 --column=path --column=digest | grep "^$blob\s" | awk '{ print $2 }' )"
    if [[ "${existing_digest##*:}" == "${new_digest}" ]]; then
      echo "$blob (${existing_digest}) unchanged; skipping"
      continue
    fi

    echo "replacing existing blob $blob (${existing_digest} --> ${new_digest})"
    bosh remove-blob "$blob"
    bosh add-blob --sha2 "$blob_location" "$blob"
  done

  local blobfile="$( basename "$blob_location" )"

  if bosh blobs --column=path | grep -q "^${blobname}/${blobfile}\s"; then
    echo "${blobname}/${blobfile} already exists in 'config/blob.yml'; skipping"
  else
    echo "adding new blob $blobfile"
    bosh add-blob --sha2 "$blob_location" "${blobname}/${blobfile}"
  fi

  bosh blobs
}

function configure-git() {
  export GIT_COMMITTER_NAME="Concourse"
  export GIT_COMMITTER_EMAIL="concourse.ci@localhost"
  git config --global user.email "${GIT_USER_EMAIL:-ci@localhost}"
  git config --global user.name "${GIT_USER_NAME:-CI Bot}"
}

function prepare-credentials() {
  cat >> config/private.yml <<EOF
---
blobstore:
  provider: s3
  options:
    access_key_id: "$BLOBSTORE_ACCESS_KEY_ID"
    secret_access_key: "$BLOBSTORE_SECRET_ACCESS_KEY"
EOF
}
