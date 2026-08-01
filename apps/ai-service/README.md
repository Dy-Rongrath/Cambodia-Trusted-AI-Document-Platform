# trusted-ai-service

FastAPI AI Service for Cambodia Trusted AI Document Platform — Phase 1 Scaffold.

## Execution

This service runs inside Docker via Docker Compose.

```bash
# Start all development services including AI service
./scripts/docker/start.sh

# Run quality gates (Ruff, mypy, pytest) inside Docker
./scripts/docker/lint.sh
./scripts/docker/typecheck.sh
./scripts/docker/test.sh
```
