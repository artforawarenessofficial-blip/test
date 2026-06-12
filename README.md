# Skills API

A RESTful API for managing skills, built with OpenAPI Specification 3.1.

## Overview

This API allows you to:
- Create, read, update, and delete skills
- Organize skills by categories
- Filter and search skills

## API Specification

The API is defined in `openapi.yaml` using the OpenAPI 3.1.0 specification.

### Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/skills` | List all skills |
| POST | `/skills` | Create a new skill |
| GET | `/skills/{skillId}` | Get a skill by ID |
| PUT | `/skills/{skillId}` | Update a skill |
| DELETE | `/skills/{skillId}` | Delete a skill |
| GET | `/categories` | List all categories |

## Getting Started

### View the API Documentation

You can view the interactive API documentation by:

1. **Swagger Editor**: Paste `openapi.yaml` contents at [editor.swagger.io](https://editor.swagger.io)
2. **Redocly**: Use [Redocly](https://redocly.github.io/redoc/) to render the spec
3. **Local tools**: Use `npx @redocly/cli preview-docs openapi.yaml`

### Generate Code

Generate client SDKs or server stubs using OpenAPI Generator:

```bash
# Install OpenAPI Generator
npm install @openapitools/openapi-generator-cli -g

# Generate a Node.js server
openapi-generator-cli generate -i openapi.yaml -g nodejs-express-server -o server/

# Generate a Python client
openapi-generator-cli generate -i openapi.yaml -g python -o client-python/

# Generate a TypeScript client
openapi-generator-cli generate -i openapi.yaml -g typescript-fetch -o client-ts/
```

## Schema

### Skill Object

```json
{
  "id": "uuid",
  "name": "JavaScript",
  "description": "A programming language",
  "category": "Programming",
  "level": "intermediate",
  "tags": ["web", "frontend"],
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

## License

MIT
