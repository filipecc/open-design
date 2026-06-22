---
maestru: "0.4"
type: doc
id: 01-app-shell-and-routing
title: "App Shell & Routing"
description: "App.tsx as the entry/shell, the custom URL router (useRoute/navigate, no react-router), and the onboarding gate that blocks the app"
tags: [web, routing, app-shell, onboarding, router]
created: 2026-06-22
updated: 2026-06-22
---

# App Shell & Routing

<!-- maestru:summary -->
The web app's entry and shell is apps/web/src/App.tsx (2300+ lines): it loads config on mount, manages top-level state and the config lifecycle, and dispatches the current Route to a view (MarketplaceView, PluginDetailView, DesignSystemCreationFlow, ProjectView, or the EntryView/EntryShell home). Routing avoids react-router via a tiny custom router in apps/web/src/router.ts: a Route union type (home with view='onboarding'|'projects'|'tasks'|'plugins', project, marketplace, design-system-*), a useRoute() hook subscribing to popstate, and navigate(route,{replace}) which updates the URL and broadcasts via a microtask-deferred popstate event. parseRoute/buildPath convert URL↔Route and support deep links (e.g. /projects/:id/conversations/:cid/files/:fileName, /brands/:id). The onboarding gate lives here: App.tsx checks config.onboardingCompleted and, when the home view is active but onboarding is incomplete, auto-navigates to the onboarding view; completion (handleCompleteOnboarding) sets onboardingCompleted:true and persists via saveConfig+syncConfigToDaemon.
<!-- /maestru:summary -->

## Entry / shell — `App.tsx`

`apps/web/src/App.tsx` is the entry point and top-level shell (2300+ lines). It:
- loads config on mount (`loadConfig()`), tracks `daemonConfigLoaded`,
- reads the current route via `useRoute()` and **dispatches** to a view (`MarketplaceView`, `PluginDetailView`, `DesignSystemCreationFlow`, `ProjectView`, or the home `EntryView` → `EntryShell`),
- owns the config-persist lifecycle (`saveConfig` + `syncConfigToDaemon`).

## Routing — `router.ts` (no react-router)

A deliberately tiny URL router (`apps/web/src/router.ts`):
- **`Route` union** — `home` (with `view`: `'onboarding' | 'projects' | 'tasks' | 'plugins'`), `project`, `marketplace`, `design-system-*`.
- **`useRoute()`** — subscribes to `popstate`, returns the current `Route`.
- **`navigate(route, { replace })`** — updates the URL and broadcasts to subscribers via a microtask-deferred `popstate` event.
- **`parseRoute(pathname)` / `buildPath(route)`** — URL ↔ Route conversion; supports deep links like `/projects/:id/conversations/:cid/files/:fileName` and `/brands/:id`.

## The onboarding gate

This is the only thing standing between a fresh load and the app:
- `App.tsx` checks `config.onboardingCompleted`.
- If the home view is active and onboarding is incomplete, it **auto-navigates to the onboarding view** (`navigate({kind:'home', view:'onboarding'}, {replace:true})`).
- Completion (`handleCompleteOnboarding`) sets `onboardingCompleted: true` and persists via `saveConfig` + `syncConfigToDaemon`.

The gate is **onboarding, not authentication** — see [02-onboarding-and-auth-ui.md](./02-onboarding-and-auth-ui.md) and [../02-architecture/03-security-and-origin-model.md](../02-architecture/03-security-and-origin-model.md).
