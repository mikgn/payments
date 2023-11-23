FROM ruby:3.1.2-slim

RUN apt-get update -qq && apt-get install --no-install-recommends -y \
      build-essential libpq-dev libxslt-dev curl cron npm && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
      /tmp/node-build-master/bin/node-build 20.9.0 /usr/local/node

# RUN rm -rf /tmp/node-build-master

ENV APP_HOME /app

RUN echo "gem: --no-rdoc --no-ri" > /etc/gemrc

WORKDIR $APP_HOME

COPY Gemfile Gemfile.lock ./
COPY package.json yarn.lock ./

RUN bundle check || bundle install --jobs 20 --retry 5

RUN npm install

COPY . .

RUN chmod +x ./entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]

# CMD ["rails", "s", "-p", "3000", "-b", "0.0.0.0"]
CMD ["bin/dev"]

############################################

# FROM ruby:3.1.2-alpine3.15

# ENV BUNDLER_VERSION=2.4.10

# RUN apk add --update --no-cache \
#       binutils-gold \
#       build-base \
#       curl py-pip \
#       curl \
#       file \
#       g++ \
#       gcc \
#       git \
#       less \
#       libstdc++ \
#       libffi-dev \
#       libc-dev \
#       linux-headers \
#       libxml2-dev \
#       libxslt-dev \
#       libgcrypt-dev \
#       make \
#       netcat-openbsd \
#       nodejs \
#       openssl \
#       pkgconfig \
#       postgresql-contrib \
#       libpq-dev \
#       python3 \
#       tzdata \
#       yarn

# RUN gem install bundler -v $BUNDLER_VERSION

# RUN gem install nokogiri --platform=ruby

# WORKDIR /app

# COPY Gemfile Gemfile.lock ./

# # RUN bundle config build.nokogiri --use-system-libraries

# RUN bundle lock --add-platform x86_64-linux

# # RUN bundle check || bundle install

# COPY package.json yarn.lock ./

# RUN yarn install --check-files

# COPY . ./

# RUN ["chmod", "+x", "entrypoint.sh"]

# EXPOSE 3000

# ENTRYPOINT ["sh", "entrypoint.sh"]
