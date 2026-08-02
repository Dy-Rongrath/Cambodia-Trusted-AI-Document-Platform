# Project-local skill inventory

All installed skills are pinned to the reviewed source commit. Repository rules in `AGENTS.md` override skill guidance.

The `systematic-debugging`, `multi-stage-dockerfile`, and `frontend-design` frontmatter descriptions are locally hardened with narrower triggers and explicit exclusions; their workflow bodies remain unchanged from the pinned sources. Modified third-party files carry local modification notices where required by their licenses.

| Skill | Source | Reviewed commit | License | Scope |
|---|---|---|---|---|
| security-best-practices | openai/skills | 49f948faa9258a0c61caceaf225e179651397431 | Apache-2.0 | Explicit secure-coding review or implementation |
| security-threat-model | openai/skills | 49f948faa9258a0c61caceaf225e179651397431 | Apache-2.0 | Explicit threat-model requests |
| systematic-debugging | obra/superpowers | 44c9b2d6e889982ac18c27d05a19fefe335194e1 | MIT | Evidence-first diagnosis of failures |
| verification-before-completion | obra/superpowers | 44c9b2d6e889982ac18c27d05a19fefe335194e1 | MIT | Verification before completion claims |
| receiving-code-review | obra/superpowers | 44c9b2d6e889982ac18c27d05a19fefe335194e1 | MIT | Evaluate and address review feedback |
| multi-stage-dockerfile | github/awesome-copilot | 336af71f1b7d2e6e15a8a986ba79ca031a40549b | MIT | Dockerfile-only image optimization |
| frontend-design | anthropics/skills | b29e7cf65e5cb78a5ac33d582270551bc74a14eb | Apache-2.0 | Explicit UX/UI design and material interface redesign |

## Candidate classification

- Install now: the seven skills above.
- Install later: Playwright/browser testing, Sentry, Jupyter/PDF, and ML/data skills when their corresponding implementation phases begin.
- Duplicate: architecture blueprint, writing plans, GitHub PR/CI skills, and browser-control skills; repository guidance or already-installed plugins cover them.
- Explicit-only: both installed security skills; deployment, database migration, authentication, cryptography, CI/CD, and MCP changes remain governed by human approval in `AGENTS.md`.
- Not relevant now: cloud, Kubernetes, broker, mobile, credential-protocol, and production ML skills for roadmap-only technologies.
- Rejected: Trail of Bits skills pending license/legal review; brainstorming server tooling due telemetry/background-process behavior; test-driven-development due conflicting mandatory workflow; PostgreSQL review due unsafe/incompatible recommendations; generic Jest/pytest skills due convention and dependency conflicts.

No skill may deploy, push, commit, apply migrations, rotate keys, alter identity-provider configuration, or access credentials or production data without the repository's explicit approval requirements.
