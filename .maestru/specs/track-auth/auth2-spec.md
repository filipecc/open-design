---
maestru: "0.4"
type: work-spec
id: auth2-spec
title: "AUTH2 — Per-user Instance Router + Namespace/Data-dir Mapping"
template: implementation-plan-v1
work-item: track-auth/AUTH2
owner: developer
created: 2026-06-22
---

# AUTH2 — Per-user Instance Router + Namespace/Data-dir Mapping

## Overview

Turn the authenticated identity from AUTH1 into a **per-user instance**. A small router sits between the auth proxy and the app: it reads `X-Forwarded-Email`, maps the user to a stable **namespace** + dedicated **`OD_DATA_DIR`**, and reverse-proxies the request to *that user's* web sidecar. This is the core of **model B** and the foundation for per-user MCP (AUTH4).

Verified feasible (`tools/dev` namespaces isolate IPC sockets + runtime dirs at `/tmp/open-design/ipc/<ns>/`; `OD_DATA_DIR` independently isolates `app.sqlite`/projects/`mcp-tokens.json`; multiple daemon+web pairs run concurrently; all share `~/.claude` because `HOME` is never overridden — `apps/daemon/src/runtimes/env.ts`).

Chain after this item:
```
maestru.dev → oauth2-proxy(:3000) → ROUTER(:3001) → per-user web sidecar(:30xx) → per-user daemon → shared ~/.claude
```

This item owns the **mapping + routing contract + registry**; actual spawn/teardown is AUTH3. Code lives under a new clearly-owned `oktogon/` dir (additive — no Open Design edits).

## Implementation

**Phase 1 — Identity → namespace/data-dir.** `namespace = sha256(email).slice(0,12)`; `dataDir = /var/lib/open-design/users/<namespace>` (durable mount, per AUTH5). Deterministic and stable across logins.

**Phase 2 — Router.** A small Node/Express service (`oktogon/router/`) that, per request: reads `X-Forwarded-Email` (trusted only from the auth proxy hop), looks up the user's instance in the registry, and reverse-proxies (HTTP + SSE + WebSocket upgrade) to that instance's web port. Single public host; route by authenticated session (sticky to the user's instance).

**Phase 3 — Registry.** In-memory map persisted to disk: `email → { namespace, dataDir, webPort, daemonPort, pid, lastAccessAt }`. The router reads it; AUTH3's orchestrator writes it on spawn/teardown.

**Phase 4 — Wire into AUTH1.** Point oauth2-proxy `--upstream` at the router (`:3001`) instead of a single web sidecar. On a cache miss (no running instance), the router calls the orchestrator (AUTH3) to spawn one, waits for ready, then proxies — so the user never sees the plumbing.

**Phase 5 — Public-share path (AUTH6 hook).** The router must match the unauthenticated **`/share/<token>`** family *before* identity-based routing and resolve it via the AUTH6 token store (no session, read-only, one artifact). All other paths require the `X-Forwarded-Email` from the auth hop. Design the router so the share branch and the authenticated branch are cleanly separated.

**Risks / decisions.** Session stickiness (one user → one instance); `X-Forwarded-Email` must be unspoofable (only the auth-proxy hop may set it — strip any inbound copy at the router edge); cold-start latency on first request (handled by AUTH3 readiness wait); per-instance daemon stays loopback.

## Impacted Files

| File | Action | Purpose |
|------|--------|---------|
| `oktogon/router/index.ts` | Create | Identity-aware reverse proxy (HTTP/SSE/WS) |
| `oktogon/router/registry.ts` | Create | Email → instance registry (persisted) |
| `oktogon/router/namespace.ts` | Create | Deterministic email → namespace/data-dir |
| `scripts/auth-proxy.sh` | Modify | Point oauth2-proxy upstream at the router |
| `.maestru/docs/50-running-in-maestru/05-multi-user.md` | Create | Document the multi-user routing model |
