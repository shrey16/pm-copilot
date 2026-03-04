# Implementation Skill — NestJS + React

Methodology for generating production-quality NestJS backend and React frontend code from feature specifications.

## Core Principles

1. **Spec-Driven**: Every line of code traces back to a requirement (FR-xxx or NFR-xxx) in the spec
2. **Pattern-Consistent**: Follow existing patterns in the codebase before introducing new ones
3. **Incrementally Testable**: Each implementation unit must be independently testable
4. **Convention over Configuration**: Use NestJS and React conventions — don't reinvent the wheel

## Implementation Process

### Step 1: Codebase Analysis

Before generating any code:
- Detect project structure (monorepo vs separate repos)
- Identify ORM in use (TypeORM, Prisma, Sequelize, or none)
- Identify state management (Redux, Zustand, Context, React Query, or none)
- Identify API layer (fetch, axios, generated client)
- Identify existing patterns: naming conventions, file organization, error handling
- Check for existing shared utilities, DTOs, types

### Step 2: Module Decomposition

Map spec requirements to NestJS modules and React features:
- Group related FRs into a single NestJS module (controller + service + DTOs + entities)
- Group related UI requirements into React feature directories (components + hooks + types)
- Identify shared concerns: guards, interceptors, middleware, shared components

### Step 3: Backend Implementation (NestJS)

For each backend module, generate in this order:
1. **Entity/Model** — database schema reflecting the spec's data model (Section 5)
2. **DTOs** — request/response shapes matching the spec's API contracts (Section 6)
3. **Service** — business logic implementing functional requirements (Section 3)
4. **Controller** — HTTP layer with decorators, validation pipes, guards (Section 6)
5. **Module** — wiring it all together with proper imports/exports

### Step 4: Frontend Implementation (React)

For each UI feature, generate in this order:
1. **Types/Interfaces** — shared types matching API contract shapes
2. **API Layer** — service functions that call the backend endpoints
3. **Hooks** — custom hooks for data fetching, mutations, and local state
4. **Components** — UI components following the spec's user flows (Section 2)
5. **Pages/Routes** — page-level components and route registration

### Step 5: Integration

- Wire frontend to backend via API layer
- Set up proper error handling matching spec's error states (Section 7)
- Implement loading/empty/error states per spec

## Scaffolding New Projects

If no NestJS or React project exists:

### NestJS Scaffold
```bash
npx @nestjs/cli new backend --package-manager npm --skip-git
```
Then set up: ConfigModule, ValidationPipe (global), class-transformer, class-validator

### React Scaffold
```bash
npm create vite@latest frontend -- --template react-ts
```
Then set up: React Router, a fetch/axios wrapper, basic layout structure

## Error Handling Strategy

- NestJS: Use built-in exception filters. Map spec error codes to HTTP exceptions.
- React: Use error boundaries for render errors. Use try/catch + state for async errors.
- Always match error messages to those defined in the spec's edge cases table.

## Code Quality Checklist

Before marking an implementation unit complete:
- [ ] All targeted FRs have corresponding code
- [ ] DTOs have class-validator decorators matching spec constraints
- [ ] Controllers have proper HTTP status codes per spec
- [ ] React components handle loading, error, and empty states
- [ ] No hardcoded values — use constants or config
- [ ] Proper TypeScript types throughout (no `any`)
- [ ] Follows existing codebase patterns
