---
maestru: "0.4"
type: doc
id: 04-sidecar-proxy
title: "The Sidecar Proxy"
description: "apps/web/sidecar/server.ts — how it serves the Next.js app, binds OD_HOST, discovers the daemon port, and proxies /api, /artifacts, /frames"
tags: [web, sidecar, proxy, od-host, origin, daemon-port]
created: 2026-06-22
updated: 2026-06-22
---

# The Sidecar Proxy

<!-- maestru:summary -->
apps/web/sidecar/server.ts is the Node process that fronts the Next.js app and proxies daemon traffic. It binds HOST = process.env.OD_HOST || "127.0.0.1" (set OD_HOST=0.0.0.0 to expose to a proxy) and listens on the web port (--web-port). It discovers the daemon via resolveDaemonOrigin() reading the DAEMON_PORT env (port 0 = daemon unavailable, daemon routes skipped). isDaemonProxyPathname() matches /api/*, /artifacts/*, /frames/* and resolveDaemonProxyTarget()/createDaemonProxyHandler() forward those to http://127.0.0.1:<daemonPort>; everything else falls through to the Next.js handler. Before forwarding, normalizeDaemonProxyOriginHeader() sanitizes the Origin header: loopback hosts (127.0.0.1/localhost/::1 and the OD_HOST value) are allowed, isSameBrowserHostOrigin() permits requests whose Host matches the web server, and OD_ALLOWED_DEV_ORIGINS (comma-separated, *. wildcard) admits extra dev origins. Note the sidecar's origin handling is the WEB layer; the daemon independently enforces its own origin trust via OD_ALLOWED_ORIGINS, which is why a proxied deployment needs both. The sidecar is also the natural seam for adding real front-door auth (a gate in front of the proxy handler).
<!-- /maestru:summary -->

`apps/web/sidecar/server.ts` is the Node process that serves the Next.js app **and** proxies daemon traffic. It is the front door.

## Bind & listen

- `HOST = process.env.OD_HOST || "127.0.0.1"`. Default loopback-only; `OD_HOST=0.0.0.0` exposes it to a proxy.
- Listens on the web port (`--web-port`, or `0` for auto-assign), publishes the bound URL in its status snapshot.

## Daemon discovery

- `resolveDaemonOrigin()` reads the daemon port from env (`DAEMON_PORT`); returns `http://127.0.0.1:<port>` or `null` if the port is `0` (daemon unavailable → daemon routes skipped).

## What gets proxied

- `isDaemonProxyPathname()` matches **`/api/*`, `/artifacts/*`, `/frames/*`**.
- `resolveDaemonProxyTarget()` / `createDaemonProxyHandler()` forward those to the daemon over loopback; everything else falls through to the Next.js handler.

## Origin handling (web layer)

Before forwarding, `normalizeDaemonProxyOriginHeader()` sanitizes the `Origin` header:
- loopback hosts (`127.0.0.1`, `localhost`, `::1`, and the `OD_HOST` value) are allowed,
- `isSameBrowserHostOrigin()` permits requests whose `Host` matches the web server,
- **`OD_ALLOWED_DEV_ORIGINS`** (comma-separated, `*.` wildcard) admits extra dev origins.

> This is the **web** layer of origin handling. The **daemon** independently enforces its own origin trust via `OD_ALLOWED_ORIGINS` (see [../20-daemon/02-auth-and-request-guards.md](../20-daemon/02-auth-and-request-guards.md)). A proxied deployment needs **both** — that's the root cause of the 403s in [../85-audits/01-auth-and-origin-analysis-2026-06.md](../85-audits/01-auth-and-origin-analysis-2026-06.md).

## Why this is the auth seam

If you want **real front-door access control** on the public URL, the sidecar — sitting in front of `createDaemonProxyHandler()` — is the cleanest, most additive place to add a session/login gate, rather than editing the daemon or the onboarding UI. See [../80-methodology/01-evolution-principles.md](../80-methodology/01-evolution-principles.md).
