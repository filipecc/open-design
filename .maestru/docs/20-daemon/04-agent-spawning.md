---
maestru: "0.4"
type: doc
id: 04-agent-spawning
title: "Agent Spawning"
description: "How the daemon detects agent CLIs (runtimes/detection.ts) and spawns them to run a design, with per-agent stream handlers and the ACP family"
tags: [daemon, agents, spawn, detection, acp, runtimes]
created: 2026-06-22
updated: 2026-06-22
---

# Agent Spawning

<!-- maestru:summary -->
The daemon both detects and runs agent CLIs. Detection: runtimes/detection.ts detectAgents(configuredEnvByAgent) probes every entry in AGENT_DEFS (runtimes/registry.ts) in parallel — running each agent's --version, fetching model lists, classifying availability (invocable / auth-issue / unavailable); detectAgentsStream() yields agents as each probe completes (this is what produced the many short opencode runs seen during onboarding). Agent definitions live in runtimes/defs/ (claude.ts, codex.ts, amr.ts, cursor.ts, hermes.ts, kimi.ts, qoder.ts, antigravity.ts, …), each declaring binary, version args, model fetch, stream format, and stdin/stdout behavior. Spawning: server.ts (~6834) calls spawn(command, args, {env, stdio, cwd, shell:false}); spawnEnvForAgent (agents.ts ~140) builds the child env (launch customizations, model resolution, injected MCP servers, OD_DATA_DIR=RUNTIME_DATA_DIR). Prompts are passed via argv or, when def.promptViaStdin, written to stdin. Agent stdout is routed through per-agent stream handlers — Claude, Copilot, ACP (Hermes/Kimi via attachAcpSession), Qoder, Pi-RPC, and a generic JSON-event handler. Mock CLIs under mocks/ are PATH-overlay drop-ins for deterministic tests. The agent itself is BYO — see 30-agents-and-clis.
<!-- /maestru:summary -->

The daemon is what actually **detects** and **runs** the agent. The agent binary itself is not shipped — see [../30-agents-and-clis/00-overview.md](../30-agents-and-clis/00-overview.md).

## Detection

`runtimes/detection.ts`:
- `detectAgents(configuredEnvByAgent)` probes every `AGENT_DEFS` entry (`runtimes/registry.ts`) **in parallel** — runs each agent's `--version`, fetches model lists, classifies availability (invocable / auth-issue / unavailable).
- `detectAgentsStream()` yields agents as each probe completes.

> This is what produced the many short-lived `opencode` runs seen in the logs during onboarding — they were detection probes, not failures.

Definitions live in `runtimes/defs/` (`claude.ts`, `codex.ts`, `amr.ts`, `cursor.ts`, `hermes.ts`, `kimi.ts`, `qoder.ts`, `antigravity.ts`, …); each declares the binary, version args, model-fetch logic, stream format, and stdin/stdout behavior.

## Spawning

- `server.ts` (~6834): `spawn(command, args, { env, stdio, cwd, shell:false })`; stores the child + PID.
- `spawnEnvForAgent` (`agents.ts` ~140) builds the child environment: launch customizations, model resolution, injected MCP servers, and `OD_DATA_DIR=RUNTIME_DATA_DIR`.
- Prompt delivery: via argv, or written to **stdin** when `def.promptViaStdin`.

## Stream handlers

Agent stdout is routed through a per-agent handler:

| Handler | Agents |
|---------|--------|
| `createClaudeStreamHandler()` | Claude |
| `createCopilotStreamHandler()` | Copilot |
| `attachAcpSession()` | ACP family (Hermes, Kimi, …) |
| `createQoderStreamHandler()` | Qoder |
| `attachPiRpcSession()` | Pi-RPC agents |
| `createJsonEventStreamHandler()` | Generic JSON-event |

## Mocks

`mocks/` holds replay-based mock agent CLIs (`claude`/`codex`/`gemini`/`cursor`/`opencode`/the ACP family/`vela`), built from anonymized traces. They are **PATH-overlay drop-ins** for deterministic tests and self-validation — see [../30-agents-and-clis/05-mocks.md](../30-agents-and-clis/05-mocks.md).
