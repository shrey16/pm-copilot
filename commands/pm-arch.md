---
description: Define application architecture, tech stack, and application structure through interactive exploration
allowed-tools: Read, Write, Edit, Glob, Grep, Agent
argument-hint: [app-type]
---

# Architecture Definition

Create `.claude/architecture.md` through auto-detection and interactive exploration.

## Important Rules

- **Always use `AskUserQuestion`** — never ask questions as plain text. Provide 2-4 MCQ options.
- **Always recommend one option.** First option = recommended with "(Recommended)" label. Description explains WHY.
- **Ask ONE question at a time** unless grouping tightly related questions (max 2 per round).
- **Never assume answers.** Follow up on vague responses.
- **Skip what you can infer.** Use Phase 1 detection results to pre-fill or skip questions entirely.
- **Use $ARGUMENTS as app type** if provided (e.g., "saas", "api", "cli", "game").
- **Check for existing architecture.** If `.claude/architecture.md` exists, offer Update or Start fresh.
- **Do NOT use EnterPlanMode, ExitPlanMode, or Skill tool.**

---

## Phase 0: Prerequisites Check

1. Check if `.claude/product-context.md` exists. If NOT → tell the user: "No product context found. Run `/pm-copilot:pm-init` first to set up product context." Then STOP.

2. If product context exists, read it. Extract: product name, one-liner, vision, personas, feature backlog, technical constraints.

3. Check if `.claude/architecture.md` exists.

**If the file EXISTS:**

Use `AskUserQuestion`:

> "An architecture definition already exists for this project. How would you like to proceed?"

| Option | Label | Description |
|--------|-------|-------------|
| 1 (Recommended) | Update | Keep existing decisions. Re-scan codebase and update sections that have changed. Run Q&A only for fields that are missing or need updating. |
| 2 | Start fresh | Discard existing architecture.md and rebuild from scratch. Full scan + full Q&A. |

Store choice as **ARCH_MODE** (`update` or `start-fresh`).

- **Update**: In Phase 2/3, skip questions whose answers already exist and haven't changed. In Phase 4, merge new data into existing file.
- **Start fresh**: Full Phase 1-4. Overwrite existing file.

**If the file does NOT exist:**

Set ARCH_MODE to `new`. Proceed to Phase 1.

---

## Phase 1: Auto-Detect Stack (silent, no output)

Output the message: "Scanning codebase for tech stack and project structure..."

Use the `Agent` tool with `subagent_type: "Explore"` to scan the codebase. Pass the following instructions:

---

**Subagent instructions (copy verbatim into the Agent prompt):**

> You are a tech stack detector. Scan this project and return structured JSON describing the tech stack.
>
> **Security rules — NEVER read or report contents of:** `.env`, `.env.*`, `credentials.*`, `secrets.*`, `*.key`, `*.pem`, or any file whose name contains "secret", "password", or "token".
>
> **Cross-platform path rules:** Use forward slashes in all glob patterns.
>
> **Instructions:**
> 1. Read the detection patterns from `${CLAUDE_PLUGIN_ROOT}/skills/architecture/references/stack-catalog.md` — it contains file→framework mappings for backend, frontend, database, ORM, UI, testing, deployment, and monorepo detection.
> 2. For each detection pattern, use Glob to check if the file exists. For `package.json`, read it to check dependencies.
> 3. List top-level directories (max 2 levels deep). Check for `src/`, `app/`, `lib/`, `server/`, `client/`, `api/`, `web/`, `mobile/`.
> 4. Count test files: `*.test.*`, `*.spec.*`.
>
> **Return ONLY this JSON:**
> ```json
> {
>   "language": "TypeScript|Python|Go|Rust|Ruby|Java|C#|PHP|unknown",
>   "backend_framework": "nestjs|express|fastify|fastapi|django|flask|rails|gin|asp-dotnet|none|unknown",
>   "frontend_framework": "react|nextjs|vue|nuxt|angular|svelte|sveltekit|remix|astro|none|unknown",
>   "database": "postgresql|mysql|mongodb|sqlite|firebase|supabase|none|unknown",
>   "orm": "prisma|typeorm|drizzle|sequelize|mongoose|sqlalchemy|activerecord|none|unknown",
>   "ui_library": "tailwind|mui|antd|chakra|shadcn|styled-components|emotion|none|unknown",
>   "test_framework": "jest|vitest|playwright|cypress|pytest|none|unknown",
>   "test_file_count": 0,
>   "deployment": "docker|vercel|netlify|serverless|kubernetes|fly|railway|render|heroku|none|unknown",
>   "monorepo": "nx|turbo|lerna|pnpm-workspaces|none",
>   "package_manager": "npm|yarn|pnpm|bun|pip|poetry|cargo|go-mod|bundler|composer|unknown",
>   "project_structure": ["list", "of", "top-level", "dirs"],
>   "detected_configs": ["list of config files found"],
>   "notes": "any additional observations"
> }
> ```

---

**After the subagent returns:**

1. Parse the JSON output. Store as **DETECTED_STACK**.
2. Do not print raw JSON to the user.
3. Proceed to Phase 2.

---

## Phase 2: Stack & Architecture Q&A

Ask one question at a time via `AskUserQuestion`. Use DETECTED_STACK to set recommended options and skip fully-determined questions.

**Skip rules**: If a DETECTED_STACK field is NOT "unknown" or "none", use that as the recommended option. If the detection is unambiguous AND ARCH_MODE is `update` with an existing answer that matches, skip entirely.

---

### Q1: Application Type

**Header**: "App type"

**Question**: "What type of application are you building?"

**Skip if**: $ARGUMENTS explicitly specifies app type.

**Adaptation**: Use product context (vision, personas, features) to set the recommended option:
- If personas mention "end users" + features include UI components → recommend "Web App"
- If personas mention "developers" + features are all API routes → recommend "API-only"
- If features include CLI commands and no UI → recommend "CLI Tool"

| Option | Label | Description |
|--------|-------|-------------|
| 1 | Web App (SaaS / Dashboard) | Browser-based application with user accounts, data management, and interactive UI. Most common for B2B and B2C products. |
| 2 | API / Backend Only | REST or GraphQL API consumed by external clients. No built-in UI — clients are mobile apps, third-party integrations, or separate frontends. |
| 3 | CLI Tool | Command-line application. Terminal-based interface, typically for developer tools or automation. |
| 4 | Full-Stack with SSR | Server-rendered web app (Next.js, Nuxt, SvelteKit). SEO-friendly, faster initial load, server + client code in one project. |

If the user selects "Other", also support: Mobile App (React Native), Browser Extension, Desktop App (Electron), Library/SDK, Game (web-based).

Store answer as **APP_TYPE**.

---

### Q2: Architecture Pattern

**Header**: "Architecture"

**Question**: "What architecture pattern fits your needs?"

**Adaptation**:
- If DETECTED_STACK.monorepo is not "none" → recommend "Modular Monolith" or "Monorepo Multi-App"
- If product stage is "Pre-launch" or "Beta" → recommend "Monolith"
- If feature count > 20 shipped → suggest "Modular Monolith"

| Option | Label | Description |
|--------|-------|-------------|
| 1 (Recommended) | Monolith | Single deployable unit. Simplest to develop, test, and deploy. Best for most projects, especially early stage. |
| 2 | Modular Monolith | Single deployment but internal module boundaries. Good balance of simplicity and organization for growing projects. |
| 3 | Microservices | Multiple independently deployable services. Only for teams with operational maturity. Adds complexity. |
| 4 | Serverless Functions | Individual functions deployed to cloud (AWS Lambda, Vercel Functions). Best for event-driven, low-traffic, or cost-sensitive workloads. |

Store as **ARCH_PATTERN**.

---

### Q3: Backend Stack

**Header**: "Backend"

**Question**: "What backend technology will you use?"

**Skip if**: DETECTED_STACK.backend_framework is not "unknown".

**Adaptation**: Use DETECTED_STACK.backend_framework as recommended option. If detected, show: "We detected {framework} in your project. Confirm or change?"

| Option | Label | Description |
|--------|-------|-------------|
| 1 | NestJS (TypeScript) | Opinionated, modular Node.js framework. Great for structured APIs. Best documentation support in this tool. |
| 2 | Express (TypeScript) | Minimal Node.js framework. Maximum flexibility, less structure. |
| 3 | FastAPI (Python) | Modern Python framework. Automatic OpenAPI docs, type hints, async. |
| 4 | Django (Python) | Batteries-included Python framework. ORM, admin, auth built in. |

If "Other": support Rails (Ruby), Go (net/http, Gin, Fiber), ASP.NET Core (C#), Fastify, Hono, None (frontend-only).

Store as **BACKEND_STACK**.

---

### Q4: Frontend Stack

**Header**: "Frontend"

**Question**: "What frontend technology will you use?"

**Skip if**: DETECTED_STACK.frontend_framework is not "unknown". Also skip if APP_TYPE is "API-only" or "CLI Tool" — set to "None".

| Option | Label | Description |
|--------|-------|-------------|
| 1 | React + Vite (TypeScript) | Most popular component library. Huge ecosystem. Best documentation support in this tool. |
| 2 | Next.js (React SSR) | React with server-side rendering. SEO-friendly, file-based routing, API routes built in. |
| 3 | Vue + Vite (TypeScript) | Approachable, well-documented. Great for teams that prefer simplicity. |
| 4 | Angular | Full framework with DI, RxJS, forms. Opinionated. Good for large enterprise apps. |

If "Other": support Nuxt, Svelte, SvelteKit, Remix, Astro, None.

Store as **FRONTEND_STACK**.

---

### Q5: Data Layer

**Header**: "Data layer"

**Question**: "What's your data layer strategy?"

**Skip if**: DETECTED_STACK.database is not "unknown" AND DETECTED_STACK.orm is not "unknown".

**Adaptation**: Use detected database + ORM as recommended.

| Option | Label | Description |
|--------|-------|-------------|
| 1 | PostgreSQL + Prisma | Most versatile relational DB + modern type-safe ORM. Great developer experience. |
| 2 | PostgreSQL + TypeORM | Mature ORM with decorator-based entities. Common in NestJS projects. |
| 3 | MongoDB + Mongoose | Document database. Flexible schema. Good for unstructured or rapidly changing data. |
| 4 | SQLite (embedded) | File-based database. Zero setup. Good for local-first apps, CLIs, small projects. |

If "Other": support MySQL, Firebase, Supabase, Drizzle, Sequelize, SQLAlchemy, None (stateless).

Store as **DATA_LAYER**.

---

### Q6: UI Foundation

**Header**: "UI library"

**Question**: "What design system or UI library?"

**Skip if**: APP_TYPE is "API-only", "CLI Tool", or "Library/SDK" — set to "None". Also skip if DETECTED_STACK.ui_library is not "unknown".

| Option | Label | Description |
|--------|-------|-------------|
| 1 | Tailwind CSS | Utility-first CSS. Maximum flexibility. Pairs well with any component library. |
| 2 | shadcn/ui + Tailwind | Copy-paste component library built on Radix + Tailwind. Accessible, customizable. |
| 3 | Material UI (MUI) | Google's design system for React. Rich component set. Opinionated styling. |
| 4 | Ant Design | Enterprise UI library. Comprehensive component set. Popular for admin dashboards. |

If "Other": support Chakra UI, Headless UI, Custom / None, DaisyUI.

Store as **UI_LIBRARY**.

---

### Q7: Deployment

**Header**: "Deployment"

**Question**: "How will this be deployed?"

**Skip if**: DETECTED_STACK.deployment is not "unknown".

| Option | Label | Description |
|--------|-------|-------------|
| 1 | Docker + Cloud (VPS) | Containerized deployment to any cloud. Most flexible. Works with AWS, GCP, Azure, DigitalOcean. |
| 2 | Vercel / Netlify | Platform deployment. Zero-config for Next.js, Nuxt, static sites. Built-in CI/CD. |
| 3 | Railway / Render / Fly.io | PaaS deployment. Simple but flexible. Good for full-stack apps with databases. |
| 4 | Not decided yet | Skip for now. Can be defined later. |

If "Other": support AWS Lambda / Serverless, Kubernetes, Heroku, Self-hosted, Local only.

Store as **DEPLOYMENT**.

---

## Phase 3: Deep Application Structure Exploration

This phase understands the *shape* of the application — pages, navigation, interactions, data patterns. The questions adapt based on APP_TYPE.

Output: "Now let's define the structure of your application..."

**Use `AskUserQuestion` for each question, one at a time.** Provide concrete options based on the product context (features, personas) wherever possible.

---

### Branch A: Web App / Full-Stack / Full-Stack SSR

Ask all 12 questions in order. Group tightly related pairs (max 2 per `AskUserQuestion` call).

**Q1 — Pages**
- Header: "Pages"
- Question: "What are the main pages or screens in the app? Select the ones that apply, or describe your own."
- Adapt: Generate options from feature backlog. E.g., if backlog has "User Management" → suggest "Users page". Always include "Dashboard" and "Settings" as common options.
- multiSelect: true
- Options: Derive 3-4 from product context features. Always allow "Other" for custom input.

**Q2 — Navigation**
- Header: "Navigation"
- Question: "What's the primary navigation pattern?"
- Options: "Sidebar + top bar (Recommended)" / "Top navigation only" / "Tab bar (bottom)" / "Minimal (logo + user menu only)"
- Adaptation: If many pages (5+) → recommend sidebar. If few (2-3) → recommend top nav.

**Q3 — Layout**
- Header: "Layout"
- Question: "Describe the main layout structure."
- Options: "Fixed sidebar + scrollable content (Recommended)" / "Full-width with collapsible sidebar" / "Top nav + centered content (max-width)" / "Multi-panel (like email client — list + detail)"

**Q4 — Auth Flow**
- Header: "Auth flow"
- Question: "How does authentication work?"
- Options: "Email + password login page (Recommended)" / "OAuth only (Google, GitHub, etc.)" / "Magic link (passwordless email)" / "No authentication needed"
- Adaptation: If personas mention "enterprise" → suggest OAuth/SSO.

**Q5 — User Roles**
- Header: "Roles"
- Question: "Are there different user roles with different access levels?"
- Options: "Single role — all users see everything (Recommended for MVP)" / "Admin + Regular User" / "Multiple roles (Admin, Manager, User, Viewer)" / "Custom roles (user-defined permissions)"

**Q6 — Key Interactions**
- Header: "Interactions"
- Question: "What are the primary user interactions? Select all that apply."
- multiSelect: true
- Options: "CRUD forms (create, read, update, delete)" / "Data tables with filtering and sorting" / "Real-time updates (live feeds, notifications)" / "File uploads and media management"
- Adapt from feature backlog.

**Q7 — Data Display**
- Header: "Data display"
- Question: "How is data primarily displayed to users?"
- multiSelect: true
- Options: "Tables and lists (Recommended)" / "Cards or grid layout" / "Charts, graphs, and dashboards" / "Timeline or activity feed"

**Q8 — Responsive**
- Header: "Devices"
- Question: "What devices must be supported?"
- Options: "Desktop only (Recommended for admin/B2B tools)" / "Desktop + tablet" / "Fully responsive (desktop, tablet, mobile)" / "Mobile-first"

**Q9 — Theming**
- Header: "Theming"
- Question: "Any theming requirements?"
- Options: "Light mode only (Recommended — simplest)" / "Light + dark mode toggle" / "System preference auto-detect" / "Brand-specific / white-label"

**Q10 — Notifications**
- Header: "Notifications"
- Question: "How does the app communicate with users?"
- multiSelect: true
- Options: "In-app toast notifications (Recommended)" / "Email notifications" / "Real-time via WebSocket" / "None for now"

**Q11 — State Complexity**
- Header: "State"
- Question: "What's the state management complexity?"
- Options: "Simple server state — fetch, display, mutate (Recommended)" / "Complex client state — drag-and-drop, multi-step wizards, undo/redo" / "Real-time sync — multiple users editing simultaneously" / "Offline-first — works without internet"
- Adaptation: If APP_TYPE is "Full-Stack SSR" → bias toward "Simple server state".

**Q12 — External Integrations**
- Header: "Integrations"
- Question: "External services to integrate with? Select all that apply."
- multiSelect: true
- Options: "None yet (Recommended — keep it simple)" / "Payment processing (Stripe, etc.)" / "Email service (SendGrid, Resend, etc.)" / "File storage (S3, Cloudflare R2, etc.)"

Store all answers as **APP_STRUCTURE**.

---

### Branch B: API / Backend Only

**Q1 — Resources**
- Header: "Resources"
- Question: "What are the main API resources or entities?"
- Adapt: Generate from feature backlog entities. multiSelect: true.
- Options: Derive 3-4 from product context. Allow "Other".

**Q2 — API Style**
- Header: "API style"
- Question: "What API style?"
- Options: "REST (Recommended)" / "GraphQL" / "gRPC" / "REST + GraphQL hybrid"

**Q3 — Versioning**
- Header: "Versioning"
- Question: "API versioning strategy?"
- Options: "URL prefix /api/v1 (Recommended)" / "Header-based (Accept-Version)" / "No versioning (single version)" / "Query parameter (?v=1)"

**Q4 — Auth**
- Header: "Auth"
- Question: "Authentication method?"
- Options: "JWT Bearer tokens (Recommended)" / "API key (header)" / "OAuth2 (third-party apps)" / "No auth (public API)"

**Q5 — Rate Limiting**
- Header: "Rate limits"
- Question: "Rate limiting requirements?"
- Options: "Standard per-IP throttling (Recommended)" / "Per-user with tiered plans" / "Per-endpoint custom limits" / "No rate limiting"

**Q6 — Webhooks**
- Header: "Webhooks"
- Question: "Does the API need to send webhooks or callbacks?"
- Options: "No webhooks needed (Recommended for MVP)" / "Yes — event-driven webhooks to external URLs" / "Yes — WebSocket for real-time" / "Both webhooks and WebSocket"

**Q7 — Background Jobs**
- Header: "Async"
- Question: "Any async or background job processing needed?"
- Options: "No — all requests are synchronous (Recommended)" / "Simple queue (email sending, report generation)" / "Complex workflows (multi-step pipelines)" / "Scheduled jobs (cron-like tasks)"

**Q8 — Documentation**
- Header: "Docs"
- Question: "API documentation approach?"
- Options: "Swagger / OpenAPI auto-generated (Recommended)" / "Manual documentation" / "GraphQL introspection (if GraphQL)" / "No documentation for now"

Store all answers as **APP_STRUCTURE**.

---

### Branch C: CLI Tool

**Q1 — Commands**
- Header: "Commands"
- Question: "What are the main commands or subcommands?"
- Adapt: Generate from feature backlog. multiSelect: true.

**Q2 — Input**
- Header: "Input"
- Question: "How does the CLI receive input?"
- multiSelect: true
- Options: "Command-line arguments and flags (Recommended)" / "Interactive prompts (inquirer-style)" / "Stdin piping" / "Config files (YAML/JSON/TOML)"

**Q3 — Output**
- Header: "Output"
- Question: "What output formats?"
- multiSelect: true
- Options: "Formatted text with colors (Recommended)" / "JSON (machine-readable)" / "Tables" / "Progress bars and spinners"

**Q4 — Config**
- Header: "Config"
- Question: "Configuration approach?"
- Options: "Config file in project directory (Recommended)" / "Environment variables only" / "XDG config directory (~/.config/)" / "No configuration needed"

**Q5 — Persistence**
- Header: "Storage"
- Question: "Does it need local storage or state?"
- Options: "No — stateless (Recommended)" / "SQLite database" / "JSON/YAML file" / "OS keychain (for credentials)"

**Q6 — Auth**
- Header: "Auth"
- Question: "Does it need authentication?"
- Options: "No authentication (Recommended)" / "API key (stored in config)" / "OAuth device flow (browser-based)" / "Token from environment variable"

**Q7 — Distribution**
- Header: "Distribution"
- Question: "How will the CLI be distributed?"
- Options: "npm global package (Recommended for Node.js)" / "Standalone binary (pkg, nexe)" / "Homebrew formula" / "Docker image"

**Q8 — Extensibility**
- Header: "Plugins"
- Question: "Plugin or extension system?"
- Options: "No plugins needed (Recommended)" / "Plugin directory with auto-discovery" / "Hook-based extension points" / "Full plugin API"

Store all answers as **APP_STRUCTURE**.

---

### Branch D: Other App Types

For Mobile, Browser Extension, Desktop, Library/SDK, or Game: adapt the Web App questions to the platform's equivalent concepts (e.g., "Screens" instead of "Pages", mobile navigation patterns instead of sidebar). Ask 8-10 questions covering the platform's key structural decisions.

---

## Phase 4: Write Architecture Context

1. Create `.claude/` directory if needed.
2. Read the template at `${CLAUDE_PLUGIN_ROOT}/skills/architecture/templates/architecture-template.md`.
3. Fill every section using the Phase 2 and Phase 3 answers. Omit sections that don't apply (e.g., for API-only: omit Pages, Navigation, Layout, Theming).
4. For Scaffolding Commands, reference `${CLAUDE_PLUGIN_ROOT}/skills/architecture/references/stack-catalog.md` for stack-specific bootstrap commands.
5. Write the filled template to `.claude/architecture.md`.

If ARCH_MODE is `update`: Read existing file, merge new answers into existing sections, preserve unchanged sections, append new decisions to Decision Log.

---

## Phase 5: Summary

Output:

```
## Architecture Defined

**App Type**: {APP_TYPE} | **Pattern**: {ARCH_PATTERN}
**Stack**: {BACKEND_STACK} + {FRONTEND_STACK} + {DATA_LAYER}
**File**: `.claude/architecture.md`

Decisions: {count} | Pages/Routes: {count} | API Endpoints: {count}

Next: `/pm-copilot:pm-feature [idea]` to drill into a feature, or `/pm-copilot:pm-next` for recommendations.
```

---

**Begin now.** Start with Phase 0.
