#!/usr/bin/env bash

set -ex

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export STEMCELL_NAME="bosh-warden-boshlite-ubuntu-xenial-go_agent"
export STEMCELL_VERSION="315.36"
export STEMCELL_SHA1="b33bc047562aab2d9860420228aadbd88c5fccfb"

echo "-----> [$(date -u)]: Upload stemcell"
bosh -n upload-stemcell "https://bosh.io/d/stemcells/${STEMCELL_NAME}?v=${STEMCELL_VERSION}" \
  --sha1 $STEMCELL_SHA1 \
  --name $STEMCELL_NAME \
  --version $STEMCELL_VERSION

echo "-----> [$(date -u)]: Delete previous deployment"
bosh -n -d test delete-deployment --force

pushd "${script_dir}"/..
  echo "-----> [$(date -u)]: Deploy"
  bosh -n -d test deploy ./manifests/test.yml

  echo "-----> [$(date -u)]: Run test errand"
  bosh -n -d test run-errand crystal-0.28.0-test

  echo "-----> [$(date -u)]: Delete deployments"
  bosh -n -d test delete-deployment

  echo "-----> [$(date -u)]: Done"
popd
