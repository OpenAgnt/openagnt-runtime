# syntax=docker/dockerfile:1
FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive \
    NODE_ENV=production

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl tar gzip xz-utils unzip openssl libstdc++6 libatomic1 tzdata \
 && rm -rf /var/lib/apt/lists/*

# CPython 3.14.10 (python-build-standalone) - the build stage
# installs the exact same build, so wheel ABIs match.
ARG TARGETARCH=amd64
RUN case "$TARGETARCH" in \
      amd64) PY_ARCH=x86_64 ;; \
      arm64) PY_ARCH=aarch64 ;; \
      *) echo "unsupported arch: $TARGETARCH" && exit 1 ;; \
    esac \
 && curl -fsSL "https://github.com/astral-sh/python-build-standalone/releases/download/20261026/cpython-3.14.10%2B20261026-${PY_ARCH}-unknown-linux-gnu-install_only_stripped.tar.gz" \
      -o /tmp/python.tar.gz \
 && tar -xzf /tmp/python.tar.gz -C /usr/local --strip-components=1 \
 && rm /tmp/python.tar.gz \
 && python3 --version

RUN useradd --create-home --uid 10001 app \
 && mkdir -p /app /opt/openagnt \
 && chown -R app:app /app

COPY entrypoint.sh /opt/openagnt/entrypoint.sh
RUN chmod 0555 /opt/openagnt/entrypoint.sh

USER app
WORKDIR /app
ENTRYPOINT ["/opt/openagnt/entrypoint.sh"]
