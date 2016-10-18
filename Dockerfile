FROM ruby:2.1-onbuild
ADD postkubevents.rb .
ADD Gemfile .
ADD Gemfile.lock .
CMD ["./postkubevents.rb"]
