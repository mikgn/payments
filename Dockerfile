FROM ruby:3.2.2-bullseye

WORKDIR /app

COPY Gemfile Gemfile.lock /app/

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

RUN echo "deb http://deb.debian.org/debian/ bullseye main" > /etc/apt/sources.list && \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends gnupg dirmngr curl cron debian-keyring libyaml-dev && \
    apt-get install -y nodejs npm && \
    npm install -g yarn && \
    apt-get purge -y nodejs && \
    apt-get install -y npm && \
    npm install -g n && \
    n stable && \
    apt-get purge -y nodejs && \
    apt-get install -y npm && \
    rm -rf /var/lib/apt/lists/* && \
    gem install rails -v '7.0.3'

COPY . /app/

RUN bundle install

RUN yarn install

RUN bundle exec rake assets:precompile

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
