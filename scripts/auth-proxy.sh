#!/usr/bin/env bash
# AUTH1 — front-door authentication gate.
# Runs oauth2-proxy on :3000 in front of the INTERNAL web sidecar (:3001).
# All org/deploy values come from env (.env.local). The repo stays vendor-neutral.
#
# Run order:
#   1) web sidecar internally:
#        OD_HOST=127.0.0.1 OD_ALLOWED_ORIGINS="https://$PUBLIC_HOST" \
#        pnpm tools-dev run web --web-port 3001
#   2) this gate:
#        scripts/auth-proxy.sh
set -euo pipefail
cd "$(dirname "$0")/.."

# load local (gitignored) env
for f in .env.local .env; do [ -f "$f" ] && { set -a; . "./$f"; set +a; break; }; done

command -v oauth2-proxy >/dev/null || {
  echo "oauth2-proxy not installed. Install a release from"
  echo "  https://github.com/oauth2-proxy/oauth2-proxy/releases  (or 'go install')"
  exit 1
}

: "${PUBLIC_HOST:?set PUBLIC_HOST in .env.local}"
: "${OAUTH2_PROXY_EMAIL_DOMAINS:?set in .env.local}"
: "${OAUTH2_PROXY_CLIENT_ID:?set in .env.local}"
: "${OAUTH2_PROXY_CLIENT_SECRET:?set in .env.local (from Google Cloud)}"
: "${OAUTH2_PROXY_COOKIE_SECRET:?set in .env.local (openssl rand -base64 24)}"
UPSTREAM="${OAUTH2_PROXY_UPSTREAM:-http://127.0.0.1:3001}"

echo "[auth-proxy] :3000  Google SSO (domain=$OAUTH2_PROXY_EMAIL_DOMAINS)  ->  $UPSTREAM"

exec oauth2-proxy \
  --provider=google \
  --email-domain="$OAUTH2_PROXY_EMAIL_DOMAINS" \
  --client-id="$OAUTH2_PROXY_CLIENT_ID" \
  --client-secret="$OAUTH2_PROXY_CLIENT_SECRET" \
  --cookie-secret="$OAUTH2_PROXY_COOKIE_SECRET" \
  --redirect-url="https://$PUBLIC_HOST/oauth2/callback" \
  --upstream="$UPSTREAM" \
  --http-address="0.0.0.0:3000" \
  --reverse-proxy=true \
  --pass-user-headers=true \
  --set-xauthrequest=true \
  --skip-provider-button=true \
  --flush-interval=1s \
  --skip-auth-route="^/share/"     # AUTH6 public share carve-out; /oauth2/* is always open
