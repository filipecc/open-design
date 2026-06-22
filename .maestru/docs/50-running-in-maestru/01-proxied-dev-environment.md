---
maestru: "0.4"
type: doc
id: 01-proxied-dev-environment
title: "Proxied Dev Environment"
description: "The runbook for serving Open Design through the public maestru.dev proxy: scripts/dev-web.sh, the three env vars, and 502/403 troubleshooting"
tags: [running, maestru, proxy, dev-web, troubleshooting, 502, 403]
created: 2026-06-22
updated: 2026-06-22
---

# Proxied Dev Environment

<!-- maestru:summary -->
Runbook for serving Open Design behind the public maestru.dev reverse proxy. The proxy at https://opendesign.<id>.maestru.dev forwards to the web sidecar on port 3000 inside the container. Three env vars are required every launch or the app breaks: OD_HOST=0.0.0.0 (else the loopback-only default 502s), OD_ALLOWED_DEV_ORIGINS=<host> (web/Next.js host allowlist), and OD_ALLOWED_ORIGINS=https://<host> (daemon CSRF origin trust; without it every /api call 403s). scripts/dev-web.sh bakes all three in with overridable PORT/PUBLIC_HOST and execs pnpm tools-dev run web --web-port 3000. Troubleshooting: 502 Bad Gateway = web bound to loopback (fix OD_HOST); 403 on /api = daemon origin not trusted (fix OD_ALLOWED_ORIGINS, full scheme); a stubborn 403 on secret-writing endpoints (composio config, diagnostics/plugin export) is by-design loopback-only and cannot be fixed via env. The daemon and web logs are at /app/.tmp/tools-dev/default/logs/{daemon,web}/latest.log; the daemon does not log /api requests, so client-side DevTools Network is the primary diagnostic.
<!-- /maestru:summary -->

## The run command

```bash
scripts/dev-web.sh
# overridable:
PORT=4000 PUBLIC_HOST=opendesign.<id>.maestru.dev scripts/dev-web.sh
```

The script (`scripts/dev-web.sh`) exports the three required vars and execs `pnpm tools-dev run web --web-port "$PORT"`. Equivalent raw command:

```bash
OD_HOST=0.0.0.0 \
OD_ALLOWED_DEV_ORIGINS=opendesign.<id>.maestru.dev \
OD_ALLOWED_ORIGINS=https://opendesign.<id>.maestru.dev \
pnpm tools-dev run web --web-port 3000
```

## Why each var

| Var | Without it |
|-----|-----------|
| `OD_HOST=0.0.0.0` | Web binds loopback-only → proxy gets **502 Bad Gateway** |
| `OD_ALLOWED_DEV_ORIGINS=<host>` | Web sidecar / Next.js reject the cross-origin host |
| `OD_ALLOWED_ORIGINS=https://<host>` | Daemon CSRF guard 403s **every `/api`** call |

Background: [../03-environment-variables/01-web-sidecar.md](../03-environment-variables/01-web-sidecar.md), [../03-environment-variables/02-daemon.md](../03-environment-variables/02-daemon.md).

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Public URL → **502** | Web bound to `127.0.0.1` | `OD_HOST=0.0.0.0` |
| Page loads, **403 on every `/api`** | Public origin not in daemon trust | `OD_ALLOWED_ORIGINS=https://<host>` (full scheme!) |
| **500** on `/api/amr/models` | No Open Design Cloud account | Expected — use Local agent or BYOK |
| **403** only on Composio config / exports | `requireLocalDaemonRequest` (loopback-only) | By design — unreachable via proxy |
| `/api/community/discord` 502, `connectors/logos/*` 404, favicon 404 | External fetches blocked/missing | Cosmetic — ignore |

### Logs

```
/app/.tmp/tools-dev/default/logs/daemon/latest.log
/app/.tmp/tools-dev/default/logs/web/latest.log
```

The daemon does **not** log `/api` requests — only startup and exceptions. So a clean log during a failing action is normal; use the browser **DevTools → Network** tab (look for red `/api` rows and their status) as the primary diagnostic.

### Verifying from inside the container

`ss` is often blind in this container; use `/proc/net/tcp` (port hex, e.g. `0BB8` = 3000; local `00000000:` = all-interfaces, `0100007F:` = loopback). Test the proxy path with the browser Origin header:

```bash
curl -H 'Origin: https://opendesign.<id>.maestru.dev' \
  -o /dev/null -w '%{http_code}\n' \
  https://opendesign.<id>.maestru.dev/api/app-config   # expect 200
```

The full investigation that produced this runbook: [../85-audits/01-auth-and-origin-analysis-2026-06.md](../85-audits/01-auth-and-origin-analysis-2026-06.md).
