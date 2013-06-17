web: bundle exec puma -t 0:8 -p $PORT -e $RACK_ENV
worker: bundle exec sidekiq -C config/sidekiq.yml
