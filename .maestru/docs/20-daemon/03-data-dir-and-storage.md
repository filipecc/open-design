---
maestru: "0.4"
type: doc
id: 03-data-dir-and-storage
title: "Data Dir & Storage"
description: "RUNTIME_DATA_DIR resolution, the SQLite database (better-sqlite3), derived data dirs, and the legacy data migrator"
tags: [daemon, storage, data-dir, sqlite, runtime-data-dir, migration]
created: 2026-06-22
updated: 2026-06-22
---

# Data Dir & Storage

<!-- maestru:summary -->
On startup server.ts computes RUNTIME_DATA_DIR = resolveDataDir(process.env.OD_DATA_DIR, PROJECT_ROOT) (~line 772). resolveDataDir (daemon-paths.ts ~125-163) returns OD_DATA_DIR resolved against the project root, or defaults to <projectRoot>/.od; it creates the dir, write-tests it, and throws an actionable error on permission problems. Every daemon-owned path derives from RUNTIME_DATA_DIR per the AGENTS.md "Daemon data directory contract": PROJECTS_DIR (managed projects), ARTIFACTS_DIR (renders), CRITIQUE_ARTIFACTS_DIR, USER_SKILLS_DIR, USER_DESIGN_SYSTEMS_DIR, PLUGIN_LOCKFILE_PATH/PLUGIN_REGISTRY_ROOTS, plus connector credential and Composio config stores (FileConnectorCredentialStore/configureComposioConfigStore, ~3399-3402). SQLite is opened at server.ts ~3386 via openDatabase(PROJECT_ROOT,{dataDir:RUNTIME_DATA_DIR}) using better-sqlite3, storing projects/conversations/messages/deployments/routines/templates/preview-comments/agent-sessions at <RUNTIME_DATA_DIR>/app.sqlite (+WAL). The legacy-data-migrator (one-shot, OD_LEGACY_DATA_DIR, called ~796) copies 0.3.x .od payloads into the new root, idempotent via a .migrated-from marker. Runtime data stays out of git.
<!-- /maestru:summary -->

## Resolution

`server.ts` (~line 772): `RUNTIME_DATA_DIR = resolveDataDir(process.env.OD_DATA_DIR, PROJECT_ROOT)`.

`daemon-paths.ts` `resolveDataDir()` (~125–163):
- `OD_DATA_DIR` set → resolved against the project root;
- unset → default **`<projectRoot>/.od`** (here `/app/.od`);
- creates the dir, write-tests it, throws an actionable error (names the user, suggests an ownership fix) on permission failure.

## Derived paths (the contract)

Per the top-level `AGENTS.md` **"Daemon data directory contract"**, every daemon path derives from `RUNTIME_DATA_DIR`:

| Constant | Holds |
|----------|-------|
| `PROJECTS_DIR` | Managed projects (imported folders are projects too) |
| `ARTIFACTS_DIR` | Generated design/render outputs |
| `CRITIQUE_ARTIFACTS_DIR` | Critique system outputs |
| `USER_SKILLS_DIR`, `USER_DESIGN_SYSTEMS_DIR` | User content |
| `PLUGIN_LOCKFILE_PATH`, `PLUGIN_REGISTRY_ROOTS` | Plugin manifest/registries |
| (connector credential store, Composio config store) | `FileConnectorCredentialStore` / `configureComposioConfigStore` (~3399–3402) |

> Don't improvise path conventions elsewhere — link to the `AGENTS.md` contract.

## SQLite

Opened at `server.ts` ~3386: `openDatabase(PROJECT_ROOT, { dataDir: RUNTIME_DATA_DIR })` (better-sqlite3). Stores projects, conversations, messages, deployments, routines, templates, preview comments, agent sessions at `<RUNTIME_DATA_DIR>/app.sqlite` (+ WAL).

## Legacy migration

`legacy-data-migrator.ts` — one-shot copy of 0.3.x `.od/` payloads into the new root, triggered by `OD_LEGACY_DATA_DIR`, called at `server.ts` ~796. Idempotent: refuses if the new root already has a payload or a `.migrated-from` marker.

Runtime data (`.od/`, `.tmp/`, artifacts, scratch) stays out of git. System-level view: [../02-architecture/01-data-model.md](../02-architecture/01-data-model.md).
