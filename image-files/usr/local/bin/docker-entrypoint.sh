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

if [ "$1" = 'php-fpm' -a "$(id -u)" = '0' ]; then
	# Change the ownership of user-mutable directories to www-data
	for path in ${VOLUME_PATH[@]} \
	; do
		chown -R www-data:www-data "$path"
	done

	set -- gosu www-data "$@"
	#exec gosu www-data "$BASH_SOURCE" "$@"
fi

# Execute CMD
exec "$@"