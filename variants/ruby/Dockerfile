# syntax=docker/dockerfile:1
FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive \
    NODE_ENV=production

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl tar gzip xz-utils unzip openssl libstdc++6 libatomic1 tzdata \
 && rm -rf /var/lib/apt/lists/*

# Ruby + toolchain for native gem extensions.
RUN apt-get update \
 && apt-get install -y --no-install-recommends ruby ruby-dev build-essential git \
 && rm -rf /var/lib/apt/lists/* \
 && ruby --version && gem --version

RUN useradd --create-home --uid 10001 app \
 && mkdir -p /app /opt/openagnt \
 && chown -R app:app /app

COPY entrypoint.sh /opt/openagnt/entrypoint.sh
RUN chmod 0555 /opt/openagnt/entrypoint.sh

USER app
WORKDIR /app
ENTRYPOINT ["/opt/openagnt/entrypoint.sh"]
