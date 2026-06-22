---
maestru: "0.4"
type: doc
id: 05-connectors-and-mcp
title: "Connectors & MCP"
description: "The Composio connector engine and the MCP install/config routes — and why connector credential writes are loopback-only"
tags: [daemon, connectors, composio, mcp, credentials]
created: 2026-06-22
updated: 2026-06-22
---

# Connectors & MCP

<!-- maestru:summary -->
The daemon hosts two integration surfaces. Connectors (src/connectors/): registerConnectorRoutes (routes.ts ~528) exposes /api/connectors/* — public reads like list/status/discovery, get, cached Composio logos (/api/connectors/logos/:slug), and tools/connectors/list — but every credential-bearing write is gated by requireLocalDaemonRequest: composio config PUT (routes.ts:578), connector connect OAuth prep (:629), authorization cancel (:678), connection DELETE (:688), tool execute (:729). The Composio provider (connectors/composio.ts) is a singleton over the Composio API with a featured catalog, 10-min OAuth state TTL, 60s discovery cache, 24h catalog refresh; configured at server.ts ~3400-3402 against RUNTIME_DATA_DIR. MCP (src/mcp-routes.ts registerMcpRoutes ~13): /api/mcp/install-info (CLI/Node path, port; 5s cache), one-click Codex install routes, /api/mcp/config GET/PUT/DELETE over ~/.claude/claude.json or project .mcp.json (writes are local-only), and /api/mcp/oauth + /api/mcp/tokens for external MCP servers; mcp-config.ts builds the Claude/ACP MCP server JSON. This is why the maestru.dev proxy can read connectors but cannot write Composio config (403 by design).
<!-- /maestru:summary -->

## Connectors — `src/connectors/`

`registerConnectorRoutes()` (`connectors/routes.ts` ~528) exposes `/api/connectors/*`:

| Access | Endpoints |
|--------|-----------|
| **Public reads** | list / status / discovery, `GET /api/connectors/:id`, cached logos `GET /api/connectors/logos/:slug`, `GET /api/tools/connectors/list` |
| **Loopback-only writes** (`requireLocalDaemonRequest`) | `PUT /api/connectors/composio/config` (:578), connect OAuth prep (:629), authorization cancel (:678), connection `DELETE` (:688), tool execute (:729) |

The **Composio provider** (`connectors/composio.ts`) is a singleton over the Composio API: featured catalog, **10-min OAuth state TTL**, **60s discovery cache**, **24h catalog refresh**. Configured at `server.ts` ~3400–3402 against `RUNTIME_DATA_DIR`.

> This is exactly why, over the `maestru.dev` proxy, you can **read** connectors but **writing** Composio config returns `403` — the write path is loopback-only by design. See [02-auth-and-request-guards.md](./02-auth-and-request-guards.md).

## MCP — `src/mcp-routes.ts`

`registerMcpRoutes()` (~13) exposes `/api/mcp/*`:
- `GET /api/mcp/install-info` — CLI path, Node path, port (5s cache),
- one-click Codex install routes,
- `GET/PUT/DELETE /api/mcp/config` — read/write `~/.claude/claude.json` or a project-scoped `.mcp.json` (**writes are local-only**),
- `/api/mcp/oauth/*` and `/api/mcp/tokens/*` for external MCP servers.

`mcp-config.ts` builds the canonical Claude/ACP MCP server JSON (`buildClaudeMcpJson()`, `buildAcpMcpServers()`) that gets injected into spawned agents (see [04-agent-spawning.md](./04-agent-spawning.md)).

The cloud/MCP platform design at large is documented under maestru-core's `35-mcp-server` section; here we only cover the daemon's local MCP surface.
