---
maestru: "0.4"
type: doc
id: 02-relationship-to-upstream
title: "Relationship to Upstream"
description: "What the Oktogon Design Partner adopts from Open Design vs. where it deliberately diverges, and the license posture"
tags: [product, upstream, fork, divergence, license, apache-2]
created: 2026-06-22
updated: 2026-06-22
---

# Relationship to Upstream

<!-- maestru:summary -->
Defines the boundary between Open Design (upstream nexu-io/open-design) and the Oktogon Design Partner. We ADOPT, unchanged and kept mergeable: the two-process engine (daemon + web sidecar), the agent-adapter layer and BYOK/cloud modes, the content system (skills/design-systems/design-templates/plugins/craft/atoms), the data model, and the security primitives. We DIVERGE additively via: Oktogon/client brand design-systems, curated skills and guided plugin pipelines, the Maestru spec layer + this body of knowledge, the hosted run environment (dev-web.sh, proxy config), and — as net-new capability Open Design lacks — front-door access control and (later) multi-user/hosting. License posture: Open Design is Apache-2.0, which permits private modification and even offering a modified hosted product, provided we preserve license/NOTICE and attribution; bundled templates retain their own MIT licenses. We are not obligated to upstream our changes, but selectively contributing non-differentiating fixes reduces our merge burden. The governing rule is the divergence discipline in 80-methodology: adopt by reference, diverge by addition, edit core only when unavoidable and documented.
<!-- /maestru:summary -->

## Adopt (kept mergeable)

We take these from upstream **as-is** and keep absorbing their improvements:
- the two-process **engine** (daemon + web sidecar) — `02`/`10`/`20`,
- the **agent-adapter** layer + BYOK/cloud modes — `30`,
- the **content system** (skills, design-systems, design-templates, plugins, craft, atoms) — `40`,
- the **data model** and **security primitives** — `02-architecture/01`, `02-architecture/03`.

## Diverge (additively)

We build our product through additive surfaces:
- **Oktogon + client brand design-systems**,
- **curated skills and guided plugin pipelines** for our deliverables,
- the **Maestru spec layer** + this body of knowledge,
- the **hosted run environment** (`dev-web.sh`, proxy config),
- **net-new capability Open Design lacks**: front-door access control, and later multi-user / hosting.

See the cost gradient in [../80-methodology/00-overview.md](../80-methodology/00-overview.md).

## License posture

Open Design is **Apache-2.0**. That permits private modification and **offering a modified hosted product**, provided we:
- preserve the `LICENSE`/`NOTICE` and attribution,
- respect bundled templates that retain their own **MIT** licenses (e.g. the PPT templates).

We're **not obligated to upstream** our changes — but selectively contributing **non-differentiating** fixes upstream reduces our own merge burden over time.

## Governing rule

> **Adopt by reference, diverge by addition, edit core only when unavoidable and documented** ([../80-methodology/02-customization-discipline.md](../80-methodology/02-customization-discipline.md)).
