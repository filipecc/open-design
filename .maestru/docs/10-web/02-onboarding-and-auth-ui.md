---
maestru: "0.4"
type: doc
id: 02-onboarding-and-auth-ui
title: "Onboarding & Auth UI"
description: "EntryShell.tsx and the three backend modes (Cloud/AMR, Local coding agent, BYOK) — what the 'Sign in' screen actually does"
tags: [web, onboarding, auth, entryshell, byok, amr, modes]
created: 2026-06-22
updated: 2026-06-22
---

# Onboarding & Auth UI

<!-- maestru:summary -->
The "Sign in to Open Design" screen is rendered by apps/web/src/components/EntryShell.tsx and is the onboarding flow, not authentication — it picks an execution backend and flips config.onboardingCompleted. Three modes: (1) Open Design Cloud / AMR — handleCloudSignIn() spawns the vela device-auth login; config.mode stays 'daemon' with agentId='amr'; cloud is the model provider. (2) Local coding agent — config.mode='daemon' with agentId set to a detected CLI (claude/codex/opencode/…); no key, no account, just a binary on PATH. (3) BYOK — config.mode='api' with apiProtocol/apiKey/baseUrl/model; the daemon proxies the provider. Onboarding cards render while config.onboardingCompleted is false; completion (handleCompleteOnboarding in App.tsx) sets it true and persists. There is no user/session/password; "who you are" is not modeled. EntryShell is a redesigned sibling of EntryView.tsx (kept separate to allow independent rebasing against upstream). To add a custom auth/backend, the additive seam is a fourth mode here plus an ExecMode extension in types.ts and a daemon connection-test case — see the methodology section before editing this hot file in place.
<!-- /maestru:summary -->

The "Sign in to Open Design" screen is `apps/web/src/components/EntryShell.tsx`. It is **onboarding** — it selects an execution backend and flips `onboardingCompleted`. There is **no user, session, or password**.

## The three modes

| Mode | `config` it sets | Handler / behavior |
|------|------------------|--------------------|
| **Open Design Cloud (AMR)** | `mode:'daemon'`, `agentId:'amr'` | `handleCloudSignIn()` spawns `vela` device-auth login; cloud is the model provider |
| **Local coding agent** | `mode:'daemon'`, `agentId:<cli>` | Uses a detected CLI on `$PATH` (claude/codex/opencode…); no key, no account |
| **BYOK** | `mode:'api'`, `apiProtocol`/`apiKey`/`baseUrl`/`model` | Daemon proxies the chosen provider |

`ExecMode` is `'daemon' | 'api'` (`apps/web/src/types.ts`). Onboarding cards render while `onboardingCompleted` is false; `handleCompleteOnboarding` (in `App.tsx`) sets it true and persists.

> `EntryShell.tsx` is a **redesigned sibling of `EntryView.tsx`**, kept separate so it can be rebased against upstream independently. It's a *hot file* — edit with care (see below).

## Extending: a custom auth / backend

The additive seam for a custom mode (e.g. Oktogon SSO or an internal proxy):
1. add a fourth option + i18n strings in `EntryShell.tsx`,
2. extend `ExecMode` / `AppConfig` in `types.ts`,
3. add a validation case in the daemon connection test.

But `EntryShell.tsx` and the auth area are exactly the kind of upstream-hot files where in-place edits cost merge pain. **Read [../80-methodology/01-evolution-principles.md](../80-methodology/01-evolution-principles.md) first** — prefer a new module/middleware over rewriting the onboarding component, and if front-door access control is the goal, the cleaner seam is the sidecar (see [04-sidecar-proxy.md](./04-sidecar-proxy.md) and [../02-architecture/03-security-and-origin-model.md](../02-architecture/03-security-and-origin-model.md)).
