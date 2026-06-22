---
maestru: "0.4"
type: doc
id: 05-work-loop
title: "The Work Loop"
description: "How to manage Open Design work with Maestru: tracks, work-items, specs, the in-progress/done rules, and the maestru check gate"
tags: [methodology, work-loop, maestru, tracks, work-items, specs]
created: 2026-06-22
updated: 2026-06-22
---

# The Work Loop

<!-- maestru:summary -->
How Open Design work is managed with Maestru in this fork. .maestru/ is the source of truth; maestru sql is a derived interface and maestru check is the required validation gate. Work is organized as work-tracks (e.g. track-bok) containing work-items (e.g. BOK0..BOK10), each work-item optionally backed by work-specs using templates (implementation-plan-v1/v2, research-v1, testing-plan-v1, diagrams-v1, wireframes-v1) for complex 3+ file changes. The loop: maestru search <topic> for context, maestru sql to find/claim the item (UPDATE status='in-progress' when starting), write a spec if the change touches 3+ files, do the work treating .maestru markdown as canonical, then maestru check (mandatory — fix all errors) before considering it done. Status flow is backlog→assigned→in-progress→done(/archived); the agent sets in-progress but does NOT set done — terminal status requires human review. Branches follow {item-id}-{short-name}, commits are small/atomic and reference the item id, main stays stable. This Body of Knowledge effort is itself run this way under track-bok, demonstrating the loop. Combine with the evolution principles so work items land on additive seams wherever possible.
<!-- /maestru:summary -->

`.maestru/` is the source of truth; `maestru sql` is a derived interface; **`maestru check` is the required gate**.

## The hierarchy

- **work-track** (e.g. `track-bok`) — a body of related work.
- **work-item** (e.g. `BOK0`–`BOK10`) — a unit; has priority + status.
- **work-spec** — an implementation plan for complex (3+ file) work, using a template (`implementation-plan-v1`/`v2`, `research-v1`, `testing-plan-v1`, `diagrams-v1`, `wireframes-v1`).

## The loop

```
maestru search <topic>                                  # gather context
maestru sql "SELECT … FROM work_items WHERE …"          # find/verify the item
maestru sql "UPDATE work_items SET status='in-progress' WHERE id='<ID>'"   # claim
# (write a work-spec if the change touches 3+ files)
… do the work; treat .maestru markdown as canonical …
maestru check                                           # MANDATORY — fix all errors
```

## Status rules

```
backlog → assigned → in-progress → done
                                  ↘ archived
```

- The agent **sets `in-progress`** when starting.
- The agent **does NOT set `done`** — terminal status requires **human review**.

## Git conventions

- Branches: `{item-id}-{short-name}` (e.g. `bok9-methodology`).
- Commits: small, atomic, reference the item id; keep `main` stable.

## This corpus, dogfooded

This Body of Knowledge is itself run this way under **`track-bok`** — query it:

```bash
maestru sql "SELECT id, title, status FROM work_items WHERE track_id='track-bok' ORDER BY id"
```

Combine the loop with the [evolution principles](./01-evolution-principles.md): scope work-items onto **additive seams** wherever possible.
