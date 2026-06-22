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

Put a per-user login in front of the whole app so only authenticated users **from the configured organization domain** can reach it, **without editing any Open Design code**. The clean, additive seam (per `80-methodology/01-evolution-principles.md`) is an auth reverse-proxy in front of the web sidecar: rather than gating inside `apps/web/sidecar/server.ts`, run **oauth2-proxy** on the public port and move the web sidecar to an internal port.

```
public proxy → :3000 oauth2-proxy (Google OAuth, domain-restricted via env)
                     └─ authenticated only → 127.0.0.1:3001 web sidecar → daemon
```

Delivers **model A** (shared workspace, per-user login) and exposes the authenticated identity as `X-Forwarded-Email`/`X-Forwarded-User`, which **AUTH2** consumes to route each user to their own instance. Claude Code stays the shared org account.

**Repo stays vendor-neutral:** no organization name, domain, host, or secret is hardcoded in committed files. All org/deploy specifics come from **environment at run time** (see *Deployment values* below); committed config uses env interpolation and placeholders only.

**Decision gate — RESOLVED (2026-06-22):** a header-capture probe confirmed the hosting proxy is a **plain reverse proxy** — it forwards only `x-forwarded-for/host/proto`, **no identity header and no cookie**, even on an authenticated top-level navigation. So there is no upstream identity to ride: **AUTH1 owns the login via oauth2-proxy + Google.** (Implication: the public URL is currently unauthenticated to anyone with the link — AUTH1 is also the access-control fix, not just identity.)

### Settled decisions (2026-06-22)

- **Identity source:** own login via **oauth2-proxy + Google** (no hosting-proxy identity exists — probed).
- **Access scope:** **Google Workspace domain restriction**, configured via env (`OAUTH2_PROXY_EMAIL_DOMAINS`). *Not* a per-email allowlist and *not* a Google-group gate. (If a tighter pilot is later wanted, switch to `--authenticated-emails-file` or `--google-group`; out of scope for AUTH1.)
- **Auth coverage:** **deny-by-default** — every route behind login except (a) oauth2-proxy's own `/oauth2/*` endpoints and (b) the **public share-link carve-out** owned by **AUTH6**. See the no-bypass invariant below.
- **Public sharing:** **allowed** — a deliberate unauthenticated route for shared artifacts is in scope, specified separately in AUTH6 so the hole stays small and auditable.

### Deployment values (set at run time, NOT committed)

| Env var | Meaning | Current deployment value |
|---------|---------|--------------------------|
| `OAUTH2_PROXY_EMAIL_DOMAINS` | Allowed Google Workspace domain | _set in deploy `.env`_ |
| `PUBLIC_HOST` | Public hostname (for redirect URI + origin trust) | _set in deploy `.env`_ |
| `OAUTH2_PROXY_CLIENT_ID` / `_CLIENT_SECRET` | Google OAuth client | _set in deploy `.env`_ |
| `OAUTH2_PROXY_COOKIE_SECRET` | Session cookie secret | _generated per deploy_ |

> Concrete values (domain, host, secrets) live only in the deployment environment / `.env` — never in the repo. The repo is organization-agnostic.

## Implementation

**Phase 0 — Identity-source decision. ✅ DONE.** Header-capture probe run 2026-06-22: the hosting proxy forwards no identity header/cookie → option (b), own login via oauth2-proxy. No further investigation needed.

**Phase 1 — Google OAuth client** (org task — a Google Workspace admin of the deployment domain creates it). Exact requirements:
- Google Cloud Console → APIs & Services → **OAuth consent screen**: User type **Internal** (restricts to the Workspace org automatically), app name + support email.
- → **Credentials → Create OAuth client ID → Web application**.
- **Authorized redirect URI:** `https://<PUBLIC_HOST>/oauth2/callback` (oauth2-proxy's default callback path).
- **Scopes:** `openid email profile` (oauth2-proxy needs email to enforce the domain).
- Output → env/secret (`OAUTH2_PROXY_CLIENT_ID` / `OAUTH2_PROXY_CLIENT_SECRET`), **never committed**.
- Also generate the cookie secret: `OAUTH2_PROXY_COOKIE_SECRET=$(openssl rand -base64 32 | head -c 32)`.

**Phase 2 — oauth2-proxy.** Provider `google`, `--email-domain=$OAUTH2_PROXY_EMAIL_DOMAINS`, `--upstream=http://127.0.0.1:3001`, `--http-address=0.0.0.0:3000`, `--reverse-proxy=true`, `--pass-user-headers=true`, `--set-xauthrequest=true`, `--cookie-secret=$OAUTH2_PROXY_COOKIE_SECRET`, `--flush-interval=1s` (SSE). All values from env. Run as a sibling process (binary or container).

**Phase 3 — Re-wire ports.** Web sidecar internal: `OD_HOST=127.0.0.1`, `--web-port 3001`. Keep `OD_ALLOWED_ORIGINS=https://$PUBLIC_HOST` / `OD_ALLOWED_DEV_ORIGINS=$PUBLIC_HOST` (origin trust unchanged — oauth2-proxy forwards Host/Origin). Extend `scripts/dev-web.sh` (or add `scripts/auth-proxy.sh` + compose) to launch both.

**Phase 4 — Auth coverage & no-bypass invariant.** The security contract; verify explicitly:
- **Deny-by-default:** oauth2-proxy gates 100% of upstream. The only open paths are `/oauth2/*` (login machinery) and the AUTH6 public-share routes (added as oauth2-proxy `--skip-auth-route` entries). Everything else — UI, all `/api/*`, `/artifacts/*`, `/frames/*`, SSE, static assets — requires login.
- **No back door:** the web sidecar must bind **`127.0.0.1:3001`** and the daemon must stay loopback, so the *only* publicly reachable listener is oauth2-proxy on `:3000` (all the public proxy forwards to). Exposing the sidecar/daemon on `0.0.0.0` would bypass the gate — this invariant must hold and be tested.
- Optional: exempt `/api/health`,`/api/ready`,`/api/version` for monitoring.

**Phase 5 — Verify behavior.** Unauthenticated → Google login; the configured domain passes, other domains rejected; authenticated `/api/*` still 200 and SSE flushes; `X-Forwarded-Email` reaches the web sidecar (handoff to AUTH2); a direct hit to `:3001`/daemon from outside the container is refused (no-bypass confirmed).

**Risks / decisions.** Secrets via env only; SSE buffering (`--flush-interval`); TLS terminates at the hosting proxy, oauth2-proxy runs HTTP internally; the no-bypass invariant depends on the sidecar/daemon staying internal (applies to each per-user instance in AUTH3/AUTH5 too).

**Validated (spike A, 2026-06-22):** ran a front proxy on `:3000` → web sidecar on internal `127.0.0.1:3001` → daemon. The **full public chain** (hosting proxy → `:3000` proxy → `:3001` sidecar → daemon) returned **200** for the page, `/api/app-config`, and `/api/projects` (real data) with the public `Origin` — **origin trust intact through the extra hop**. Sidecar + daemon bound `127.0.0.1` only → **no-bypass confirmed**. (A pipe-based proxy streamed fine; oauth2-proxy will need `--flush-interval` for SSE, already in Phase 2.) This is exactly oauth2-proxy's position minus the Google gate.

**Validated LIVE end-to-end (2026-06-22):** stood up the real gate — oauth2-proxy v7.15.3 on `:3000` (Google provider, domain-restricted) in front of the internal web sidecar on `:3001`, behind the hosting proxy. Confirmed: unauthenticated → **302 to Google**; a Google account **outside** the allowed domain was **correctly rejected (403)** by oauth2-proxy's `--email-domain` check; an allowed-domain account completed login and **reached the app**. The `/share` carve-out stayed reachable without auth. **AUTH1 works in practice with real Google SSO**, not just in spec. Hardening notes for AUTH5: secrets via env not argv (done); set `--trusted-proxy-ip` to the hosting proxy CIDR (oauth2-proxy warns it trusts all `X-Forwarded-*` by default); the Google OAuth client/consent-screen org must match the intended login domain.

## Impacted Files

| File | Action | Purpose |
|------|--------|---------|
| `scripts/auth-proxy.sh` | ✅ Scaffolded | Env-driven oauth2-proxy launcher on :3000 → :3001; `--skip-auth-route=^/share/` (AUTH6); `/oauth2/*` open |
| `.env.example` | ✅ Scaffolded | Env keys + placeholders: `OAUTH2_PROXY_*`, `PUBLIC_HOST` (no real values) |
| `.env.local` | (gitignored) | Real deploy values live here; never committed |
| `scripts/dev-web.sh` | Modify (later) | Add internal-port mode (web on `127.0.0.1:3001`) when wiring AUTH1 live |
| `.maestru/docs/02-architecture/03-security-and-origin-model.md` | Modify | Document the front-door layer + the no-bypass invariant |

> Scaffold status (2026-06-22): `scripts/auth-proxy.sh` + `.env.example` created (config from env, no `.cfg` file needed). `.env.local` holds the real `PUBLIC_HOST`, domain, client ID, and a generated cookie secret; the **Google client secret** is the only blank. oauth2-proxy isn't installed in the dev container — install at deploy. No live wiring yet (web still on :3000 via `dev-web.sh`).
