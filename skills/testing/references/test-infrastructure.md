# Test Infrastructure Guide

How to set up and manage test infrastructure for PM Copilot implementations. Since test infrastructure is project-dependent, this guide provides patterns and questions to ask — not prescriptive solutions.

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

### Patterns for QA Accounts

**Pattern A: API-Seeded Accounts**
```typescript
// test/helpers/seed-users.ts
async function seedTestUser(role: string): Promise<TestUser> {
  const response = await fetch(`${API_URL}/test/seed-user`, {
    method: 'POST',
    headers: { 'X-Test-Secret': process.env.TEST_SECRET },
    body: JSON.stringify({ role, prefix: `test-${Date.now()}` }),
  });
  return response.json();
}
```

**Pattern B: Database-Seeded Accounts**
```typescript
// test/helpers/seed-users.ts
async function seedTestUser(prisma: PrismaClient, role: string): Promise<User> {
  return prisma.user.create({
    data: {
      email: `test-${Date.now()}@test.local`,
      role,
      password: await hash('test-password'),
    },
  });
}
```

**Pattern C: Fixture Files**
```json
// test/fixtures/users.json
{
  "admin": { "email": "admin@test.local", "password": "test-pass", "role": "admin" },
  "user": { "email": "user@test.local", "password": "test-pass", "role": "user" }
}
```

---

## Test Data Seeding

### Principles

1. **Isolation**: Each test creates its own data — never depend on shared state
2. **Cleanup**: Remove test data after each test (or use transactions that roll back)
3. **Determinism**: Use fixed seeds for random data, fixed timestamps for dates
4. **Speed**: Seed only what you need for each test — avoid large fixture sets

### Seeding Strategies

**Strategy 1: In-Memory Database**
Best for: Unit and integration tests
```typescript
// Use SQLite in-memory for TypeORM tests
TypeOrmModule.forRoot({
  type: 'sqlite',
  database: ':memory:',
  entities: [/* ... */],
  synchronize: true,
})
```

**Strategy 2: Test Transactions**
Best for: Integration tests against real DB
```typescript
beforeEach(async () => {
  queryRunner = dataSource.createQueryRunner();
  await queryRunner.startTransaction();
});
afterEach(async () => {
  await queryRunner.rollbackTransaction();
  await queryRunner.release();
});
```

**Strategy 3: API-Based Seeding**
Best for: E2E tests
```typescript
test.beforeEach(async ({ request }) => {
  await request.post('/api/test/seed', {
    data: { scenario: 'user-search', entities: 50 },
  });
});
test.afterEach(async ({ request }) => {
  await request.post('/api/test/cleanup');
});
```

---

## Fixture Management

### Factory Functions

Prefer factory functions over static JSON fixtures:

```typescript
// test/factories/feature.factory.ts
let counter = 0;

export function buildFeature(overrides?: Partial<Feature>): Feature {
  counter++;
  return {
    id: `test-feature-${counter}`,
    name: `Feature ${counter}`,
    description: 'A test feature',
    status: 'active',
    createdAt: new Date('2024-01-01T00:00:00Z'),
    updatedAt: new Date('2024-01-01T00:00:00Z'),
    ...overrides,
  };
}
```

### Large Dataset Fixtures

For performance or load testing:
```typescript
export function buildFeatureList(count: number): Feature[] {
  return Array.from({ length: count }, (_, i) =>
    buildFeature({ name: `Feature ${i + 1}` })
  );
}
```

---

## Test Environment Configuration

### Environment Variables

```bash
# .env.test
DATABASE_URL=postgresql://test:test@localhost:5432/app_test
API_URL=http://localhost:3001
TEST_SECRET=test-secret-key
NODE_ENV=test
```

### Playwright Configuration

```typescript
// playwright.config.ts
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  timeout: 30000,
  retries: 0,  // No retries — tests must be deterministic
  use: {
    baseURL: 'http://localhost:3000',
    screenshot: 'only-on-failure',
    trace: 'on-first-retry',
  },
  webServer: [
    {
      command: 'npm run start:backend:test',
      port: 3001,
      reuseExistingServer: true,
    },
    {
      command: 'npm run start:frontend:test',
      port: 3000,
      reuseExistingServer: true,
    },
  ],
});
```

---

## Checklist for New Features

When implementing a new feature's test infrastructure:

- [ ] QA accounts: Can test accounts be created for all required roles?
- [ ] Test data: Is there a seeding strategy for the feature's data requirements?
- [ ] Cleanup: Does test data get cleaned up after each test?
- [ ] Isolation: Can tests run in parallel without interfering with each other?
- [ ] CI/CD: Do tests run in the CI pipeline? Is the test DB available?
- [ ] External services: Are external dependencies mocked or sandboxed?
- [ ] Performance: Can the full test suite run in under 5 minutes?
