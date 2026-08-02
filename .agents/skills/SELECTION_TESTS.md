# Skill selection checks

These non-destructive checks verify the smallest matching skill set. They do not execute skill scripts or modify application code. All selected `SKILL.md` files were loaded completely during the review.

| Prompt | Selected skills and reason | Correctly excluded | Ambiguous trigger | Full SKILL.md loaded |
|---|---|---|---|---|
| Design the initial NestJS and FastAPI service boundaries. | None; repository architecture and ADRs already define this boundary. | Security skills because this is not an explicit security request; roadmap-only architecture skills. | No. | Not applicable. |
| Create a PostgreSQL multi-tenant schema. | None; schema changes require human approval and no trusted, compatible PostgreSQL skill was approved. | Rejected generic PostgreSQL reviewer; security skills because schema creation is not a security audit. | Approval is required before implementation. | Not applicable. |
| Threat-model document upload and processing. | `security-threat-model`; this is an explicit threat-model request. | `security-best-practices` because the smallest set is the dedicated threat-model skill until implementation review is requested. | No. | Yes. |
| Design a secure AI-inference endpoint. | `security-best-practices`; explicit secure implementation for the FastAPI service. | `security-threat-model` because the prompt requests endpoint design, not a threat model. | The architecture boundary must be confirmed from repository evidence. | Yes. |
| Create tests for Khmer document validation. | None; use repository testing rules until a reviewed multilingual/data-quality skill is needed. | Generic Jest and pytest-coverage skills due convention and dependency conflicts. | Test layer and implemented validator are not specified. | Not applicable. |
| Design credential issuance using OpenID4VCI. | None; credential work is Phase 3 and security-critical specifications require dedicated review. | General security skills because they do not supply protocol authority. | Stable specification versions and approved identity architecture are unresolved. | Not applicable. |
| Investigate a failing Docker Compose health check. | `systematic-debugging`; the request is evidence-first diagnosis of a failure. | `multi-stage-dockerfile` unless evidence identifies a Dockerfile cause. | Dockerfile skill may be added after root-cause evidence. | Yes. |
| Review the API for insecure defaults. | `security-best-practices`; this is an explicit security review. | `security-threat-model` because the prompt does not request abuse-path modeling. | NestJS uses Express, so the Express reference is supporting guidance rather than NestJS-specific authority. | Yes. |
| Create an Angular document-upload workflow. | `frontend-design` for the user-facing workflow, hierarchy, responsive behavior, accessibility, and interface copy. | Browser/Playwright because this prompt is implementation rather than E2E testing; security skills unless secure upload handling is explicitly requested. | Backend upload contracts and trust-boundary controls remain governed by architecture and security rules. | Yes. |
| Plan an MLflow and DVC model lifecycle. | None; this is Phase 4 roadmap work and not current implementation. | Jupyter, model-training, and data-lifecycle candidates. | No. | Not applicable. |

Additional routing coverage:

| Prompt | Selected skills and reason | Correctly excluded | Ambiguous trigger | Full SKILL.md loaded |
|---|---|---|---|---|
| Optimize a production Dockerfile. | `multi-stage-dockerfile`; exact container-image scope. | Deployment and infrastructure skills because optimization does not authorize deployment. | Human approval remains required for infrastructure changes. | Yes. |
| Address concrete review feedback and verify the fix. | `receiving-code-review`, then `verification-before-completion`; review evidence followed by proof before completion. | Debugging unless the feedback describes a reproducible defect. | No. | Yes. |
| Improve the UX/UI of the Angular administration dashboard. | `frontend-design`; this is an explicit material interface-design request. | Security and debugging skills unless the request separately identifies those concerns. | Existing design-system constraints must be discovered before visual changes. | Yes. |
