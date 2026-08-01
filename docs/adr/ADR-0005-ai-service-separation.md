# ADR-0005 — Separate Python FastAPI Service for AI Inference

## Status

`Accepted`

## Decision Owner / Approved By

Dy Rongrath, Project Owner — approved through review and merge of PR #1 on 2026-08-01.

## Date

2026-08-01

## Context

The platform requires AI-powered document classification, information extraction, and explanation generation. These capabilities require:

- PyTorch for model training and inference.
- Hugging Face Transformers for pre-trained multilingual models.
- Python-native ML libraries (NumPy, scikit-learn, etc.).

The main application backend is written in TypeScript and runs on Node.js. Combining Python ML dependencies with a Node.js process is technically possible (via child processes or native modules) but creates significant operational complexity, runtime conflicts, and dependency management problems.

A decision is needed on how to integrate AI capabilities into the platform architecture.

## Decision

We will run AI inference and training as a **separate Python FastAPI service** (`apps/ai-service/`) that communicates with the NestJS backend over a well-defined internal HTTP API.

This is not a microservice in the distributed systems sense. During Phase 0–9, it runs as a single Docker Compose service on the same machine as the backend. The HTTP boundary is a clean architectural separation — not a performance optimisation.

Internal communication:
- The NestJS backend sends classification requests to the FastAPI service via HTTP POST.
- The FastAPI service returns predictions, confidence scores, and explanations.
- The FastAPI service does not call back to the NestJS backend — it is stateless from the backend's perspective.
- The FastAPI service does not have direct database access.

Service communication is on a private Docker network — not exposed externally.

Authentication between backend and AI service: The backend sends a shared internal API key in the `X-Internal-Api-Key` header. This key is set via environment variables and rotated regularly. A more robust solution (mTLS or service tokens) is a Phase 14 consideration.

## Alternatives Considered

| Option | Description | Why rejected |
|---|---|---|
| Child process from Node.js | Spawn Python as a child process from the NestJS backend | Brittle. Process lifecycle management in Node.js is error-prone. No independent scaling. Log management is complex. Cannot use a Python virtual environment cleanly. Rejected. |
| Python native modules in Node.js | Use `node-gyp` or WebAssembly-compiled ML libraries | No meaningful PyTorch support via this path. ONNX Runtime for Node.js exists but does not support training or fine-tuning. Only partial inference support. Insufficient for this platform. |
| Node.js ML libraries only (TensorFlow.js, ONNX Runtime) | Use JavaScript-native ML libraries | TensorFlow.js and ONNX Runtime for Node.js cannot replace PyTorch for training and fine-tuning. The Hugging Face Transformers ecosystem is Python-first. Rejected. |
| Separate deployed microservice from day one | Deploy the AI service independently on a separate machine | Premature. Docker Compose on a single machine is sufficient for Phase 0–9. Independent deployment can be enabled in Phase 14 by extracting the service from the Compose file. |

## Consequences

### Positive consequences
- Clean language and runtime separation. Python dependencies never conflict with Node.js dependencies.
- The FastAPI service can be independently upgraded, replaced, or scaled without touching the NestJS backend.
- Python's ML ecosystem (PyTorch, Hugging Face, scikit-learn) is available without compromise.
- FastAPI provides automatic OpenAPI documentation for the internal AI API.
- The AI service can be developed and tested independently.
- Deployment scaling: the AI service can be independently scaled to GPU instances when needed.

### Negative consequences / trade-offs
- Two services to start locally (`backend` + `ai-service` in Docker Compose).
- Two sets of logs, two healthcheck endpoints.
- A network hop between backend and AI service (negligible latency for document classification — typically milliseconds on a local network).
- Two language toolchains for contributors to understand (TypeScript + Python).
- The internal API contract must be maintained carefully — breaking changes require coordinated updates.

### Neutral consequences
- The AI service is developed in `apps/ai-service/` with its own `pyproject.toml` and `uv.lock`.
- The FastAPI service exposes an internal-only API (not accessible from outside Docker Compose).
- A shared OpenAPI schema for the internal AI API will be maintained in `packages/shared-types/` as a reference.

## Security Impact

The AI service must:
- Not be reachable from outside the Docker network.
- Validate the internal API key on every request.
- Validate all input received from the backend (treat the backend as untrusted — defence in depth).
- Never log document content, personal data, or internal API keys.
- Use `safetensors` format for model weights — never `pickle` for production models.
- Validate model integrity before loading.

A future improvement (Phase 14): Replace the shared API key with mTLS between the backend and AI service.

## Privacy Impact

The AI service processes document content for classification. Document content must:
- Never be logged.
- Never be stored by the AI service.
- Be held in memory only for the duration of a single inference request.
- Never be sent to an external AI API or service.

## Operational Impact

- Local development: FastAPI service runs in Docker Compose alongside the backend.
- GPU inference: The Docker Compose service can be given a GPU device allocation when running on a GPU host.
- Production: The AI service can be deployed as a separate Kubernetes Deployment on GPU nodes (Phase 14).
- Health: The FastAPI service exposes `/health` for Docker and Kubernetes health checks.
- Metrics: The FastAPI service exposes Prometheus metrics at `/metrics` (Phase 4+).

## Migration Impact

The HTTP boundary between backend and AI service means the internal implementation can be replaced independently. If a different inference framework (e.g., vLLM for large models) is required in Phase 8+, it replaces the AI service implementation without touching the NestJS backend — as long as the API contract is maintained.

## Review Conditions

- Review if latency between backend and AI service becomes a bottleneck (measure first, optimise if P95 > 5 seconds for classification).
- Review if a zero-copy memory sharing mechanism is required for very large documents.
- Review in Phase 14 when independent scaling and GPU node allocation is implemented.
