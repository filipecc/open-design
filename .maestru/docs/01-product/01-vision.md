---
maestru: "0.4"
type: doc
id: 01-vision
title: "Vision — The Oktogon Design Partner"
description: "Why we forked Open Design and what the Oktogon Design Partner is meant to become"
tags: [product, vision, oktogon-design-partner, strategy]
created: 2026-06-22
updated: 2026-06-22
---

# Vision — The Oktogon Design Partner

<!-- maestru:summary -->
The vision: turn Open Design's engine into the Oktogon Design Partner — a hosted, branded, opinionated AI design partner that Oktogon uses internally and offers to clients to go from brief to on-brand artifact (decks, prototypes, pages, images, video) fast, under our control. Why fork rather than use the SaaS: Open Design is local-first, BYOK, and Apache-2.0, so we own the data path, the model choice, the brand systems, and the deployment — no vendor lock-in, generated work stays in our environment, and we can layer Oktogon brand design-systems, curated skills/plugins/pipelines, and our own access model. Near-term shape: (1) run it reliably in the Maestru-hosted environment (done — proxied dev env + dev-web.sh); (2) load Oktogon and client brand design-systems; (3) build guided generation pipelines as plugins for our recurring deliverables; (4) add real front-door auth so the hosted instance is safe to share; (5) decide the hosting/multi-user model. The strategic constraint is divergence discipline: build via Open Design's additive seams so we keep absorbing upstream improvements. Success = a design partner that produces on-brand output at agency speed, fully owned by Oktogon.
<!-- /maestru:summary -->

## What it is

The **Oktogon Design Partner** is Open Design's engine, evolved into a hosted, branded, opinionated AI design partner — something Oktogon uses internally and offers to clients to go from **brief → on-brand artifact** (decks, prototypes, pages, images, video) at agency speed, under our control.

## Why fork, not use the SaaS

Open Design is **local-first, BYOK, and Apache-2.0**, so forking lets us own what matters:
- the **data path** — generated work stays in our environment ([../02-architecture/01-data-model.md](../02-architecture/01-data-model.md)),
- the **model choice** — any CLI, BYOK provider, or cloud ([../30-agents-and-clis/00-overview.md](../30-agents-and-clis/00-overview.md)),
- the **brand systems, skills, and pipelines** — Oktogon and client design systems as first-class content ([../40-content-system/00-overview.md](../40-content-system/00-overview.md)),
- the **deployment and access model** — our infra, our auth.

No vendor lock-in; no forcing client work through someone else's cloud.

## Near-term shape

1. **Run it reliably** in the Maestru-hosted environment — *done* ([../50-running-in-maestru/01-proxied-dev-environment.md](../50-running-in-maestru/01-proxied-dev-environment.md)).
2. **Load brand design-systems** — Oktogon + client brands as `design-systems/` ([../40-content-system/02-design-systems.md](../40-content-system/02-design-systems.md)).
3. **Build guided pipelines as plugins** for our recurring deliverables ([../40-content-system/04-plugins.md](../40-content-system/04-plugins.md)).
4. **Add real front-door auth** so the hosted instance is safe to share ([03-open-questions.md](./03-open-questions.md)).
5. **Decide the hosting / multi-user model**.

## The strategic constraint

Build through Open Design's **additive seams** so we keep absorbing upstream improvements — see [../80-methodology/01-evolution-principles.md](../80-methodology/01-evolution-principles.md). Divergence discipline is what keeps "our product" from becoming "an unmaintainable forked codebase."

> **Success** = a design partner that produces on-brand output at agency speed, fully owned by Oktogon, still riding upstream's improvements.
