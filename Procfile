web: bundle exec rails server puma -p $PORT -e $RACK_ENV
worker: bundle exec sidekiq -C config/sidekiq.yml