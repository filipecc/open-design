---
maestru: "0.4"
type: doc
id: 02-design-systems
title: "Design Systems"
description: "Per-brand DESIGN.md + token packages: the 9-section schema, the token tiers, the _schema contract, and how to add a brand"
tags: [content, design-systems, design-md, tokens, brand]
created: 2026-06-22
updated: 2026-06-22
---

# Design Systems

<!-- maestru:summary -->
A design system (design-systems/, ~151) encodes a brand's visual language. The legacy model is a DESIGN.md with a 9-section schema (Visual Theme, Color, Typography, Spacing, Layout, Components, Motion, Voice, Anti-patterns); the modern model adds a manifest.json that unlocks project-shape validation plus tokens.css, optional design-tokens.json, tailwind-v4.css, components.html, assets/, preview/, USAGE.md, and a source/ evidence trail. The contract lives in design-systems/_schema/ (tokens.schema.ts re-exported from packages/contracts/src/design-systems/token-schema.ts, manifest.schema.ts, defaults.css) and is machine-enforced when a manifest is present. Tokens are tiered: A1-identity and A1-structure (brand must define, guard fails if missing — e.g. --bg/--fg/--accent/--font-display, type scale/--container-max), A2 (brand-with-fallback, guard-required today), B-slot (aliasTo a richer tier), C-extensions (brand-specific, allowlist/prefix-gated). Adding a brand: create design-systems/<slug>/, write DESIGN.md with the 9 headings and :root{} blocks of real hex/fonts (dark mode via [data-theme=dark]), optionally add manifest.json, then run pnpm guard. Discovered lazily at /api/design-systems. Authoring brands is a core additive customization for the Oktogon Design Partner.
<!-- /maestru:summary -->

A **design system** encodes one brand's visual language. Authoritative: `docs/design-systems.md`, `design-systems/_schema/AGENTS.md`. ~151 ship.

## Two models

- **Legacy** — a `DESIGN.md` with a **9-section schema**: Visual Theme, Color, Typography, Spacing, Layout, Components, Motion, Voice, Anti-patterns.
- **Modern** — adds a `manifest.json` (unlocks project-shape validation) plus `tokens.css`, optional `design-tokens.json`, `tailwind-v4.css`, `components.html`, `assets/`, `preview/`, `USAGE.md`, and a `source/` evidence trail.

## The schema contract (`design-systems/_schema/`)

- `tokens.schema.ts` — token contract (re-exported from `packages/contracts/src/design-systems/token-schema.ts`),
- `manifest.schema.ts` — project-manifest contract,
- `defaults.css` — fallback values.

Machine-enforced **when a `manifest.json` is present**.

## Token tiers

| Tier | Rule | Examples |
|------|------|----------|
| **A1-identity** | Brand must define; guard fails if missing | `--bg`, `--fg`, `--accent`, `--font-display` |
| **A1-structure** | Brand must define; guard fails if missing | type scale, `--container-max`, `--section-y-*` |
| **A2** | Brand-with-fallback (guard-required today) | `--motion-fast`, `--success`, `--space-4`, `--font-mono` |
| **B-slot** | Brand or schema alias (`aliasTo`) | `--fg-2 → var(--fg)` |
| **C-extensions** | Brand-specific (allowlist / prefix-gated) | custom tokens |

## Adding a brand

1. `design-systems/<slug>/`
2. `DESIGN.md` with the 9 section headings,
3. `:root {}` blocks with **real** hex / font labels (dark mode via `[data-theme="dark"]`),
4. optionally `manifest.json`,
5. `pnpm guard` to validate.

Discovered lazily at `/api/design-systems`. **Authoring brands is a core additive customization** for the Oktogon Design Partner — see [../01-product/01-vision.md](../01-product/01-vision.md).
