---
maestru: "0.4"
type: doc
id: 03-maestru-layer
title: "The Maestru Layer"
description: "How Maestru is layered on top of the upstream Open Design tree without forking its files: .maestru/, maestru.yaml, dual-import CLAUDE.md"
tags: [running, maestru, layer, claude-md, additive]
created: 2026-06-22
updated: 2026-06-22
---

# The Maestru Layer

<!-- maestru:summary -->
Maestru is layered on top of Open Design purely additively, so it never conflicts with upstream merges. The layer consists of: .maestru/ (config.yaml, schema.yaml, theme.yaml, docs/, templates/, tracks/, specs/), maestru.yaml (dev process config), and a CLAUDE.md that imports BOTH guides via `@AGENTS.md` (Open Design's own agent guide) and `@CLAUDE.maestru.md` (the Maestru spec-driven workflow). Open Design ships its own CLAUDE.md as a one-line `@AGENTS.md`; we keep that import and add the Maestru one alongside, so both workflows coexist. .claude/settings.json (with the Bash(maestru *) permission) is git-ignored by Open Design and kept untracked locally. The .maestru build cache (.maestru/.cache) and .pnpm-store are git-ignored. Because the entire layer is new files plus a two-line CLAUDE.md, the conflict surface against upstream is effectively zero — the model the methodology section prescribes for all customization. The Body of Knowledge corpus itself lives under .maestru/docs and is managed by work-track track-bok.
<!-- /maestru:summary -->

Maestru is layered **additively** on the upstream tree — new files plus a two-line `CLAUDE.md`. Nothing in Open Design's own source is modified, so the layer never conflicts on an upstream merge.

## What the layer is

| Path | Purpose |
|------|---------|
| `.maestru/config.yaml` | Maestru config (allowed authors, template rules) |
| `.maestru/schema.yaml`, `theme.yaml` | Entity schema + presentation |
| `.maestru/docs/` | This Body of Knowledge corpus |
| `.maestru/templates/` | Work-spec templates |
| `.maestru/tracks/`, `.maestru/specs/` | Work tracks, items, specs |
| `maestru.yaml` | Dev process config for the Maestru runtime |
| `CLAUDE.md` | Imports **both** `@AGENTS.md` and `@CLAUDE.maestru.md` |
| `CLAUDE.maestru.md` | The Maestru spec-driven workflow guide |
| `scripts/dev-web.sh` | Proxied-env launcher |

## The dual-import `CLAUDE.md`

Open Design ships `CLAUDE.md` as a single line, `@AGENTS.md`. We keep that and add the Maestru guide, so both workflows are in context:

```
@AGENTS.md
@CLAUDE.maestru.md
```

## Git-ignored bits

- `.claude/settings.json` (holds the `Bash(maestru *)` permission) — Open Design git-ignores it; kept untracked locally.
- `.maestru/.cache/` and `.pnpm-store/` — ignored.

## Why this shape

It's the worked example of the [evolution principle](../80-methodology/01-evolution-principles.md): **diverge additively.** A new-files-only layer has ~zero merge cost forever. The same discipline applies to product features — prefer Open Design's extension seams (`plugins/`, `skills/`, `design-systems/`) and new modules over editing core files.
