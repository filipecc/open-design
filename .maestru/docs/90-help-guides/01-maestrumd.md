---
maestru: "0.4"
type: doc
id: 01-maestrumd
title: "MaestruMD Framework & CLI"
description: "Guide to the MaestruMD spec-driven development framework and CLI"
created: 2026-06-22
updated: 2026-06-22
tags: [maestru, methodology, cli]
---

# MaestruMD Framework & CLI

<!-- maestru:summary -->
MaestruMD is a spec-driven development methodology for building software with AI. All project knowledge lives in `.maestru/` as markdown with frontmatter — specs, work-items, docs, architecture — and `maestru` is the CLI that queries, validates, and manipulates it.
<!-- /maestru:summary -->

## Why MaestruMD

- **One source of truth.** Everything about the project — what's planned, what's done, how it's architected — lives in `.maestru/` as human-readable markdown. No database to keep in sync, no side system that can drift.
- **AI-friendly by design.** The structure is discoverable by agents via `maestru search` and `maestru sql`; agents don't need to grep the codebase to learn the project.
- **Validation as a gate.** `maestru check` catches broken references, missing fields, and stale summary tables before they cause confusion downstream.

## Commands

| Command | Purpose |
|---------|---------|
| `maestru search <query>` | Natural-language search across all documents |
| `maestru sql "<query>"` | SQL queries, updates, and inserts against the entity index |
| `maestru check` | Validate all `.maestru/` files and rebuild indexes |
| `maestru init` | Scaffold `AGENTS.md` and `CLAUDE.md` for a new project |
| `maestru help [cmd]` | Usage details for any command, plus `maestru help prompt` to re-render the recommended agent content |

### `maestru search` — context discovery

Always start with `maestru search` before exploring code. It indexes docs, specs, tracks, and work-items and returns ranked results. Use `--type` to narrow:

```
maestru search authentication              # search everything
maestru search auth --type doc             # only docs
maestru search login --type work-item      # only work-items
```

Only fall back to grep/glob when `maestru search` does not return what you need.

### `maestru sql` — structured queries and writes

The indexer exposes per-type tables that you can query and mutate directly with SQL. Writes compile into validated markdown edits — they never mutate SQLite as authoritative state.

**Per-type tables:**

- `work_tracks` (id, path, title, description, status, owner, created)
- `work_items` (id, path, title, `track_id`, status, owner, priority, created, completed, branch, pr)
- `work_specs` (id, path, title, `work_item_id`, template, owner, created)
- `docs` (id, path, title, description, tags, owner, created, updated)

**Relationship tables:**

- `work_item_specs` (work_item_id, work_spec_id)
- `work_item_blocks` (blocker_id, blocked_id)
- `refs` (source_id, target_path)
- `templates` (name, type, mode, description)

**SELECT — lookup and filtering:**

```
maestru sql "SELECT id, status FROM work_items WHERE status='in-progress' ORDER BY id"
maestru sql "SELECT status, COUNT(*) as n FROM work_items GROUP BY status"
maestru sql "SELECT name, mode, description FROM templates"
```

**JOIN — across per-type tables via FK columns:**

```
maestru sql "SELECT s.title, i.status FROM work_specs s JOIN work_items i ON s.work_item_id=i.id WHERE i.status='in-progress'"
```

**UPDATE — modify frontmatter, syncs back to markdown:**

```
maestru sql "UPDATE work_items SET status='done' WHERE id='T12'"
maestru sql "UPDATE work_items SET owner='filipe' WHERE status='in-progress' AND owner IS NULL"
```

Auto-sets `completed` on terminal status transitions. Use `--dry-run` to preview.

**INSERT — create documents, template-aware:**

```
maestru sql "INSERT INTO work_items (id, title, track_id, status, priority) VALUES ('T13', 'New feature', 'track-main', 'backlog', 'medium')"
maestru sql "INSERT INTO work_specs (id, title, work_item_id, template, owner) VALUES ('t13-spec', 'T13 Spec', 'T13', 'implementation-plan-v1', 'developer')"
```

**INSERT into join tables — link without editing the parent file:**

```
maestru sql "INSERT INTO work_item_specs (work_item_id, work_spec_id) VALUES ('T13', 't13-spec')"
maestru sql "INSERT INTO work_item_blocks (blocker_id, blocked_id) VALUES ('T12', 'T13')"
```

### `maestru check` — validation gate

Run `maestru check` after modifying any `.maestru/` file. It validates frontmatter, cross-references, and summary tables. A change isn't done until check passes. Common causes of failure:

- Missing required frontmatter fields (`id`, `title`, `created`)
- Invalid status values for the type
- Broken cross-references in `blocked-by` or `specs`
- Stale summary tables (fix automatically with `maestru check --fix`)

## Discovering templates

Don't read template files by hand first. Ask the indexer:

```
maestru sql "SELECT name, mode, description FROM templates"
```

That tells you which templates exist, which type they apply to, whether they're enforced or optional, and what each one is for. Only read the markdown under `.maestru/templates/` when you need the body structure itself (e.g., you're about to author a spec against it).

## Custom types

`.maestru/` ships with a handful of system types (`work-item`, `work-track`, `work-spec`, `doc`). A project can declare **custom types** in `.maestru/schema.yaml` to model domain-specific entities (e.g., `candidate`, `company`, `lesson-plan`) alongside the system types.

A custom type declaration looks like:

```yaml
types:
  candidate:
    storagePath: docs/hr/candidates
    fields:
      email:  { type: string, required: true }
      stage:  { type: enum, values: [sourced, screened, onsite, offer] }
    statuses:
      values:
        - { id: active, category: open }
        - { id: hired,  category: closed }
        - { id: declined, category: closed }
      terminal: [hired, declined]
```

Once declared:

- Files with `type: candidate` frontmatter live under `storagePath` (ancestor-fallback applies — a candidate file can nest under a more-specific custom tree).
- `maestru sql` exposes a per-type table named after the custom type (`candidates` in this example) with the declared fields as columns.
- `maestru check` validates those files the same way it validates system types — missing required fields, invalid status values, type-path-mismatches all surface as errors.

Use custom types when your domain has entities that aren't naturally work-items or docs — they deserve their own schema and their own queryable table.

## `maestru help prompt`

Run `maestru help prompt` to print the recommended `AGENTS.md` / `CLAUDE.md` content, rendered from this project's live `schema.yaml` and `.maestru/templates/`. Diff it against your own agent files and merge anything that's missing. Running `maestru init` writes the same content to a fresh project and creates a `CLAUDE.md → AGENTS.md` symlink.

## Work-item workflow

### Before code

1. `maestru search <topic>` — gather context.
2. `maestru sql "SELECT ... FROM work_items WHERE ..."` — find or verify the work-item.
3. `maestru sql "UPDATE work_items SET status='in-progress' WHERE id='<ID>'"` — claim it.
4. Check whether a spec exists (required if 3+ files are being changed): `maestru sql "SELECT id, title FROM work_specs WHERE work_item_id='<ID>'"`. If not, create one with INSERT.

### While coding

- Treat `.maestru/` markdown as the source of truth.
- Use `maestru search` and `maestru sql` over manual file hunting.
- If implementation reveals a better approach, update the spec before you ship.

### After code

1. Update spec/docs if anything changed.
2. `maestru sql "UPDATE work_items SET status='<done|in-review>' WHERE id='<ID>'"` — whichever status matches this project's transition model (see `AGENTS.md`).
3. `maestru check` — mandatory. Fix any failures before considering the task done.

## Git conventions

- **Branches:** `{item-id}-{short-name}` (e.g. `t12-add-auth`, `t15-fix-login-redirect`).
- **Commits:** small, atomic, reference the work-item ID in the message (e.g. `T12: add JWT middleware`).
- Keep `main` stable — only merge reviewed, working code.
