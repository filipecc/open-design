---
maestru: "0.4"
type: doc
id: 03-upstream-merge-runbook
title: "Upstream Merge Runbook"
description: "Step-by-step procedure to pull Open Design improvements into the fork, resolve conflicts, and verify nothing broke"
tags: [methodology, upstream, merge, runbook, conflicts, git]
created: 2026-06-22
updated: 2026-06-22
---

# Upstream Merge Runbook

<!-- maestru:summary -->
The repeatable procedure for absorbing upstream Open Design changes. Preconditions: clean working tree, on main, remotes origin=filipecc/open-design and upstream=nexu-io/open-design. Steps: git fetch upstream; review what changed (git log --oneline main..upstream/main, git diff --stat); git merge upstream/main (prefer merge over rebase on a shared fork — rebase rewrites SHAs and breaks others' clones). If conflicts: they only occur where both sides touched the same lines or added the same path; resolve using the CUSTOMIZATIONS.md log and OKTOGON-CUSTOM markers to confirm each custom edit survives; for files marked merge=ours in .gitattributes git keeps our side automatically. After resolving: reinstall if lockfile changed (corepack pnpm install), run maestru check for the .maestru layer, boot the app via scripts/dev-web.sh and smoke-test, optionally run the mocks golden suite to verify agent/parser behavior. Then git push origin main. Cadence: merge frequently (small deltas conflict less). When divergence is extreme, cherry-pick specific commits instead of merging wholesale. Always verify, never assume a clean auto-merge is correct — run the app.
<!-- /maestru:summary -->

## Preconditions

- Clean working tree, on `main`.
- Remotes: `origin` = `filipecc/open-design`, `upstream` = `nexu-io/open-design` ([../50-running-in-maestru/02-fork-and-upstream-sync.md](../50-running-in-maestru/02-fork-and-upstream-sync.md)).

## Steps

```bash
# 1. Fetch
git fetch upstream

# 2. Review what's coming
git log --oneline main..upstream/main
git diff --stat main..upstream/main

# 3. Merge (NOT rebase on a shared fork)
git merge upstream/main
```

### If conflicts

Conflicts only occur where both sides touched the same lines or added the same path.
- Use `CUSTOMIZATIONS.md` and `grep -rn 'OKTOGON-CUSTOM'` to confirm **every** custom edit survives the merge ([02-customization-discipline.md](./02-customization-discipline.md)).
- Files marked `merge=ours` in `.gitattributes` keep our side automatically.
- Resolve, `git add`, `git commit`.

## Verify (never assume a clean auto-merge is correct)

```bash
corepack enable && pnpm install        # if pnpm-lock.yaml changed
maestru check                          # the .maestru layer still valid
scripts/dev-web.sh                     # boot + smoke-test the app
pnpm --filter @open-design/daemon test mocks-golden   # agent/parser regression (optional)
```

Then:

```bash
git push origin main
```

## Cadence & escalation

- **Merge frequently** — small deltas conflict less.
- **Extreme divergence** → switch from wholesale merge to `git cherry-pick <sha>` of the specific improvements you want.

> Prefer `merge` over `rebase` on `main`: rebase rewrites commit SHAs and corrupts anyone else's clone of the fork. Rebase only on private feature branches.
