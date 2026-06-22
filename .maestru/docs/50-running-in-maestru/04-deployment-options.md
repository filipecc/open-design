---
maestru: "0.4"
type: doc
id: 04-deployment-options
title: "Deployment Options"
description: "Ways to run Open Design beyond tools-dev — Docker Compose, Sealos, packaged desktop — and how each interacts with the proxy/origin model"
tags: [running, deployment, docker, sealos, desktop]
created: 2026-06-22
updated: 2026-06-22
---

# Deployment Options

<!-- maestru:summary -->
Open Design can run several ways; our hosted setup currently uses tools-dev (dev mode) behind the maestru.dev proxy. Other options: the packaged desktop app (Electron, zero-config, auto-detects agent CLIs, the recommended end-user path); from source (corepack + pnpm install + pnpm tools-dev run web — what we use); Docker Compose (deploy/ dir: copy .env.example, set OD_API_TOKEN via openssl rand, docker compose up -d — the right path for a real hosted server because it pairs a non-loopback bind with token auth); and Sealos one-click cloud via an App Store template. For any non-loopback deployment the security model flips on: the daemon then REQUIRES OD_API_TOKEN to bind a public host, and OD_ALLOWED_ORIGINS/OD_BIND_HOST/OD_DATA_DIR must be set deliberately per deploy/README.md. Moving the Oktogon Design Partner from dev mode to a Docker deployment with a real token and persistent OD_DATA_DIR is the natural next infrastructure step; this doc indexes the options, deploy/README.md is authoritative for the container path.
<!-- /maestru:summary -->

Our hosted setup currently runs **`tools-dev` (dev mode)** behind the proxy ([01-proxied-dev-environment.md](./01-proxied-dev-environment.md)). Other options:

| Option | What | When |
|--------|------|------|
| **Packaged desktop** | Electron app, zero-config, auto-detects agent CLIs | End-user / local laptop |
| **From source** | `corepack enable && pnpm install` → `pnpm tools-dev run web` | Development (what we use) |
| **Docker Compose** | `deploy/` dir — `.env` + `docker compose up -d` | A real hosted server |
| **Sealos** | One-click cloud via App Store template | Quick cloud trial |

## Docker (the path to a real deployment)

```bash
cd deploy
cp .env.example .env
echo "OD_API_TOKEN=$(openssl rand -hex 32)" >> .env
docker compose up -d
```

`deploy/README.md` is **authoritative** for the container path. Set `OD_BIND_HOST`, `OD_ALLOWED_ORIGINS`, and a persistent `OD_DATA_DIR`.

## Security model flips on for non-loopback deploys

The moment the daemon binds a non-loopback host, the model changes (see [../02-architecture/03-security-and-origin-model.md](../02-architecture/03-security-and-origin-model.md)):
- the daemon **requires `OD_API_TOKEN`** to bind a public host,
- token middleware enforces `Authorization: Bearer` on non-loopback callers,
- `OD_ALLOWED_ORIGINS` still governs browser-origin trust.

> Note this still does **not** add front-door auth to the *web app* — that gap (and the Oktogon Design Partner access-control requirement) is tracked in [../02-architecture/03-security-and-origin-model.md](../02-architecture/03-security-and-origin-model.md) and [../01-product/03-open-questions.md](../01-product/03-open-questions.md).

## Next step for us

Promoting from dev mode to a **Docker deployment with a real `OD_API_TOKEN` and persistent `OD_DATA_DIR`** is the natural next infrastructure move once the fork stabilizes.
