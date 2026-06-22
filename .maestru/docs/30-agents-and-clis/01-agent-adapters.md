---
maestru: "0.4"
type: doc
id: 01-agent-adapters
title: "Agent Adapters"
description: "The RuntimeAgentDef model, the AGENT_DEFS registry of 24 CLIs, detection probing, and the ACP family"
tags: [agents, adapters, agent-defs, detection, acp, runtimes]
created: 2026-06-22
updated: 2026-06-22
---

# Agent Adapters

<!-- maestru:summary -->
An "agent" is an external CLI Open Design delegates the agent loop to. apps/daemon/src/runtimes/registry.ts holds AGENT_DEFS — 24 RuntimeAgentDef entries, each in runtimes/defs/<id>.ts declaring binary + fallbacks, version args, model-fetch, stream format, stdin/stdout behavior, MCP injection, and session-resume support. The CLIs: claude, codex, opencode, cursor-agent, gemini, qwen, copilot, devin, hermes, kimi, kilo, kiro, vibe, qoder, pi, deepseek, trae-cli, amp, aider, antigravity, codebuddy, reasonix, grok-build, amr. detection.ts detectAgents()/detectAgentsStream() probe each in parallel (run --version, fetch models, classify availability) — the source of the short detection runs seen at onboarding. Stream output is parsed by per-agent handlers keyed off streamFormat (claude-stream-json, json-event-stream variants, acp, plain). Six adapters speak ACP (Agent Client Protocol, JSON-RPC 2.0 over stdio): devin, hermes, kilo, kiro, vibe, trae-cli (and amr/vela). ACP lifecycle (apps/daemon/src/acp.ts attachAcpSession): initialize → session/new → optional set_model → session/prompt → session/update notifications → session/cancel. New agents are added by dropping a def in runtimes/defs/ and registering it — a clean additive extension point.
<!-- /maestru:summary -->

## The model

To Open Design, an **agent** is an external CLI it hands the full loop (model, tools, context, permissions, resume, cancel). The daemon detects it, feeds it a skill + prompt + working dir, and streams its output to the UI.

- **`apps/daemon/src/runtimes/registry.ts`** → `AGENT_DEFS` enumerates the agents.
- Each has a **`RuntimeAgentDef`** in `runtimes/defs/<id>.ts`: binary (+ fallbacks), version args, model-fetch, stream format, stdin/stdout behavior, MCP injection, session-resume support.

## The 24 CLIs

```
claude  codex  opencode  cursor-agent  gemini  qwen  copilot
devin  hermes  kimi  kilo  kiro  vibe  trae-cli          (ACP family)
qoder  pi  deepseek  amp  aider  antigravity  codebuddy  reasonix  grok-build
amr                                                       (cloud/Vela, ACP)
```

## Detection

`runtimes/detection.ts`:
- `detectAgents(configuredEnvByAgent)` probes every def in parallel — runs `--version`, fetches model lists, classifies availability (invocable / auth-issue / unavailable).
- `detectAgentsStream()` yields each as its probe completes.

> Those probes are why onboarding spawns many short-lived agent runs (e.g. `opencode`) — detection, not failures.

## Stream handling

Output is parsed by a per-agent handler keyed off `streamFormat`: `claude-stream-json`, JSON-event-stream variants (opencode/codex/gemini/cursor), `acp`, and `plain` (deepseek/qwen/grok). See [../20-daemon/04-agent-spawning.md](../20-daemon/04-agent-spawning.md).

## ACP family

Six adapters speak **ACP (Agent Client Protocol)** — JSON-RPC 2.0 over **stdio** (`docs/new-agent-runtime-acp.md`): `devin`, `hermes`, `kilo`, `kiro`, `vibe`, `trae-cli` (plus `amr`/Vela). Lifecycle (`apps/daemon/src/acp.ts` `attachAcpSession`): `initialize` → `session/new` → optional `session/set_model` → `session/prompt` → `session/update` notifications → `session/cancel`. Permission requests are auto-approved.

## Adding an agent (extension point)

Drop a `RuntimeAgentDef` in `runtimes/defs/` and register it in `registry.ts`. This is a clean **additive** seam — new file, minimal edit — exactly the kind of divergence the [methodology](../80-methodology/01-evolution-principles.md) favors.
