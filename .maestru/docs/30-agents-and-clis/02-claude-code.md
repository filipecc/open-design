---
maestru: "0.4"
type: doc
id: 02-claude-code
title: "Claude Code Adapter"
description: "How the claude (Claude Code) adapter is wired: stream-json I/O, native skill loading, bypassPermissions, session resume"
tags: [agents, claude-code, claude, adapter, stream-json]
created: 2026-06-22
updated: 2026-06-22
---

# Claude Code Adapter

<!-- maestru:summary -->
The Claude Code adapter is apps/daemon/src/runtimes/defs/claude.ts (id 'claude', bin 'claude', fallbackBins ['openclaude']). It invokes claude in print mode with stream-json I/O: -p --input-format stream-json --output-format stream-json --verbose --permission-mode bypassPermissions, plus model selection, --add-dir for skills, and session resume. promptViaStdin:true delivers the prompt over stdin as stream-json (no argv length limit). Output is parsed by apps/daemon/src/runtimes/claude-stream.ts (streamFormat 'claude-stream-json'), which maps JSONL events to AgentEvent types (thinking, tool_call, tool_result, text_delta, file_write, error, done) and warns on unrecognized CLI versions. Skills are loaded natively by symlinking into ~/.claude/skills/; edits use Claude's native Edit tool; MCP is injected via .mcp.json (externalMcpInjection 'claude-mcp-json'); sessions persist via --session-id/--resume (resumesSessionViaCli). Cancel is SIGTERM (Claude flushes and exits). This is the default/reference local-agent path and is well-suited to the Maestru-hosted environment where the claude CLI is on PATH.
<!-- /maestru:summary -->

Definition: `apps/daemon/src/runtimes/defs/claude.ts` — `id:'claude'`, `bin:'claude'`, `fallbackBins:['openclaude']`.

## Invocation

`claude` is run in print/stream mode:

```
claude -p
  --input-format stream-json
  --output-format stream-json
  --verbose
  --permission-mode bypassPermissions
  --model <model>  --add-dir <skill dir>  [--session-id <uuid> | --resume <id>]
```

- `promptViaStdin: true` — the prompt is written to **stdin** as stream-json (no argv length limit), `promptInputFormat: 'stream-json'`.
- `streamFormat: 'claude-stream-json'`.

## Stream parsing

`apps/daemon/src/runtimes/claude-stream.ts` parses the JSONL stdout into `AgentEvent`s (`thinking`, `tool_call`, `tool_result`, `text_delta`, `file_write`, `error`, `done`). It is version-aware and warns on unrecognized Claude Code builds.

## Specifics

| Concern | Behavior |
|---------|----------|
| Skill loading | Symlinks the skill into `~/.claude/skills/`; Claude auto-loads it |
| Edits | Uses Claude's native `Edit` tool for surgical changes |
| Permissions | `--permission-mode bypassPermissions` for headless runs |
| MCP | Injected via `.mcp.json` (`externalMcpInjection: 'claude-mcp-json'`) |
| Resume | `--session-id` for new, `--resume` to continue (`resumesSessionViaCli`) |
| Cancel | `SIGTERM`; Claude flushes and exits |

This is the **default/reference local-agent** path and fits the Maestru-hosted environment well — the `claude` CLI is on `PATH` here. To run a design with it, pick **"Local coding agent"** in onboarding (see [../10-web/02-onboarding-and-auth-ui.md](../10-web/02-onboarding-and-auth-ui.md)).
