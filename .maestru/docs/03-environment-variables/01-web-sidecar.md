---
maestru: "0.4"
type: doc
id: 01-web-sidecar
title: "Web Sidecar Env Vars"
description: "OD_HOST and OD_ALLOWED_DEV_ORIGINS — the web sidecar bind address and dev-host allowlist, and how they feed Next.js allowedDevOrigins"
tags: [environment-variables, web, sidecar, od-host, allowed-dev-origins]
created: 2026-06-22
updated: 2026-06-22
---

# Web Sidecar Env Vars

<!-- maestru:summary -->
The web sidecar (apps/web/sidecar/server.ts) binds to the host in OD_HOST, defaulting to 127.0.0.1 (loopback-only). Behind a reverse proxy that default causes 502 Bad Gateway because the proxy cannot reach a loopback-only listener; set OD_HOST=0.0.0.0 to bind all interfaces. OD_ALLOWED_DEV_ORIGINS is a comma-separated hostname allowlist consumed in two places: the sidecar's isAllowedDevHost/configuredAllowedDevHosts (supports *. wildcard) and apps/web/next.config.ts configuredAllowedDevHosts(), which also folds in OD_ALLOWED_ORIGINS hostnames and the OD_HOST value to build Next.js's allowedDevOrigins (required so Next 16 does not block cross-origin dev requests). Note OD_ALLOWED_DEV_ORIGINS is hostname-only and does NOT satisfy the daemon's CSRF check — that needs OD_ALLOWED_ORIGINS with a scheme. The web port is set via --web-port (CLI) and surfaced as OD_WEB_PORT.
<!-- /maestru:summary -->

## `OD_HOST` — bind address

The sidecar binds to `process.env.OD_HOST || "127.0.0.1"` (`apps/web/sidecar/server.ts`). Loopback-only by default.

> **Symptom:** behind a reverse proxy, every request returns **502 Bad Gateway** — the proxy can't connect to a loopback-only listener. **Fix:** `OD_HOST=0.0.0.0`.

## `OD_ALLOWED_DEV_ORIGINS` — dev host allowlist

Comma-separated **hostnames** (wildcards like `*.maestru.dev` supported). Consumed in two places:
- the sidecar's `configuredAllowedDevHosts()` / `isAllowedDevHost()` host check, and
- `apps/web/next.config.ts` → `configuredAllowedDevHosts()`, which builds Next.js's **`allowedDevOrigins`** (Next 16 blocks cross-origin dev requests otherwise). It also folds in hostnames from `OD_ALLOWED_ORIGINS` and the `OD_HOST` value.

> **Gotcha:** this var is **hostname-only** and does **not** satisfy the *daemon's* CSRF origin check. That one needs `OD_ALLOWED_ORIGINS` (full `scheme://host`) — see [02-daemon.md](./02-daemon.md). Setting only `OD_ALLOWED_DEV_ORIGINS` yields a working page but `403` on every `/api` call.

## Ports

The web port is passed via `--web-port <n>` to `tools-dev` and surfaced as `OD_WEB_PORT` for the daemon's browser-origin checks. The daemon port is auto-chosen (or forced with `--daemon-port`).
