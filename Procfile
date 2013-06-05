consumer: sequel -m db/migrations $DATABASE_URL && bundle exec bin/consumer
web: bundle exec puma --quiet --threads 8:32 --port $PORT config.ru
