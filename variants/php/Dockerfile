# syntax=docker/dockerfile:1
FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive \
    NODE_ENV=production

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl tar gzip xz-utils unzip openssl libstdc++6 libatomic1 tzdata \
 && rm -rf /var/lib/apt/lists/*

# PHP CLI + the extensions Laravel/Symfony require, plus composer.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      php-cli php-mbstring php-xml php-sqlite3 php-curl php-zip php-intl git \
 && rm -rf /var/lib/apt/lists/* \
 && curl -fsS https://getcomposer.org/installer -o /tmp/composer-setup.php \
 && php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer --quiet \
 && rm /tmp/composer-setup.php \
 && php --version && composer --version

RUN useradd --create-home --uid 10001 app \
 && mkdir -p /app /opt/openagnt \
 && chown -R app:app /app

COPY entrypoint.sh /opt/openagnt/entrypoint.sh
RUN chmod 0555 /opt/openagnt/entrypoint.sh

USER app
WORKDIR /app
ENTRYPOINT ["/opt/openagnt/entrypoint.sh"]
