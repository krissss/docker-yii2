#!/bin/bash

# This script is run within the php containers on start

# Fail on any error
set -o errexit

if [ "${YII_MIGRATION_DO}" == 1 ]; then
    if [ ! -d "/flag-yii2-migrate" ]; then
        php yii migrate --interactive=0
        mkdir /flag-yii2-migrate
    fi
fi

if [ ! -z "${VOLUME_PATH}" ]; then
    if [ ! -d "/flag-volume-path" ]; then
        # Change the ownership of user-mutable directories to www-data
        for path in ${VOLUME_PATH[@]} \
        ; do
            mkdir -p "$path"
            chown -R www-data:www-data "$path"
            #echo "chown volume path: " "$path"
        done
        mkdir /flag-volume-path
        # 此处设置会产生操作权限问题（因此不启用此处时，gosu未使用到）
        #set -- gosu www-data "$@"
    else
        echo "flag-volume-path exist"
    fi
else
    echo "VOLUME_PATH empty"
fi

# Execute CMD
exec "$@"
