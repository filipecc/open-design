---
maestru: "0.4"
type: work-spec
id: auth4-spec
title: "AUTH4 — Per-user MCP OAuth/PKCE with the Maestru MCP Server"
template: implementation-plan-v1
work-item: track-auth/AUTH4
owner: developer
created: 2026-06-22
---

# AUTH4 — Per-user MCP OAuth/PKCE with the Maestru MCP Server

## Overview

Each user, **in their own daemon** (AUTH3), authorizes the **Maestru internal MCP server** via OAuth 2.1 + PKCE; the resulting per-user token is stored in their `OD_DATA_DIR` and injected into their Claude Code spawns, so the shared org Claude Code acts on **that user's** connected accounts (Gmail, Calendar, Drive, Notion…).

This is **mostly built-in** — the daemon is already a full MCP OAuth client (verified):
- discovery (RFC 9728 + RFC 8414) + dynamic client registration (RFC 7591) cached in `mcp-oauth-clients.json`,
- PKCE S256 (`apps/daemon/src/mcp-oauth.ts` `generateCodeVerifier`/`deriveCodeChallenge`),
- token store at `<OD_DATA_DIR>/mcp-tokens.json` (mode 0600), refreshed on spawn,
- injection into Claude Code via `<cwd>/.mcp.json` Bearer headers (`mcp-config.ts` `buildClaudeMcpJson`).

The Maestru MCP server is a standard match: `<origin>/.well-known/oauth-authorization-server` → `/oauth/register` → `/oauth/authorize` (PKCE S256) → `/oauth/token` → Bearer on `ALL /mcp`; tokens are bound to one Maestru user and run as that user. The single-tenant token limit is **dissolved by AUTH3** — one daemon (hence one `mcp-tokens.json`) per user.

Crucially, `GET /api/mcp/oauth/callback` is **deliberately not loopback-gated**, so it works through the public proxy; the other `/api/mcp/*` endpoints use `isLocalSameOrigin` which `OD_ALLOWED_ORIGINS` already satisfies (not the strict loopback-only guard). So little/no Open Design code change is needed.

## Implementation

**Phase 1 — Seed the MCP server config per instance.** On spawn (AUTH3 hook), register the Maestru MCP server in the user's daemon (`PUT /api/mcp/servers`): `url=<maestru-mcp-origin>/mcp`, `authMode=oauth`. Users shouldn't have to configure it.

**Phase 2 — Per-user authorize.** User clicks Connect → `POST /api/mcp/oauth/start` → daemon does discovery + DCR + builds the PKCE S256 authorize URL → user's browser → Maestru login + consent → redirect to `/api/mcp/oauth/callback` → token exchange → stored in their `mcp-tokens.json`.

**Phase 3 — Redirect-URI allowlist (the integration subtlety).** The daemon's callback URL must be in the Maestru box's `OAUTH_DYNAMIC_CLIENT_ALLOWED_REDIRECT_HOSTS` (exact match). Since requests traverse the public proxy → router → the user's instance, settle the **single public callback URL shape** and ensure the router routes `/api/mcp/oauth/callback?state=…` back to the originating user's instance (state-keyed). Coordinate the box config with the Maestru MCP admin.

**Phase 4 — Injection.** On each spawn, `buildClaudeMcpJson` writes the user's Bearer token into `<cwd>/.mcp.json`, so Claude Code calls `/mcp` as that user. Tokens auto-refresh on spawn when expired (built-in).

**Phase 5 — Scopes & lifecycle.** Request `mcp:read mcp:write offline_access` (refresh token). Consider per-run scoped tokens (Maestru MCP126 `allowed_tools`) for headless runs later. Handle `401 + WWW-Authenticate` by re-running the flow.

**Risks / decisions.** Redirect-host allowlist on the Maestru box needs an admin change — coordinate early. Router must map the OAuth callback back to the right user instance via `state`. Confirm the daemon's DCR redirect URI uses the public host, not loopback.

## Impacted Files

| File | Action | Purpose |
|------|--------|---------|
| `gateway/orchestrator/seed-mcp.ts` | Create | Auto-register the Maestru MCP server per instance |
| `gateway/router/index.ts` | Modify | Route `/api/mcp/oauth/callback` by `state` → user instance |
| `deploy/maestru-mcp.md` | Create | Box config: allowlist the redirect host (admin coordination) |
| `.maestru/docs/20-daemon/05-connectors-and-mcp.md` | Modify | Document the per-user MCP OAuth wiring |
| `.maestru/docs/50-running-in-maestru/05-multi-user.md` | Modify | Document per-user MCP association |
