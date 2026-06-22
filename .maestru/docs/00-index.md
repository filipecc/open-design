---
maestru: "0.4"
type: doc
id: 00-index
title: "OpenDesign"
description: "Project documentation"
created: 2026-06-22
updated: 2026-06-22
---

# OpenDesign

<!-- maestru:summary -->
Welcome to your new project! This is a blank starting point — add your code and documentation as you build.
<!-- /maestru:summary -->

## Getting Started

1. Configure your dev server in `maestru.yaml`
2. Add your code
3. Document your architecture in `.maestru/docs/`

## Configuration

### maestru.yaml

Uncomment and configure the process definitions when you're ready:

```yaml
processes:
  setup:
    command: npm install       # runs on project open
  run:
    command: npm run dev       # main dev process
    port: 3000                 # port for Preview tab
```

## Documentation

Use `.maestru/docs/` to document your project as it grows:
- Architecture decisions and diagrams
- API specifications
- Development guides and conventions

Run `maestru search <query>` to find docs, and `maestru check` to validate them.
