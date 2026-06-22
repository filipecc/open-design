---
maestru: "0.4"
type: work-spec
id: auth1-spec
title: "AUTH1 — Front-door Authentication Gate"
template: implementation-plan-v1
work-item: track-auth/AUTH1
owner: developer
created: 2026-06-22
---

# AUTH1 — Front-door Authentication Gate

## Overview

Put a per-user login in front of the whole app so only authenticated `@oktogon.io` users can reach it, **without editing any Open Design code**. The clean, additive seam (per `80-methodology/01-evolution-principles.md`) is an auth reverse-proxy in front of the web sidecar: rather than gating inside `apps/web/sidecar/server.ts`, run **oauth2-proxy** on the public port and move the web sidecar to an internal port.

```
maestru.dev proxy → :3000 oauth2-proxy (Google OAuth, --email-domain=oktogon.io)
                          └─ authenticated only → 127.0.0.1:3001 web sidecar → daemon
```

Delivers **model A** (shared workspace, per-user login) and exposes the authenticated identity as `X-Forwarded-Email`/`X-Forwarded-User`, which **AUTH2** consumes to route each user to their own instance. Claude Code stays the shared org account.

**Decision gate — RESOLVED (2026-06-22):** a header-capture probe confirmed the Maestru proxy is a **plain reverse proxy** — it forwards only `x-forwarded-for/host/proto`, **no identity header and no cookie**, even on an authenticated top-level navigation. So there is no Maestru identity to ride: **AUTH1 owns the login via oauth2-proxy + Google.** (Implication: the public URL is currently unauthenticated to anyone with the link — AUTH1 is also the access-control fix, not just identity.)

## Implementation

**Phase 0 — Identity-source decision. ✅ DONE.** Header-capture probe run 2026-06-22: the maestru.dev proxy forwards no identity header/cookie → option (b), own login via oauth2-proxy. No further investigation needed.

**Phase 1 — Google OAuth client** (org task — only the user can create it). Google Cloud Console → Credentials → OAuth client ID (Web application); redirect URI `https://opendesign.<id>.maestru.dev/oauth2/callback`; capture `client_id` + `client_secret` as env/secret, never committed.

**Phase 2 — oauth2-proxy.** Provider `google`, `--email-domain=oktogon.io`, `--upstream=http://127.0.0.1:3001`, `--http-address=0.0.0.0:3000`, `--reverse-proxy=true`, `--pass-user-headers=true`, `--set-xauthrequest=true`, generated `--cookie-secret`, `--flush-interval=1s` (SSE). Run as a sibling process (binary or container).

**Phase 3 — Re-wire ports.** Web sidecar internal: `OD_HOST=127.0.0.1`, `--web-port 3001`. Keep `OD_ALLOWED_ORIGINS` / `OD_ALLOWED_DEV_ORIGINS` = public host (origin trust unchanged — oauth2-proxy forwards Host/Origin). Extend `scripts/dev-web.sh` (or add `scripts/auth-proxy.sh` + compose) to launch both.

**Phase 4 — Verify.** Unauthenticated → Google login; `@oktogon.io` passes, others rejected; `/api/*` still 200 and SSE flushes; `X-Forwarded-Email` reaches the web sidecar (handoff contract for AUTH2).

**Risks / decisions.** Secrets via env only; SSE buffering (`--flush-interval`); TLS terminates at the maestru.dev proxy, oauth2-proxy runs HTTP internally.

## Impacted Files

| File | Action | Purpose |
|------|--------|---------|
| `scripts/dev-web.sh` | Modify | Launch web sidecar on internal port 3001 |
| `scripts/auth-proxy.sh` | Create | Launch oauth2-proxy on :3000 → :3001 |
| `deploy/oauth2-proxy.cfg` | Create | oauth2-proxy config (provider, domain, upstream) |
| `.env.example` | Create | Document required secrets (client id/secret, cookie secret) |
| `.maestru/docs/02-architecture/03-security-and-origin-model.md` | Modify | Document the new front-door layer |
