---
maestru: "0.4"
type: doc
id: 02-request-lifecycle
title: "Request Lifecycle"
description: "How a browser request travels from the UI through the web sidecar proxy to the daemon, and why /api requests are subject to origin trust"
tags: [architecture, request, proxy, sidecar, api, lifecycle]
created: 2026-06-22
updated: 2026-06-22
---

# Request Lifecycle

<!-- maestru:summary -->
Two request paths exist. Page/asset requests hit the Next.js app served by the web sidecar. Data requests are `/api/*` calls that the sidecar (apps/web/sidecar/server.ts) proxies to the daemon over 127.0.0.1 — the browser never reaches the daemon directly. In our hosted setup the full chain is: browser → public reverse proxy (https://<sub>.maestru.dev) → web sidecar on 0.0.0.0:3000 → daemon on 127.0.0.1:<port>. Because the sidecar→daemon hop is loopback, the daemon's API-token middleware loopback bypass applies, but its CSRF/origin-trust layer (apps/daemon/src/origin-validation.ts, isLocalSameOrigin) still inspects the forwarded Origin/Host headers and rejects unknown origins with 403 unless they are in OD_ALLOWED_ORIGINS. A separate, stricter guard (requireLocalDaemonRequest / validateLocalDaemonRequest in server.ts) locks secret-writing endpoints to literal loopback Host+Origin and ignores OD_ALLOWED_ORIGINS by design. Net effect: reads and most writes work once OD_ALLOWED_ORIGINS includes the public origin; a few secret-bearing writes (e.g. connector config) are intentionally unreachable through any remote proxy.
<!-- /maestru:summary -->

## Two paths

1. **Pages & assets** → served by the Next.js app behind the web sidecar.
2. **Data (`/api/*`)** → the sidecar **proxies** to the daemon. The browser has no direct daemon connection.

## The full chain (hosted)

```
Browser
  │  Origin: https://opendesign.<id>.maestru.dev
  ▼
Public reverse proxy  (maestru.dev)
  ▼  forwards to the container
Web sidecar           (apps/web/sidecar/server.ts, bound 0.0.0.0:3000)
  │  serves UI; proxies /api/* over loopback
  ▼
Daemon                (apps/daemon, bound 127.0.0.1:<port>)
  │  may spawn an agent CLI
  ▼
Artifact written under RUNTIME_DATA_DIR → previewed in sandboxed iframe
```

## Why `/api` calls can 403

The sidecar→daemon hop is **loopback**, so the daemon's API-token middleware loopback bypass applies (no token needed locally). But the daemon **also** runs a CSRF/origin-trust check on the *forwarded* `Origin`/`Host` headers:

- `apps/daemon/src/origin-validation.ts` → `isLocalSameOrigin()` rejects requests whose `Origin` isn't trusted → **HTTP 403**.
- Trust is granted to loopback/private-LAN origins **and** anything in `OD_ALLOWED_ORIGINS`.

So when the app is served from a public domain, every `/api` call 403s until that origin is added to `OD_ALLOWED_ORIGINS`. Full detail and the fix: [03-security-and-origin-model.md](./03-security-and-origin-model.md) and [../03-environment-variables/02-daemon.md](../03-environment-variables/02-daemon.md).

## The stricter write guard

A handful of secret-writing endpoints use `requireLocalDaemonRequest` (`server.ts` → `validateLocalDaemonRequest`), which demands the request's **peer, `Host`, and `Origin` all be literal loopback** and **ignores `OD_ALLOWED_ORIGINS`**. These (e.g. `PUT /api/connectors/composio/config`, diagnostics/plugin export) are deliberately unreachable through a remote proxy — by design, not a bug.

See the dated investigation in [../85-audits/01-auth-and-origin-analysis-2026-06.md](../85-audits/01-auth-and-origin-analysis-2026-06.md).
