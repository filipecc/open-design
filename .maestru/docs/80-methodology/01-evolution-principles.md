---
maestru: "0.4"
type: doc
id: 01-evolution-principles
title: "Evolution Principles"
description: "Additive-first development: prefer Open Design's extension seams over in-place edits to keep the fork mergeable as it diverges"
tags: [methodology, principles, additive, seams, divergence]
created: 2026-06-22
updated: 2026-06-22
---

# Evolution Principles

<!-- maestru:summary -->
Five principles for evolving the fork. (1) Additive-first: prefer new files and Open Design's extension seams (plugins, skills, design-systems, design-templates, craft, agent defs, OD_* env, new modules) over editing upstream's own files; a new-file change has ~zero merge cost forever while an in-place edit of a hot file costs conflict resolution on every upstream merge. (2) Seams over edits, mapped: design output → plugin/skill/template; brand → design-system; new agent → runtimes/defs; behavior toggle → env/config; front-door auth → a gate in the web sidecar in front of the proxy handler, not inside EntryShell or origin-validation. (3) Isolate the unavoidable: when you must edit a core file, make the change minimal, mark it, and log it so a messy merge can't silently drop it. (4) Merge frequently: small upstream deltas conflict less than big ones. (5) Prefer composition and configuration to forking logic. The litmus test before editing any upstream file: "Is there a seam that achieves this without touching their code?" Usually yes. This is why the Maestru layer, dev-web.sh, and even the documented custom-auth options are framed as additive modules.
<!-- /maestru:summary -->

## 1. Additive-first

Prefer **new files** and Open Design's extension seams over editing upstream's own files. A new-file change has ~zero merge cost forever; an in-place edit of a hot file costs conflict resolution on **every** upstream merge.

## 2. Seams over edits

Map the goal to a seam before reaching for a core edit:

| Goal | Additive seam | Avoid editing |
|------|---------------|---------------|
| New design output | a plugin / skill / design-template | the generation core |
| New brand | a `design-systems/<brand>/` | — |
| New agent CLI | a `runtimes/defs/<id>.ts` | the registry's neighbors |
| Behavior toggle | `OD_*` env / config | hardcoded logic |
| **Front-door auth** | a gate in the **web sidecar** before the proxy handler | `EntryShell` / `origin-validation` |

The auth example matters: the [sidecar](../10-web/04-sidecar-proxy.md) is the clean place to add access control; rewriting the onboarding UI ([../10-web/02-onboarding-and-auth-ui.md](../10-web/02-onboarding-and-auth-ui.md)) or the daemon's [origin guard](../20-daemon/02-auth-and-request-guards.md) in place is the expensive path.

## 3. Isolate the unavoidable

When a core edit is genuinely required, make it **minimal**, **mark it**, and **log it** so a messy merge can't silently drop it — see [02-customization-discipline.md](./02-customization-discipline.md).

## 4. Merge frequently

Small upstream deltas conflict less than big ones. Pulling monthly hurts far less than yearly — see [03-upstream-merge-runbook.md](./03-upstream-merge-runbook.md).

## 5. Composition over forking logic

Prefer composing existing primitives (atoms, craft, context chips, MCP) over reimplementing them in a forked code path.

## The litmus test

> Before editing any upstream file: **"Is there a seam that achieves this without touching their code?"** Usually yes.

This is why the [Maestru layer](../50-running-in-maestru/03-maestru-layer.md), `dev-web.sh`, and even the documented custom-auth options are all framed as additive modules.
