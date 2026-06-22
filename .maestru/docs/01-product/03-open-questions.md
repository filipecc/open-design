---
maestru: "0.4"
type: doc
id: 03-open-questions
title: "Open Questions"
description: "Decisions resolved and pending for the Oktogon Design Partner — auth, hosting, multi-user, divergence scope, fork host"
tags: [product, open-questions, decisions, auth, hosting]
created: 2026-06-22
updated: 2026-06-22
---

# Open Questions

<!-- maestru:summary -->
Running list of decisions for the Oktogon Design Partner, resolved and pending, as of 2026-06-22. Resolved: fork model (origin=filipecc/open-design, upstream=nexu-io; merge not rebase), Maestru layered additively, hosted run via tools-dev behind maestru.dev proxy with the three OD_* env vars baked into dev-web.sh, and divergence discipline (additive seams) as the governing methodology. Pending and material: (1) Front-door auth — the public web app has no access control; who can reach the instance and how (session gate in the sidecar vs. an external authenticating proxy vs. OD_API_TOKEN with non-loopback bind) is the top open item. (2) Hosting/multi-user model — single shared instance vs. per-user/per-client instances vs. true multi-tenancy (which the local daemon does not model). (3) Fork host — keep under personal filipecc or move to an oktogon org. (4) Divergence scope — how opinionated to get before cherry-pick replaces wholesale merge. (5) Deployment target — stay on dev-mode tools-dev or promote to the Docker path with a real token and persistent OD_DATA_DIR. Each pending item should graduate into a work-item/spec when picked up; move resolved items to a decisions log and bump updated.
<!-- /maestru:summary -->

> Snapshot as of **2026-06-22**. Move resolved items to a decisions log as they land; graduate pending items into work-items/specs when picked up.

## Resolved

| Decision | Choice | Reference |
|----------|--------|-----------|
| Fork model | `origin`=filipecc/open-design, `upstream`=nexu-io; **merge not rebase** | [../50-running-in-maestru/02-fork-and-upstream-sync.md](../50-running-in-maestru/02-fork-and-upstream-sync.md) |
| Maestru integration | Layered **additively** (new files only) | [../50-running-in-maestru/03-maestru-layer.md](../50-running-in-maestru/03-maestru-layer.md) |
| Hosted run | `tools-dev` behind `maestru.dev` proxy; 3 env vars in `dev-web.sh` | [../50-running-in-maestru/01-proxied-dev-environment.md](../50-running-in-maestru/01-proxied-dev-environment.md) |
| Governing methodology | Additive seams / divergence discipline | [../80-methodology/01-evolution-principles.md](../80-methodology/01-evolution-principles.md) |

## Pending (material)

1. **Front-door auth (top item).** The public web app has **no access control** ([../02-architecture/03-security-and-origin-model.md](../02-architecture/03-security-and-origin-model.md)). Options: a session/login gate in the **web sidecar** (preferred additive seam, [../10-web/04-sidecar-proxy.md](../10-web/04-sidecar-proxy.md)), an **external authenticating proxy**, or `OD_API_TOKEN` with a non-loopback daemon bind. Who may reach the instance, and how?
2. **Hosting / multi-user model.** Single shared instance vs. per-user/per-client instances vs. true multi-tenancy (which the local daemon does **not** model — [../02-architecture/01-data-model.md](../02-architecture/01-data-model.md)).
3. **Fork host.** Keep under personal `filipecc` or move to an `oktogon` org.
4. **Divergence scope.** How opinionated before cherry-pick replaces wholesale merge ([../80-methodology/03-upstream-merge-runbook.md](../80-methodology/03-upstream-merge-runbook.md)).
5. **Deployment target.** Stay on dev-mode `tools-dev`, or promote to the Docker path with a real token + persistent `OD_DATA_DIR` ([../50-running-in-maestru/04-deployment-options.md](../50-running-in-maestru/04-deployment-options.md)).
