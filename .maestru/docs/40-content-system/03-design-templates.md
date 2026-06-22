---
maestru: "0.4"
type: doc
id: 03-design-templates
title: "Design Templates"
description: "The rendering catalogue — packaged shapes (deck/prototype/image/video/audio) with baked example.html, mirroring the skills API"
tags: [content, design-templates, rendering, deck, prototype, example-html]
created: 2026-06-22
updated: 2026-06-22
---

# Design Templates

<!-- maestru:summary -->
Design templates (design-templates/, ~109) are the rendering catalogue — packaged "shapes" the agent renders into project artifacts, as opposed to skills which are functional capabilities. Each entry is a folder with a SKILL.md (same shape as a functional skill but with an explicit od.mode of prototype/deck/template/image/video/audio), a required baked example.html for gallery preview, optional examples/<key>.html for derived <parent>:<key> cards, and side files. They are listed under /api/design-templates (mirroring the /api/skills shape) and surfaced in the EntryView Templates tab and the new-project panel. Asset/example routes span both registries so URLs stay stable after the skills/templates split. Deck-mode templates must ship self-contained navigation (keyboard ArrowRight/Left/PageDown/Up/Space/Home/End, wheel/trackpad threshold, 50px+ touch swipe, dot indicators with aria-current, .slide.active state, iframe focus on load). Discovery is the same lazy drop-in model as skills. Together with skills, design systems, and craft, templates are composed by plugins into the generation pipeline.
<!-- /maestru:summary -->

A **design template** is a packaged *shape* the agent renders into an artifact — the rendering catalogue. (Functional capabilities are [skills](./01-skills.md).) Authoritative: `design-templates/AGENTS.md`. ~109 ship.

## Shape

```
design-templates/<id>/
  SKILL.md          # frontmatter incl. od.mode: prototype | deck | template | image | video | audio
  example.html      # REQUIRED — gallery preview
  examples/<key>.html   # optional — derived <parent>:<key> cards
  assets/, references/  # optional
```

## Surfaces & discovery

- Listed under `/api/design-templates` (mirrors the `/api/skills` shape).
- Surfaced in the **EntryView Templates tab** and the new-project panel.
- Asset/example routes span both registries, so URLs stay stable after the skills/templates split.
- Same lazy **drop-in** discovery as skills.

## Deck contract

Templates with `od.mode: deck` must ship **self-contained navigation**: keyboard (`ArrowRight/Left`, `PageDown/Up`, `Space`, `Home/End`), wheel/trackpad threshold, 50px+ touch swipe, dot indicators (`aria-current="true"`), a `.slide.active` state, and iframe focus on load.

## Composition

Templates are composed alongside skills, design systems, and craft by **plugins** into the generation pipeline — see [04-plugins.md](./04-plugins.md).
