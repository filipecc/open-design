---
maestru: "0.4"
type: doc
id: 02-fork-and-upstream-sync
title: "Fork & Upstream Sync"
description: "The git remote topology (origin = our fork, upstream = nexu-io) and how Open Design improvements are pulled into the fork"
tags: [running, fork, upstream, git, remotes, sync]
created: 2026-06-22
updated: 2026-06-22
---

# Fork & Upstream Sync

<!-- maestru:summary -->
This repo (/app) is a fork of Open Design set up to both customize and track upstream. Remotes: origin = https://github.com/filipecc/open-design.git (our fork; main tracks it, customizations push here) and upstream = https://github.com/nexu-io/open-design.git (the canonical project, source of improvements). It was created by repointing the original empty Maestru scaffold's git: add upstream, git reset --hard upstream/main, then re-layer Maestru on top as the first custom commit. Pulling improvements is plain git: git fetch upstream && git merge upstream/main (prefer merge over rebase on main, since rebase rewrites SHAs and breaks anyone else's clone of the fork). Conflict cost is a function of how much of upstream's own files we edit in place — everything so far is additive (new files only), so merges stay clean. The deep methodology for diverging without merge hell lives in the 80-methodology section; this doc is the operational remote/sync reference.
<!-- /maestru:summary -->

## Remotes

| Remote | URL | Role |
|--------|-----|------|
| `origin` | `https://github.com/filipecc/open-design.git` | Our fork — `main` tracks it; customizations push here |
| `upstream` | `https://github.com/nexu-io/open-design.git` | Canonical Open Design — source of improvements |

This was set up by repointing the original (near-empty) Maestru scaffold's git at Open Design: `git remote add upstream …`, `git fetch upstream`, `git reset --hard upstream/main`, then re-layering Maestru as the first custom commit.

## Pulling upstream improvements

```bash
git fetch upstream
git merge upstream/main          # 3-way merge; auto-merges non-overlapping changes
git push origin main
```

- **Prefer `merge` over `rebase` on `main`.** Rebase rewrites your commit SHAs, which corrupts anyone else's clone of the fork. Rebase is fine on private feature branches.
- **Merge frequently.** Small upstream deltas = small conflicts.

## Why conflicts are rare (so far)

A conflict only happens where **both** sides edited the same lines of the same file (or both added a file at the same path). Everything we've added is **additive** — new files (`.maestru/`, `scripts/dev-web.sh`) and runtime env, with **zero edits to upstream's own source**. That keeps merges clean.

The full discipline for *staying* mergeable as we diverge — extension seams, customization markers, `.gitattributes`, the merge runbook — is in [../80-methodology/00-overview.md](../80-methodology/00-overview.md). This doc is just the remote/sync reference.

## Fork host note

The fork currently lives under the personal account `filipecc`. To move it to an org (e.g. `oktogon`), re-fork with `gh repo fork nexu-io/open-design --org <org>` and re-point `origin`.
