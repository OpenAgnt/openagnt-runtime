# syntax=docker/dockerfile:1
FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive \
    NODE_ENV=production \
    BUN_INSTALL=/usr/local

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl tar gzip xz-utils unzip openssl libstdc++6 \
 && rm -rf /var/lib/apt/lists/*

# Node 26.13.0 (same major the build stage assumes).
ARG TARGETARCH=amd64
RUN case "$TARGETARCH" in \
      amd64) NODE_ARCH=x64 ;; \
      arm64) NODE_ARCH=arm64 ;; \
      *) echo "unsupported arch: $TARGETARCH" && exit 1 ;; \
    esac \
 && curl -fsSL "https://nodejs.org/dist/v26.13.0/node-v26.13.0-linux-${NODE_ARCH}.tar.xz" \
      -o /tmp/node.tar.xz \
 && tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1 \
 && rm /tmp/node.tar.xz \
 && node --version

# Bun 1.4.4 â€” single-sourced with the build stage.
RUN curl -fsSL https://bun.sh/install | bash -s "bun-v1.4.4" \
 && bun --version

RUN useradd --create-home --uid 10001 app \
 && mkdir -p /app /opt/openagnt \
 && chown -R app:app /app

COPY entrypoint.sh /opt/openagnt/entrypoint.sh
COPY static-server.ts /opt/openagnt/static-server.ts
RUN chmod 0555 /opt/openagnt/entrypoint.sh

USER app
WORKDIR /app
ENTRYPOINT ["/opt/openagnt/entrypoint.sh"]
