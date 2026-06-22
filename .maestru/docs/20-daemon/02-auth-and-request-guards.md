---
maestru: "0.4"
type: doc
id: 02-auth-and-request-guards
title: "Auth & Request Guards"
description: "The daemon's three request defenses: api-token-auth.ts (OD_API_TOKEN), origin-validation.ts (OD_ALLOWED_ORIGINS), and the loopback-only validateLocalDaemonRequest"
tags: [daemon, auth, guards, api-token, origin, loopback, 403]
created: 2026-06-22
updated: 2026-06-22
---

# Auth & Request Guards

<!-- maestru:summary -->
The daemon authorizes /api requests in three independent layers, all in apps/daemon/src. (1) api-token-auth.ts: isApiTokenMiddlewareEnabled() requires OD_API_TOKEN set AND OD_DISABLE_API_AUTH not truthy; the server gate (server.ts ~3272-3296) bypasses loopback peers (~3287) and otherwise requires Authorization: Bearer <OD_API_TOKEN> (401 on mismatch); open paths /api/health|ready|version. (2) origin-validation.ts isLocalSameOrigin() (~line 155): trusts loopback/private-LAN origins (isLoopbackOrPrivateLanHost) plus configuredAllowedOrigins() from OD_ALLOWED_ORIGINS (comma-separated full scheme://host, throws on bare hostname); allowedBrowserPorts() folds in OD_WEB_PORT; cross-origin requests are rejected ~403 except health/version. (3) validateLocalDaemonRequest()/requireLocalDaemonRequest() (server.ts ~2569-2613): the strict guard requiring loopback peer AND loopback Host header AND (if present) loopback Origin, ignoring OD_ALLOWED_ORIGINS — applied to secret writes: connector credential/config writes, MCP config writes, diagnostics export, plugin install. Net: reads+most writes need OD_ALLOWED_ORIGINS to include the public origin; secret writes are loopback-only by design.
<!-- /maestru:summary -->

Three independent layers, all under `apps/daemon/src`. This is the canonical daemon-side reference; the system-level view is [../02-architecture/03-security-and-origin-model.md](../02-architecture/03-security-and-origin-model.md).

## 1. API-token middleware — `api-token-auth.ts`

- `apiTokenFromEnv()` reads `OD_API_TOKEN`; `isApiAuthDisabled()` reads `OD_DISABLE_API_AUTH`; `isApiTokenMiddlewareEnabled()` requires a token **and** auth not disabled.
- Server gate (`server.ts` ~3272–3296): **loopback peers bypass** (~3287); non-loopback callers must send `Authorization: Bearer <token>` or get **401**.
- Open paths: `/api/health`, `/api/ready`, `/api/version`.

## 2. Origin trust — `origin-validation.ts`

- `isLocalSameOrigin()` (~line 155) is the per-request check.
- Trusts loopback / private-LAN origins (`isLoopbackOrPrivateLanHost`) **plus** `configuredAllowedOrigins()` from **`OD_ALLOWED_ORIGINS`** (comma-separated, full `scheme://host`; `new URL()` throws on a bare hostname).
- `allowedBrowserPorts()` folds in `OD_WEB_PORT`.
- Cross-origin → **403** (except health/version). `Origin: null` allowed only for safe read-only GETs.

> This is the layer that 403s every `/api` call from a public domain until its origin is in `OD_ALLOWED_ORIGINS`.

## 3. The strict loopback-only guard

`validateLocalDaemonRequest()` / `requireLocalDaemonRequest()` (`server.ts` ~2569–2613) requires **all** of:
- loopback peer socket address,
- loopback `Host` header,
- loopback `Origin` (if present).

It **ignores `OD_ALLOWED_ORIGINS`**. Applied to secret-bearing endpoints:
- connector credential/config writes (`connectors/routes.ts:578, 629, 678, 688`),
- MCP config writes (`mcp-routes.ts`),
- diagnostics export (`server.ts:~3767`),
- plugin install (`server.ts:~4173`).

These are intentionally **unreachable through a remote proxy** — see the audit [../85-audits/01-auth-and-origin-analysis-2026-06.md](../85-audits/01-auth-and-origin-analysis-2026-06.md).
