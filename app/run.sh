#!/usr/bin/env bash

# determine this files directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

ENV="local"
if [ $# -eq 1 ]
then
    ENV=$1
fi

PERSISTENT_DIR="$DIR/../../persistent"
if [ $ENV != "local" ]
then
    docker pull opinephp/application
    mkdir -p /app/persistent
    PERSISTENT_DIR="/app/persistent"
else
    mkdir -p "$PERSISTENT_DIR"/log
fi

PROJECT_NAME="$(cd "$DIR/../.." && basename $PWD)"

docker stop "$PROJECT_NAME"-server &> /dev/null
docker rm "$PROJECT_NAME"-server &> /dev/null

docker run \
    --name "$PROJECT_NAME"-server \
    -p 80:80 \
    -p 443:443 \
    -v "$DIR/../../app":/app \
    -v "$PERSISTENT_DIR":/media/persistent \
    -e OPINE_ENV="$ENV" \
    -d opinephp/application

echo "TO ENTER CONTAINER, RUN: sudo docker exec -i -t $PROJECT_NAME-server /bin/bash"
