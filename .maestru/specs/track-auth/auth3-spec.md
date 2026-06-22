---
maestru: "0.4"
type: work-spec
id: auth3-spec
title: "AUTH3 — Per-user Daemon Lifecycle & Orchestration"
template: implementation-plan-v1
work-item: track-auth/AUTH3
owner: developer
created: 2026-06-22
---

# AUTH3 — Per-user Daemon Lifecycle & Orchestration

## Overview

The orchestrator that **spawns and tears down a per-user daemon+web pair on demand**, keyed by the namespace + `OD_DATA_DIR` from AUTH2, all sharing the one org `~/.claude` (Claude Code). It populates the registry the AUTH2 router proxies against. Verified: `OD_DATA_DIR=<dir> tools-dev run web --namespace <ns>` runs an isolated instance; ports auto-allocate without collision (`tools/dev/src/shared-ports.ts`); `HOME` (and thus `~/.claude`) is shared across instances (`apps/daemon/src/runtimes/env.ts`); per-instance state (sqlite, projects, MCP tokens, `installation.json`) lives under its own `OD_DATA_DIR`.

No Open Design code changes — pure orchestration around `tools-dev`. Lives in `gateway/orchestrator/`.

## Implementation

**Phase 1 — Spawn.** On first request for a user (router cache miss), launch `OD_DATA_DIR=<dir> OD_HOST=127.0.0.1 OD_ALLOWED_ORIGINS=https://<public-host> tools-dev run web --namespace <ns> --web-port 0`. Capture the allocated web + daemon ports from the tools-dev status snapshot / IPC (`/tmp/open-design/ipc/<ns>/`).

**Phase 2 — Readiness.** Wait for "dev server ready" / a health probe on the web port before the router proxies to it (avoids 502s on cold start).

**Phase 3 — Registry + lifecycle.** Write `{ pid, webPort, daemonPort, lastAccessAt }` to the shared registry; update `lastAccessAt` on each request. **Idle teardown** after N minutes; cleanup on orchestrator exit via `TOOLS_DEV_PARENT_PID`.

**Phase 4 — Shared Claude Code.** Confirm `HOME` unchanged so all instances read the same `~/.claude` org credential; do **not** set per-user agent homes. (Per-user *data* isolated; per-user *agent account* shared — exactly the requirement.)

**Phase 5 — Resource ceilings.** Cap concurrent instances; LRU teardown of the least-recently-used when over the cap; optional warm pool to cut cold-start latency. Each instance is ~1 daemon + 1 Next.js process.

**Risks / decisions.** Spawn latency (mitigate with warm pool / readiness wait); memory (N Node pairs → cap + LRU); port exhaustion (auto-alloc + registry); sqlite is per-dir so no lock contention; ensure idempotent spawn (one instance per namespace).

## Impacted Files

| File | Action | Purpose |
|------|--------|---------|
| `gateway/orchestrator/index.ts` | Create | Spawn/teardown per-user tools-dev instances |
| `gateway/orchestrator/spawn.ts` | Create | Launch + capture ports + readiness wait |
| `gateway/orchestrator/lifecycle.ts` | Create | Idle teardown, LRU cap, parent-death cleanup |
| `gateway/router/registry.ts` | Modify | Orchestrator writes instance records here |
| `.maestru/docs/50-running-in-maestru/05-multi-user.md` | Modify | Document the lifecycle model |
