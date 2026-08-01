# ADR-0008: Local Object-Storage Strategy Evaluation

- **Status:** Proposed
- **Date:** 2026-08-01
- **Deciders:** Dy Rongrath (Project Owner / Lead Maintainer)
- **Consulted:** Architecture Reviewer, Security Reviewer, DevSecOps Specialist
- **Informed:** Core Contributors

---

## Context and Problem Statement

The platform architecture requires S3-compatible object storage to store uploaded documents (`Restricted` and `Confidential` data classifications) starting in Phase 4 (Secure Document Upload).

Earlier documentation specified MinIO as the mandatory local object-storage service in Docker Compose for Phase 1. However, object-storage requirements do not need to be locked in Phase 1 before document upload features are introduced. Furthermore, object-storage technology selection must be evaluated against maintenance status, upstream security update practices, licensing, ARM64 / Apple Silicon native execution, memory/CPU footprint, Docker image availability, S3 API compatibility, and solo-developer operational complexity.

We need an architectural decision framework to evaluate object-storage options for local development and future production without forcing premature container dependencies in Phase 1.

---

## Decision Drivers

1. **Licensing & Open-Source Status:** Licensing clarity (e.g. Apache-2.0, AGPL, BSL) and compatibility with platform commercial neutrality.
2. **Local-First & Low-Resource Footprint:** Lightweight CPU and memory consumption during local development on Apple Silicon M5 (ARM64).
3. **S3 API Compatibility:** High fidelity for standard S3 API operations (PutObject, GetObject, DeleteObject, presigned URLs, multipart uploads).
4. **Upstream Maintenance & Security:** Active open-source community, transparent security advisory process, and clean Docker image distribution.
5. **Solo-Developer Maintainability:** Low setup and operational complexity for a single maintainer.
6. **Future Migration & Production Path:** Smooth transition from local development to managed S3 or self-hosted S3-compatible storage in production (Phase 16).

---

## Considered Options

### Option 1: Defer Object-Storage Container Selection to Phase 4 (Recommended Default)
- **Description:** Phase 1 scaffolding includes PostgreSQL 17 and optional Keycloak 26 containers only. Object-storage container integration is deferred until Phase 4 (Secure Document Upload) when file storage APIs are implemented.
- **Pros:** Keeps Phase 1 Docker Compose environment minimal and fast to start. Avoids premature container dependencies before file upload code exists.
- **Cons:** Document storage container is not verified until Phase 4.

### Option 2: Local-Filesystem Adapter for Development
- **Description:** Implement a storage abstraction module (`StorageModule`) in NestJS with a local filesystem driver (`LocalStorageDriver`) for Phase 1–3 local development, and an S3 driver (`S3StorageDriver`) for Phase 4+.
- **Pros:** Zero container overhead. Extremely fast local execution. Simple backup and clean setup.
- **Cons:** S3 API behavior (e.g. presigned URLs, S3 headers) is simulated rather than executed against a real S3 endpoint in local development.

### Option 3: Garage S3 Storage
- **Description:** [Garage](https://garagehq.deuxfleurs.fr/) is an open-source (AGPLv3), lightweight, self-hosted object-storage service written in Rust.
- **Pros:** Extremely low resource consumption, native ARM64 / Apple Silicon support, clean single-binary Docker image, simple configuration.
- **Cons:** AGPLv3 licence requires review for commercial distribution if bundled; designed primarily for self-hosted cluster deployment.

### Option 4: SeaweedFS S3 Gateway
- **Description:** [SeaweedFS](https://github.com/seaweedfs/seaweedfs) is an open-source (Apache 2.0) distributed storage system with built-in S3 API support written in Go.
- **Pros:** Apache 2.0 licensed, fast file handling, native ARM64 support, active maintenance.
- **Cons:** Multi-component architecture (Master, Volume, S3 Gateway) introduces slight configuration complexity for local dev.

### Option 5: MinIO / MinIO AIStor Community Edition
- **Description:** [MinIO](https://min.io/) is an AGPLv3-licensed object storage server widely used in local development.
- **Pros:** Excellent S3 API compatibility, widely known tooling, robust documentation.
- **Cons:** AGPLv3 licence requires legal care; memory footprint is higher than lightweight alternatives; recent upstream licensing and branding changes require ongoing review.

---

## Evaluation Matrix

| Criterion | Option 1 (Defer to Ph 4) | Option 2 (LocalFS) | Option 3 (Garage) | Option 4 (SeaweedFS) | Option 5 (MinIO) |
|---|---|---|---|---|---|
| **Phase 1 Dependency** | None | None | Docker container | Docker container | Docker container |
| **Licence** | N/A | Apache-2.0 | AGPLv3 | Apache-2.0 | AGPLv3 |
| **S3 API Fidelity** | N/A | Simulated | High | High | Very High |
| **Resource Footprint** | Zero | Near Zero | Very Low (<30MB RAM) | Low (<50MB RAM) | Moderate (~150MB+ RAM) |
| **ARM64 / Apple Silicon** | Native | Native | Native | Native | Native |
| **Solo Developer Fit** | Excellent | Excellent | Good | Good | Fair |

---

## Proposed Strategy & Next Steps

1. **Phase 1 Implementation:** Phase 1 proceeds with PostgreSQL 17 and optional Keycloak 26 in `infra/docker/docker-compose.yml`. Object-storage container integration is not mandatory in Phase 1.
2. **Backend Abstraction:** NestJS `StorageModule` will be designed with a driver interface (`StorageDriver`) to decouple application logic from the underlying storage provider.
3. **Maintainer Approval:** Dy Rongrath will review and select the final object-storage container strategy prior to Phase 4 (Secure Document Upload).

---

## Consequences

- Phase 1 scaffolding is lightweight and free of unreviewed object-storage container dependencies.
- Developers can bootstrap local infrastructure quickly without downloading unnecessary storage containers during early authentication and foundation work.
- Final provider selection remains gated until explicit maintainer approval.
