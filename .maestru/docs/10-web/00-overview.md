---
maestru: "0.4"
type: doc
id: 00-overview
title: "Web App Overview"
description: "apps/web — the Next.js 16 + React 18 UI, its app shell and router, the onboarding gate, config/state model, and the sidecar proxy"
tags: [web, apps-web, nextjs, react, overview]
created: 2026-06-22
updated: 2026-06-22
---

# Web App Overview

<!-- maestru:summary -->
apps/web is the Next.js 16 App Router + React 18 front-end plus a Node sidecar. The browser loads a single-page-ish app whose entry is apps/web/src/App.tsx; routing is a tiny custom URL router (apps/web/src/router.ts, useRoute/navigate, no react-router) over a Route union (home/project/marketplace/design-system-*). The whole app is gated behind onboarding: config.onboardingCompleted (default false in state/config.ts) is checked in App.tsx and forces the EntryShell onboarding view until set true. EntryShell.tsx renders the three-mode picker (Cloud/AMR, Local coding agent, BYOK) which writes config.mode/agentId/apiKey. Client config lives in localStorage under 'open-design:config' (state/config.ts loadConfig/saveConfig) and is mirrored to the daemon via syncConfigToDaemon → POST /api/app-config. The sidecar (apps/web/sidecar/server.ts) serves the Next app, binds OD_HOST (default 127.0.0.1), and proxies /api, /artifacts, /frames to the daemon over loopback, applying dev-origin checks. Notable src dirs: components (incl. Theater = Critique review), providers, state, hooks, i18n (18 langs), media, analytics. Subsystem detail in the sibling docs.
<!-- /maestru:summary -->

`apps/web` is the **Next.js 16 + React 18** UI plus a Node **sidecar**. The browser only ever talks to the sidecar; the sidecar serves the UI and proxies data calls to the daemon.

## In this section

| Doc | Purpose |
|-----|---------|
| [01-app-shell-and-routing.md](./01-app-shell-and-routing.md) | `App.tsx`, the custom router, the onboarding gate |
| [02-onboarding-and-auth-ui.md](./02-onboarding-and-auth-ui.md) | `EntryShell.tsx` and the three backend modes |
| [03-state-and-config.md](./03-state-and-config.md) | `AppConfig`, localStorage, daemon sync |
| [04-sidecar-proxy.md](./04-sidecar-proxy.md) | `apps/web/sidecar/server.ts` — serving + proxying |

## Key files

| File | Role |
|------|------|
| `apps/web/src/App.tsx` | Entry point; route dispatch; config lifecycle; onboarding gate |
| `apps/web/src/router.ts` | Tiny URL ↔ Route router; `useRoute()` / `navigate()` |
| `apps/web/src/components/EntryShell.tsx` | Home layout + onboarding 3-mode selection |
| `apps/web/src/types.ts` | `AppConfig`, `ExecMode`, domain types |
| `apps/web/src/state/config.ts` | `loadConfig` / `saveConfig` / `syncConfigToDaemon` |
| `apps/web/sidecar/server.ts` | Next.js host + daemon proxy |

## Notable `src/` directories

`components/` (incl. `Theater/` = Critique review — see its `AGENTS.md`), `providers/` (data fetching: `registry.ts`, `daemon.ts`), `state/`, `hooks/`, `router.ts`, `types.ts`, `i18n/` (18 languages), `media/`, `analytics/`, `observability/`, `artifacts/`, `edit-mode/`, `styles/`, `lib/`.
