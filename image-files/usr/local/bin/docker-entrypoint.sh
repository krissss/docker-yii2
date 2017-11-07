#!/bin/bash

# This script is run within the php containers on start

# Fail on any error
set -o errexit

if [ ${YII_MIGRATION_DO} == 1 ]; then
    if [ ! -d "/yii2-migrat-flag" ]; then
        php yii migrate --interactive=0
        mkdir /yii2-migrat-flag
    fi
fi

# Execute CMD
exec "$@"