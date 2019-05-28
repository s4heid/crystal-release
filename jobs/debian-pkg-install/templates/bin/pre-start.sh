#!/bin/bash

set -x

archivesDir="/var/vcap/packages/debian-required/apt/cache/archives"

if [ -d "$archivesDir" ]; then
  cd $archivesDir
  . install-packages.sh
fi
