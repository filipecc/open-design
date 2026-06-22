---
maestru: "0.4"
type: doc
id: 02-customization-discipline
title: "Customization Discipline"
description: "How to make unavoidable core edits survivable: markers, a CUSTOMIZATIONS.md log, and .gitattributes merge strategies"
tags: [methodology, customization, markers, gitattributes, discipline]
created: 2026-06-22
updated: 2026-06-22
---

# Customization Discipline

<!-- maestru:summary -->
When an in-place edit of an upstream file is unavoidable, three habits keep it survivable across merges. (1) Markers: wrap every custom edit in a searchable comment (e.g. // OKTOGON-CUSTOM: <why>) so a noisy merge can't silently drop it and so grep can enumerate the fork's footprint at any time. (2) A CUSTOMIZATIONS.md log at repo root: one row per core-file change (file, why, marker, upstream-risk), so after a conflict-heavy merge you can verify each change is still present and intact. (3) .gitattributes merge strategies: for files you always want to keep your version of, set `path merge=ours`; for generated/lock files, an appropriate strategy avoids noise. Keep edits minimal and localized — a one-line hook is easier to re-apply than a refactor. Branch experiments under the Maestru convention ({item-id}-{short-name}) and merge to main only when stable, so main stays mergeable with upstream. When divergence becomes extreme, shift from wholesale git merge upstream/main to cherry-picking specific upstream improvements. The goal is always to keep the fork's edit footprint small, visible, and documented.
<!-- /maestru:summary -->

For the edits you *can't* route through a seam ([01-evolution-principles.md](./01-evolution-principles.md)), keep them survivable.

## 1. Mark every custom edit

Wrap in-place edits in a searchable marker:

```ts
// OKTOGON-CUSTOM: gate /api behind session check — see CUSTOMIZATIONS.md#auth
```

Benefits: a noisy merge can't silently drop it, and `grep -rn 'OKTOGON-CUSTOM'` enumerates the fork's entire core-edit footprint at any time.

## 2. Keep a `CUSTOMIZATIONS.md` log

One row per core-file change at repo root:

| File | Why | Marker | Upstream risk |
|------|-----|--------|---------------|
| `apps/web/sidecar/server.ts` | session gate before proxy | `OKTOGON-CUSTOM:auth` | medium (hot file) |

After a conflict-heavy merge, walk this list to verify each change is still present and intact.

## 3. `.gitattributes` merge strategies

For files you always want **your** version of:

```gitattributes
path/to/our-file    merge=ours
```

Use appropriate strategies for generated/lock files to cut merge noise.

## 4. Branch experiments

Per the Maestru convention, do feature work on `{item-id}-{short-name}` branches and merge to `main` only when stable — keeps `main` mergeable with upstream ([05-work-loop.md](./05-work-loop.md)).

## 5. Extreme divergence → cherry-pick

When the fork has diverged so far that wholesale `git merge upstream/main` is more churn than value, switch to **cherry-picking** specific upstream improvements (`git cherry-pick <sha>`). That's the natural end state of a fork that has become its own product — see [03-upstream-merge-runbook.md](./03-upstream-merge-runbook.md).

> Goal: keep the fork's edit footprint **small, visible, and documented.**
