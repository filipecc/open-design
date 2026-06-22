---
maestru: "0.4"
type: doc
id: 01-data-model
title: "Data Model & Storage"
description: "How the daemon resolves its data directory (RUNTIME_DATA_DIR / OD_DATA_DIR), the SQLite database, and where projects and artifacts live"
tags: [architecture, data, sqlite, storage, data-dir, artifacts]
created: 2026-06-22
updated: 2026-06-22
---

# Data Model & Storage

<!-- maestru:summary -->
All daemon-owned state lives under a single resolved root, RUNTIME_DATA_DIR, derived from the OD_DATA_DIR env var on startup in apps/daemon/src/server.ts. When OD_DATA_DIR is unset (the tools-dev / OSS path), it defaults to `<projectRoot>/.od` — in this repo that is `/app/.od`, which holds `app.sqlite` plus projects and artifacts. The resolver (apps/daemon/src/daemon-paths.ts → resolveDataDir) creates the dir, checks writability, and throws an actionable error if it is owned by another user or non-writable. Derived constants like PROJECTS_DIR and ARTIFACTS_DIR must come from RUNTIME_DATA_DIR — the AGENTS.md "Daemon data directory contract" is the single source of truth and forbids improvising path conventions elsewhere. SQLite (better-sqlite3) is the system of record for app/project/plugin state and connector credentials; generated files (HTML/PPT/images/video) are written under the data root, not committed to git. There is no server-side user/session store for local use; "who you are" is not modeled — see the security and onboarding docs.
<!-- /maestru:summary -->

## One root: `RUNTIME_DATA_DIR`

On startup, `apps/daemon/src/server.ts` resolves `OD_DATA_DIR` into **`RUNTIME_DATA_DIR`**. Every daemon-owned path derives from it. The contract is documented authoritatively in the top-level **`AGENTS.md` → "Daemon data directory contract"**, which forbids restating or improvising path rules elsewhere — link there, don't copy.

- **Default (dev / OSS / `tools-dev`)**: `OD_DATA_DIR` unset → `<projectRoot>/.od`. In this repo: **`/app/.od`**.
- **Hosted / Docker**: set `OD_DATA_DIR` to a persistent mount.

Resolution lives in `apps/daemon/src/daemon-paths.ts` (`resolveDataDir`): it `mkdir -p`s the path, verifies write access, and on failure throws a message naming the current user and suggesting an ownership fix (a common footgun when a dir was created with `sudo`).

```
RUNTIME_DATA_DIR  (= OD_DATA_DIR or <root>/.od)
├── app.sqlite          ← system of record (better-sqlite3)
├── PROJECTS_DIR        ← managed-project root (imported folders are projects too)
├── ARTIFACTS_DIR       ← generated HTML/PPT/image/video output
└── … plugin state, connector credentials, agent runtime homes, sandbox logs
```

## SQLite is the system of record

`app.sqlite` holds app/project/plugin state and **connector credentials**. `better-sqlite3` is in `onlyBuiltDependencies` (native build). `dataDirIsEmptyOrFresh()` treats the absence of `app.sqlite` as a fresh data dir (used by the legacy data migrator).

## What is NOT modeled

There is **no user or session table** for local use. Open Design does not have accounts, passwords, or multi-tenancy in the local daemon — "authentication" in the UI is really onboarding state stored in the browser and synced to the daemon config. See [../10-web/03-state-and-config.md](../10-web/03-state-and-config.md) and [03-security-and-origin-model.md](./03-security-and-origin-model.md).

## Don't commit data

Local runtime data, `.od/`, `.tmp/`, artifacts, and agent scratch dirs are git-ignored. When documenting or changing any data path, read the `AGENTS.md` contract first.
