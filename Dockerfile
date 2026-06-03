# syntax = docker/dockerfile:1

ARG RUBY_VERSION=3.4.9
ARG TARGETPLATFORM

FROM --platform=$TARGETPLATFORM registry.docker.com/library/ruby:$RUBY_VERSION-slim AS base

LABEL service="cityofbrass"

WORKDIR /rails

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"


FROM --platform=$TARGETPLATFORM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential git pkg-config ssh \
      curl ca-certificates gnupg \
      libsqlite3-dev libyaml-dev \
      libxml2-dev libxslt1-dev zlib1g-dev \
      shared-mime-info && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install --no-install-recommends -y nodejs && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY Gemfile Gemfile.lock .ruby-version ./
COPY engines/ ./engines/
RUN bundle lock --add-platform x86_64-linux \
 && bundle config set deployment true \
 && bundle config set without 'development test' \
 && bundle install --jobs 4 --retry 3 && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

COPY . .

RUN bundle exec bootsnap precompile app/ lib/

RUN SECRET_KEY_BASE=dummy_for_assets_precompile ./bin/rails assets:precompile


FROM base

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl sqlite3 libsqlite3-0 libvips \
      libxml2 libxslt1.1 zlib1g \
      imagemagick && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp public/assets
USER 1000:1000

ARG APP_VERSION
ENV APP_VERSION=$APP_VERSION
ARG GIT_REVISION
ENV GIT_REVISION=$GIT_REVISION

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 80
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
