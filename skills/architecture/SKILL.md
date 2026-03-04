---
name: architecture
description: This skill should be used when defining application architecture, choosing a tech stack, deciding on project structure, or when the user says "define architecture", "choose tech stack", "what stack", "project structure", "app type", "set up the project"
version: 0.2.0
---

# Architecture Skill

Methodology for defining application architecture, tech stack, and holistic application structure before implementation begins.

## Core Principles

1. **Product-Driven**: Architecture decisions flow from product requirements (personas, features, KPIs), not technology preferences
2. **Detect Before Asking**: Always scan the codebase first — skip questions that can be answered from existing files
3. **Appropriate Complexity**: Recommend the simplest architecture that serves the product. Monoliths before microservices. Simple state before complex state.
4. **Holistic View**: Don't just pick a stack — define the full shape of the application (pages, navigation, interactions, data patterns)
5. **Extensible Stack Model**: Pattern references are modular. The system supports any stack via pluggable pattern files.

## Decision Frameworks

### Application Type Selection

Choose based on:
- **Who are the users?** End users → Web App or Mobile. Developers → API or CLI. Internal team → Web App (admin).
- **How do they access it?** Browser → Web App or SSR. Terminal → CLI. App store → Mobile. Programmatically → API/Library.
- **What's the interaction model?** CRUD data management → Web App. Real-time collaboration → Web App + WebSocket. Automation → CLI or API.

### Architecture Pattern Selection

| Signal | Recommendation |
|--------|---------------|
| Early stage, small team, < 10 features | Monolith |
| Growing codebase, clear domain boundaries | Modular Monolith |
| Multiple teams, independent deployment needed | Microservices |
| Event-driven, variable load, cost-sensitive | Serverless |
| Content-heavy, SEO-critical | Static + API (JAMstack) |

**Default to Monolith** unless there's a specific reason not to. Premature distribution is the most common architectural mistake.

### Tech Stack Selection

Prioritize:
1. **What the team knows** — familiarity beats theoretical superiority
2. **What's detected in the codebase** — if code already exists, follow it
3. **What the product needs** — real-time → consider WebSocket-friendly stacks; ML-heavy → consider Python
4. **Ecosystem fit** — choose stacks where the ORM, testing, deployment tools work well together

### Application Structure Exploration

The deep structure exploration (Phase 3) is the most valuable part. It transforms abstract features into a concrete application shape. Key principles:

- **Start with pages/screens** — these are the user-facing entry points
- **Navigation reveals information architecture** — how pages relate tells you about the app's mental model
- **Layout defines the frame** — sidebar vs top-nav vs minimal dramatically affects UX
- **Auth flow is load-bearing** — it affects every page and API endpoint
- **Interactions define complexity** — CRUD is simple, real-time sync is complex, offline-first is very complex

## How Pattern References Work

Pattern references live in `skills/implementation/references/` organized by layer (`backend/`, `frontend/`, `common/`). The implementer agent resolves the correct file based on architecture context: specific pattern → generic fallback → built-in knowledge.

See `references/stack-catalog.md` for the full directory structure, resolution order, and extensibility guide.

## Architecture Context File

The output is `.claude/architecture.md` — a single file that every downstream agent reads:

- **spec-writer** uses it for Test Strategy section (correct framework names)
- **implementer** uses it for code generation (correct patterns, project structure)
- **unit-tester** uses it for test framework and assertion patterns
- **e2e-tester** uses it for app URLs and startup commands
- **spec-verifier** uses it for pattern validation

This file is the bridge between "what to build" (product-context.md + specs) and "how to build it" (code generation).
