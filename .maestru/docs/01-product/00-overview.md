---
maestru: "0.4"
type: doc
id: 00-overview
title: "Product — Overview"
description: "The product framing for this fork: from Open Design (the engine) to the Oktogon Design Partner (our product), and what this section covers"
tags: [product, oktogon-design-partner, vision, overview]
created: 2026-06-22
updated: 2026-06-22
---

# Product — Overview

<!-- maestru:summary -->
This is the opinion layer: it frames what we are building on top of Open Design, separate from the factual descriptions in sections 02-40. Open Design is the engine — a local-first, BYOK, Apache-2.0 app that turns conversation into design artifacts by driving coding-agent CLIs. The Oktogon Design Partner is the product: Open Design's engine, evolved and operated by Oktogon as a hosted, branded, opinionated design partner for our own and clients' work — with Oktogon brand design-systems, curated skills/plugins/pipelines, our run environment, and (eventually) real access control and multi-user support. The relationship-to-upstream doc defines what we adopt vs. diverge; the vision doc states the why and the near-term shape; open-questions tracks the decisions still pending (notably front-door auth, hosting model, brand/IP, and how far to diverge). Keeping this layer explicitly separate from the factual layers is deliberate: facts stay mergeable with upstream knowledge, opinions evolve independently. Treat this section as living strategy, not settled fact.
<!-- /maestru:summary -->

This is the **opinion layer** — what we're building on top of Open Design, kept separate from the factual descriptions in sections `02`–`40` so the facts stay mergeable and the strategy can evolve independently.

## Engine vs. product

- **Open Design** is the **engine**: a local-first, BYOK, Apache-2.0 app that turns conversation into design artifacts by driving agent CLIs ([../02-architecture/00-overview.md](../02-architecture/00-overview.md)).
- **Oktogon Design Partner** is the **product**: that engine, evolved and operated by Oktogon as a hosted, branded, opinionated design partner.

## In this section

| Doc | Purpose |
|-----|---------|
| [01-vision.md](./01-vision.md) | Why this exists; the near-term shape |
| [02-relationship-to-upstream.md](./02-relationship-to-upstream.md) | What we adopt vs. diverge |
| [03-open-questions.md](./03-open-questions.md) | Decisions resolved and pending |

> Living strategy, not settled fact. Bump `updated` as decisions land; move resolved questions out of [03-open-questions.md](./03-open-questions.md).
