#!/usr/bin/env bash

# determine this files directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

MODE="install"
if [ $# -eq 1 ]
then
    MODE=$1
fi

if [ $MODE = "install" ]
then
    rm -rf $DIR/../../app/backend/vendor
    rm -f $DIR/../../app/backend/composer.lock
fi

docker run --rm -v "$DIR/../../app/backend":/app opinephp/backendcomposer $MODE
