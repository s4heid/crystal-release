#!/usr/bin/env bash

set -eux


echo "-----> [$(date -u)]: Starting Docker and Director"

start-bosh

# shellcheck disable=SC1091
source /tmp/local-bosh/director/env


echo "-----> [$(date -u)]: Run tests"

basedir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"

export STEMCELL_PATH=$( echo "${basedir}"/../stemcell/*.tgz )
# export STEMCELL_OS=$( tar -Oxzf "$stemcell_path" stemcell.MF | grep '^operating_system: ' | awk '{ print $2 }' )

${basedir}/tests/run.sh
