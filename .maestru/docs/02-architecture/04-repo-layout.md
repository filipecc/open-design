---
maestru: "0.4"
type: doc
id: 04-repo-layout
title: "Repository Layout"
description: "Folder-by-folder map of the Open Design monorepo and the in-repo AGENTS.md guides that are the authoritative source for each subsystem"
tags: [architecture, repo, layout, monorepo, agents-md, structure]
created: 2026-06-22
updated: 2026-06-22
---

# Repository Layout

<!-- maestru:summary -->
Map of the Open Design pnpm monorepo. Workspaces are packages/*, apps/*, tools/*, e2e (pnpm-workspace.yaml). apps/ holds web (Next.js UI + sidecar), daemon (privileged local process + od bin), desktop/packaged (Electron), landing-page. packages/ holds shared libs (contracts, sidecar, diagnostics, metatool, components). The content system is skills/ (functional skills the agent invokes), design-systems/ (brand DESIGN.md files), design-templates/ (deck/prototype/image/video rendering assets), plugins/ (official + community). tools/ has dev/pack/serve control planes. mocks/ provides replay-based mock agent CLIs for tests. Crucially, ~17 in-repo AGENTS.md files are the authoritative, always-current source for each subsystem (apps/daemon/AGENTS.md, apps/web/src/components/Theater/AGENTS.md, plugins/AGENTS.md, skills/AGENTS.md, etc.) plus the top-level AGENTS.md which owns the daemon data directory contract. These BOK docs distill and index those guides; when the two disagree, the in-repo AGENTS.md and the code win.
<!-- /maestru:summary -->

The monorepo workspaces are declared in `pnpm-workspace.yaml`: `packages/*`, `apps/*`, `tools/*`, `e2e`.

## Top-level map

| Path | Role | Authoritative guide |
|------|------|---------------------|
| `apps/web` | Next.js 16 UI + sidecar proxy | `apps/web/src/components/Theater/AGENTS.md`, [../10-web/00-overview.md](../10-web/00-overview.md) |
| `apps/daemon` | Local daemon, `/api/*`, `od` bin | `apps/daemon/AGENTS.md`, [../20-daemon/00-overview.md](../20-daemon/00-overview.md) |
| `apps/desktop`, `apps/packaged` | Electron shell + packaged runtime | `apps/packaged/AGENTS.md` |
| `apps/landing-page` | Marketing site | `apps/landing-page/AGENTS.md` |
| `packages/` | Shared libs: contracts, sidecar, diagnostics, metatool, components | `packages/AGENTS.md` |
| `skills/` | Functional skills the agent invokes mid-task | `skills/AGENTS.md` |
| `design-systems/` | Brand `DESIGN.md` files | `design-systems/_schema/AGENTS.md` |
| `design-templates/` | Deck/prototype/image/video rendering assets | `design-templates/AGENTS.md` |
| `plugins/` | Official + community plugins | `plugins/AGENTS.md` |
| `tools/dev`, `tools/pack`, `tools/serve` | Dev / packaged-build / fixture-serve control planes | `tools/AGENTS.md`, `tools/pack/AGENTS.md`, `tools/serve/AGENTS.md` |
| `mocks/` | Replay-based mock agent CLIs for tests | `mocks/README.md` |
| `e2e/` | End-to-end + Playwright UI tests | `e2e/AGENTS.md` |
| `docs/` | Open Design's own (upstream) docs | — |

## AGENTS.md is authoritative

Open Design ships ~17 `AGENTS.md` files (run `find . -name AGENTS.md -not -path './node_modules/*'`). They are maintained alongside the code and are the **source of truth** for their subsystem. The top-level `AGENTS.md` additionally owns the **daemon data directory contract** (see [01-data-model.md](./01-data-model.md)).

> These Body-of-Knowledge docs **distill and index** the `AGENTS.md` set into a queryable Maestru corpus — they do not replace it. When a BOK doc and the in-repo `AGENTS.md`/code disagree, the code wins; fix the BOK doc and bump its `updated` date.

## Maestru layer (ours)

On top of the upstream tree, this fork adds `.maestru/` (specs, docs, templates, tracks), `maestru.yaml`, `CLAUDE.md` (imports both `@AGENTS.md` and `@CLAUDE.maestru.md`), and `scripts/dev-web.sh`. See [../50-running-in-maestru/03-maestru-layer.md](../50-running-in-maestru/03-maestru-layer.md).
