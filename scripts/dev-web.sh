#!/usr/bin/env bash
# dev-web.sh — launch the Open Design web app for a hosted/proxied dev environment.
#
# Why this exists: when the app is served through a public reverse proxy (e.g.
# https://<sub>.maestru.dev) instead of plain localhost, three things must be set
# or every /api call dies:
#   OD_HOST=0.0.0.0           -> bind all interfaces so the proxy can reach the web port
#                                (default 127.0.0.1 is loopback-only -> 502 Bad Gateway)
#   OD_ALLOWED_DEV_ORIGINS    -> web sidecar host allowlist + Next.js allowedDevOrigins
#                                (hostname only)
#   OD_ALLOWED_ORIGINS        -> daemon CSRF origin trust (full scheme://host)
#                                (without it the daemon 403s every /api request)
#
# Note: a few secret-writing endpoints (Composio connector config, diagnostics/
# plugin export) are hard-locked to true localhost and will still 403 over the
# proxy by design — see apps/daemon/src/server.ts:validateLocalDaemonRequest.
#
# Usage:
#   scripts/dev-web.sh
#   PORT=4000 PUBLIC_HOST=opendesign.example.maestru.dev scripts/dev-web.sh
set -euo pipefail

PORT="${PORT:-3000}"
PUBLIC_HOST="${PUBLIC_HOST:-opendesign.1fd31e6f.maestru.dev}"
SCHEME="${SCHEME:-https}"

export OD_HOST="${OD_HOST:-0.0.0.0}"
export OD_ALLOWED_DEV_ORIGINS="${OD_ALLOWED_DEV_ORIGINS:-$PUBLIC_HOST}"
export OD_ALLOWED_ORIGINS="${OD_ALLOWED_ORIGINS:-$SCHEME://$PUBLIC_HOST}"

cd "$(dirname "$0")/.."

echo "[dev-web] public URL : $SCHEME://$PUBLIC_HOST"
echo "[dev-web] bind        : $OD_HOST:$PORT"
echo "[dev-web] OD_ALLOWED_ORIGINS=$OD_ALLOWED_ORIGINS"
echo "[dev-web] starting Open Design web (Ctrl+C to stop)…"

exec pnpm tools-dev run web --web-port "$PORT"
