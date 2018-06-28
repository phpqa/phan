#!/usr/bin/env sh
set -e

if [ "$(printf %c "$1")" = '-' ]; then
  set -- /sbin/tini -- php /composer/vendor/bin/phan "$@"
elif [ "$1" = "/composer/vendor/bin/phan" ]; then
  set -- /sbin/tini -- php "$@"
elif [ "$1" = "phan" ]; then
  set -- /sbin/tini -- php /composer/vendor/bin/"$@"
fi

exec "$@"
