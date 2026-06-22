---
maestru: "0.4"
type: doc
id: 04-doc-conventions
title: "Documentation Conventions"
description: "The taxonomy, frontmatter, summary blocks, and authoring rules for this Maestru body of knowledge — modeled on maestru-core"
tags: [methodology, documentation, conventions, taxonomy, maestru, summary]
created: 2026-06-22
updated: 2026-06-22
---

# Documentation Conventions

<!-- maestru:summary -->
The rules for authoring this corpus, modeled on maestrumd/maestru-core. Structure: numbered sections under .maestru/docs/ in bands that leave room to insert (00 index, 01-product, 02-architecture, 03-environment-variables, 10/20/30/40 subsystems, 50-running-in-maestru, 80-methodology, 85-audits); each section opens with a 00-overview.md (or 00-readme.md) and sub-areas nest. Every doc carries Maestru doc frontmatter (type: doc, id matching the filename stem and path-scoped not global, title, description [required], tags, created, updated [required]) and a <!-- maestru:summary -->…<!-- /maestru:summary --> block immediately under the H1 — a single dense paragraph that powers maestru search/recall and is the most important convention. Cross-link with relative paths; the factual layers (02-40) describe Open Design as-is and stay mergeable with upstream knowledge while the opinion layers (01/50/80) are Oktogon-specific. Distill the in-repo AGENTS.md and code rather than duplicating them; when a doc and the code disagree, the code wins — fix the doc and bump updated. Validate with maestru check (broken links and missing frontmatter are errors). Write a doc when a concept spans multiple files or required real investigation; bump updated on every material change; record dated point-in-time analyses under 85-audits.
<!-- /maestru:summary -->

Modeled on `maestrumd/maestru-core`. These are the rules for this corpus.

## Structure

- **Numbered sections** under `.maestru/docs/`, in bands that leave room to insert: `00` index, `01-product`, `02-architecture`, `03-environment-variables`, `10/20/30/40` subsystems, `50-running-in-maestru`, `80-methodology`, `85-audits`.
- Each section opens with **`00-overview.md`** (or `00-readme.md`); sub-areas nest in subfolders.

## Per-doc requirements

Frontmatter (Maestru `doc` type):
```yaml
type: doc
id: <filename-stem>      # path-scoped, NOT globally unique (00-overview repeats per section)
title: "..."
description: "..."       # required
tags: [...]
created: YYYY-MM-DD
updated: YYYY-MM-DD       # required — bump on every material change
```

A **`<!-- maestru:summary -->` … `<!-- /maestru:summary -->`** block immediately under the H1: one dense paragraph that powers `maestru search`/recall. **This is the most important convention** — it's what makes the corpus queryable, not just readable.

## Layering

- **Factual layers (`02`–`40`)** describe Open Design as-is → stay mergeable with upstream knowledge.
- **Opinion layers (`01`, `50`, `80`)** are Oktogon-specific.

## Authoring rules

- **Distill, don't duplicate** the in-repo `AGENTS.md` / code. When a doc and the code disagree, **the code wins** — fix the doc, bump `updated`.
- Cross-link with **relative paths**.
- **Validate** with `maestru check` (broken links, missing frontmatter, and orphan specs are errors).
- **When to write a doc:** a concept spans multiple files, or it took real investigation to understand. Record dated point-in-time analyses under `85-audits`.
- Manage doc work via the [work-loop](./05-work-loop.md) under `track-bok`.
