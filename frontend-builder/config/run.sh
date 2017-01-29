#!/usr/bin/env bash

cd /app

# ensure ownership
mkdir -p /app/dist
mkdir -p /app/static
if [ -d /app ]; then
    chown -R www-data /app
    chmod -R ug+rw /app/*
fi

if [ $1 = "webpack.dev.client.js" ]
then
    # install any new dependencies
    runuser -s /bin/bash www-data -c "npm install"

    # run webpack in watch mode
    runuser -s /bin/bash www-data -c "./node_modules/.bin/webpack --progress --config $1 --display-error-details --colors --watch"

elif [ $1 = "webpack.prod.server.js" ]
then
    # install any new dependencies
    runuser -s /bin/bash www-data -c "npm install --silent"

    # build bundle once
    runuser -s /bin/bash www-data -c "./node_modules/.bin/webpack --no-info -p --config $1"

else
    # install any new dependencies
    runuser -s /bin/bash www-data -c "npm install --silent"

    # build bundle once
    runuser -s /bin/bash www-data -c "./node_modules/.bin/webpack --no-info -p --config $1"

    # ensure that id file exists
    touch ./static/bundle-prod-id.txt

    # read last version in the file
    LAST_UUID=$(tail -1 ./static/bundle-prod-id.txt)

    # check if there is an older build version yet
    if [ -z $LAST_UUID ]
    then
        # do nothing, first build
        LAST_UUID="xxx"
    fi

    # remove last build
    touch "./static/bundle-prod-$LAST_UUID.js"
    rm -f "./static/bundle-prod-$LAST_UUID.js" || true
    touch "./static/bundle-prod-$LAST_UUID.css"
    rm -f "./static/bundle-prod-$LAST_UUID.css" || true

    # remove source maps
    rm -f ./static/*.map || true

    # get a new random value
    UUID=$(cat /proc/sys/kernel/random/uuid)

    # copy the build file to a random value
    mv ./static/bundle-prod.js "./static/bundle-prod-$UUID.js"
    mv ./static/bundle-prod.css "./static/bundle-prod-$UUID.css"

    # save the id to a text file
    echo "$UUID" > ./static/bundle-prod-id.txt

    # set ownership of files
    chown www-data ./static/*
    chgrp www-data ./static/*
fi
