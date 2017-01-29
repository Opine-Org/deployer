#!/usr/bin/env bash

cd /app && runuser -s /bin/bash www-data -c 'composer dump-autoload'

if [ -d /app ]; then
    cd /app && chmod -R ug+rw ./*
    cd /app && chown www-data ./* -R
fi

runuser -s /bin/bash www-data -c "/app/vendor/opine/api/bin/opine $1"
