---
maestru: "0.4"
type: work-spec
id: {{id}}
title: "{{title}}"
template: implementation-plan-v2
work-item: {{work-item}}
owner: {{owner}}
created: {{created}}
---

# {{title}}

## Overview

<!-- Guidelines:
- What this feature adds and why it's needed
- Who benefits (users, agents, developers)
- Link to the work-item that motivated this
- Keep to 2-3 sentences — detail goes in Implementation
-->

## Unit Tests

<!-- Guidelines:
- IMPORTANT: These tests are normative. Coding should not redefine them.
- This section is the locked acceptance contract for the work-spec.
- Write tests BEFORE the implementation section. During coding, implementation should adapt to these tests; do not change this section unless the product requirement itself changes.
- Every test must be independently verifiable and written in behavior-first language.
- Prefer exact expected outputs over vague behavior:
  - exact JSON shapes
  - exact status codes
  - exact error payloads
  - exact sorting rules
  - exact null/empty semantics
  - exact UI text / button labels / loading states
  - exact timing behavior when relevant (e.g. debounce: 300ms)
- If an endpoint or UI state has multiple outcomes, specify each one separately:
  - success case
  - empty state
  - not found
  - validation failure
  - upstream/dependency failure
  - auth failure
  - rate limiting / retry behavior
- Avoid vague phrases like:
  - "works correctly"
  - "filters properly"
  - "returns the expected data"
  Replace them with concrete outcomes.
- Format: "It should [exact outcome] when [condition]"
- If useful, add a short "Response Shapes" or "UI States" subsection immediately after this section with exact contracts.
- These tests are the evaluation basis for implementation.
-->

## Implementation

<!-- Guidelines:
- IMPORTANT: Every step must be executable as Red -> Green -> Refactor without redefining acceptance criteria.
- Break into phases (### Phase N: Name), each independently completable.
- Steps within phases (#### Step N.N: Name).
- Each step must map to one or more tests from the Unit Tests section.
- Each step needs an action table: | Action | File | Details |
- Action types: Create, Modify, Delete, Run

- TDD is mandatory for every step. Follow this exact sequence:
  1. RED: add or extend the test(s) for this step first
  2. RUN: execute the relevant test(s) and confirm they fail for the expected reason
  3. GREEN: implement the minimum code required to make those test(s) pass
  4. RUN: execute the same test(s) again and confirm they pass
  5. REFACTOR: improve structure only if behavior stays unchanged
  6. RUN: re-run the relevant test(s) after refactoring

- Under every step, include a dedicated red/green block using this structure:

  **Tests first (red):**
  | Action | File | Details |

  **Implementation (green):**
  | Action | File | Details |

- Do not describe implementation-only work without the test that proves it.
- If a step cannot be driven by an automated test, state why explicitly and add a manual verification checklist item.
- End each phase with a verification checklist (- [ ]) using observable outcomes, not implementation statements.
- Include code snippets only for logic that would otherwise be ambiguous.
-->

## Impacted Files

<!-- Guidelines:
- One row per file, no duplicates
- Action column: Create, Modify, Delete
- Purpose column: brief explanation of the change
- Order by phase/dependency, not alphabetically
-->

| File | Action | Purpose |
|------|--------|---------|
