consumer: sequel -m db/migrations $DATABASE_URL && bundle exec bin/consumer
web: bundle exec thin start -R config.ru -e $RACK_ENV -p $PORT
