# Generic Backend Patterns

Universal backend principles for frameworks without a specific pattern reference file. The implementer should prioritize existing codebase patterns over these guidelines.

## Project Structure

```
src/
├── modules/ or routes/ or handlers/    # Feature-grouped business logic
│   └── {feature}/
│       ├── controller or handler        # HTTP/request layer
│       ├── service                      # Business logic
│       ├── model or entity              # Data model
│       └── dto or schema                # Input/output shapes
├── common/ or shared/                   # Cross-cutting concerns
│   ├── middleware/
│   ├── auth/
│   └── errors/
├── config/                              # Configuration
└── entry point (main.ts, app.py, etc.)
```

## Key Principles

1. **Separation of concerns**: Controllers handle HTTP, services handle logic, models handle data
2. **Input validation**: Validate all inputs at the boundary (controller/handler level)
3. **Error handling**: Use framework-specific error types. Return consistent error response format:
   ```json
   { "error": { "code": "NOT_FOUND", "message": "Resource not found" } }
   ```
4. **Environment config**: Use environment variables for all deployment-specific values
5. **Dependency injection**: Use the framework's DI system if available. Avoid global state.
6. **Logging**: Structured logging with request ID correlation

## Testing

- Test files co-located with source: `{file}.spec.ts` or `{file}.test.ts`
- Mock external dependencies (database, APIs)
- Test the service layer primarily (most business logic lives there)
- Test controller layer for input validation and HTTP status codes
