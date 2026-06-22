---
maestru: "0.4"
type: doc
id: 04-cloud-amr-vela
title: "Cloud — AMR / Vela"
description: "The Open Design Cloud path: the AMR runtime via the vela CLI, device-auth login, model gating, and why it 500s without an account"
tags: [agents, cloud, amr, vela, acp]
created: 2026-06-22
updated: 2026-06-22
---

# Cloud — AMR / Vela

<!-- maestru:summary -->
"Open Design Cloud" is the AMR (Agent Model Runtime) path, driven by the vela CLI and defined in apps/daemon/src/runtimes/defs/amr.ts. AMR is an OpenRouter-compatible gateway that dispatches to many remote models, speaking ACP JSON-RPC over stdio like the other ACP agents. Login is device-auth: the daemon's /api/vela/* routes (routes/vela.ts) spawn `vela login`, which writes credentials (~/.amr/config.json); status is read back from disk. Running uses `vela agent run --runtime opencode`, which starts a private OpenCode server and forwards stream-json over ACP; it requires env like VELA_RUNTIME_KEY (OpenRouter key) and VELA_LINK_URL. Models come from `vela models`; vela strictly rejects session/prompt until session/set_model is called, and public model ids are normalized to link slugs. In our hosted environment there is no Cloud account, so /api/amr/models returns 500 and the Cloud sign-in cannot complete — this is expected and harmless; use Local agent or BYOK instead. The mock vela (mocks/lib/format-vela.mjs) implements login/models with error-injection envs for tests.
<!-- /maestru:summary -->

"Open Design Cloud" is the **AMR (Agent Model Runtime)** path, driven by the **`vela` CLI**. Definition: `apps/daemon/src/runtimes/defs/amr.ts`.

## What AMR is

An OpenRouter-compatible gateway dispatching to many remote models. Like the other cloud-ish agents, it speaks **ACP JSON-RPC over stdio**.

## Login (device-auth)

The daemon's `/api/vela/*` routes (`apps/daemon/src/routes/vela.ts`):
- `POST /api/vela/login` → spawns `vela login` (device-auth); credentials are written to `~/.amr/config.json`.
- `GET /api/vela/status` → reads login status from disk.

The credential file is managed by `vela`, not by Open Design — the daemon just spawns the process and reads the result.

## Running & models

- `vela agent run --runtime opencode` starts a private OpenCode server and forwards stream-json over ACP. Needs env like `VELA_RUNTIME_KEY` (OpenRouter key) and `VELA_LINK_URL`.
- `vela models` lists models; `vela` **rejects `session/prompt` until `session/set_model`** is called. Public model ids are normalized to link slugs (`normalizeVelaModelId`).

## In our environment: expected 500

There is **no Open Design Cloud account** on this box, so `/api/amr/models` returns **500** and Cloud sign-in can't complete. This is expected and harmless — use **Local coding agent** ([02-claude-code.md](./02-claude-code.md)) or **BYOK** ([03-byok-providers.md](./03-byok-providers.md)). Documented in [../85-audits/01-auth-and-origin-analysis-2026-06.md](../85-audits/01-auth-and-origin-analysis-2026-06.md).

## Mock

`mocks/lib/format-vela.mjs` implements `vela login` / `vela models` with error-injection envs (`FAKE_VELA_*`) for tests — see [05-mocks.md](./05-mocks.md).
