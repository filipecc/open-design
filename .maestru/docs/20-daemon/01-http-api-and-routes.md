---
maestru: "0.4"
type: doc
id: 01-http-api-and-routes
title: "HTTP API & Routes"
description: "How server.ts registers the /api/* surface and the main route groups (projects, chat, runs, plugins, connectors, MCP, vela, media, …)"
tags: [daemon, api, routes, express, server, od-bin]
created: 2026-06-22
updated: 2026-06-22
---

# HTTP API & Routes

<!-- maestru:summary -->
apps/daemon/src/server.ts is the Express composition root. It installs middleware (JSON body limit ~4MB, API-token auth, CORS/origin validation) around lines 3248-3385, registers every route group (roughly lines 3573-4449), and binds with app.listen() (~line 8810). Routes live in src/routes/ and a few legacy top-level files: projects (routes/project/index.ts, /api/projects/*), chat SSE (routes/chat.ts, /api/chat), runs (routes/runs.ts), plugins+atoms (routes/plugins/), design-systems (routes/design-systems.ts), memory (routes/memory.ts), media (routes/media.ts), live-artifacts (routes/live-artifact.ts), terminal (routes/terminal.ts), vela/AMR (routes/vela.ts, /api/vela/* login/profile/models), connectors (connectors/routes.ts, /api/connectors/*), MCP (mcp-routes.ts, /api/mcp/*), deploy, import/export (import-export-routes.ts), telemetry, social-share, genui, host-tools, active-context, xai. The od bin (src/cli.ts) is the CLI composition root whose default mode launches the daemon + web UI; subcommands like `od media` are thin HTTP clients that POST to a running daemon. Open monitoring paths /api/health|ready|version bypass auth. The same /api surface the web UI uses is available to scripts and MCP.
<!-- /maestru:summary -->

## `server.ts` — the composition root

`apps/daemon/src/server.ts` wires the Express app:
- **Middleware** (~lines 3248–3385): JSON body limit (~4 MB), API-token auth, CORS/origin validation.
- **Route registration** (~lines 3573–4449): calls each route group's registrar.
- **Listen** (~line 8810): `app.listen()`.

## Main route groups

| Domain | File | Paths |
|--------|------|-------|
| Projects | `src/routes/project/index.ts` | `/api/projects/*` |
| Chat (SSE) | `src/routes/chat.ts` | `/api/chat` |
| Runs | `src/routes/runs.ts` | `/api/runs/*` |
| Plugins / atoms | `src/routes/plugins/` | `/api/plugins/*`, `/api/atoms/*` |
| Design systems | `src/routes/design-systems.ts` | `/api/design-systems/*` |
| Memory | `src/routes/memory.ts` | `/api/memory/*` |
| Media | `src/routes/media.ts` | `/api/media/*` |
| Live artifacts | `src/routes/live-artifact.ts` | `/api/live-artifacts/*` |
| Terminal | `src/routes/terminal.ts` | `/api/terminal/*` |
| Vela / AMR (cloud) | `src/routes/vela.ts` | `/api/vela/*` (login, profile, models) |
| Connectors | `src/connectors/routes.ts` | `/api/connectors/*`, `/api/tools/connectors/*` |
| MCP | `src/mcp-routes.ts` | `/api/mcp/*` |
| Deploy | `src/routes/deploy.ts` | `/api/deploy/*` |
| Import / export | `src/import-export-routes.ts` | `/api/import/*`, `/api/projects/*/export` |
| Misc | `src/routes/{telemetry,social-share,genui,host-tools,active-context,xai}.ts` | `/api/*` |

## Open (auth-bypass) paths

`/api/health`, `/api/ready`, `/api/version` skip the token middleware (monitoring probes) — see [02-auth-and-request-guards.md](./02-auth-and-request-guards.md).

## The `od` bin

`apps/daemon/src/cli.ts` is the CLI composition root. Its **default mode launches the daemon + web UI**; subcommands like `od media …` are thin HTTP clients that POST to a running daemon. The same `/api` surface the web UI uses is available to scripts and to MCP.
