---
maestru: "0.4"
type: doc
id: 01-skills
title: "Skills"
description: "Functional skills — folder + SKILL.md capabilities the agent invokes mid-task, lazily discovered and shadowable"
tags: [content, skills, skill-md, capabilities]
created: 2026-06-22
updated: 2026-06-22
---

# Skills

<!-- maestru:summary -->
A skill (skills/, ~156) is a functional capability the agent invokes mid-task to do work on user input — utilities, briefs, packagers, extractors — as opposed to a rendering shape (that's a design template). Each skill is a folder with a SKILL.md whose frontmatter declares name, description, triggers, and od.mode (utility or design-system), plus side files (assets/, references/, scripts). Skills are registered at /api/skills (functional only) and discovered by the daemon's lazy scanner — drop a folder in and it appears on the next request, no rebuild during local dev; a user-imported skill shadows a built-in of the same name. Asset routes (/api/skills/:id/example, /api/skills/:id/assets/*) serve both skills and design templates. The shipped set is a curated lightweight catalogue of stubs (frontmatter + upstream link) seeded idempotently from awesome-agent-skills/awesome-claude-skills, tagged by od.category (image-generation, video-generation, slides, documents, design-systems, figma, animation-motion, 3d-shaders, diagrams, creative-direction, marketing-creative, …) for filtering. Skills can opt into craft rules via od.craft.requires and suggest a brand via od.mode:design-system. Authoring a new skill is a clean additive customization.
<!-- /maestru:summary -->

A **skill** is a functional capability the agent invokes mid-task — utilities, briefs, packagers, extractors. (Rendering *shapes* are [design templates](./03-design-templates.md), a separate registry.) Authoritative: `skills/AGENTS.md`. ~156 ship.

## Shape

```
skills/<id>/
  SKILL.md         # frontmatter: name, description, triggers, od.mode (utility | design-system)
  assets/          # optional
  references/      # optional
  …scripts
```

## Discovery (drop-in)

- Registered at `/api/skills` (functional only).
- The daemon's **lazy scanner** picks up new folders on the next request — no rebuild in local dev.
- A user-imported skill **shadows** a built-in of the same name.
- Asset routes `/api/skills/:id/example` and `/api/skills/:id/assets/*` serve both skills and design templates.

## The shipped catalogue

A curated set of lightweight **stubs** (frontmatter + link to upstream repos), seeded idempotently from `awesome-agent-skills` / `awesome-claude-skills`, tagged by `od.category` (image-generation, video-generation, slides, documents, design-systems, figma, animation-motion, 3d-shaders, diagrams, creative-direction, marketing-creative, …) for filtering.

## Composition

- A skill opts into universal design rules via `od.craft.requires: [...]` ([04-plugins.md](./04-plugins.md) covers craft).
- `od.mode: design-system` suggests a brand ([02-design-systems.md](./02-design-systems.md)).

> Authoring a skill is a clean **additive** customization — a new folder, no core edits. See [../80-methodology/01-evolution-principles.md](../80-methodology/01-evolution-principles.md).
