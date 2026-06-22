---
maestru: "0.4"
type: doc
id: 00-overview
title: "Running in Maestru — Overview"
description: "How this fork runs inside the Oktogon/Maestru hosted environment: proxied web app, fork remotes, the Maestru layer, and deployment options"
tags: [running, maestru, oktogon, hosted, overview]
created: 2026-06-22
updated: 2026-06-22
---

# Running in Maestru — Overview

<!-- maestru:summary -->
This section documents how the fork is operated inside the Oktogon/Maestru hosted environment, as opposed to a developer's laptop or a packaged desktop install. The repo lives at /app inside a container; the app is reached through a public reverse proxy (https://opendesign.<id>.maestru.dev) that forwards to the web sidecar. Running here requires binding the web sidecar to 0.0.0.0 and trusting the public origin at both the web and daemon layers — captured in scripts/dev-web.sh and the proxied-dev-environment runbook. The fork is wired with origin=filipecc/open-design and upstream=nexu-io/open-design so customizations push to our fork and upstream improvements merge in. Maestru is layered on top of the upstream tree (.maestru/, maestru.yaml, dual-import CLAUDE.md) without forking upstream's own files. Deployment options beyond tools-dev (Docker, Sealos, source) are summarized for when we move past dev mode. Read 01 for the exact run command and troubleshooting, 02 for the upstream-sync model, 03 for the Maestru layer, 04 for deployment.
<!-- /maestru:summary -->

How this fork is operated inside the **Oktogon/Maestru hosted environment** — distinct from a laptop dev setup or a packaged desktop install.

- The repo is at **`/app`** inside a container; the app is reached via a **public reverse proxy** `https://opendesign.<id>.maestru.dev`.
- Running here needs the web sidecar on `0.0.0.0` and the public origin trusted at **both** the web and daemon layers.

## In this section

| Doc | Purpose |
|-----|---------|
| [01-proxied-dev-environment.md](./01-proxied-dev-environment.md) | The exact run command, the three env vars, and 502/403 troubleshooting |
| [02-fork-and-upstream-sync.md](./02-fork-and-upstream-sync.md) | `origin`/`upstream` remotes and how upstream improvements merge in |
| [03-maestru-layer.md](./03-maestru-layer.md) | How `.maestru/` is layered on the upstream tree |
| [04-deployment-options.md](./04-deployment-options.md) | Docker / Sealos / source beyond dev mode |

## Fast path

```bash
scripts/dev-web.sh            # port 3000, public host baked in
# → open https://opendesign.<id>.maestru.dev/
```

If `/api` calls 403 or the page 502s, go straight to [01-proxied-dev-environment.md](./01-proxied-dev-environment.md).
