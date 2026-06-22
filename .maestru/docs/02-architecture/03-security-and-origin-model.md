---
maestru: "0.4"
type: doc
id: 03-security-and-origin-model
title: "Security & Origin Model"
description: "The daemon's three-layer request defense: loopback binding, API-token middleware, and the CSRF origin-trust / local-only guards"
tags: [architecture, security, auth, origin, csrf, api-token, 403]
created: 2026-06-22
updated: 2026-06-22
---

# Security & Origin Model

<!-- maestru:summary -->
The local daemon is the trust boundary and defends itself in three layers. (1) Bind host: it refuses to bind a non-loopback host without OD_API_TOKEN (apps/daemon/src/server.ts), defaulting to loopback. (2) API-token middleware (apps/daemon/src/api-token-auth.ts): active only when OD_API_TOKEN is set and OD_DISABLE_API_AUTH is not; it whitelists /api/health|ready|version, bypasses loopback peers, and otherwise requires Authorization: Bearer <token>. (3) Origin trust (apps/daemon/src/origin-validation.ts → isLocalSameOrigin): every /api request's Origin/Host is checked; loopback/private-LAN origins are trusted, plus any origin listed in OD_ALLOWED_ORIGINS (full scheme://host, comma-separated). Unknown origin → 403. A stricter guard, requireLocalDaemonRequest/validateLocalDaemonRequest, gates secret-writing endpoints on literal-loopback peer+Host+Origin and ignores OD_ALLOWED_ORIGINS entirely. Crucially there is NO front-door auth on the web app itself: anyone who can reach the public URL gets a working instance. The "Sign in" screen is onboarding, not access control. Adding real access control is an explicit gap for the Oktogon Design Partner.
<!-- /maestru:summary -->

The daemon is where filesystem access, process spawning, and credentials live — so it, not the web app, enforces security. Three layers:

## 1. Bind host

The daemon **refuses to bind a non-loopback host (e.g. `0.0.0.0`) unless `OD_API_TOKEN` is set** (`apps/daemon/src/server.ts`). Default is loopback-only. (Our hosted setup keeps the *daemon* on loopback and only exposes the *web sidecar* — see [../03-environment-variables/01-web-sidecar.md](../03-environment-variables/01-web-sidecar.md).)

## 2. API-token middleware

`apps/daemon/src/api-token-auth.ts`:
- Active **only** when `OD_API_TOKEN` is set **and** `OD_DISABLE_API_AUTH` is not truthy.
- Open paths: `/api/health`, `/api/ready`, `/api/version`.
- **Loopback peers bypass** the token (desktop/dev flow).
- Non-loopback requests must send `Authorization: Bearer <OD_API_TOKEN>` or get **401**.

## 3. Origin trust (the CSRF layer)

`apps/daemon/src/origin-validation.ts` → `isLocalSameOrigin()` runs on `/api` requests:
- Loopback and private-LAN origins are trusted automatically.
- **`OD_ALLOWED_ORIGINS`** (comma-separated, full `scheme://host`) adds trusted origins.
- Anything else → **HTTP 403** ("cross-origin request rejected").

This is the layer that 403s every `/api` call when the app is served from a public domain. Fix: add the public origin to `OD_ALLOWED_ORIGINS`.

### The stricter local-only guard

`requireLocalDaemonRequest` → `validateLocalDaemonRequest` (`server.ts`) requires **all** of:
- peer socket address is loopback,
- `Host` header is a loopback hostname,
- `Origin` (if present) is a loopback origin.

It **ignores `OD_ALLOWED_ORIGINS`**. Used for secret-writing endpoints (connector config writes, diagnostics/plugin export, some memory writes). Intentionally unreachable through a remote proxy.

## The big gap: no front-door auth

> There is **no access control on the web app**. Anyone who can load the public URL gets a fully working instance. `OD_API_TOKEN` only guards the *daemon's* non-loopback binding, which our setup doesn't use.

The "Sign in to Open Design" screen is **onboarding state** (which backend to use), not authentication — see [../10-web/02-onboarding-and-auth-ui.md](../10-web/02-onboarding-and-auth-ui.md). Real access control is a deliberate build item for the Oktogon Design Partner; design notes belong in [../01-product/03-open-questions.md](../01-product/03-open-questions.md) and any auth spec under `track-bok` or a future track.
