#!/usr/bin/env bash

set -eu

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

pushd "${script_dir}"/..

  echo "-----> [$(date -u)]: Upload stemcell"

  if [[ -z $STEMCELL_PATH ]]; then
    bosh -n upload-stemcell "https://bosh.io/d/stemcells/${STEMCELL_NAME:-"bosh-warden-boshlite-ubuntu-xenial-go_agent"}?v=${STEMCELL_VERSION:-"315.36"}" \
      --version "${STEMCELL_VERSION:-"315.36"}" \
      --sha1 "${STEMCELL_SHA1:-"b33bc047562aab2d9860420228aadbd88c5fccfb"}" \
      --name "${STEMCELL_NAME:-"bosh-warden-boshlite-ubuntu-xenial-go_agent"}"
  else
    bosh -n upload-stemcell "$STEMCELL_PATH"
  fi

  echo "-----> [$(date -u)]: Delete old deployment"
  bosh -n -d test delete-deployment --force

  echo "-----> [$(date -u)]: Deploy"
  test_packagename="$(find ./packages -type d -name "*-test" | awk '{print $NF}' FS=/)"
  bosh -n -d test deploy ./manifests/test.yml -v crystal-test-job="$test_packagename"

  echo "-----> [$(date -u)]: Run test errand"
  bosh -n -d test run-errand "$test_packagename"

  echo "-----> [$(date -u)]: Delete deployments and cleanup"
  bosh -n -d test delete-deployment
  bosh -n clean-up --all

  echo "-----> [$(date -u)]: Done"

popd
