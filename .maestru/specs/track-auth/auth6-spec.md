---
maestru: "0.4"
type: work-spec
id: auth6-spec
title: "AUTH6 — Public Share Links"
template: implementation-plan-v1
work-item: track-auth/AUTH6
owner: developer
created: 2026-06-22
---

# AUTH6 — Public Share Links

## Overview

Let a logged-in user generate a **public, no-login URL** for a single artifact so it can be shared outside the org. This is a **deliberate, narrow exception** to the AUTH1 deny-by-default gate (decision: "public share links allowed", 2026-06-22). The design goal is to keep the hole **small and auditable**: a share link exposes exactly one read-only artifact, nothing else.

The hard part is the interaction with **per-user isolation** (AUTH2/AUTH3): a public visitor has no identity, so the normal "auth → route to your instance" path doesn't apply. A share link must carry an **unguessable token** that resolves, on its own, to *one* artifact in *one* user's instance — without a session and without exposing that user's other projects. Hence AUTH6 depends on AUTH3 (per-user instances must exist to resolve into).

Security stance: opt-in per artifact, revocable, no enumeration, read-only, no `/api` access beyond serving that artifact.

## Implementation

**Phase 1 — Share-token model.** A logged-in user clicks "Share" on an artifact → mint an unguessable token (e.g. 128-bit random) recorded in the **router's** store as `token → { namespace, projectId, artifactPath, createdBy, createdAt, revoked }`. Tokens live in the router/registry layer (`oktogon/`), not in the per-user daemon, so resolution needs no user session.

**Phase 2 — Public route + oauth2-proxy carve-out.** Expose a single unauthenticated path family, e.g. `GET /share/<token>` (and the static sub-assets it references). Add it to oauth2-proxy `--skip-auth-route=^/share/` so it bypasses login. Everything else stays gated (AUTH1 invariant).

**Phase 3 — Token → artifact resolution (router).** The AUTH2 router special-cases `/share/<token>`: look up the token, and **internally** proxy a read-only fetch of just that artifact from the owning user's instance (`projects/<id>/<artifact>`), rewriting asset URLs to stay under `/share/<token>/…`. The visitor never reaches `/api/*`, another project, or the owner's session.

**Phase 4 — Hardening.** Read-only (GET only); 404 (not 403, no existence leak) on unknown/revoked tokens; rate-limit by IP; optional expiry (`expiresAt`) and password option; strip `X-Forwarded-*`; ensure the served artifact can't call back into authenticated `/api` (sandbox the iframe / serve as static). No directory listing, no enumeration.

**Phase 5 — Management & audit.** UI to list/revoke a user's share links; audit log of share-create / revoke / public-view (ties to AUTH5 attribution). Revocation is immediate (token marked revoked in the router store).

**Risks / decisions.** Reaching into a running per-user instance to serve one artifact (vs. copying it to a public bucket — alternative to evaluate); ensuring no auth/`/api` reachability through the share path; token leakage = that one artifact only (acceptable, revocable); whether share survives the owner's instance being idle-torn-down (router may need to spin it up read-only, or serve from a cached copy).

## Impacted Files

| File | Action | Purpose |
|------|--------|---------|
| `oktogon/router/share.ts` | Create | Token store + `/share/<token>` resolution to one artifact |
| `oktogon/router/index.ts` | Modify | Route `/share/*` before the auth-required path |
| `deploy/oauth2-proxy.cfg` | Modify | `--skip-auth-route=^/share/` carve-out |
| `oktogon/router/audit.ts` | Modify | Log share create/revoke/public-view |
| `.maestru/docs/02-architecture/03-security-and-origin-model.md` | Modify | Document the single deliberate unauthenticated exception |
| `.maestru/docs/50-running-in-maestru/05-multi-user.md` | Modify | Document public sharing in the multi-user model |
