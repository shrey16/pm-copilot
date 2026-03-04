# Application Type Catalog

Reference for recommending and evaluating application types during `/pm-arch`.

---

## Web App (SaaS / Dashboard)

**Description**: Browser-based application with user accounts, data management, and interactive UI. Typically behind authentication.

**Typical Stack**: Backend framework (NestJS, Express, Django) + Frontend framework (React, Vue) + Database + ORM

**Typical Structure**:
- Login/signup pages
- Dashboard as home
- CRUD pages for entities
- Settings/profile page
- Admin panel (if multi-tenant)

**Key Considerations**:
- Session management and auth
- Role-based access control
- Responsive design (at least desktop + tablet)
- Data loading states (loading, empty, error)
- Multi-tenancy (if SaaS)

---

## API / Backend Only

**Description**: REST or GraphQL API consumed by external clients. No built-in UI.

**Typical Stack**: Backend framework + Database + ORM + API documentation (Swagger/GraphQL Playground)

**Typical Structure**:
- Resource-oriented endpoints
- Authentication middleware
- Input validation layer
- Error response format
- Rate limiting
- API versioning

**Key Considerations**:
- Clear API contract documentation
- Consistent error response format
- Pagination strategy
- Authentication for external consumers
- Backward compatibility for versioned APIs

---

## CLI Tool

**Description**: Command-line application with terminal-based interface.

**Typical Stack**: Node.js (Commander/Yargs/Oclif), Python (Click/Typer), Go (Cobra), Rust (Clap)

**Typical Structure**:
- Command hierarchy (main → subcommands)
- Config file management
- Output formatting (text, JSON, tables)
- Progress indicators for long operations

**Key Considerations**:
- Cross-platform compatibility (Windows, macOS, Linux)
- Exit codes for scripting
- Piping and stdin support
- Config file location (XDG, project-local, home dir)
- Distribution method (npm, binary, homebrew)

---

## Full-Stack with SSR

**Description**: Server-rendered web application. Single project containing both server and client code.

**Typical Stack**: Next.js, Nuxt, SvelteKit, Remix + Database

**Typical Structure**:
- File-based routing (pages/ or app/ directory)
- Server components vs client components
- API routes co-located with frontend
- Static generation for content pages
- Server-side data fetching

**Key Considerations**:
- Hydration strategy
- SEO optimization
- Server vs client rendering decisions per page
- Deployment to edge/serverless platforms
- Caching strategy (ISR, SWR)

---

## Mobile App (React Native)

**Description**: Cross-platform mobile application.

**Typical Stack**: React Native (Expo or bare) + Backend API + Mobile database (AsyncStorage, SQLite, Realm)

**Typical Structure**:
- Screen-based navigation (Stack, Tab, Drawer)
- Native module integration
- Offline data storage
- Push notification handling
- App store deployment pipeline

**Key Considerations**:
- Platform-specific UI differences (iOS vs Android)
- App store review process
- Deep linking
- Background tasks and push notifications
- Offline-first data sync

---

## Other App Types

Browser Extension, Desktop App (Electron/Tauri), Library/SDK, and Game (web-based) are supported as app type selections. When chosen, the architecture exploration adapts the Web App or API questions to the platform's equivalent concepts. Additional detailed app type entries can be added to this catalog as pattern file support is implemented.
