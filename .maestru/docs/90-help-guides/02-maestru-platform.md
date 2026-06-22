---
maestru: "0.4"
type: doc
id: 02-maestru-platform
title: "Maestru Platform Guide"
description: "Guide to the Maestru cloud workspace — tabs, sections, and workflows"
created: 2026-06-22
updated: 2026-06-22
tags: [maestru, platform, workspace]
---

# Maestru Platform Guide

<!-- maestru:summary -->
The Maestru platform is a cloud workspace for building projects with AI. It provides terminals, previews, AI coding tabs, database management, and deployment — all in one interface.
<!-- /maestru:summary -->

## Overview

When you open a project in Maestru, you get a workspace with a sidebar of tabs organized into four sections: **Plan**, **Agents**, **Build**, and **Settings**. Each tab serves a specific purpose in the development workflow.

## Plan

Tools for understanding and organizing your project.

### Work Items

**Goal:** Track what needs to be done and what's already done.

The visual interface for MaestruMD. Browse work tracks, view item statuses and priorities, navigate to specs, and update progress. This is where you go to see the big picture of your project — what's in backlog, what's in progress, and what's complete.

### File Browser

**Goal:** Explore and manage project files without leaving the workspace.

A unified file explorer with upload, delete, and inline editing capabilities. Use it to browse the project structure, open files for editing, and manage assets. Replaces the need for a separate file manager.

## Agents

AI-powered tools that understand your project and write code.

### Agent tabs

**Goal:** chat-based AI coding in the workspace. Open an Agent tab to describe what you want to build, ask questions about the codebase, or run multi-step coding tasks. Each tab is an isolated session; run several in parallel for different parts of the project, or for different AI coding tools side by side.

> Requires an account and API key or subscription with the AI provider of your choice. Supported providers are pre-installed in your Buildbox.

### Workstreams

**Goal:** work on multiple branches and agent sessions simultaneously, each in an isolated copy of the repository.

A Workstream is an isolated working directory on a specific branch — backed by a git worktree — with its own terminals, agents, and Git tab scoped to that branch. Use Workstreams to:

- Run a bug fix on `main` in parallel with an in-progress feature branch, without stashing or losing state.
- Dispatch a work item to an AI agent on a dedicated branch and keep working on something else.
- Compare two approaches side by side, each in its own Workstream.

The **Workstreams** tab is where you create, list, archive, and switch between them.

## Build

Development, runtime, and deployment tools for building and shipping your app.

### Terminal

**Goal:** Run shell commands in a full terminal environment.

Standard shell terminal sessions. Each instance is a separate shell with its own state. Use for installing packages, running scripts, debugging, git commands, or anything you'd do in a local terminal. You can open multiple terminals for parallel workflows.

### Preview

**Goal:** See your running app in real time as you develop.

Live preview of your dev server, typically showing the app on port 3000. Updates automatically when you save files thanks to Vite's hot module replacement (HMR). This is how you visually verify your changes without switching to a browser.

### Console

**Goal:** Monitor your application's runtime output and logs.

Streams stdout/stderr from your running processes in real time. Use it to see server startup messages, API request logs, errors, and debug output. When something goes wrong, the Console tab is usually the first place to check.

### Database

**Goal:** Explore and manage your database visually.

A built-in database explorer that connects to the PostgreSQL instance configured in your environment variables. Browse tables, view and edit data, and run queries — all without needing an external SQL client like pgAdmin or TablePlus.

### Version Control

**Goal:** Manage git operations visually — stage, commit, branch, and diff.

A visual git interface for everyday version control operations. View changed files, stage/unstage changes, write commit messages, create and switch branches, and view diffs. A more accessible alternative to running git commands in the terminal.

### Secrets

**Goal:** Manage environment variables for your project.

An editor for `.env` files. View and modify environment variables like `DATABASE_URL`, `PORT`, and `CORS_ORIGIN`. Changes are written to the `.env` files and take effect when you restart the dev server. Keeps sensitive configuration out of your code.

### Review

**Goal:** Inspect code changes before committing or creating pull requests.

A diff viewer that shows all your changes in a reviewable format. Use it to double-check your work, catch unintended changes, and ensure code quality before committing.

### Publishing

**Goal:** Deploy your app to production via Railway.

Manages Railway deployments from within the workspace. Deploy your app, monitor deployment status, view build and deploy logs, and manage production settings. Works with the `railway.toml` configuration files in `apps/web/` and `apps/api/`.

## Settings

Configuration for the workspace and AI agents.

### Agent Skills

**Goal:** Customize what AI agents can do in your project.

Configure capabilities and extensions for the Agent tabs — add custom tools, enable or disable behaviors, and tailor the AI experience to your project's needs.

### Project Settings

**Goal:** Configure project-level settings and processes.

Manage the `maestru.yaml` configuration — process definitions (setup commands, dev server, ports), and other project-wide settings that control how Maestru runs your project.

## Key Files

| File | Purpose |
|------|---------|
| `maestru.yaml` | Process definitions — what Maestru runs on project open and for dev server |
| `railway.toml` | Railway deployment configuration (one per app) |
| `.env` | Environment variables (managed via the **Secrets** tab) |
| `.claude/settings.json` | Claude Code permissions and allowed commands |
| `CLAUDE.md` / `AGENTS.md` | Agent instructions — loaded automatically by AI agents |
