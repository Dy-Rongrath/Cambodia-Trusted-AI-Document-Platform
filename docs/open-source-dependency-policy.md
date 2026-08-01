# Open-Source Dependency & Asset Policy — Cambodia Trusted AI Document Platform

> **Status:** Active project policy.
> **Scope:** Applies to all application, infrastructure, AI/ML, and documentation dependencies.

---

## 1. Purpose

Dependencies and third-party assets introduce legal, security, and operational supply-chain risks. This policy defines the evaluation and approval requirements for introducing new third-party software dependencies, datasets, model weights, fonts, icons, or assets to the platform.

---

## 2. Mandatory Approval Process

Before adding any new dependency to `package.json`, `pyproject.toml`, Docker base images, or repository assets:

1. Search existing codebase and ADRs to confirm an equivalent capability does not already exist.
2. Complete the dependency evaluation checklist below.
3. For major or security-critical dependencies, submit an Architecture Decision Record (ADR) or task proposal for maintainer review ([AGENTS.md](../AGENTS.md) Section 7).

### Evaluation Checklist

Every proposed dependency must document:

- **Package Name & Version:** Exact pinned version tag.
- **Purpose:** Clear justification of why the dependency is necessary.
- **Official Source:** Package repository URL (e.g. npm, PyPI, official GitHub).
- **Maintainer / Publisher:** Active development entity or community maintainer.
- **Licence:** SPDX licence identifier.
- **Maintenance & Health Status:** Recent commits, release history, open issues.
- **Security Advisory Status:** No unpatched critical/high CVEs (`npm audit` / `uv audit`).
- **Apple Silicon / ARM64 Compatibility:** Confirmed native execution on Apple Silicon M5 without forced x86/AMD64 emulation.
- **Classification:** Runtime dependency or Development-only dependency.
- **Alternatives Considered:** Reason why alternatives were rejected.

## 3. Unified Licensing Evaluation Rule

Every dependency and third-party asset must have a known licence and complete the project dependency-review process.

Licences in the generally approved list below may be accepted through normal maintainer review. Copyleft, weak-copyleft, source-available, custom, unlicensed, or commercially restricted terms require explicit maintainer and legal review before adoption. No licence is automatically prohibited solely by name, and no licence is automatically approved solely because it is OSI-approved. Review must evaluate distribution obligations, hosted-service obligations, static vs dynamic linking, modification disclosure, commercial restrictions, compatibility with Apache-2.0, and model/dataset-specific usage terms.

### Generally Approved Permissive Licences

The following permissive open-source licences are generally approved for runtime and development use:

| Licence | SPDX Identifier | Status |
|---|---|---|
| **Apache License 2.0** | `Apache-2.0` | Preferred |
| **MIT License** | `MIT` | Approved |
| **BSD 2-Clause / 3-Clause** | `BSD-2-Clause` / `BSD-3-Clause` | Approved |
| **ISC License** | `ISC` | Approved |
| **PostgreSQL License** | `PostgreSQL` | Approved |
| **Python Software Foundation License** | `PSF-2.0` | Approved |

---

## 4. Licences Requiring Additional Review

Dependencies or assets using the following licences require explicit maintainer and legal review before adoption:

| Licence Family | Examples | Review Focus |
|---|---|---|
| Weak Copyleft | LGPL-2.1 / LGPL-3.0, MPL-2.0, EPL-2.0, CDDL-1.0 | Dynamic vs static linking, modification disclosure obligations. |
| Strong Copyleft | GPL-2.0 / GPL-3.0, AGPL-3.0 | Source disclosure requirements for application code or hosted SaaS. |
| Source-Available / Non-Open-Source | SSPL, BSL / BUSL, Elastic License, Commons Clause | Commercial deployment restrictions and license compatibility. |
| Custom / Unlicensed | Proprietary or missing licence files | Cannot be used without explicit legal clarification. |

---

## 5. Third-Party Asset Licensing Scope

To maintain clear legal boundaries across the project:

| Asset Category | Licensing Policy |
|---|---|
| **Application & Infra Code** | Licensed under [Apache License 2.0](../LICENSE). Project copyright recorded in [NOTICE](../NOTICE). |
| **Documentation** | Licensed under [Apache License 2.0](../LICENSE). |
| **Training Code** | Licensed under [Apache License 2.0](../LICENSE) (unless upstream dependency requires copyleft). |
| **Third-Party Standard Texts** | DCO 1.1 and Contributor Covenant 2.1 retain their upstream copyrights and terms in [THIRD_PARTY_NOTICES.md](../THIRD_PARTY_NOTICES.md) and are NOT relicensed under Apache-2.0. |
| **Datasets** | Subject to individual dataset licences. Documented via Dataset Cards. Apache-2.0 does not automatically apply. |
| **Model Weights** | Subject to individual model weight licences (e.g. Hugging Face OpenRAIL, Llama license, etc.). Documented via Model Cards. |
| **Third-Party Models** | Original upstream licence applies. Must be reviewed for commercial and privacy compatibility. |
| **Fonts, Icons & Media** | Original asset licence applies (e.g. SIL Open Font License, Creative Commons). |
| **User-Uploaded Documents** | Private tenant data — strictly excluded from open-source distribution. |

---

## 6. Dependency Minimisation & Local-First Principles

- **Avoid Heavy Dependencies:** Prefer lightweight, standard-library, or decoupled solutions over monolithic frameworks where appropriate.
- **Zero Required Paid Cloud Services:** All dependencies must support local development on Apple Silicon M5 without requiring paid cloud API keys or cloud subscriptions during early phases.
- **Vendor Lock-in Avoidance:** Standardized protocols (REST, OpenAPI, OIDC, S3 API, OpenTelemetry) must be used to ensure platform portability.
