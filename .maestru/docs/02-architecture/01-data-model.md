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
All daemon-owned state lives under a single resolved root, RUNTIME_DATA_DIR, derived from the OD_DATA_DIR env var on startup in apps/daemon/src/server.ts. When OD_DATA_DIR is unset (the tools-dev / OSS path), it defaults to `<projectRoot>/.od` — in this repo that is `/app/.od`, which holds `app.sqlite` plus projects and artifacts. The resolver (apps/daemon/src/daemon-paths.ts → resolveDataDir) creates the dir, checks writability, and throws an actionable error if it is owned by another user or non-writable. Derived constants like PROJECTS_DIR and ARTIFACTS_DIR must come from RUNTIME_DATA_DIR — the AGENTS.md "Daemon data directory contract" is the single source of truth and forbids improvising path conventions elsewhere. The split to remember: files-on-disk hold the CONTENT (each project is a real folder `projects/<uuid>/` containing the generated artifact, e.g. index.html + index.html.artifact.json + a copied .od-skills/), while SQLite (better-sqlite3) holds the CATALOG (project/conversation/message/run records that tie the folders together) plus app/plugin state and connector credentials; per-run agent event logs live in runs/<uuid>/events.jsonl. Generated files (HTML/PPT/images/video) are written under the data root, not committed to git. There is no server-side user/session store for local use; "who you are" is not modeled — see the security and onboarding docs.
<!-- /maestru:summary -->

## One root: `RUNTIME_DATA_DIR`

On startup, `apps/daemon/src/server.ts` resolves `OD_DATA_DIR` into **`RUNTIME_DATA_DIR`**. Every daemon-owned path derives from it. The contract is documented authoritatively in the top-level **`AGENTS.md` → "Daemon data directory contract"**, which forbids restating or improvising path rules elsewhere — link there, don't copy.

- **Default (dev / OSS / `tools-dev`)**: `OD_DATA_DIR` unset → `<projectRoot>/.od`. In this repo: **`/app/.od`**.
- **Hosted / Docker**: set `OD_DATA_DIR` to a persistent mount.

Resolution lives in `apps/daemon/src/daemon-paths.ts` (`resolveDataDir`): it `mkdir -p`s the path, verifies write access, and on failure throws a message naming the current user and suggesting an ownership fix (a common footgun when a dir was created with `sudo`).

```
RUNTIME_DATA_DIR  (= OD_DATA_DIR or <root>/.od; here /app/.od)
├── app.sqlite (+ -wal/-shm)  ← the CATALOG (better-sqlite3)
├── app-config.json           ← persisted daemon prefs (agentId, designSystemId, onboarding…)
├── installation.json         ← installation id
├── projects/<uuid>/          ← the CONTENT: one folder per project (see below)
├── runs/<uuid>/events.jsonl  ← per-run agent event stream
├── artifacts/                ← rendered/exported outputs
├── critique-artifacts/       ← critique outputs
├── connectors/               ← connector credentials (mode 0700)
└── skills/ design-systems/ design-templates/ plugins/   ← user-imported content
```

### A project on disk

Each project is a **real folder of real files** — the generated artifact, not a blob in the DB:

```
projects/8a41f1fe-…/
├── index.html                 ← the actual creation (the deck/page/prototype)
├── index.html.artifact.json   ← its metadata
└── .od-skills/<skill>/         ← the skill copied into the project (SKILL.md, example.html, assets)
```

Exports (PDF/PPTX/ZIP) are rendered from these files.

## Content vs. catalog

> **Files-on-disk hold the content; SQLite holds the catalog.**

`app.sqlite` (better-sqlite3, in `onlyBuiltDependencies`) is the **system of record for the records** — projects, conversations, messages, runs, deployments — plus app/plugin state and **connector credentials**. The *content* of each project lives as files under `projects/<uuid>/`. `dataDirIsEmptyOrFresh()` treats the absence of `app.sqlite` as a fresh data dir (used by the legacy data migrator).

## What is NOT modeled

There is **no user or session table** for local use. Open Design does not have accounts, passwords, or multi-tenancy in the local daemon — "authentication" in the UI is really onboarding state stored in the browser and synced to the daemon config. See [../10-web/03-state-and-config.md](../10-web/03-state-and-config.md) and [03-security-and-origin-model.md](./03-security-and-origin-model.md).

## Don't commit data

Local runtime data, `.od/`, `.tmp/`, artifacts, and agent scratch dirs are git-ignored. When documenting or changing any data path, read the `AGENTS.md` contract first.
