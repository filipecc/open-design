---
maestru: "0.4"
type: work-spec
id: auth5-spec
title: "AUTH5 — Deployment, Secrets & Hardening"
template: implementation-plan-v1
work-item: track-auth/AUTH5
owner: developer
created: 2026-06-22
---

# AUTH5 — Deployment, Secrets & Hardening

## Overview

Productionize the multi-user stack: durable per-user data, real secrets handling, a supervised process chain, resource limits, audit/attribution, and a clean upgrade path that keeps absorbing upstream. This closes the persistence and access-control open questions in `01-product/03-open-questions.md`.

Target topology (unchanged hosting proxy in front):
```
hosting proxy → oauth2-proxy(:3000) → router(:3001) → orchestrator → per-user {web, daemon}  → shared ~/.claude
                                                                              └ /var/lib/open-design/users/<ns>/ (durable)
```

## Implementation

**Phase 1 — Persistence.** Per-user `OD_DATA_DIR` on a durable volume (`/var/lib/open-design/users/<namespace>`), so projects/MCP tokens survive restarts — resolves the "ephemeral `.od`" gap. Backups of that tree.

**Phase 2 — Secrets.** Google `client_secret`, oauth2-proxy `cookie-secret`, and any MCP client credentials via env/secret store (not git). `.env.example` documents the required set; real values injected at deploy.

**Phase 3 — Supervision.** Compose (or systemd) for oauth2-proxy + router + orchestrator as long-lived services; the hosting proxy still targets `:3000` (whatever public host fronts the deployment). Health checks + restart policy. Per-user instances run a **production web build** (`pnpm --filter @open-design/web build`, then `tools-dev --prod`) — spike C showed dev mode adds ~12–13s of on-demand compile to cold-start, which prod removes.

**Phase 4 — Hardening.** Per-instance daemon stays loopback (the AUTH1 no-bypass invariant applies to *every* per-user instance, not just the gate); the router strips any inbound `X-Forwarded-*` it didn't set; concurrent-instance ceiling + LRU teardown; rate limits. The **public share routes (AUTH6)** are the only unauthenticated surface — verify they expose read-only single artifacts and no `/api` reachability. **Audit log** of logins, runs, and share create/view keyed by `X-Forwarded-Email` for attribution (the shared Claude Code account makes per-user attribution otherwise invisible).

**Phase 5 — Upgrade path.** All custom code lives under `gateway/` + `scripts/` (additive) → `git merge upstream/main` stays clean (`80-methodology/03-upstream-merge-runbook.md`). Document a rolling restart that drains per-user instances.

**Risks / decisions.** Volume sizing per user; cost of N idle instances (idle teardown mitigates); secret rotation; GDPR/retention for stored user MCP tokens + projects; whether to cap to known org emails (allowlist) beyond the configured domain check.

## Impacted Files

| File | Action | Purpose |
|------|--------|---------|
| `deploy/multiuser/compose.yaml` | Create | Supervise oauth2-proxy + router + orchestrator |
| `gateway/orchestrator/lifecycle.ts` | Modify | Resource ceilings, idle teardown, drain-on-upgrade |
| `gateway/router/audit.ts` | Create | Per-user login/run audit log (attribution) |
| `.env.example` | Modify | Full secret + volume documentation |
| `.maestru/docs/50-running-in-maestru/04-deployment-options.md` | Modify | Promote to the supervised multi-user deployment |
| `.maestru/docs/01-product/03-open-questions.md` | Modify | Mark auth + persistence decisions resolved |
