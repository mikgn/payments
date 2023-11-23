#!/bin/sh
set -e

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

echo `yarn -v`
echo `node -v`
echo `npm -v`

yarn

bundle check || bundle install

# prepare db
bundle exec rake db:prepare

# prepare test db
bundle exec rake db:test:prepare

# update cron tasks
# whenever --update-crontab

exec "$@"
