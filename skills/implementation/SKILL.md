# Implementation Skill

Methodology for generating production-quality code from feature specifications, following the project's chosen architecture and tech stack.

## Core Principles

1. **Spec-Driven**: Every line of code traces back to a requirement (FR-xxx or NFR-xxx) in the spec
2. **Pattern-Consistent**: Follow existing patterns in the codebase before introducing new ones
3. **Incrementally Testable**: Each implementation unit must be independently testable
4. **Convention over Configuration**: Follow the project's chosen framework conventions — don't reinvent the wheel
5. **Architecture-Aware**: Read `.claude/architecture.md` before generating any code to understand the stack and structure

## Implementation Process

### Step 0: Read Architecture Context

Before anything else:
- Read `.claude/architecture.md` to determine: application type, backend framework, frontend framework, database, ORM, UI library, project structure, key conventions, scaffolding commands
- Load the appropriate pattern reference from `references/backend/{framework}-patterns.md` and `references/frontend/{framework}-patterns.md`. If no specific file exists, use `generic-backend.md` or `generic-frontend.md`.

### Step 1: Codebase Analysis

Before generating any code:
- Detect project structure (monorepo vs separate repos)
- Identify ORM in use (from architecture context or codebase detection)
- Identify state management approach
- Identify API layer (fetch, axios, generated client)
- Identify existing patterns: naming conventions, file organization, error handling
- Check for existing shared utilities, DTOs/schemas, types

### Step 2: Module Decomposition

Map spec requirements to backend modules and frontend features based on the project's chosen frameworks:
- Group related FRs into a single backend module (controller/handler + service + DTOs/schemas + entities/models)
- Group related UI requirements into frontend feature directories (components + hooks/composables + types)
- Identify shared concerns: middleware, guards, shared components

### Step 3: Backend Implementation

For each backend module, generate in this order (adapting to the framework from architecture context):
1. **Entity/Model** — database schema reflecting the spec's data model (Section 5)
2. **DTOs/Schemas** — request/response shapes matching the spec's API contracts (Section 6) with appropriate validation
3. **Service** — business logic implementing functional requirements (Section 3)
4. **Controller/Handler** — HTTP layer matching spec Section 6 endpoints
5. **Module/Registration** — wiring it all together

### Step 4: Frontend Implementation

For each UI feature, generate in this order (adapting to the framework from architecture context):
1. **Types/Interfaces** — shared types matching API contract shapes
2. **API Layer** — service functions that call the backend endpoints
3. **Hooks/Composables** — data fetching, mutations, and local state logic
4. **Components** — UI components following the spec's user flows (Section 2)
5. **Pages/Routes** — page-level components and route registration

### Step 5: Integration

- Wire frontend to backend via API layer
- Set up proper error handling matching spec's error states (Section 7)
- Implement loading/empty/error states per spec

## Scaffolding New Projects

If no project exists, use the scaffolding commands from `.claude/architecture.md`. The architecture context defines exactly which commands to run for the chosen stack.

## Error Handling Strategy

- Backend: Use framework-specific exception/error handling. Map spec error codes to HTTP exceptions.
- Frontend: Use error boundaries (or framework equivalent) for render errors. Use try/catch + state for async errors.
- Always match error messages to those defined in the spec's edge cases table.

## Code Quality Checklist

Before marking an implementation unit complete:
- [ ] All targeted FRs have corresponding code
- [ ] Input validation matches spec constraints
- [ ] HTTP status codes match spec's API contracts
- [ ] UI components handle loading, error, and empty states
- [ ] No hardcoded values — use constants or config
- [ ] Proper types throughout (no `any` in TypeScript)
- [ ] Follows existing codebase patterns
