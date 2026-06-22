---
maestru: "0.4"
type: work-spec
id: auth4-spec
title: "AUTH4 — Per-user MCP Connections (OAuth 2.1 + PKCE)"
template: implementation-plan-v1
work-item: track-auth/AUTH4
owner: developer
created: 2026-06-22
---

# AUTH4 — Per-user MCP Connections (OAuth 2.1 + PKCE)

## Overview

Let each authenticated user connect to **any standards-compliant MCP server** that supports **OAuth 2.1 + PKCE** — server-agnostic. The user authorizes; their token is stored in their own `OD_DATA_DIR` and injected into their Claude Code spawns, so the shared org Claude Code acts on **that user's** connected accounts. **No specific MCP server is hardcoded** — which server(s) are offered/seeded is deploy/run-time config (per the vendor-neutral principle).

**Mostly built-in** — the daemon is already a generic MCP OAuth client (verified), so we build to the *standard*, not to any one server:
- discovery (RFC 9728 + RFC 8414) + dynamic client registration (RFC 7591), cached in `mcp-oauth-clients.json`,
- PKCE S256 (`apps/daemon/src/mcp-oauth.ts` `generateCodeVerifier`/`deriveCodeChallenge`),
- per-user token store at `<OD_DATA_DIR>/mcp-tokens.json` (mode 0600), refreshed on spawn,
- injection into Claude Code via `<cwd>/.mcp.json` Bearer headers (`mcp-config.ts` `buildClaudeMcpJson`).

`GET /api/mcp/oauth/callback` is **deliberately not loopback-gated** (works through the public proxy); other `/api/mcp/*` endpoints use `isLocalSameOrigin`, which `OD_ALLOWED_ORIGINS` already satisfies. So the connect capability is server-agnostic and already present in Open Design.

**What AUTH4 actually adds** on top of that built-in capability: make it work **per-user in the multi-user deployment** (each user's own daemon + token store, from AUTH3), route the OAuth **callback back through the proxy to the right user's instance**, and make **token refresh/rotation robust**. The single-tenant token limit is dissolved by AUTH3 (one `mcp-tokens.json` per user).

## Implementation

**Phase 1 — Register MCP server(s).** Use the existing UI/endpoint (`PUT /api/mcp/servers`, `authMode=oauth`) so a user can add any MCP server by URL. Optionally seed a default set per instance from **deploy config** (server origins are env/config, not hardcoded). No server identity baked into the repo.

**Phase 2 — Per-user authorize (generic).** Connect → `POST /api/mcp/oauth/start` → daemon does discovery + DCR + builds the PKCE S256 authorize URL → user's browser → that server's login/consent → redirect to `/api/mcp/oauth/callback` → token exchange → stored in the user's `mcp-tokens.json`.

**Phase 3 — Callback routing through the proxy.** The router maps `/api/mcp/oauth/callback?state=…` back to the **originating user's instance** (state-keyed). Confirm the daemon's DCR redirect URI uses the **public host** (`https://$PUBLIC_HOST/api/mcp/oauth/callback`), not loopback. Generic requirement: whatever MCP server the user connects must permit that redirect URI under its own client-registration/allowlist policy (for DCR-capable servers this is typically automatic; for stricter servers, the server operator allowlists it — a per-server, deploy-time concern, not in the repo).

**Phase 4 — Injection.** On each spawn, `buildClaudeMcpJson` writes the user's Bearer token into `<cwd>/.mcp.json`, so Claude Code calls that server's `/mcp` as the user.

**Phase 5 — Token refresh, rotation & expiry.** Standards-based, server-agnostic:
- Request `offline_access` (or the server's equivalent) so a **refresh token** is issued — precondition for any refresh.
- The daemon refreshes on spawn when the access token is expired, using the persisted `refreshToken`/`tokenEndpoint`/`clientId`/`clientSecret`.
- **MUST-VERIFY:** OAuth servers **may rotate** the refresh token on each use (RFC 6749 §6 allows it; some servers revoke the whole chain if a rotated token is reused). Confirm the daemon **persists the rotated `refreshToken` back** to `mcp-tokens.json` after each refresh — otherwise the 2nd refresh fails and the user is silently disconnected. If it doesn't, that's the one small Open Design change AUTH4 needs.
- **No concurrent refresh** on the same token (rely on the per-`dataDir` mutex; per-user daemons make cross-instance races impossible).
- **Expiry UX:** access-token refresh is silent; when the **refresh token itself** expires or a refresh fails (`401 + WWW-Authenticate`), surface a clear **"Reconnect"** prompt to the user and re-run the authorize flow. Define behavior for mid-run expiry and the AUTH3 idle-teardown gap (token persists under the durable per-user `OD_DATA_DIR` from AUTH5; on next spawn, refresh-on-spawn applies).

**Phase 6 — Scopes, disconnect, lifecycle.** Request the scopes the server advertises (read/write + offline_access). Support disconnect/revoke (`POST /api/mcp/oauth/disconnect`). Optionally use per-run scoped tokens if a server offers them.

**Risks / decisions.** The connected server's redirect-URI/client-registration policy must permit our callback (server-dependent, deploy-time). Router must state-key the callback to the right user instance. **Verify rotated-refresh-token write-back before relying on "built-in" refresh** — this is the one genuine code-risk in AUTH4.

## Impacted Files

| File | Action | Purpose |
|------|--------|---------|
| `gateway/router/index.ts` | Modify | Route `/api/mcp/oauth/callback` by `state` → user instance |
| `gateway/orchestrator/seed-mcp.ts` | Create | (Optional) seed default MCP server config per instance from deploy config |
| `deploy/mcp-servers.example` | Create | Deploy-time MCP server origin(s) + per-server redirect-allowlist notes (no values committed) |
| `apps/daemon/src/mcp-oauth.ts` | Verify (only) | Confirm rotated refresh token is persisted; patch only if it isn't |
| `.maestru/docs/20-daemon/05-connectors-and-mcp.md` | Modify | Document per-user MCP OAuth + refresh wiring |
| `.maestru/docs/50-running-in-maestru/05-multi-user.md` | Modify | Document per-user MCP connections |
