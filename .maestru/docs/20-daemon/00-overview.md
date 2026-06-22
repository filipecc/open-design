---
maestru: "0.4"
type: doc
id: 00-overview
title: "Daemon Overview"
description: "apps/daemon — the privileged local process and od bin that owns /api/*, auth guards, SQLite storage, agent spawning, connectors and MCP"
tags: [daemon, apps-daemon, overview, api, od-bin]
created: 2026-06-22
updated: 2026-06-22
---

# Daemon Overview

<!-- maestru:summary -->
apps/daemon is the privileged local Node process and the `od` binary (apps/daemon/src/cli.ts) — the trust boundary of Open Design. Its Express server (apps/daemon/src/server.ts) registers the entire /api/* surface across many route modules under src/routes/ and src/connectors/ (projects, chat SSE, runs, plugins, design-systems, memory, media, vela/AMR, connectors, MCP, deploy, import/export, telemetry, etc.). It defends itself with three layers — API-token middleware (api-token-auth.ts), CSRF origin trust (origin-validation.ts, OD_ALLOWED_ORIGINS), and a stricter loopback-only guard (validateLocalDaemonRequest) for secret writes. All state roots at RUNTIME_DATA_DIR (resolved from OD_DATA_DIR), with app.sqlite via better-sqlite3 and derived dirs PROJECTS_DIR/ARTIFACTS_DIR. It detects agent CLIs (runtimes/detection.ts detectAgents) and spawns them to run a design, routing their stdout through per-agent stream handlers (Claude/Copilot/ACP/Qoder/JSON). It also hosts the connector engine (Composio) and MCP install/config routes. Sibling docs cover each area.
<!-- /maestru:summary -->

`apps/daemon` is the **privileged local process** and the **`od` binary** — it owns everything that touches the filesystem, spawns processes, or holds credentials. It is the trust boundary; the web app is a client of it.

## In this section

| Doc | Purpose |
|-----|---------|
| [01-http-api-and-routes.md](./01-http-api-and-routes.md) | `server.ts` and the `/api/*` route modules |
| [02-auth-and-request-guards.md](./02-auth-and-request-guards.md) | Token middleware, origin trust, loopback-only guard |
| [03-data-dir-and-storage.md](./03-data-dir-and-storage.md) | `RUNTIME_DATA_DIR`, SQLite, migration |
| [04-agent-spawning.md](./04-agent-spawning.md) | Detecting and running agent CLIs |
| [05-connectors-and-mcp.md](./05-connectors-and-mcp.md) | Composio connectors + MCP routes |

## Key files

| File | Role |
|------|------|
| `apps/daemon/src/server.ts` | Express entry; middleware; route registration; agent spawn; `app.listen()` |
| `apps/daemon/src/cli.ts` | The `od` bin; default mode starts daemon + web UI |
| `apps/daemon/src/api-token-auth.ts` | Bearer-token middleware |
| `apps/daemon/src/origin-validation.ts` | CSRF origin trust |
| `apps/daemon/src/daemon-paths.ts` | Data-dir + path resolution |
| `apps/daemon/src/routes/`, `src/connectors/`, `src/mcp-routes.ts` | The `/api/*` surface |
| `apps/daemon/src/runtimes/` | Agent definitions + detection |

> The authoritative in-repo guide is `apps/daemon/AGENTS.md`, and the top-level `AGENTS.md` owns the **daemon data directory contract**.
