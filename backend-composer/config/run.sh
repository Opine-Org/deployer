#!/usr/bin/env bash


runuser -s /bin/bash www-data -c "cd /app && composer --ansi $1"
