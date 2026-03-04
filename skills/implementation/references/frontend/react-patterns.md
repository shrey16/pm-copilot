# React Patterns Reference

Standard patterns and conventions for React frontend implementation within PM Copilot.

---

## Project Structure

```
src/
├── main.tsx                      # Entry point
├── App.tsx                       # Root component + router
├── api/                          # API layer
│   ├── client.ts                 # Base fetch/axios config
│   └── {feature}.api.ts          # Feature-specific API calls
├── components/                   # Shared/reusable components
│   ├── ui/                       # Generic UI primitives
│   └── layout/                   # Layout components
├── features/                     # Feature modules
│   └── {feature}/
│       ├── components/           # Feature-specific components
│       ├── hooks/                # Feature-specific hooks
│       ├── types.ts              # Feature types/interfaces
│       └── index.ts              # Feature barrel export
├── hooks/                        # Shared hooks
├── types/                        # Shared types
└── utils/                        # Shared utilities
```

---

## API Layer Pattern

```typescript
// api/client.ts
const BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000/api/v1';

async function request<T>(path: string, options?: RequestInit): Promise<T> {
  const res = await fetch(`${BASE_URL}${path}`, {
    headers: { 'Content-Type': 'application/json', ...options?.headers },
    ...options,
  });
  if (!res.ok) {
    const error = await res.json().catch(() => ({ message: res.statusText }));
    throw new ApiError(res.status, error.message);
  }
  return res.json();
}

export const api = {
  get: <T>(path: string) => request<T>(path),
  post: <T>(path: string, body: unknown) =>
    request<T>(path, { method: 'POST', body: JSON.stringify(body) }),
  patch: <T>(path: string, body: unknown) =>
    request<T>(path, { method: 'PATCH', body: JSON.stringify(body) }),
  delete: <T>(path: string) => request<T>(path, { method: 'DELETE' }),
};
```

```typescript
// api/feature.api.ts
import { api } from './client';
import type { Feature, CreateFeatureDto } from '../features/feature/types';

export const featureApi = {
  list: () => api.get<Feature[]>('/features'),
  getById: (id: string) => api.get<Feature>(`/features/${id}`),
  create: (dto: CreateFeatureDto) => api.post<Feature>('/features', dto),
  update: (id: string, dto: Partial<CreateFeatureDto>) =>
    api.patch<Feature>(`/features/${id}`, dto),
  delete: (id: string) => api.delete<void>(`/features/${id}`),
};
```

---

## Custom Hook Patterns

### Data Fetching Hook

```typescript
function useFeatures() {
  const [features, setFeatures] = useState<Feature[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    featureApi.list()
      .then((data) => { if (!cancelled) setFeatures(data); })
      .catch((err) => { if (!cancelled) setError(err.message); })
      .finally(() => { if (!cancelled) setLoading(false); });
    return () => { cancelled = true; };
  }, []);

  return { features, loading, error };
}
```

### Mutation Hook

```typescript
function useCreateFeature() {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const create = async (dto: CreateFeatureDto): Promise<Feature | null> => {
    setLoading(true);
    setError(null);
    try {
      const result = await featureApi.create(dto);
      return result;
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
      return null;
    } finally {
      setLoading(false);
    }
  };

  return { create, loading, error };
}
```

---

## Component Patterns

### Feature List Component

```tsx
function FeatureList() {
  const { features, loading, error } = useFeatures();

  if (loading) return <LoadingSpinner />;
  if (error) return <ErrorMessage message={error} />;
  if (features.length === 0) return <EmptyState message="No features yet" />;

  return (
    <ul>
      {features.map((feature) => (
        <FeatureCard key={feature.id} feature={feature} />
      ))}
    </ul>
  );
}
```

### Form Component

```tsx
function CreateFeatureForm({ onSuccess }: { onSuccess: (feature: Feature) => void }) {
  const { create, loading, error } = useCreateFeature();

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);
    const result = await create({
      name: formData.get('name') as string,
      description: formData.get('description') as string,
    });
    if (result) onSuccess(result);
  };

  return (
    <form onSubmit={handleSubmit}>
      <input name="name" required maxLength={255} disabled={loading} />
      <textarea name="description" maxLength={1000} disabled={loading} />
      {error && <ErrorMessage message={error} />}
      <button type="submit" disabled={loading}>
        {loading ? 'Creating...' : 'Create Feature'}
      </button>
    </form>
  );
}
```

---

## Routing Pattern

```tsx
// App.tsx
import { BrowserRouter, Routes, Route } from 'react-router-dom';

function App() {
  return (
    <BrowserRouter>
      <Layout>
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="/features" element={<FeatureListPage />} />
          <Route path="/features/:id" element={<FeatureDetailPage />} />
          <Route path="/features/new" element={<CreateFeaturePage />} />
          <Route path="*" element={<NotFoundPage />} />
        </Routes>
      </Layout>
    </BrowserRouter>
  );
}
```

---

## Error Boundary Pattern

```tsx
class ErrorBoundary extends React.Component<
  { children: React.ReactNode; fallback?: React.ReactNode },
  { hasError: boolean; error: Error | null }
> {
  state = { hasError: false, error: null };

  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error };
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback || <ErrorMessage message="Something went wrong" />;
    }
    return this.props.children;
  }
}
```

---

## State Management

### When to use what

| Approach | Use when |
|----------|----------|
| `useState` | Local component state |
| `useReducer` | Complex local state with multiple actions |
| React Context | Shared state across a subtree (theme, auth, etc.) |
| React Query / SWR | Server state (data fetching, caching, sync) |
| Zustand / Redux | Global client state shared across unrelated components |

Follow whatever the existing project uses. Don't introduce a new state library unless needed.

---

## Testing Patterns

```tsx
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

describe('FeatureList', () => {
  it('renders features', async () => {
    vi.spyOn(featureApi, 'list').mockResolvedValue([
      { id: '1', name: 'Test Feature', status: 'active' },
    ]);

    render(<FeatureList />);

    await waitFor(() => {
      expect(screen.getByText('Test Feature')).toBeInTheDocument();
    });
  });

  it('shows empty state', async () => {
    vi.spyOn(featureApi, 'list').mockResolvedValue([]);
    render(<FeatureList />);

    await waitFor(() => {
      expect(screen.getByText('No features yet')).toBeInTheDocument();
    });
  });

  it('shows error', async () => {
    vi.spyOn(featureApi, 'list').mockRejectedValue(new Error('Network error'));
    render(<FeatureList />);

    await waitFor(() => {
      expect(screen.getByText('Network error')).toBeInTheDocument();
    });
  });
});
```

---

## Accessibility Conventions

- All interactive elements must be keyboard accessible
- Use semantic HTML (`<button>`, `<nav>`, `<main>`, `<form>`) over generic `<div>`
- Add `aria-label` to icon-only buttons
- Form inputs must have associated `<label>` elements
- Loading states must use `aria-busy="true"`
- Error messages must use `role="alert"`
