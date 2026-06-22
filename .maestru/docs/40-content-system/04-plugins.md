---
maestru: "0.4"
type: doc
id: 04-plugins
title: "Plugins, Craft & Atoms"
description: "The plugin distribution unit (open-design.json manifest, apply flow), the craft rule library, and the atom pipeline primitives"
tags: [content, plugins, craft, atoms, manifest, pipeline, apply]
created: 2026-06-22
updated: 2026-06-22
---

# Plugins, Craft & Atoms

<!-- maestru:summary -->
A plugin is Open Design's unit of distribution: one or more skills + optional design-system ref + optional craft rules + Claude-plugin assets + preview + use-case query + a machine-readable open-design.json sidecar, anchored to a portable SKILL.md. Bundled first-party plugins live in plugins/_official/ (~457 across atoms/, design-systems/, scenarios/, examples/, image-templates/, video-templates/ — only this tree is scanned on boot as source_kind=bundled) and user/community plugins in plugins/community/ (installed restricted). The open-design.json manifest (v1 schema docs/schemas/open-design.plugin.v1.json) declares od.kind, od.taskKind (new-generation/code-migration/figma-migration/tune-collab), od.preview, od.useCase.query with {{vars}}, od.context.* chips (skills/designSystem/craft/assets/claudePlugins/mcp/atoms), od.pipeline.stages[].atoms[], od.genui.surfaces[], od.connectors, and od.capabilities gates. Apply is pure-by-default: POST /api/plugins/:id/apply resolves manifest→hydrated query→context items→connector OAuth prompts and returns an ApplyResult; the run/project inherits the plugin's prompt context on send. Craft (craft/, ~13) are brand-agnostic universal design rules a skill/plugin pulls in via od.craft.requires (only listed slugs injected). Atoms (docs/atoms.md, ~15 implemented) are named daemon capabilities (discovery-question-form, direction-picker, todo-write, file-*, research-search, media-*, live-artifact, connector, critique-theater) composed into pipeline stages emitting signals like critique.score. Plugins are the richest additive customization seam.
<!-- /maestru:summary -->

A **plugin** is Open Design's **unit of distribution**: one or more skills + optional design-system ref + optional craft rules + Claude-plugin assets + a preview + a use-case query + a machine-readable `open-design.json` sidecar, anchored to a portable `SKILL.md`. Authoritative: `plugins/AGENTS.md`, `docs/plugins-spec.md`.

## Directory model

| Path | What |
|------|------|
| `plugins/_official/` | Bundled first-party — **only tree scanned on boot** (`source_kind=bundled`); subdirs `atoms/`, `design-systems/`, `scenarios/`, `examples/`, `image-templates/`, `video-templates/` (~457 total) |
| `plugins/community/` | User/community — installed **restricted** by default |
| `plugins/spec/` | Portable spec + authoring kit (not an installed catalog) |

## The `open-design.json` manifest (v1)

Key fields (`docs/schemas/open-design.plugin.v1.json`):
- `od.kind` (skill/scenario/atom/bundle), `od.taskKind` (`new-generation` / `code-migration` / `figma-migration` / `tune-collab`),
- `od.preview` (marketplace card), `od.useCase.query` (template text with `{{vars}}`),
- `od.context.*` (chips: skills, designSystem, craft, assets, claudePlugins, mcp, atoms),
- `od.pipeline.stages[].atoms[]` (ordered pipeline), `od.genui.surfaces[]` (form/choice/confirmation),
- `od.connectors` (Composio deps), `od.capabilities` (gates: `prompt:inject`, `fs:read/write`, `mcp`, `subprocess`, `network`, `connector:<id>`).

## Apply flow (pure by default)

```
POST /api/plugins/:id/apply  (optional projectId)
  → resolve manifest → hydrate useCase.query with inputs
  → resolve context items → derive OAuth prompts for required connectors
  → return ApplyResult { query, contextItems, assets, requiredCapabilities, connectors }
UI shows ContextChipStrip + PluginInputsForm
  → send creates project/run (POST /api/projects | /api/runs) passing pluginId
```

No side effects until run/project creation.

## Craft (`craft/`, ~13)

Brand-agnostic **universal design rules** (typography, color, `anti-ai-slop`, state-coverage, accessibility-baseline, animation-discipline, rtl-and-bidi, form-validation, laws-of-ux…). A skill/plugin opts in via `od.craft.requires: [...]`; the daemon injects **only the listed** slugs into the system prompt. Some are auto-checked (P0/P1 linter via `pnpm lint:craft`), others are guidance. `craft/README.md` is authoritative.

## Atoms (`docs/atoms.md`, ~15)

Named daemon capabilities plugins compose into `od.pipeline.stages[].atoms[]`: `discovery-question-form`, `direction-picker`, `todo-write`, `file-read/write/edit`, `research-search`, `media-image/video/audio`, `live-artifact`, `connector`, `critique-theater` (emits `critique.score`). The daemon resolves each id, injects prompt fragments, gates tool access, and declares GenUI surfaces. Signal vocabulary (v1): `critique.score`, `iterations`, `user.confirmed`, `preview.ok`.

> Plugins are the **richest additive seam** in Open Design — a new plugin folder can add a whole guided workflow without touching core. This is the preferred way to build Oktogon Design Partner features. See [../80-methodology/01-evolution-principles.md](../80-methodology/01-evolution-principles.md).
