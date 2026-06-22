---
maestru: "0.4"
type: doc
id: 00-overview
title: "Agents & CLIs — Overview"
description: "The agent adapter layer: how Open Design delegates the agent loop to 24 external CLIs, plus BYOK and cloud (AMR/Vela) modes"
tags: [agents, cli, adapters, byok, amr, acp, overview]
created: 2026-06-22
updated: 2026-06-22
---

# Agents & CLIs — Overview

<!-- maestru:summary -->
Open Design ships no model — it delegates the entire agent loop (model calls, tool use, context, permissions, resume, cancel) to an external coding-agent CLI, or to a BYOK API key, or to the cloud AMR runtime. The adapter layer lives in apps/daemon/src/runtimes: registry.ts (AGENT_DEFS) enumerates 24 supported CLIs, each with a RuntimeAgentDef under runtimes/defs/ (claude, codex, opencode, cursor-agent, gemini, qwen, copilot, devin, hermes, kimi, kilo, kiro, vibe, qoder, pi, deepseek, trae-cli, amp, aider, antigravity, codebuddy, reasonix, grok-build, amr). detection.ts probes each (--version, models, auth) and the daemon spawns the chosen one, routing stdout through a per-agent stream handler. Three execution modes (docs/modes.md): daemon (local CLI subprocess), api (BYOK direct provider via /api/proxy/{anthropic,openai,azure,google,ollama}/stream), and cloud (AMR via the vela CLI over ACP). A subset of agents (devin/hermes/kilo/kiro/vibe/trae/amr) speak ACP (Agent Client Protocol, JSON-RPC over stdio). The mocks/ directory provides replay-based mock CLIs as a PATH overlay for deterministic tests. Sibling docs cover adapters, Claude Code, BYOK, cloud/AMR, and mocks.
<!-- /maestru:summary -->

Open Design ships **no model**. It delegates the whole agent loop to an external CLI, a BYOK API key, or the cloud runtime. This layer lives in `apps/daemon/src/runtimes/`.

## In this section

| Doc | Purpose |
|-----|---------|
| [01-agent-adapters.md](./01-agent-adapters.md) | The adapter model, `AGENT_DEFS`, the 24 CLIs, ACP family |
| [02-claude-code.md](./02-claude-code.md) | How Claude Code is wired |
| [03-byok-providers.md](./03-byok-providers.md) | BYOK proxy + connection test + SSRF guard |
| [04-cloud-amr-vela.md](./04-cloud-amr-vela.md) | The AMR cloud runtime via `vela` |
| [05-mocks.md](./05-mocks.md) | Replay-based mock CLIs for tests |

## Three execution modes (`docs/modes.md`)

| Mode | What | Transport |
|------|------|-----------|
| **daemon** (local CLI) | Spawns a local agent CLI as a child process | stdio / subprocess |
| **api** (BYOK) | Your API key, direct to a provider | HTTP `/api/proxy/{anthropic,openai,azure,google,ollama}/stream` |
| **cloud** (AMR/Vela) | OpenRouter-compatible runtime via the `vela` CLI | ACP JSON-RPC over stdio |

`docs/modes.md` also describes the *output* modes (prototype / deck / template / design-system) — the artifact shapes, covered in [../40-content-system/00-overview.md](../40-content-system/00-overview.md).

## Authoritative sources

`docs/agent-adapters.md` (adapter interface), `docs/new-agent-runtime-acp.md` (ACP), `apps/daemon/src/runtimes/`. These BOK docs distill them.
