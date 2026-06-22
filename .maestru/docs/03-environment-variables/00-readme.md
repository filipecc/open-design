---
maestru: "0.4"
type: doc
id: 00-readme
title: "Environment Variables — Overview"
description: "How OD_* environment configuration flows through the web sidecar and daemon, and which vars matter when running behind a proxy"
tags: [environment-variables, config, od, overview]
created: 2026-06-22
updated: 2026-06-22
---

# Environment Variables — Overview

<!-- maestru:summary -->
Open Design is configured almost entirely through OD_*-prefixed environment variables read at process startup; there are hundreds (grep `OD_[A-Z_]+` under apps/daemon/src), but only a handful matter for running the app, especially behind a reverse proxy. tools-dev launches the web sidecar and daemon as a process pair, and env set on the launch command is inherited by both. The vars split by surface: the web sidecar reads OD_HOST (bind address) and OD_ALLOWED_DEV_ORIGINS (host allowlist, also feeds Next.js allowedDevOrigins); the daemon reads OD_DATA_DIR (RUNTIME_DATA_DIR), OD_API_TOKEN + OD_DISABLE_API_AUTH (token middleware), OD_BIND_HOST, and OD_ALLOWED_ORIGINS (CSRF origin trust — full scheme://host). The three that unblock a proxied deployment are OD_HOST=0.0.0.0, OD_ALLOWED_DEV_ORIGINS=<host>, and OD_ALLOWED_ORIGINS=<scheme://host>; scripts/dev-web.sh bakes them in. Per-surface detail is in the sibling docs.
<!-- /maestru:summary -->

Open Design is configured through **`OD_*` environment variables** read at startup. There are *hundreds* (`grep -rohE 'OD_[A-Z_]+' apps/daemon/src | sort -u`), but only a few matter day-to-day.

## How env reaches the processes

`pnpm tools-dev run web` spawns **both** the web sidecar and the daemon. Env set on that command is inherited by both children — so a single export reaches whichever process reads it.

## The vars that matter, by surface

| Surface | Var | Effect |
|---------|-----|--------|
| Web sidecar | `OD_HOST` | Bind address of the web server (default `127.0.0.1`) |
| Web sidecar | `OD_ALLOWED_DEV_ORIGINS` | Host allowlist for the sidecar + Next.js `allowedDevOrigins` (hostname only) |
| Daemon | `OD_DATA_DIR` | Resolves to `RUNTIME_DATA_DIR` (default `<root>/.od`) |
| Daemon | `OD_API_TOKEN` | Bearer token; also required to bind a non-loopback host |
| Daemon | `OD_DISABLE_API_AUTH` | Skip token middleware (when a proxy already authenticates) |
| Daemon | `OD_BIND_HOST` | Daemon bind host |
| Daemon | `OD_ALLOWED_ORIGINS` | CSRF origin trust — full `scheme://host`, comma-separated |
| Daemon | `OD_WEB_PORT` | Advertised web port for browser-origin checks |

## The three for a proxied deployment

```bash
OD_HOST=0.0.0.0
OD_ALLOWED_DEV_ORIGINS=opendesign.<id>.maestru.dev
OD_ALLOWED_ORIGINS=https://opendesign.<id>.maestru.dev
```

`scripts/dev-web.sh` bakes these in. Why each is needed: [01-web-sidecar.md](./01-web-sidecar.md), [02-daemon.md](./02-daemon.md), and the runbook [../50-running-in-maestru/01-proxied-dev-environment.md](../50-running-in-maestru/01-proxied-dev-environment.md).
