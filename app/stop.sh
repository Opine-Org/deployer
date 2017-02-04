#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_NAME="$(cd "$DIR/../.." && basename $PWD)"

docker stop "$PROJECT_NAME"-server &> /dev/null
docker rm "$PROJECT_NAME"-server &> /dev/null
