---
maestru: "0.4"
type: work-track
id: track-auth
title: Authenticated Multi-User Access + Per-User MCP
created: 2026-06-22
description: "Per-user front-door authentication (shared org Claude Code), per-user workspace isolation, and per-user MCP OAuth/PKCE association with the Maestru internal MCP server."
owner: developer
status: active
---

# track-auth: Authenticated Multi-User Access + Per-User MCP

Per-user front-door authentication with a shared organization Claude Code account, evolving from shared-workspace access control (model A) to per-user workspace isolation (model B), and per-user OAuth 2.1 + PKCE association with the Maestru internal MCP server so each user's agent acts on their own connected accounts. Built additively in front of / around Open Design (no upstream code edits) so the fork stays mergeable. Each work-item has an implementation-plan spec under `.maestru/specs/`.

## Summary

<!-- maestru:work-items-list -->
| ID | Title | Status | Created | Owner | Priority | Completed | Blocked By | Spec |
|---|---|---|---|---|---|---|---|---|
| AUTH1 | Front-door authentication gate (oauth2-proxy + Google domain SSO) | backlog | 2026-06-22 |  | critical |  |  | [AUTH1](../specs/track-auth/auth1-spec.md) |
| AUTH2 | Per-user instance router + namespace/data-dir mapping | backlog | 2026-06-22 |  | high |  | AUTH1 | [AUTH2](../specs/track-auth/auth2-spec.md) |
| AUTH3 | Per-user daemon lifecycle & orchestration (shared Claude Code) | backlog | 2026-06-22 |  | high |  | AUTH2 | [AUTH3](../specs/track-auth/auth3-spec.md) |
| AUTH4 | Per-user MCP OAuth/PKCE with the Maestru MCP server | backlog | 2026-06-22 |  | high |  | AUTH3 | [AUTH4](../specs/track-auth/auth4-spec.md) |
| AUTH5 | Deployment, secrets & hardening | backlog | 2026-06-22 |  | medium |  | AUTH4, AUTH6 | [AUTH5](../specs/track-auth/auth5-spec.md) |
| AUTH6 | Public share links (unauthenticated artifact sharing) | backlog | 2026-06-22 |  | medium |  | AUTH3 | [AUTH6](../specs/track-auth/auth6-spec.md) |
<!-- /maestru:work-items-list -->
