# ADR-0009: Optional Development Deployment Pilot (Phase 1)

**Status:** Proposed
**Date:** 2026-08-02
**Context:**
As part of Phase 1 local scaffolding and initial infrastructure setup, there is a need to validate that the local Docker Compose configuration and container artifacts translate correctly to a remote environment without introducing a full Kubernetes rollout (which is reserved for Phase 16) or merging CI with CD. The team requires a pilot mechanism for manual, remote development deployment.

**Decision:**
We will implement an optional, manual development deployment pilot using Docker Compose on a single GCP Compute Engine VM.
- **Workflow:** A dedicated GitHub Actions workflow (`deploy-development.yml`) triggered manually (`workflow_dispatch`).
- **Validation:** The workflow requires a strict 40-character commit SHA (`DEPLOY_SHA`) that must be reachable from `main`.
- **Image Pinning:** Deployment uses immutable image digests for all base images and dependencies (verified via `docker buildx imagetools inspect`).
- **Certificate Handling:** TLS certificates are securely transferred via GCP IAP SSH using `umask 077` and stored outside the Git checkout (`$DEPLOY_CERT_DIR`), ensuring they are never committed to the repository or leaked via base64 encoded environment variables.
- **Network Scope:** The frontend runs internally on port `8080` and is exposed only via Caddy on ports `80` and `443`. Backend and databases remain private.

**Consequences:**
- Validation of production-like image builds without the complexity of Kubernetes in Phase 1.
- Clear separation of CI (`ci.yml`) and CD (`deploy-development.yml`), enforcing the principle of least privilege.
- Stronger guarantees around deployment traceability by validating `DEPLOY_SHA`.
- Temporary maintenance of two Caddy profiles (local and deployment) until further infrastructure phases unify the ingress layer.
