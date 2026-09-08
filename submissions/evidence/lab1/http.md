Captured at 2026-09-08T13:27:05+0300.

Fresh isolated data: four seed notes; POST returned HTTP 201; five notes afterwards.

### `GET /health` (HTTP 200)

```bash
curl -s http://localhost:8080/health | python3 -m json.tool
```

```json
{
    "notes": 4,
    "status": "ok"
}
```

### `GET /notes` (HTTP 200)

```bash
curl -s http://localhost:8080/notes | python3 -m json.tool
```

```json
[
    {
        "id": 1,
        "title": "Welcome to QuickNotes",
        "body": "This is the project you'll containerize, deploy, monitor, and harden across all 10 labs.",
        "created_at": "2026-01-15T10:00:00Z"
    },
    {
        "id": 2,
        "title": "Read app/main.go first",
        "body": "Start by understanding the entry point \u2014 env vars, signal handling, graceful shutdown.",
        "created_at": "2026-01-15T10:05:00Z"
    },
    {
        "id": 3,
        "title": "DevOps mantra",
        "body": "If it hurts, do it more often.",
        "created_at": "2026-01-15T10:10:00Z"
    },
    {
        "id": 4,
        "title": "Endpoint cheat-sheet",
        "body": "GET /notes  GET /notes/{id}  POST /notes  DELETE /notes/{id}  GET /health  GET /metrics",
        "created_at": "2026-01-15T10:15:00Z"
    }
]
```

### `POST /notes` (HTTP 201)

```bash
curl -s -X POST -H 'Content-Type: application/json' -d '{"title":"hello","body":"first POST"}' http://localhost:8080/notes | python3 -m json.tool
```

```json
{
    "id": 5,
    "title": "hello",
    "body": "first POST",
    "created_at": "2026-09-08T10:27:05.276015472Z"
}
```

### `GET /notes` (HTTP 200)

```bash
curl -s http://localhost:8080/notes | python3 -m json.tool
```

```json
[
    {
        "id": 3,
        "title": "DevOps mantra",
        "body": "If it hurts, do it more often.",
        "created_at": "2026-01-15T10:10:00Z"
    },
    {
        "id": 4,
        "title": "Endpoint cheat-sheet",
        "body": "GET /notes  GET /notes/{id}  POST /notes  DELETE /notes/{id}  GET /health  GET /metrics",
        "created_at": "2026-01-15T10:15:00Z"
    },
    {
        "id": 5,
        "title": "hello",
        "body": "first POST",
        "created_at": "2026-09-08T10:27:05.276015472Z"
    },
    {
        "id": 1,
        "title": "Welcome to QuickNotes",
        "body": "This is the project you'll containerize, deploy, monitor, and harden across all 10 labs.",
        "created_at": "2026-01-15T10:00:00Z"
    },
    {
        "id": 2,
        "title": "Read app/main.go first",
        "body": "Start by understanding the entry point \u2014 env vars, signal handling, graceful shutdown.",
        "created_at": "2026-01-15T10:05:00Z"
    }
]
```

### `GET /health` (HTTP 200)

```bash
curl -s http://localhost:8080/health | python3 -m json.tool
```

```json
{
    "notes": 5,
    "status": "ok"
}
```
