---
maestru: "0.4"
type: doc
id: 03-byok-providers
title: "BYOK Providers"
description: "The api mode: daemon-proxied provider streaming, the connection test, the SSRF guard, and daemon-side tool execution"
tags: [agents, byok, providers, proxy, ssrf, connection-test]
created: 2026-06-22
updated: 2026-06-22
---

# BYOK Providers

<!-- maestru:summary -->
BYOK is config.mode='api': instead of a local CLI, Open Design calls a model provider directly with the user's key, proxied through the daemon (never the browser) for SSRF protection. Proxy routes live in apps/daemon/src/routes/chat.ts: POST /api/proxy/{anthropic,openai,azure,google,ollama}/stream (plus senseaudio/aihubmix media gateways). Supported protocols: Anthropic Messages, OpenAI Chat Completions, Azure OpenAI, Google Vertex generateContent, Ollama (OpenAI-compatible). Before a real run the Settings dialog validates credentials via apps/daemon/src/connectionTest.ts testProviderConnection() (sends a tiny "reply ok" request, categorizes auth/network/success) and validateBaseUrlResolved() — a DNS-aware SSRF guard that rejects loopback/RFC1918/metadata-service targets. Because BYOK providers don't run the agent loop themselves, apps/daemon/src/byok-tools.ts injects OpenAI-shaped tool definitions and executes tool calls daemon-side (Read/Write/Edit, media generation), looping model→tool_call→daemon execute→tool result→next completion. Provider keys/timeouts surface as OD_<PROVIDER>_* env (see 03-environment-variables/03). This is the path to use when no local CLI is installed or to pin a specific provider.
<!-- /maestru:summary -->

BYOK is `config.mode='api'`: Open Design calls a provider directly with your key — but **through the daemon**, never the browser, so the key isn't exposed and the target is SSRF-checked.

## Proxy routes (`apps/daemon/src/routes/chat.ts`)

```
POST /api/proxy/anthropic/stream     POST /api/proxy/google/stream
POST /api/proxy/openai/stream        POST /api/proxy/ollama/stream
POST /api/proxy/azure/stream         (+ senseaudio / aihubmix media gateways)
```

Supported protocols: Anthropic Messages, OpenAI Chat Completions, Azure OpenAI, Google Vertex (`generateContent`), Ollama (OpenAI-compatible).

## Connection test + SSRF guard

`apps/daemon/src/connectionTest.ts`:
- `testProviderConnection()` — sends a tiny "reply with ok" request, returns a categorized result (auth error / network error / success). The Settings dialog runs this before a real chat.
- `validateBaseUrlResolved()` — a **DNS-aware SSRF guard** that rejects loopback / RFC1918 / cloud metadata-service targets.

## Daemon-side tool execution

BYOK providers don't run an agent loop, so `apps/daemon/src/byok-tools.ts` makes one: it injects OpenAI-shaped `tools` into the completion request and executes tool calls **daemon-side** (Read/Write/Edit for files, media generation), looping `model → tool_call → daemon execute → tool result → next completion`.

## Config & env

The UI's BYOK onboarding sets `apiProtocol`/`apiKey`/`baseUrl`/`model` ([../10-web/03-state-and-config.md](../10-web/03-state-and-config.md)). Provider keys/timeouts can also come from `OD_<PROVIDER>_*` env — see [../03-environment-variables/03-agents-and-byok.md](../03-environment-variables/03-agents-and-byok.md).

Use BYOK when no local CLI is installed or to pin a specific provider.
