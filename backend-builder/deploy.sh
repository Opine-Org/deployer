#!/usr/bin/env bash

# determine this files directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

ENV="local"
if [ $# -eq 2 ]
  then
    ENV=$2
fi

docker run \
    -e "OPINE_ENV=$ENV" \
    --rm \
    -v "$DIR/../../app/.deployer/workspace/app/backend":/app \
    opinephp/backendbuilder \
    $1
