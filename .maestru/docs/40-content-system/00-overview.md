---
maestru: "0.4"
type: doc
id: 00-overview
title: "Content System — Overview"
description: "Skills, design systems, design templates, plugins, craft, and atoms — the droppable building blocks Open Design composes to produce artifacts"
tags: [content, skills, design-systems, design-templates, plugins, craft, atoms, overview]
created: 2026-06-22
updated: 2026-06-22
---

# Content System — Overview

<!-- maestru:summary -->
Open Design's content system is the set of droppable building blocks the agent composes into artifacts. Six related concepts: Skills (skills/, ~156) are functional capabilities the agent invokes mid-task. Design systems (design-systems/, ~151) are per-brand DESIGN.md + token packages encoding visual language, validated by design-systems/_schema. Design templates (design-templates/, ~109) are the rendering catalogue — packaged shapes (deck/prototype/image/video/audio) with a baked example.html, mirroring the skills API shape. Plugins (plugins/) are the unit of distribution: _official/ (bundled, ~457 across atoms/design-systems/scenarios/examples/image-/video-templates) + community/, each with an open-design.json manifest declaring kind, taskKind, preview, useCase query, context chips, pipeline of atoms, GenUI surfaces, connectors, and capabilities; applied via POST /api/plugins/:id/apply. Craft (craft/, ~13) are brand-agnostic universal design rules a skill opts into via od.craft.requires. Atoms (docs/atoms.md) are named daemon capabilities plugins compose into pipeline stages. The unifying model is "drop a folder in, the picker finds it": local registries are lazily scanned with no rebuild; trust is tiered (bundled/official trusted, community restricted). This makes the content system the primary additive surface for customizing Open Design.
<!-- /maestru:summary -->

The content system is the set of **droppable building blocks** the agent composes into artifacts. It is also the **primary additive surface** for customizing Open Design without editing core code.

## In this section

| Doc | Purpose |
|-----|---------|
| [01-skills.md](./01-skills.md) | Functional skills the agent invokes |
| [02-design-systems.md](./02-design-systems.md) | Per-brand `DESIGN.md` + token packages |
| [03-design-templates.md](./03-design-templates.md) | The rendering catalogue (deck/prototype/image/video/audio) |
| [04-plugins.md](./04-plugins.md) | The unit of distribution + craft + atoms |

## The six concepts

| Concept | Path | Count | What |
|---------|------|-------|------|
| **Skills** | `skills/` | ~156 | Functional capabilities invoked mid-task |
| **Design systems** | `design-systems/` | ~151 | Per-brand `DESIGN.md` + tokens |
| **Design templates** | `design-templates/` | ~109 | Rendering shapes with baked `example.html` |
| **Plugins** | `plugins/` | ~457 official + community | The distribution unit (manifest + pipeline) |
| **Craft** | `craft/` | ~13 | Brand-agnostic universal design rules |
| **Atoms** | `docs/atoms.md` | ~15 | Named daemon capabilities plugins compose |

## The drop-in model

> "Drop a folder in, the picker finds it."

Local registries (`skills/`, `design-systems/`, `design-templates/`) are **lazily scanned** — new folders appear on the next `/api/*` request, no rebuild. Trust is tiered: bundled `plugins/_official/` and official-marketplace items are **trusted**; community/third-party are **restricted** until granted capabilities. Each plugin declares the capabilities it needs (`prompt:inject`, `fs:read`, `mcp`, `connector:<id>`…).

Authoritative guides: `skills/AGENTS.md`, `design-systems/_schema/AGENTS.md`, `design-templates/AGENTS.md`, `plugins/AGENTS.md`, `docs/design-systems.md`, `docs/atoms.md`, `docs/plugins-spec.md`, `craft/README.md`.
