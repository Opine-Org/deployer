#!/usr/bin/env bash

# determine this files directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

docker pull opinephp/application

mkdir -p /app/persistent

docker run \
    --name opinephp-server \
    -p 80:80 \
    -p 443:443 \
    -v "$DIR":/app \
    -v /app/persistent:/media/persistent \
    -e OPINE_ENV=production \
    -d opinephp/application
