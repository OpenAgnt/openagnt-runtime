#!/usr/bin/env bash
# Platform-owned entrypoint. No bundle script is executed before extraction.
set -euo pipefail

# Job runs download the JOB bundle (source + prod deps), not the serving
# bundle — `node scripts/cleanup.js` needs scripts/, not .next/standalone.
if [ "${JOB_MODE:-0}" = "1" ]; then
  ARTIFACT_URL="$JOB_ARTIFACT_URL"
  ARTIFACT_TOKEN="${JOB_ARTIFACT_TOKEN:-}"
  ARTIFACT_SHA256="$JOB_ARTIFACT_SHA256"
  WORKDIR="${JOB_WORKDIR:-/app}"
  CMD="$JOB_COMMAND"
  MAX_ENTRIES="${JOB_ARTIFACT_MAX_ENTRIES:-60000}"
else
  WORKDIR=/app
  CMD="$START_COMMAND"
  MAX_ENTRIES="${ARTIFACT_MAX_ENTRIES:-20000}"
fi

mkdir -p /app /tmp

# Optional auth header as a bash array: parameter expansion with embedded
# quotes would not preserve argument boundaries.
# A presigned URL (X-Amz-Signature) is self-authorizing — sending a bearer
# header as well makes S3 reject the request (400, conflicting auth).
auth=()
if [ -n "${ARTIFACT_TOKEN:-}" ] && [ "${ARTIFACT_URL#*X-Amz-Signature=}" = "$ARTIFACT_URL" ]; then
  auth=(-H "Authorization: Bearer ${ARTIFACT_TOKEN}")
fi

for i in 1 2 3; do
  if curl -fsSL "${auth[@]}" -o /tmp/release.tar.gz "$ARTIFACT_URL"; then
    echo "$ARTIFACT_SHA256  /tmp/release.tar.gz" | sha256sum -c - >/dev/null 2>&1 \
      && tar tzf /tmp/release.tar.gz > /tmp/entries.txt \
      && ! grep -Eq '(^/|(^|/)\.\.(/|$))' /tmp/entries.txt \
      && [ "$(wc -l < /tmp/entries.txt)" -le "$MAX_ENTRIES" ] \
      && tar xzf /tmp/release.tar.gz -C /app \
      && rm -f /tmp/release.tar.gz /tmp/entries.txt && break
  fi
  [ "$i" = 3 ] && exit 1
  sleep $((i * 5))
done

cd "$WORKDIR"
exec sh -c "$CMD"
