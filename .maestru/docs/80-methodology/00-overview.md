---
maestru: "0.4"
type: doc
id: 00-overview
title: "Methodology — Overview"
description: "The rules for evolving this fork into the Oktogon Design Partner without inheriting upstream merge pain"
tags: [methodology, rules, evolution, fork, overview]
created: 2026-06-22
updated: 2026-06-22
---

# Methodology — Overview

<!-- maestru:summary -->
This section is the rulebook for evolving the fork into the Oktogon Design Partner while staying mergeable with upstream Open Design. The core thesis: the cost of a fork is a function of how much of upstream's own files you edit in place, because git conflicts only arise where both sides change the same lines (or add the same path). So the discipline is "diverge additively" — push customizations through Open Design's real extension seams (plugins/, skills/, design-systems/, design-templates/, craft/, agent defs, the OD_* env surface, new modules, and the web sidecar for front-door concerns) instead of rewriting core components like EntryShell or origin-validation. The section covers: evolution principles (additive-first, seams over edits), customization discipline (markers, CUSTOMIZATIONS.md, .gitattributes merge strategies), the upstream-merge runbook (fetch/merge/resolve, prefer merge over rebase on main), doc conventions (the maestru-core taxonomy, summary blocks, when to write a doc and bump updated), and the Maestru work-loop (tracks/items/specs/check for managing Open Design work). Everything done in this fork so far — the Maestru layer, dev-web.sh, this corpus — is additive and proves the model.
<!-- /maestru:summary -->

The rulebook for growing the fork into the **Oktogon Design Partner** while staying mergeable with upstream Open Design.

## The core thesis

> A fork's maintenance cost is a function of **how much of upstream's own files you edit in place**. Git conflicts only arise where both sides change the same lines (or add the same path). So: **diverge additively.**

## In this section

| Doc | Purpose |
|-----|---------|
| [01-evolution-principles.md](./01-evolution-principles.md) | Additive-first; extension seams over core edits |
| [02-customization-discipline.md](./02-customization-discipline.md) | Markers, `CUSTOMIZATIONS.md`, `.gitattributes` |
| [03-upstream-merge-runbook.md](./03-upstream-merge-runbook.md) | Step-by-step sync + conflict resolution |
| [04-doc-conventions.md](./04-doc-conventions.md) | This taxonomy, summary blocks, when to write a doc |
| [05-work-loop.md](./05-work-loop.md) | Tracks / items / specs / check for Open Design work |

## The seams (cheapest → most expensive divergence)

| Tier | Surface | Merge cost |
|------|---------|-----------|
| Additive | new files: `plugins/`, `skills/`, `design-systems/`, `design-templates/`, `craft/`, agent `defs/`, `.maestru/`, `scripts/` | ~zero |
| Config | `OD_*` env, manifests, data dirs | ~zero |
| Light edit | small change to a shared core file | moderate, recurring |
| Invasive | rewrite a core component (e.g. `EntryShell`, `origin-validation`) | high, recurring |

Everything done in this fork so far (the [Maestru layer](../50-running-in-maestru/03-maestru-layer.md), `dev-web.sh`, this corpus) is **additive** — the model in practice.
