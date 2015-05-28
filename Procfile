web: bundle exec rackup -s puma -p $PORT
resque: env TERM_CHILD=1 COUNT=1 QUEUE=* bundle exec rake resque:work