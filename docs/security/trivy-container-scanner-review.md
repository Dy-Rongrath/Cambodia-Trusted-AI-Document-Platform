# Trivy Container Scanner Dependency Review

> **Status:** Approved for the CI container-image gate.
> **Review date:** 2026-08-02
> **Classification:** Development-only CI security tool.

## Evaluation

| Requirement              | Evidence and decision                                                                                                                                                                                                                                                                                                                                          |
| ------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Package and version      | `aquasec/trivy:0.72.0`, pinned to multi-platform index digest `sha256:cffe3f5161a47a6823fbd23d985795b3ed72a4c806da4c4df16266c02accdd6f`                                                                                                                                                                                                                        |
| Purpose                  | Scan the backend, AI-service, and frontend final runtime images for operating-system and language-package vulnerabilities before CI accepts them.                                                                                                                                                                                                              |
| Official source          | [Aqua Security Trivy](https://github.com/aquasecurity/trivy) and the [v0.72.0 immutable release](https://github.com/aquasecurity/trivy/releases/tag/v0.72.0)                                                                                                                                                                                                   |
| Maintainer / publisher   | Aqua Security open-source project; active release and issue history at review time.                                                                                                                                                                                                                                                                            |
| Licence                  | `Apache-2.0`, a generally approved project licence. See the [v0.72.0 licence](https://github.com/aquasecurity/trivy/blob/v0.72.0/LICENSE).                                                                                                                                                                                                                     |
| Security advisory status | The March 2026 Trivy ecosystem compromise affected specific 0.69.x artifacts and mutable action tags. Version 0.72.0 post-dates that incident. CI does not use `trivy-action` or `setup-trivy`, and the container is referenced by immutable digest. See [GHSA-69fq-xp46-6x23](https://github.com/aquasecurity/trivy/security/advisories/GHSA-69fq-xp46-6x23). |
| ARM64 compatibility      | The pinned index was inspected with `docker buildx imagetools inspect` and contains native `linux/amd64` and `linux/arm64` manifests.                                                                                                                                                                                                                          |
| Classification           | Development-only container executed by CI; it is not copied into any application image and is not deployed.                                                                                                                                                                                                                                                    |
| Data and permissions     | Receives only a read-only archive of each locally built runtime image and a disposable cache volume. It receives no Docker socket, repository mount, application secret, cloud credential, tenant data, or production access. Network access is used to retrieve the vulnerability database.                                                                   |

## Gate Policy

The runtime smoke script invokes Trivy with:

- vulnerability scanning only (`--scanners vuln`);
- `HIGH,CRITICAL` severities;
- non-zero exit status for a matching finding;
- `--ignore-unfixed`, so CI blocks vulnerabilities for which the advisory database identifies an available vendor fix.

This distinction is necessary because the current Debian vulnerability feed reports High/Critical findings
without fixed packages even for the latest supported official Python 3.12 slim image. Permanently failing on
findings that have no vendor remediation would make the gate non-actionable. Unfixed findings remain a
tracked base-image risk and must be reassessed when the vulnerability database or official image changes.

The scanner database is mutable security intelligence. A passing result therefore means no matching fixable
finding was known to the database downloaded during that run; it is not a permanent security guarantee.

## Alternatives Considered

| Alternative                 | Decision                                                                                                                                                              |
| --------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `aquasecurity/trivy-action` | Rejected. It adds a second action-wrapper supply chain and was directly affected by the 2026 incident. The pinned container is simpler and receives fewer privileges. |
| Grype                       | Rejected for this task because it would introduce a separate scanner without an existing repository standard or a material capability benefit.                        |
| Docker Scout                | Rejected because it adds Docker-specific service integration and weaker local-first portability.                                                                      |
| Host package installation   | Rejected because host-installed scanner versions are harder to reproduce across CI and Apple Silicon development environments.                                        |

## Review Decision and Residual Risk

Approved for the scoped CI use above. The highest residual risks are vulnerability-database false positives or
delays, unfixable upstream distribution findings, and compromise of a future scanner or database artifact.
Digest pinning, no secret mounts, no Docker socket, disposable cache storage, and periodic version review limit
the impact. Changing the scanner image or broadening its permissions requires a new dependency review.
