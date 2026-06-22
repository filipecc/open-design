---
maestru: "0.4"
type: doc
id: 00-index
title: "Open Design — Body of Knowledge"
description: "Navigation hub for the canonical documentation of how Open Design works and the rules for evolving it into the Oktogon Design Partner"
tags: [index, overview, navigation, open-design, oktogon-design-partner]
created: 2026-06-22
updated: 2026-06-22
---

# Open Design — Body of Knowledge

<!-- maestru:summary -->
Navigation hub for the Maestru-managed documentation of this Open Design fork. Open Design (upstream `nexu-io/open-design`) is a local-first, Apache-2.0, BYOK alternative to Claude Design: a two-process app (a Next.js web UI + sidecar proxy talking to a local daemon over loopback) that drives coding-agent CLIs to generate HTML/slides/PDF/image artifacts. This fork (`filipecc/open-design`) layers Maestru on top and is being evolved into the **Oktogon Design Partner**. Docs are organized in numbered bands: 01-product (vision), 02-architecture / 03-environment-variables / 10-web / 20-daemon / 30-agents-and-clis / 40-content-system (how it works today), 50-running-in-maestru (our hosted run environment), 80-methodology (rules to evolve), 85-audits (point-in-time analyses). The factual layers (02–40) describe Open Design as-is and stay mergeable with upstream knowledge; the opinion layers (01, 50, 80) are Oktogon-specific.
<!-- /maestru:summary -->

Documentation for this fork of **Open Design**, evolving into the **Oktogon Design Partner**. This repository uses **Maestru** for spec-driven development — `.maestru/` is the source of truth. Run `maestru search <query>` to find anything here.

## Start Here

1. **[02-architecture/00-overview.md](./02-architecture/00-overview.md)** — The system model (daemon ↔ web sidecar, data flow)
2. **[50-running-in-maestru/01-proxied-dev-environment.md](./50-running-in-maestru/01-proxied-dev-environment.md)** — How to run it here (the env vars that matter)
3. **[80-methodology/01-evolution-principles.md](./80-methodology/01-evolution-principles.md)** — How we evolve the fork without merge hell
4. **[01-product/01-vision.md](./01-product/01-vision.md)** — Why this exists: the Oktogon Design Partner

---

## Product

The "why" and the Oktogon Design Partner framing (our opinion layer).

| Doc | Purpose |
|-----|---------|
| [01-product/00-overview.md](./01-product/00-overview.md) | Product section entry point |
| [01-product/01-vision.md](./01-product/01-vision.md) | Why we forked Open Design; what "Design Partner" means |
| [01-product/02-relationship-to-upstream.md](./01-product/02-relationship-to-upstream.md) | Fork model — what we adopt vs. diverge |
| [01-product/03-open-questions.md](./01-product/03-open-questions.md) | Decisions resolved and pending |

## Architecture

How Open Design works at the system level (factual layer).

| Doc | Purpose |
|-----|---------|
| [02-architecture/00-overview.md](./02-architecture/00-overview.md) | Monorepo map; the daemon ↔ web-sidecar two-process model |
| [02-architecture/01-data-model.md](./02-architecture/01-data-model.md) | SQLite, `RUNTIME_DATA_DIR`, projects & artifacts |
| [02-architecture/02-request-lifecycle.md](./02-architecture/02-request-lifecycle.md) | Browser → proxy → sidecar → daemon; `/api` proxying |
| [02-architecture/03-security-and-origin-model.md](./02-architecture/03-security-and-origin-model.md) | Origin trust, API token, local-only guards |
| [02-architecture/04-repo-layout.md](./02-architecture/04-repo-layout.md) | Folder-by-folder index → subfolder `AGENTS.md` |

## Environment Variables

The `OD_*` surface — learned the hard way running behind a proxy.

| Doc | Purpose |
|-----|---------|
| [03-environment-variables/00-readme.md](./03-environment-variables/00-readme.md) | How env config flows through the two processes |
| [03-environment-variables/01-web-sidecar.md](./03-environment-variables/01-web-sidecar.md) | `OD_HOST`, `OD_ALLOWED_DEV_ORIGINS`, ports |
| [03-environment-variables/02-daemon.md](./03-environment-variables/02-daemon.md) | `OD_API_TOKEN`, `OD_DATA_DIR`, `OD_ALLOWED_ORIGINS`, `OD_DISABLE_API_AUTH` |
| [03-environment-variables/03-agents-and-byok.md](./03-environment-variables/03-agents-and-byok.md) | Agent CLI env and BYOK proxy |

## Subsystems

Deep dives, distilled from the in-repo `AGENTS.md` files plus code reading.

| Section | Purpose |
|---------|---------|
| [10-web/00-overview.md](./10-web/00-overview.md) | `apps/web` — Next.js UI, shell, onboarding, state, sidecar |
| [20-daemon/00-overview.md](./20-daemon/00-overview.md) | `apps/daemon` — `/api`, auth guards, storage, agent spawning |
| [30-agents-and-clis/00-overview.md](./30-agents-and-clis/00-overview.md) | The agent-CLI adapter layer (Claude Code, BYOK, Cloud/AMR, mocks) |
| [40-content-system/00-overview.md](./40-content-system/00-overview.md) | Skills, design systems, design templates, plugins |

## Running in Maestru (Oktogon)

Our hosted, proxied run environment.

| Doc | Purpose |
|-----|---------|
| [50-running-in-maestru/00-overview.md](./50-running-in-maestru/00-overview.md) | Section entry point |
| [50-running-in-maestru/01-proxied-dev-environment.md](./50-running-in-maestru/01-proxied-dev-environment.md) | `maestru.dev` proxy, `dev-web.sh`, the 3 env vars, 502/403 troubleshooting |
| [50-running-in-maestru/02-fork-and-upstream-sync.md](./50-running-in-maestru/02-fork-and-upstream-sync.md) | `origin`/`upstream`, merge strategy, divergence discipline |
| [50-running-in-maestru/03-maestru-layer.md](./50-running-in-maestru/03-maestru-layer.md) | The Maestru layer on top of Open Design |
| [50-running-in-maestru/04-deployment-options.md](./50-running-in-maestru/04-deployment-options.md) | Docker / Sealos / source — and our notes |

## Methodology — Rules to Evolve

How to grow the fork into the Design Partner without inheriting merge pain.

| Doc | Purpose |
|-----|---------|
| [80-methodology/00-overview.md](./80-methodology/00-overview.md) | Section entry point |
| [80-methodology/01-evolution-principles.md](./80-methodology/01-evolution-principles.md) | Additive-first; extension seams over core edits |
| [80-methodology/02-customization-discipline.md](./80-methodology/02-customization-discipline.md) | Markers, `CUSTOMIZATIONS.md`, `.gitattributes` |
| [80-methodology/03-upstream-merge-runbook.md](./80-methodology/03-upstream-merge-runbook.md) | Step-by-step sync + conflict resolution |
| [80-methodology/04-doc-conventions.md](./80-methodology/04-doc-conventions.md) | This taxonomy, summary blocks, when to write a doc |
| [80-methodology/05-work-loop.md](./80-methodology/05-work-loop.md) | Tracks / items / specs for Open Design work |

## Audits

Point-in-time analyses (dated; may go stale).

| Doc | Purpose |
|-----|---------|
| [85-audits/01-auth-and-origin-analysis-2026-06.md](./85-audits/01-auth-and-origin-analysis-2026-06.md) | The auth/origin investigation that seeded this corpus |

---

> Maintained under work-track **track-bok**. Each section maps to a `BOK*` work-item — query with `maestru sql "SELECT id, title, status FROM work_items WHERE track_id='track-bok'"`.
