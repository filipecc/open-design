---
maestru: "0.4"
type: doc
id: 02-daemon
title: "Daemon Env Vars"
description: "OD_DATA_DIR, OD_API_TOKEN, OD_DISABLE_API_AUTH, OD_BIND_HOST, OD_ALLOWED_ORIGINS — the daemon's storage, token auth, and origin-trust controls"
tags: [environment-variables, daemon, od-data-dir, od-api-token, od-allowed-origins]
created: 2026-06-22
updated: 2026-06-22
---

# Daemon Env Vars

<!-- maestru:summary -->
The daemon reads several OD_* vars at startup. OD_DATA_DIR resolves to RUNTIME_DATA_DIR (default <projectRoot>/.od) and roots all daemon-owned state including app.sqlite. OD_API_TOKEN enables the bearer-token middleware and is REQUIRED to bind a non-loopback host; OD_DISABLE_API_AUTH (truthy: 1/true/yes/on) disables the token check for setups fronted by an authenticating proxy. OD_BIND_HOST sets the daemon's own bind host (kept loopback in our setup). OD_ALLOWED_ORIGINS is the key one for proxied deployments: a comma-separated list of FULL origins (scheme://host, http/https only — it throws on a bare hostname) that the CSRF guard (origin-validation.ts) trusts; without the public origin here, every /api call 403s. OD_WEB_PORT advertises the web port for browser-origin matching. Note that OD_ALLOWED_ORIGINS does NOT relax the stricter requireLocalDaemonRequest guard on secret-writing endpoints, which always demands literal loopback.
<!-- /maestru:summary -->

## `OD_DATA_DIR` → `RUNTIME_DATA_DIR`

Roots all daemon-owned state (SQLite, projects, artifacts, credentials). Default `<projectRoot>/.od` (here `/app/.od`). See [../02-architecture/01-data-model.md](../02-architecture/01-data-model.md).

## `OD_API_TOKEN` / `OD_DISABLE_API_AUTH`

- `OD_API_TOKEN` — enables the bearer-token middleware (`apps/daemon/src/api-token-auth.ts`) and is **required to bind a non-loopback daemon host**.
- `OD_DISABLE_API_AUTH` — truthy (`1`/`true`/`yes`/`on`) disables the token check, for deployments where a reverse proxy already authenticates.
- Loopback peers bypass the token regardless.

## `OD_BIND_HOST`

The daemon's own bind host. In our hosted setup the **daemon stays on loopback** and only the web sidecar is exposed, so this is left default.

## `OD_ALLOWED_ORIGINS` — the one that fixes the 403s

Comma-separated list of **full origins** (`scheme://host`). `apps/daemon/src/origin-validation.ts` → `configuredAllowedOrigins()` parses each with `new URL()` and **throws on anything that isn't `http://`/`https://`** — a bare hostname is rejected. These origins are added to the CSRF trust set in `isLocalSameOrigin()`.

```bash
OD_ALLOWED_ORIGINS=https://opendesign.<id>.maestru.dev
```

> Without the public origin here, **every `/api` request 403s** even though the page loads. This is distinct from `OD_ALLOWED_DEV_ORIGINS` (hostname-only, web layer). You typically set both.

### What it does NOT do

`OD_ALLOWED_ORIGINS` does **not** relax `requireLocalDaemonRequest` (secret-writing endpoints like `PUT /api/connectors/composio/config`). Those always require literal loopback `Host`+`Origin` and stay `403` over a proxy by design. See [../02-architecture/03-security-and-origin-model.md](../02-architecture/03-security-and-origin-model.md).

## `OD_WEB_PORT`

Advertises the web port so the daemon's browser-origin checks (`allowedBrowserPorts`) accept requests carrying that port.
