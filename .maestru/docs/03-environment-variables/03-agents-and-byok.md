---
maestru: "0.4"
type: doc
id: 03-agents-and-byok
title: "Agent & BYOK Env Vars"
description: "Environment that controls agent CLI execution and the BYOK provider proxy (Anthropic/OpenAI/Azure/Google/Ollama)"
tags: [environment-variables, agents, byok, cli, providers]
created: 2026-06-22
updated: 2026-06-22
---

# Agent & BYOK Env Vars

<!-- maestru:summary -->
Beyond the core runtime vars, a large family of OD_* env controls agent execution and BYOK providers. Agent runtime homes and per-agent CLI environment overrides are daemon data (under RUNTIME_DATA_DIR) and configured via app-config; OD_AGENT_HOME and OD_AGENT_PROFILES_CONFIG point at agent home/profile config. Provider API keys for BYOK and cloud generation surface as OD_<PROVIDER>_API_KEY (e.g. OD_BFL_API_KEY, OD_AIHUBMIX_API_KEY) plus numerous per-provider timeout/poll knobs. The BYOK path proxies model traffic through the daemon at /api/proxy/{anthropic,openai,azure,google,ollama}/stream with SSRF protection rather than letting the browser call providers directly. Chat-run lifecycle timeouts (OD_CHAT_RUN_*), ACP adapter timeouts (OD_ACP_*), and sandbox controls (OD_SANDBOX_MODE, which makes OD_DATA_DIR mandatory) round out the surface. For day-to-day use you rarely set these — the UI's onboarding (local agent / BYOK key) configures what is needed; this doc is the index for when you must override behavior.
<!-- /maestru:summary -->

Day-to-day you rarely touch these — the UI onboarding configures the agent/key. This is the index for when you must override behavior. Discover the full set with:

```bash
grep -rohE 'OD_[A-Z_]+' apps/daemon/src | sort -u
```

## Agent execution

| Var | Effect |
|-----|--------|
| `OD_AGENT_HOME` | Agent runtime home location |
| `OD_AGENT_PROFILES_CONFIG` | Path to agent profile config |
| `OD_ACP_TIMEOUT_MS`, `OD_ACP_STAGE_TIMEOUT_MS` | ACP-family adapter timeouts |
| `OD_CHAT_RUN_INACTIVITY_TIMEOUT_MS`, `OD_CHAT_RUN_CANCEL_*` | Chat-run lifecycle timeouts |
| `OD_SANDBOX_MODE` | Enables sandbox mode — makes `OD_DATA_DIR` **mandatory** |

Per-agent CLI environment overrides (`agentCliEnv`) are stored as daemon data via app-config, not env — see [../30-agents-and-clis/00-overview.md](../30-agents-and-clis/00-overview.md).

## BYOK & provider keys

BYOK routes model traffic **through the daemon**, not the browser:

```
/api/proxy/{anthropic,openai,azure,google,ollama}/stream   (SSRF-protected)
```

Provider credentials and tuning surface as `OD_<PROVIDER>_*`:

| Var (examples) | Effect |
|-----|--------|
| `OD_BFL_API_KEY`, `OD_AIHUBMIX_API_KEY`, … | Provider API keys for image/video/model generation |
| `OD_<PROVIDER>_*_TIMEOUT_MS`, `*_MAX_POLL_MS` | Per-provider timeouts / polling |

See [../30-agents-and-clis/03-byok-providers.md](../30-agents-and-clis/03-byok-providers.md) for how the BYOK flow is wired in the UI and validated by the daemon connection test.
