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

### Settled decisions (2026-06-22)

- **Identity source:** own login via **oauth2-proxy + Google** (no Maestru proxy identity exists — probed).
- **Access scope:** **any `@oktogon.io` Google Workspace account** via `--email-domain=oktogon.io`. *Not* a per-email allowlist and *not* a Google-group gate. (If a tighter pilot is later wanted, switch to `--authenticated-emails-file` or `--google-group`; out of scope for AUTH1.)
- **Auth coverage:** **deny-by-default** — every route behind login except (a) oauth2-proxy's own `/oauth2/*` endpoints and (b) the **public share-link carve-out** owned by **AUTH6**. See the no-bypass invariant below.
- **Public sharing:** **allowed** — a deliberate unauthenticated route for shared artifacts is in scope, specified separately in AUTH6 so the hole stays small and auditable.

## Implementation

**Phase 0 — Identity-source decision. ✅ DONE.** Header-capture probe run 2026-06-22: the maestru.dev proxy forwards no identity header/cookie → option (b), own login via oauth2-proxy. No further investigation needed.

**Phase 1 — Google OAuth client** (org task — only an `oktogon.io` Google Cloud admin can create it). Exact requirements:
- Google Cloud Console → APIs & Services → **OAuth consent screen**: User type **Internal** (restricts to the Workspace org automatically), app name + support email.
- → **Credentials → Create OAuth client ID → Web application**.
- **Authorized redirect URI:** `https://opendesign.1fd31e6f.maestru.dev/oauth2/callback` (oauth2-proxy's default callback path).
- **Scopes:** `openid email profile` (oauth2-proxy needs email to enforce the domain).
- Output: **`client_id` + `client_secret`** → stored as env/secret (`OAUTH2_PROXY_CLIENT_ID` / `OAUTH2_PROXY_CLIENT_SECRET`), **never committed**.
- Also generate the proxy cookie secret: `OAUTH2_PROXY_COOKIE_SECRET=$(openssl rand -base64 32 | head -c 32)`.

**Phase 2 — oauth2-proxy.** Provider `google`, `--email-domain=oktogon.io`, `--upstream=http://127.0.0.1:3001`, `--http-address=0.0.0.0:3000`, `--reverse-proxy=true`, `--pass-user-headers=true`, `--set-xauthrequest=true`, generated `--cookie-secret`, `--flush-interval=1s` (SSE). Run as a sibling process (binary or container).

**Phase 3 — Re-wire ports.** Web sidecar internal: `OD_HOST=127.0.0.1`, `--web-port 3001`. Keep `OD_ALLOWED_ORIGINS` / `OD_ALLOWED_DEV_ORIGINS` = public host (origin trust unchanged — oauth2-proxy forwards Host/Origin). Extend `scripts/dev-web.sh` (or add `scripts/auth-proxy.sh` + compose) to launch both.

**Phase 4 — Auth coverage & no-bypass invariant.** This is the security contract; verify it explicitly:
- **Deny-by-default:** oauth2-proxy gates 100% of upstream. The only open paths are `/oauth2/*` (login machinery) and the AUTH6 public-share routes (added as oauth2-proxy `--skip-auth-route` entries). Everything else — UI, all `/api/*`, `/artifacts/*`, `/frames/*`, SSE, static assets — requires login.
- **No back door:** the web sidecar must bind **`127.0.0.1:3001`** and the daemon must stay loopback, so the *only* publicly reachable listener is oauth2-proxy on `:3000` (which is all the maestru.dev proxy forwards to). If the sidecar/daemon were exposed on `0.0.0.0`, the gate could be bypassed — this invariant must hold and be tested.
- Optional: exempt `/api/health`,`/api/ready`,`/api/version` for monitoring.

**Phase 5 — Verify behavior.** Unauthenticated → Google login; `@oktogon.io` passes, other domains rejected; authenticated `/api/*` still 200 and SSE flushes; `X-Forwarded-Email` reaches the web sidecar (handoff contract for AUTH2); a direct hit to `:3001`/daemon from outside the container is refused (no-bypass confirmed).

**Risks / decisions.** Secrets via env only; SSE buffering (`--flush-interval`); TLS terminates at the maestru.dev proxy, oauth2-proxy runs HTTP internally; the no-bypass invariant depends on the sidecar/daemon staying internal (see AUTH3/AUTH5 for the per-user instances — same rule applies to each).

## Impacted Files

| File | Action | Purpose |
|------|--------|---------|
| `scripts/dev-web.sh` | Modify | Launch web sidecar on internal port 3001 |
| `scripts/auth-proxy.sh` | Create | Launch oauth2-proxy on :3000 → :3001 |
| `deploy/oauth2-proxy.cfg` | Create | oauth2-proxy config: provider=google, email-domain=oktogon.io, upstream=:3001, skip-auth-route for AUTH6 share paths |
| `.env.example` | Create | Required secrets: `OAUTH2_PROXY_CLIENT_ID`, `OAUTH2_PROXY_CLIENT_SECRET`, `OAUTH2_PROXY_COOKIE_SECRET` |
| `.maestru/docs/02-architecture/03-security-and-origin-model.md` | Modify | Document the front-door layer + the no-bypass invariant |
