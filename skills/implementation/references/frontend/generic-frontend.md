# Generic Frontend Patterns

Universal frontend principles for frameworks without a specific pattern reference file. The implementer should prioritize existing codebase patterns over these guidelines.

## Project Structure

```
src/
├── components/                   # Shared/reusable UI components
│   ├── ui/                       # Generic primitives (Button, Input, Modal)
│   └── layout/                   # Layout components (Header, Sidebar, Footer)
├── features/ or pages/           # Feature-grouped modules
│   └── {feature}/
│       ├── components/           # Feature-specific components
│       ├── hooks/ or composables/ # Feature-specific logic
│       └── types                 # Feature-specific types
├── api/ or services/             # API communication layer
├── hooks/ or composables/        # Shared logic
├── types/                        # Shared type definitions
├── utils/                        # Pure utility functions
└── entry point (main.tsx, App.vue, etc.)
```

## Key Principles

1. **Component composition**: Small, focused components. Compose complex UIs from simple parts.
2. **State management**: Start with the simplest approach. Local state → shared context → global store.
3. **Loading/Error/Empty states**: Every data-dependent component must handle all three states.
4. **API layer**: Centralize API calls in a dedicated layer. Never call fetch/axios directly from components.
5. **Type safety**: Full TypeScript types for API responses, component props, and state.
6. **Accessibility**: Semantic HTML, keyboard navigation, ARIA attributes, color contrast.

## Testing

- Test files co-located: `{Component}.test.tsx` or `{Component}.spec.tsx`
- Use the framework's recommended testing library (React Testing Library, Vue Test Utils, etc.)
- Test user-visible behavior, not implementation details
- Mock API calls, not internal functions
