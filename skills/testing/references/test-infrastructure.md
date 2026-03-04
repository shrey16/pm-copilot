# Test Infrastructure Guide

How to set up and manage test infrastructure for PM Copilot implementations. Since test infrastructure is project-dependent, this guide provides decision frameworks — not prescriptive code.

---

## QA Account Management

### Questions to Resolve During Drilling

These should be answered during the Dependencies category of feature drilling:

1. **Does the app require authentication?** If yes:
   - How are test accounts created? (Admin panel, API, database seeding, SSO provider)
   - Are there different roles to test? (admin, user, viewer, etc.)
   - Can test accounts be created programmatically?
   - Are there rate limits on account creation?

2. **Are there external service dependencies?** If yes:
   - Are there sandbox/test environments for external APIs?
   - Are API keys needed for test environments?
   - Should external calls be mocked in tests?

### QA Account Patterns

| Pattern | When to Use | Setup |
|---------|-------------|-------|
| API-seeded | App has a user creation API | POST to test seed endpoint with X-Test-Secret header |
| Database-seeded | Direct DB access in tests | Create users via ORM in test setup |
| Fixture files | Static, unchanging test users | JSON files loaded before tests |

---

## Test Data Seeding

### Principles

1. **Isolation**: Each test creates its own data — never depend on shared state
2. **Cleanup**: Remove test data after each test (or use transactions that roll back)
3. **Determinism**: Use fixed seeds for random data, fixed timestamps for dates
4. **Speed**: Seed only what you need for each test — avoid large fixture sets

### Strategy Selection

| Strategy | Best For | Approach |
|----------|----------|----------|
| In-memory DB (SQLite) | Unit and integration tests | Swap DB config to `:memory:` with `synchronize: true` |
| Test transactions | Integration tests against real DB | Start transaction in beforeEach, rollback in afterEach |
| API-based seeding | E2E tests | POST to `/api/test/seed` in beforeEach, cleanup in afterEach |

### Fixture Best Practices

- Prefer factory functions over static JSON — they support overrides and unique IDs
- Use counter-based IDs for uniqueness across parallel tests
- Build large dataset helpers for load testing scenarios

---

## Test Environment

### Required Configuration

- `.env.test` with: DATABASE_URL (test DB), API_URL, TEST_SECRET, NODE_ENV=test
- Playwright config: baseURL pointing to test server, `retries: 0` (tests must be deterministic), screenshots on failure
- WebServer config to auto-start backend + frontend before E2E runs

---

## Checklist for New Features

- [ ] QA accounts: Can test accounts be created for all required roles?
- [ ] Test data: Is there a seeding strategy for the feature's data requirements?
- [ ] Cleanup: Does test data get cleaned up after each test?
- [ ] Isolation: Can tests run in parallel without interfering with each other?
- [ ] CI/CD: Do tests run in the CI pipeline? Is the test DB available?
- [ ] External services: Are external dependencies mocked or sandboxed?
- [ ] Performance: Can the full test suite run in under 5 minutes?
