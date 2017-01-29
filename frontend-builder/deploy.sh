#!/usr/bin/env bash

# determine this files directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# set default value of config
if [ -z $1 ]
    then
        CONFIG="webpack.dev.client.js"
else
    CONFIG="$1"
fi

docker stop opinephp-frontend-dev &> /dev/null
docker rm opinephp-frontend-dev &> /dev/null
docker run \
    --rm \
    -t \
    -i \
    --name opinephp-frontend-dev \
    -v "$DIR/../../app/.deployer/workspace/app/frontend":/app \
    opinephp/webpack \
    $CONFIG
