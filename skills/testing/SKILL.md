# Testing Skill — Unit + E2E Strategy

Methodology for writing and running tests that verify implementation against spec requirements.

## Core Principles

1. **Spec-Traced**: Every test traces to a requirement (FR-xxx, NFR-xxx) or edge case from the spec
2. **Pyramid-Shaped**: Many unit tests, fewer integration tests, fewest E2E tests
3. **Fast Feedback**: Unit tests run in seconds, E2E tests run in under a minute per flow
4. **Deterministic**: No flaky tests. Mock external dependencies. Use fixed test data.

## Testing Layers

### Layer 1: Unit Tests (Jest / Vitest)

**Backend (NestJS)**:
- Test services in isolation with mocked repositories
- Test DTOs with class-validator (valid + invalid inputs)
- Test controllers with mocked services (HTTP status codes, response shapes)
- Test guards and interceptors in isolation

**Frontend (React)**:
- Test components with React Testing Library (render, user interactions, assertions)
- Test hooks with `renderHook` (state changes, side effects)
- Test API layer with mocked fetch/axios
- Test utility functions as pure unit tests

**Naming convention**: `{source-file}.spec.ts` co-located with source

### Layer 2: Integration Tests

- Backend: Test controller → service → repository chain with in-memory DB or test DB
- Frontend: Test page-level components with mocked API responses
- Focus on wiring correctness: does data flow correctly between layers?

### Layer 3: E2E Tests (Playwright)

- Test complete user flows as defined in the spec's Section 2 (User Flows)
- Use Playwright to simulate real browser interactions
- Tests should follow the spec's primary flow, alternative flows, and key edge cases
- Each E2E test covers one complete user flow from entry to exit

**Naming convention**: `e2e/{feature-name}/{flow-name}.spec.ts`

## Test Data Strategy

### Principles
- Tests must not depend on external state
- Each test sets up its own data (arrange phase)
- Tear down after test completion
- Use factory functions for creating test entities

### Patterns
```typescript
// Factory pattern for test data
function createTestFeature(overrides?: Partial<Feature>): Feature {
  return {
    id: 'test-uuid',
    name: 'Test Feature',
    status: FeatureStatus.ACTIVE,
    createdAt: new Date('2024-01-01'),
    ...overrides,
  };
}
```

### QA Accounts & Seeding
Test infrastructure varies by project. During feature drilling, identify:
- Are QA/test accounts needed?
- How is test data seeded? (API calls, direct DB, fixture files)
- Are there shared test environments?
- Is there test data isolation between tests?

See `references/test-infrastructure.md` for detailed guidance.

## E2E Testing with Playwright

### Structure
```typescript
import { test, expect } from '@playwright/test';

test.describe('Feature: {spec feature name}', () => {
  test.beforeEach(async ({ page }) => {
    // Set up test data via API or seeding
    // Navigate to starting point
  });

  test('primary flow: {description from spec}', async ({ page }) => {
    // Follow spec Section 2.1 step by step
    await page.goto('/features');
    await page.click('button:has-text("Create")');
    await page.fill('[name="name"]', 'Test Feature');
    await page.click('button:has-text("Submit")');
    await expect(page.locator('.success-message')).toBeVisible();
  });

  test('edge case: {scenario from spec Section 7}', async ({ page }) => {
    // Test specific edge case
  });
});
```

### Playwright Best Practices
- Use `data-testid` attributes for reliable selectors
- Prefer user-visible text selectors when stable
- Use `page.waitForResponse()` when testing async operations
- Set reasonable timeouts (default 30s for navigation, 5s for assertions)
- Take screenshots on failure for debugging

## Mapping Spec to Tests

| Spec Section | Test Layer | What to Test |
|-------------|-----------|-------------|
| Section 2 (User Flows) | E2E | Complete user journeys |
| Section 3 (Functional Reqs) | Unit + Integration | Each FR has at least 1 unit test |
| Section 4 (Non-Functional Reqs) | Unit + E2E | Performance targets, accessibility |
| Section 6 (API Contracts) | Unit (controller) | Request validation, response shapes, status codes |
| Section 7 (Edge Cases) | Unit + E2E | Error handling, boundary conditions |

## Coverage Targets

- Unit tests: Aim for all FRs covered (at least 1 test per FR-xxx)
- E2E tests: Cover all primary flows and critical alternative flows
- Edge cases: Cover all scenarios listed in spec Section 7
- Don't chase coverage percentages — chase requirement coverage

## Verification Checklist

Before marking tests as passing:
- [ ] All unit tests pass (`npm test`)
- [ ] All E2E tests pass (`npx playwright test`)
- [ ] Every FR-xxx has at least one test
- [ ] Every edge case from Section 7 has a test
- [ ] No skipped or pending tests
- [ ] Tests are deterministic (run 3 times, pass 3 times)
