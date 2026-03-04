# API Design Patterns

Universal API design patterns applicable across all backend frameworks.

## REST Conventions

### URL Structure
```
GET    /api/v1/{resource}          # List
POST   /api/v1/{resource}          # Create
GET    /api/v1/{resource}/:id      # Get one
PATCH  /api/v1/{resource}/:id      # Partial update
DELETE /api/v1/{resource}/:id      # Delete
```

- Use plural nouns for resources: `/users`, `/features`, `/orders`
- Use kebab-case for multi-word resources: `/order-items`
- Nest related resources: `/users/:id/orders`
- Limit nesting to 2 levels max

### HTTP Status Codes

| Action | Success | Common Errors |
|--------|---------|---------------|
| GET (list) | 200 OK | 401, 403 |
| GET (one) | 200 OK | 401, 403, 404 |
| POST | 201 Created | 400, 401, 409 |
| PATCH | 200 OK | 400, 401, 403, 404 |
| DELETE | 204 No Content | 401, 403, 404 |

### Error Response Format

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable error message",
    "details": [
      { "field": "email", "message": "Must be a valid email address" }
    ]
  }
}
```

### Pagination

```json
GET /api/v1/features?page=1&limit=20

{
  "data": [...],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 42,
    "totalPages": 3
  }
}
```

### Filtering & Sorting

```
GET /api/v1/features?status=active&sort=-createdAt&search=keyword
```

- Use query parameters for filtering
- Prefix with `-` for descending sort
- Use `search` for full-text search

## Authentication Patterns

### JWT Bearer Token

```
Authorization: Bearer <token>
```

- Access token: short-lived (15 min)
- Refresh token: long-lived (7 days), httpOnly cookie
- Token payload: `{ sub: userId, role: "admin", exp: ... }`

### API Key

```
X-API-Key: <key>
```

- For machine-to-machine communication
- Rate limit per key
- Scope permissions per key
