# ADR-0008: Local Object-Storage Strategy Evaluation

- **Status:** Proposed
- **Date:** 2026-08-01
- **Deciders:** Dy Rongrath (Project Owner / Lead Maintainer)
- **Consulted:** None — solo-development stage
- **Informed:** Public repository readers and future contributors

---

## Context and Problem Statement

The platform architecture requires S3-compatible object storage to store uploaded documents (`Restricted` and `Confidential` data classifications) starting in Phase 4 (Secure Document Upload).

Earlier documentation specified MinIO as the mandatory local object-storage service in Docker Compose for Phase 1. However, object-storage requirements do not need to be locked in Phase 1 before document upload features are introduced. Furthermore, object-storage technology selection must be evaluated against maintenance status, upstream security update practices, licensing, ARM64 / Apple Silicon native execution, memory/CPU footprint, Docker image availability, S3 API compatibility, and solo-developer operational complexity.

We need an architectural decision framework to evaluate object-storage options for local development and future production without forcing premature container dependencies in Phase 1.

---

## Decision Drivers

1. **Licensing & Open-Source Status:** Licensing clarity (e.g. Apache-2.0, AGPL, commercial subscription) and compatibility with platform commercial neutrality.
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

### Option 2: Local-Filesystem Adapter (Deferred to Phase 4)
- **Description:** Implement a storage abstraction in NestJS with a local filesystem driver for development and an S3 driver for cloud/production when storage code is created in Phase 4.
- **Pros:** Zero container overhead in local development. Extremely fast execution and simple local setup.
- **Cons:** S3 API behavior (e.g. presigned URLs, S3 headers) is simulated rather than executed against a real S3 endpoint in local development.

### Option 3: Garage S3 Storage
- **Description:** [Garage](https://garagehq.deuxfleurs.fr/) is an open-source, lightweight, self-hosted object-storage service written in Rust, licensed under **AGPLv3**.
- **Pros:** Low resource consumption, native ARM64 / Apple Silicon support, clean single-binary distribution, simple configuration.
- **Cons:** AGPLv3 licence requires legal review for distribution/hosting obligations; designed primarily for self-hosted cluster deployment.

### Option 4: SeaweedFS S3 Gateway
- **Description:** [SeaweedFS](https://github.com/seaweedfs/seaweedfs) is an open-source, actively maintained distributed storage system with built-in S3 API gateway support written in Go, licensed under **Apache 2.0**.
- **Pros:** Permissive Apache 2.0 licence, fast file handling, native ARM64 support, active open-source maintenance.
- **Cons:** Multi-component architecture (Master, Volume, S3 Gateway) introduces slight configuration complexity for local development.

### Option 5: MinIO / MinIO AIStor Offerings
- **Description:** [MinIO](https://min.io/) is an S3-compatible object storage server.
- **Licensing & Upstream Status:** The open-source `minio/minio` repository is archived and is no longer an actively maintained open-source option for new platform adoption. MinIO AIStor Free may be available at no monetary cost for eligible single-node deployments. However, it is governed by proprietary licence terms and is not an open-source replacement for the archived `minio/minio` community repository. Its modification, redistribution, activation, deployment, and support terms must be reviewed before it can be considered for this project.
- **Pros:** High S3 API compatibility, widely known tooling and documentation.
- **Cons:** Upstream community repository is archived/unmaintained; AIStor Free remains proprietary with restrictions on modification/redistribution; commercial subscription terms apply for enterprise features.

---

## Evaluation Matrix

| Criterion | Option 1 (Defer to Ph 4) | Option 2 (LocalFS) | Option 3 (Garage) | Option 4 (SeaweedFS) | Option 5 (MinIO / AIStor) |
|---|---|---|---|---|---|
| **Phase 1 Dependency** | None | None | Docker container | Docker container | Docker container |
| **Licence** | N/A | Apache-2.0 | AGPLv3 | Apache-2.0 | Archived AGPLv3 source / proprietary AIStor Free or commercial terms |
| **S3 API Fidelity** | N/A | Simulated | High | High | Very High |
| **Resource Footprint** | Zero | Near Zero | Very Low | Low | Moderate |
| **ARM64 / Apple Silicon** | Native | Native | Native | Native | Native |
| **Solo Developer Fit** | Excellent | Excellent | Good | Good | Fair |

*Note: Qualitative resource footprint estimates must be benchmarked on the maintainer's Apple Silicon Mac before provider approval in Phase 4.*

---

## Proposed Strategy & Next Steps

1. **Phase 1 Implementation:** Phase 1 proceeds with PostgreSQL 17 and optional Keycloak 26 in `infra/docker/docker-compose.yml`. Object-storage container integration is not mandatory in Phase 1.
2. **Storage Abstraction Timing:** A storage interface may be introduced in Phase 4 after the provider decision is approved. Phase 1 must not create unused storage abstractions.
3. **Maintainer Approval:** Dy Rongrath will review and select the final object-storage container strategy prior to Phase 4 (Secure Document Upload).

---

## Consequences

- Phase 1 scaffolding is lightweight and free of unreviewed object-storage container dependencies.
- Developers can bootstrap local infrastructure quickly without downloading unnecessary storage containers during early authentication and foundation work.
- Premature engineering of unused storage interfaces in Phase 1 is prevented.
- Final provider selection remains gated until explicit maintainer approval prior to Phase 4.
