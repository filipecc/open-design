---
maestru: "0.4"
type: doc
id: 01-auth-and-origin-analysis-2026-06
title: "Audit: Auth & Origin Analysis (2026-06)"
description: "Point-in-time investigation of Open Design's auth/onboarding model and the origin-trust 403s hit when serving through the maestru.dev proxy"
tags: [audit, auth, origin, 403, onboarding, 2026-06]
created: 2026-06-22
updated: 2026-06-22
---

# Audit: Auth & Origin Analysis (2026-06)

<!-- maestru:summary -->
Dated investigation (2026-06-22) of how Open Design's "Sign in" gate and request authorization actually work, triggered by 403s when serving the app through the public maestru.dev proxy. Findings: (1) The "Sign in to Open Design" screen is ONBOARDING, not authentication — the entire gate is the boolean config.onboardingCompleted (state/config.ts) checked in App.tsx; the three options (Cloud/AMR via vela, Local coding agent, BYOK) just pick an execution backend. There is no user/session/password model for local use. (2) The systemic 403 on nearly every /api call was the daemon's CSRF origin-trust guard (origin-validation.ts isLocalSameOrigin) rejecting the maestru.dev Origin; fixed by adding OD_ALLOWED_ORIGINS=https://<host> (full scheme) — distinct from the hostname-only OD_ALLOWED_DEV_ORIGINS that only satisfies the web layer. (3) A residual 403 on Composio config and export endpoints is requireLocalDaemonRequest/validateLocalDaemonRequest demanding literal-loopback Host+Origin, ignoring OD_ALLOWED_ORIGINS by design. (4) The public web app has no front-door access control at all. This audit seeded the 02-architecture and 50-running docs; treat those as the living version and this as the historical record.
<!-- /maestru:summary -->

> **Status:** historical record as of **2026-06-22**. The living versions are [../02-architecture/03-security-and-origin-model.md](../02-architecture/03-security-and-origin-model.md) and [../50-running-in-maestru/01-proxied-dev-environment.md](../50-running-in-maestru/01-proxied-dev-environment.md). If they diverge from this, they win.

## Trigger

Serving the app via `https://opendesign.<id>.maestru.dev` produced a wall of `403`s on `/api/*` and the question "what is the auth, and how do I change it?"

## Finding 1 — the "Sign in" screen is onboarding, not auth

The gate is a single boolean:
- `apps/web/src/state/config.ts` → `onboardingCompleted: false`
- `apps/web/src/App.tsx` → if not completed, force the onboarding view (`EntryShell`).

The three buttons pick an **execution backend**, then flip the boolean:

| Button | Effect |
|--------|--------|
| Open Design Cloud | Spawns `vela login` device-auth (AMR); cloud model provider |
| Local coding agent | Uses a CLI on `$PATH` (Claude Code, Codex, opencode…) |
| BYOK | Paste an API key; daemon proxies the provider |

There is **no user, session, or password** for local use. (`desktopAuthGateActive: false` in the daemon log confirms no daemon-level gate.)

## Finding 2 — the 403 wall was origin trust

Nearly every `/api` call (`/api/active`, `/api/app-config`, `/api/projects`, `/api/memory/*`, `/api/plugins/*/apply`) returned `403` because the daemon's CSRF guard (`apps/daemon/src/origin-validation.ts` → `isLocalSameOrigin`) rejected the `maestru.dev` `Origin`.

**Fix:** add the public origin to the daemon trust set:
```bash
OD_ALLOWED_ORIGINS=https://opendesign.<id>.maestru.dev
```
This is **distinct** from `OD_ALLOWED_DEV_ORIGINS` (hostname-only, web layer) which had been set earlier and was not enough. After the fix, `/api/app-config` and `/api/projects` returned `200`; remaining `404`s were "no data yet" (empty profile/brands), not auth failures.

## Finding 3 — a residual, by-design 403

`PUT /api/connectors/composio/config` stayed `403`. Cause: `requireLocalDaemonRequest` → `validateLocalDaemonRequest` (`apps/daemon/src/server.ts`) requires the peer, `Host`, **and** `Origin` to be literal loopback, and **ignores `OD_ALLOWED_ORIGINS`**. It guards secret-writing endpoints (connector config, diagnostics/plugin export). Intentionally unreachable via a remote proxy.

## Finding 4 — no front-door auth

The public web app has **no access control**; anyone with the URL gets a working instance. `OD_API_TOKEN` only guards the daemon's non-loopback binding, which this setup doesn't use. Adding real auth is an open item — see [../01-product/03-open-questions.md](../01-product/03-open-questions.md).

## Noise (explicitly harmless)

`/api/amr/models` 500 (no Cloud account), `/api/community/discord` 502, `/api/connectors/logos/*` 404, gstatic favicon 404, React DevTools / HMR / aria / password-field-not-in-form warnings — all cosmetic.
