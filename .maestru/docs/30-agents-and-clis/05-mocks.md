---
maestru: "0.4"
type: doc
id: 05-mocks
title: "Mock Agent CLIs"
description: "How mocks/ provides replay-based mock agent CLIs as a PATH overlay for deterministic, offline tests and golden-snapshot regression"
tags: [agents, mocks, testing, replay, golden, path-overlay]
created: 2026-06-22
updated: 2026-06-22
---

# Mock Agent CLIs

<!-- maestru:summary -->
mocks/ provides replay-based mock agent CLIs so the full chat pipeline can run offline, deterministically, without burning LLM tokens — for E2E tests, parser iteration, demos, and regression. Setup: fetch the trace corpus (mocks/scripts/fetch-recordings.sh pulls ~179 traces from R2), then prepend mocks/bin to PATH to shadow the real CLIs. mocks/bin holds bash wrappers (opencode, claude, codex, gemini, cursor-agent, deepseek, qwen, grok, devin, hermes, kilo, kimi, kiro, vibe, vela) that all exec node mocks/mock-agent.mjs --as <agent>. Per-agent format renderers (mocks/lib/format-*.mjs) re-emit each trace in the right wire format (claude-stream, json-event variants, acp, vela ACP+login/models, plain). Trace selection is env-driven: OD_MOCKS_TRACE (fixed), OD_MOCKS_BY_PROMPT_HASH, OD_MOCKS_POOL, OD_MOCKS_SEED, else random; OD_MOCKS_NO_DELAY skips inter-event sleeps. Golden snapshots (mocks/golden/*.events.json) capture the exact daemon event sequence and are diffed by the daemon test suite (regenerate with MOCKS_GOLDEN_UPDATE=1). Mocks ignore CLI flags like --model/--permission-mode. A manual contract-check.sh compares a real CLI vs the mock on release. This is the backbone for testing adapter/parser changes safely as the fork evolves.
<!-- /maestru:summary -->

`mocks/` lets the full chat pipeline run **offline and deterministically** — no LLM tokens — for E2E tests, parser iteration, demos, and regression. Authoritative: `mocks/README.md`.

## Setup

```bash
bash mocks/scripts/fetch-recordings.sh     # pull the trace corpus (~179 traces) from R2
export PATH="$PWD/mocks/bin:$PATH"          # shadow the real CLIs
export OD_MOCKS_TRACE=<id>                  # pick a specific trace (optional)
export OD_MOCKS_NO_DELAY=1                  # skip inter-event sleeps
```

`mocks/bin/` holds bash wrappers (`opencode`, `claude`, `codex`, `gemini`, `cursor-agent`, `deepseek`, `qwen`, `grok`, `devin`, `hermes`, `kilo`, `kimi`, `kiro`, `vibe`, `vela`) that all `exec node mocks/mock-agent.mjs --as <agent>`.

## Format renderers

`mocks/lib/format-*.mjs` re-emit each trace in the correct wire format so the real daemon parsers are exercised unchanged: `format-claude.mjs` (→ `claude-stream.ts`), JSON-event variants (`opencode`/`codex`/`gemini`/`cursor`), `format-acp.mjs` (Devin/Hermes/Kilo/Kiro/Vibe/Trae), `format-vela.mjs` (AMR ACP + `login`/`models`), `format-plain.mjs` (DeepSeek/Qwen/Grok).

## Trace selection (env priority)

`OD_MOCKS_TRACE` (fixed) → `OD_MOCKS_BY_PROMPT_HASH` (deterministic by prompt) → `OD_MOCKS_POOL` (random in a tag pool) → `OD_MOCKS_SEED` (seeded) → uniform random.

## Golden snapshots

`mocks/golden/*.events.json` capture the exact daemon event sequence per trace, diffed by `pnpm --filter @open-design/daemon test mocks-golden` (volatile fields like `sessionId` normalized). Regenerate with `MOCKS_GOLDEN_UPDATE=1 pnpm test`.

> Mocks **ignore** CLI flags (`--model`, `--permission-mode`, `--allowed-tools`). A manual `mocks/scripts/contract-check.sh` compares a real CLI vs the mock on release.

This harness is the safe way to evolve adapter/parser code in the fork without live model calls — relevant to [../80-methodology/03-upstream-merge-runbook.md](../80-methodology/03-upstream-merge-runbook.md) when verifying post-merge behavior.
