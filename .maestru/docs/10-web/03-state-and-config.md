---
maestru: "0.4"
type: doc
id: 03-state-and-config
title: "State & Config"
description: "AppConfig, the localStorage 'open-design:config' store, and how config syncs to the daemon via /api/app-config"
tags: [web, state, config, localstorage, appconfig, daemon-sync]
created: 2026-06-22
updated: 2026-06-22
---

# State & Config

<!-- maestru:summary -->
Client configuration is the AppConfig type (apps/web/src/types.ts, ~line 366): mode (ExecMode 'daemon'|'api'), apiKey, baseUrl, model, apiProtocol (default 'anthropic'), onboardingCompleted (default false), agentId (default null), agentModels, skillId, pet/orbit, mediaProviders, etc. Persistence is in apps/web/src/state/config.ts: loadConfig() reads localStorage key 'open-design:config' (falling back to DEFAULT_CONFIG and stripping daemon-owned keys), saveConfig() writes the sanitized config back, and syncConfigToDaemon() POSTs the daemon-relevant prefs (onboardingCompleted, agentId, agentModels, …) to /api/app-config, swallowing errors when the daemon is offline. App.tsx calls loadConfig on mount and routes every change through saveConfig + syncConfigToDaemon (e.g. on settings-dialog close, which can also mark onboarding complete). So config is browser-first with a daemon mirror: localStorage is the client source of truth and the daemon holds a server-side copy of the prefs it needs to spawn agents. Secrets like BYOK keys live in localStorage/daemon, not in git; there is no user record.
<!-- /maestru:summary -->

## `AppConfig`

Defined in `apps/web/src/types.ts` (~line 366). Key fields:

| Field | Meaning |
|-------|---------|
| `mode` | `ExecMode` = `'daemon'` (local/cloud agent) or `'api'` (BYOK) |
| `onboardingCompleted` | The app gate (default `false`) |
| `agentId` | Selected agent CLI / `'amr'` for cloud (default `null`) |
| `apiKey`, `baseUrl`, `model`, `apiProtocol` | BYOK provider config (`apiProtocol` default `'anthropic'`) |
| `agentModels`, `skillId`, `pet`, `orbit`, `mediaProviders` | Other prefs |

## Persistence — `state/config.ts`

- **`loadConfig()`** — reads `localStorage['open-design:config']`, falls back to `DEFAULT_CONFIG`, strips daemon-owned keys.
- **`saveConfig(config)`** — writes the sanitized config to localStorage.
- **`syncConfigToDaemon(config)`** — POSTs daemon-relevant prefs (`onboardingCompleted`, `agentId`, `agentModels`, …) to **`/api/app-config`**; swallows errors when the daemon is offline.

`DEFAULT_CONFIG`: `onboardingCompleted:false`, `mode:'daemon'`, `apiProtocol:'anthropic'`, `agentId:null`.

## The flow

```
App.tsx mount → loadConfig() (localStorage)
   change → saveConfig() (localStorage)  +  syncConfigToDaemon() (POST /api/app-config)
```

Config is **browser-first with a daemon mirror**: localStorage is the client source of truth; the daemon keeps a server-side copy of the prefs it needs to spawn agents. BYOK keys live in localStorage / daemon, **not in git**. There is no user record — see [02-onboarding-and-auth-ui.md](./02-onboarding-and-auth-ui.md).

> Practical bypass: setting `onboardingCompleted:true` directly in the `open-design:config` localStorage value skips the onboarding screen (you still need a working backend configured). Captured in [../85-audits/01-auth-and-origin-analysis-2026-06.md](../85-audits/01-auth-and-origin-analysis-2026-06.md).
