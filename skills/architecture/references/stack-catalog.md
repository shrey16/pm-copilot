# Stack Detection & Extensibility Catalog

Reference for detecting tech stacks from file patterns and scaffolding new projects.

---

## Detection Patterns

### Backend Frameworks

| Framework | Detection Files | Package Indicators |
|-----------|----------------|-------------------|
| NestJS | `nest-cli.json` | `@nestjs/core` in package.json |
| Express | — | `express` in package.json (without `@nestjs`) |
| Fastify | — | `fastify` in package.json |
| Hono | — | `hono` in package.json |
| FastAPI | — | `fastapi` in requirements.txt/pyproject.toml |
| Django | `manage.py`, `*/settings.py` | `django` in requirements.txt/pyproject.toml |
| Flask | `app.py` with Flask import | `flask` in requirements.txt/pyproject.toml |
| Rails | `config/routes.rb`, `bin/rails` | `rails` in Gemfile |
| Go (Gin) | `go.mod` | `github.com/gin-gonic/gin` in go.mod |
| Go (net/http) | `go.mod`, `main.go` with `net/http` | — |
| ASP.NET Core | `*.csproj`, `Program.cs` | `Microsoft.AspNetCore` in .csproj |
| Spring Boot | `pom.xml` or `build.gradle` | `spring-boot` dependency |

### Frontend Frameworks

| Framework | Detection Files | Package Indicators |
|-----------|----------------|-------------------|
| React | — | `react` in package.json |
| Next.js | `next.config.*` | `next` in package.json |
| Vue | — | `vue` in package.json |
| Nuxt | `nuxt.config.*` | `nuxt` in package.json |
| Angular | `angular.json` | `@angular/core` in package.json |
| Svelte | `svelte.config.*` | `svelte` in package.json |
| SvelteKit | `svelte.config.*` with `@sveltejs/kit` | `@sveltejs/kit` in package.json |
| Remix | `remix.config.*` | `@remix-run/react` in package.json |
| Astro | `astro.config.*` | `astro` in package.json |

### Databases & ORMs

| Technology | Detection Files | Package Indicators |
|------------|----------------|-------------------|
| Prisma | `prisma/schema.prisma` | `@prisma/client` in package.json |
| TypeORM | `ormconfig.*`, `data-source.*` | `typeorm` in package.json |
| Drizzle | `drizzle.config.*` | `drizzle-orm` in package.json |
| Sequelize | — | `sequelize` in package.json |
| Mongoose | — | `mongoose` in package.json |
| SQLAlchemy | `alembic.ini`, `alembic/` | `sqlalchemy` in requirements.txt |
| ActiveRecord | `db/migrate/` | `rails` in Gemfile |

### UI Libraries

| Library | Detection Files | Package Indicators |
|---------|----------------|-------------------|
| Tailwind CSS | `tailwind.config.*` | `tailwindcss` in package.json |
| shadcn/ui | `components/ui/` with Radix | `@radix-ui/*` in package.json |
| Material UI | — | `@mui/material` in package.json |
| Ant Design | — | `antd` in package.json |
| Chakra UI | — | `@chakra-ui/react` in package.json |
| DaisyUI | — | `daisyui` in package.json |

### Test Frameworks

| Framework | Detection Files |
|-----------|----------------|
| Jest | `jest.config.*` |
| Vitest | `vitest.config.*` |
| Playwright | `playwright.config.*` |
| Cypress | `cypress.config.*`, `cypress/` |
| Pytest | `pytest.ini`, `conftest.py`, `pyproject.toml` with `[tool.pytest]` |

### Deployment

| Platform | Detection Files |
|----------|----------------|
| Docker | `Dockerfile`, `docker-compose.yml` |
| Vercel | `vercel.json` |
| Netlify | `netlify.toml` |
| Fly.io | `fly.toml` |
| Railway | `railway.json`, `railway.toml` |
| Render | `render.yaml` |
| Heroku | `Procfile` |
| Serverless | `serverless.yml`, `serverless.ts` |
| Kubernetes | `k8s/`, `kubernetes/`, `*.k8s.yml` |
| Terraform | `*.tf`, `terraform/` |

### Monorepo

| Tool | Detection Files |
|------|----------------|
| Nx | `nx.json` |
| Turborepo | `turbo.json` |
| Lerna | `lerna.json` |
| pnpm workspaces | `pnpm-workspace.yaml` |

---

## Scaffolding Commands

### NestJS + React + Prisma + Tailwind (default supported stack)

```bash
# Backend
npx @nestjs/cli new backend --package-manager npm --skip-git
cd backend && npm install @prisma/client class-validator class-transformer
npx prisma init

# Frontend
npm create vite@latest frontend -- --template react-ts
cd frontend && npm install react-router-dom
npm install -D tailwindcss @tailwindcss/vite
```

### Next.js + Prisma + Tailwind

```bash
npx create-next-app@latest . --typescript --tailwind --eslint --app --src-dir
npm install @prisma/client && npx prisma init
```

### Express + React + Prisma

```bash
# Backend
mkdir backend && cd backend && npm init -y
npm install express cors helmet
npm install -D typescript @types/express @types/node ts-node nodemon
npm install @prisma/client && npx prisma init

# Frontend
npm create vite@latest frontend -- --template react-ts
```

### FastAPI + React

```bash
# Backend
mkdir backend && cd backend
python -m venv venv
pip install fastapi uvicorn sqlalchemy alembic

# Frontend
npm create vite@latest frontend -- --template react-ts
```

### Django + React

```bash
# Backend
mkdir backend && cd backend
python -m venv venv
pip install django djangorestframework django-cors-headers

# Frontend
npm create vite@latest frontend -- --template react-ts
```

### CLI (Node.js with Commander)

```bash
mkdir {name} && cd {name} && npm init -y
npm install commander chalk ora
npm install -D typescript @types/node ts-node
```

---

## Extensibility Guide

### Adding a New Stack

To add support for a new backend or frontend stack:

1. **Create a pattern file**: Add `skills/implementation/references/backend/{name}-patterns.md` or `skills/implementation/references/frontend/{name}-patterns.md`

2. **Pattern file structure** (follow this template):
   ```markdown
   # {Framework} Patterns

   ## Module / Project Structure
   {typical directory layout}

   ## Naming Conventions
   {file naming, class naming, variable naming}

   ## Common Patterns
   {3-5 most important patterns with code examples}

   ## Error Handling
   {framework-specific error handling approach}

   ## Testing
   {test file conventions, assertion patterns}
   ```

3. **Add detection entry**: Add the framework's detection files and package indicators to the tables above in this catalog.

4. **Add scaffolding commands**: Add the project bootstrap commands to the Scaffolding Commands section above.

The implementer agent will automatically resolve the correct pattern file based on the `architecture.md` tech stack entries. No other files need to be modified.
