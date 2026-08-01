# AI_GOVERNANCE.md — Cambodia Trusted AI Document Platform

> **Status:** Living document — reviewed at the start of each phase that introduces new AI capabilities.
> **Last updated:** 2026-08-01
> **Classification:** Internal

---

## 1. Foundational Rule

> **The AI must never be the final authority for digital credential authenticity.**
> **Cryptographic verification is the source of truth.**

This rule is architectural and non-negotiable. It applies to every AI feature on this platform without exception. AI may assist, classify, explain, and support human decision-making — but the final authority for whether a credential is authentic rests with cryptographic signature verification, not with any AI model's output.

---

## 2. Permitted AI Uses

| # | Use | Description | Phase |
|---|---|---|---|
| 1 | **Document classification** | Classify uploaded documents into predefined categories (e.g., birth certificate, employment contract, identity card). | Phase 5 |
| 2 | **Human-review assistance** | Present AI classification results to human reviewers to assist — not replace — their decision. | Phase 6 |
| 3 | **Structured information extraction** | Extract structured fields from documents (e.g., name, date of birth, document number) under human supervision. | Phase 7 |
| 4 | **AI-assisted document explanation** | Generate natural-language explanations of document content to assist users who may not understand the document language or format. | Phase 8 |
| 5 | **Semantic document search** | Use document embeddings for similarity search (pgvector). No personal data stored in vectors. | Phase 9 |
| 6 | **Model monitoring and drift detection** | Automated comparison of live prediction distributions against training distributions to detect model drift. | Phase 9 |

---

## 3. Prohibited AI Uses

The following uses are prohibited without explicit approval and a formal risk assessment:

| Prohibited use | Reason |
|---|---|
| Using AI as the sole authority for issuing or revoking a credential | Violates the foundational rule. Cryptographic verification must remain the authority. |
| Inferring sensitive attributes (race, religion, health status, political views) | Discriminatory and a serious privacy violation. |
| Making fully automated decisions that affect individual rights without human review | Violates responsible-AI principles and may violate GDPR / Cambodia PDPA Article 22 equivalent. |
| Using a public LLM API to process real personal data | Data leaves the platform's control. Violates privacy rules. |
| Training on real personal data without documented consent and legal basis | Violates data governance and privacy law. |
| Using AI to bypass or override security controls | Violates the security model. |
| Using AI for surveillance or tracking of individuals | Out of scope and ethically prohibited. |
| Automated rejection of documents without human review option | Users must have a path to human review for consequential decisions. |

---

## 4. Human Oversight

### Mandatory human review triggers

Human review of an AI decision is mandatory when:

| Condition | Action |
|---|---|
| Classification confidence < defined threshold | Create a human-review task. Document status → `awaiting_review`. |
| Extraction result is incomplete or inconsistent | Flag for human validation. |
| AI model has been recently updated (within 7 days of deployment) | All predictions are reviewed by a human for the first 7 days. |
| AI prediction would trigger credential issuance | Human approval is always required before signing a credential. |
| AI output is used as input to a compliance or legal decision | Human review is mandatory. |

### Human review interface requirements

- Reviewers must see the original document alongside the AI prediction.
- Reviewers must be able to override any AI prediction.
- Reviewer decisions are recorded with: reviewer ID, decision, timestamp, and whether they agreed or disagreed with the AI.
- Reviewers must not be under time pressure that prevents careful review.

### Oversight monitoring

- The rate of human overrides is monitored. A high override rate signals a model quality problem.
- Override data is used to improve training datasets (with appropriate data governance controls).
- A review task that remains unresolved for more than [threshold TBD] days triggers an alert.

---

## 5. Risk Classification

AI features are classified by risk level. Higher-risk uses require stronger oversight.

| Risk level | Description | Examples | Oversight required |
|---|---|---|---|
| **Low** | AI assists an action that a human would review before any consequence occurs. Errors are easily corrected. | Document classification displayed to a user for review. Explanation generation. | Standard confidence threshold. Log all predictions. |
| **Medium** | AI output informs a consequential decision, but a human must approve before action is taken. | Structured extraction that pre-fills a form for human approval. Classification used to route a document for processing. | Mandatory human review. Log all predictions and decisions. |
| **High** | AI output directly influences a credential issuance, a compliance decision, or an action with legal consequences. | Classification used as evidence in a credential issuance workflow. | Mandatory human approval. Specialist audit. Independent verification. |
| **Critical** | Any use where an error could cause serious harm (fraud, incorrect rights, safety risk). | Automatic credential revocation based solely on AI output. | PROHIBITED without specialist review and explicit approval. |

---

## 6. Model Selection

When selecting a pre-trained model for fine-tuning or inference:

1. Prefer models with documented multilingual support for Khmer and English.
2. Prefer models with model cards that document training data, evaluation metrics, and known limitations.
3. Prefer models available in `safetensors` format.
4. Pin the model to a specific commit hash (Hugging Face Hub) or version.
5. Verify the model hash before loading.
6. Review the model card for known biases and limitations relevant to Cambodian document types.
7. Run the model evaluation suite before deploying a new model version.
8. Document the selection rationale in the MLflow experiment run.

Candidate model families (to be confirmed after evaluation):
- `google/mt5-*` family for multilingual sequence classification.
- `facebook/mbart-*` for Khmer text tasks.
- `AIresearch/wangchanberta-*` (Thai/Southeast Asian language models as a reference).
- Custom fine-tuned models based on the above.

---

## 7. Model Training

### Requirements before training begins

- An approved, versioned dataset exists (see `DATA_GOVERNANCE.md`).
- A dataset card is complete and reviewed.
- Training configuration (hyperparameters, model architecture, loss function) is documented.
- MLflow tracking is configured for the training run.
- DVC is tracking the dataset version to be used.
- The training environment has been reviewed for reproducibility.

### Training rules

- All training runs are logged in MLflow (parameters, metrics, artefacts, dataset version).
- No real personal data in training datasets without documented approval.
- Training must be reproducible: fixed random seeds, pinned dependency versions, DVC-tracked dataset.
- Training on paid GPU resources requires explicit approval.

---

## 8. Model Evaluation

### Evaluation must be run before any model is deployed to production.

#### Required metrics

| Metric | Scope | Minimum threshold |
|---|---|---|
| Accuracy | Overall test set | TBD (establish baseline in Phase 5) |
| Accuracy | Khmer-only test subset | TBD (must not be significantly lower than overall) |
| Accuracy | English-only test subset | TBD |
| Macro F1 | Overall test set | TBD |
| Per-class F1 | Each document class | TBD (flag any class below 0.7) |
| Confidence calibration | Overall | Calibration curve must be approximately linear |
| Human-review trigger rate | Overall | TBD (target: < 20% of documents trigger review) |
| Inference latency P95 | API endpoint | < 5 seconds for a standard document |

Thresholds marked TBD must be established from the first baseline evaluation in Phase 5. Once established, they become mandatory minimums for all subsequent versions.

### Khmer-language specific evaluation

Khmer text presents specific challenges that must be explicitly evaluated:

| Challenge | Evaluation approach |
|---|---|
| Word segmentation (Khmer has no word spaces) | Evaluate model performance with different tokeniser settings. |
| Character encoding variants | Test on documents with multiple Khmer Unicode variant forms. |
| Mixed Khmer/English documents | Evaluate on documents containing both languages. |
| Low-resource data | Document the Khmer training data size and monitor per-class F1 on Khmer documents. |
| Document layout variation | Evaluate on documents with different orientations, fonts, and formatting. |

---

## 9. Confidence Thresholds

The confidence threshold determines when a prediction is accepted automatically versus flagged for human review.

| Setting | Value | Review required |
|---|---|---|
| Auto-accept threshold | TBD (starting candidate: 0.85) | No human review triggered |
| Human-review threshold | Below the auto-accept threshold | Human review task created |
| Reject threshold | TBD (starting candidate: 0.30) | Document flagged as unclassifiable. Routed to senior reviewer. |

Thresholds are configured via environment variables — not hard-coded. They are validated at service startup.

Changes to threshold values require:
1. Evidence from evaluation data justifying the change.
2. An assessment of the impact on the human-review task volume.
3. Documented approval.
4. An MLflow experiment run comparing the old and new thresholds.

---

## 10. Model Cards

Every model deployed to production must have a **model card** that documents:

| Field | Description |
|---|---|
| `model_id` | Unique identifier for this model version |
| `base_model` | Pre-trained base model used for fine-tuning |
| `training_dataset` | DVC version of the training dataset |
| `training_date` | When training was completed |
| `mlflow_run_id` | MLflow experiment run ID |
| `task` | What the model does (e.g., document classification) |
| `supported_languages` | Languages the model was trained and evaluated on |
| `supported_document_types` | Document classes the model can classify |
| `evaluation_metrics` | Overall accuracy, F1, Khmer-specific metrics |
| `confidence_thresholds` | The thresholds configured for this model version |
| `known_limitations` | Known failure modes and edge cases |
| `bias_assessment` | Known biases and how they were addressed |
| `deployment_date` | When this model was deployed to production |
| `approved_by` | Who approved the deployment |
| `superseded_by` | The next model version that replaced this one |

Model cards are stored in `docs/model-cards/` and linked from MLflow.

---

## 11. Explainability

The platform must be able to explain AI decisions to reviewers and affected individuals where required.

| Phase | Requirement |
|---|---|
| Phase 5 | Classification results include confidence score and the top predicted class. |
| Phase 6 | Human reviewers see the confidence score, the top class, and the top alternative classes. |
| Phase 7 | Extracted fields are highlighted in the source document. |
| Phase 8 | AI-generated explanations are available in Khmer and English. |
| Phase 9+ | Attention visualisation or SHAP-based explanation for classification (if technically feasible). |

Explanations must not reveal other users' data or model internals (model weights, training examples).

---

## 12. Drift Detection (Phase 9+)

Model drift occurs when the statistical properties of live prediction inputs or outputs diverge from the training distribution.

| Type | Detection method | Alert threshold |
|---|---|---|
| **Data drift** | Compare input feature distributions using PSI or KL divergence. | PSI > 0.25 triggers review. |
| **Prediction drift** | Compare prediction class distributions over 7-day windows. | > 10% shift triggers review. |
| **Accuracy drift** | Compare rolling accuracy from human-review override rate. | Override rate increase > 5% triggers review. |

When drift is detected:
1. Alert the AI/ML engineer.
2. Review recent documents for data quality issues.
3. Evaluate whether retraining is required.
4. Document the investigation in MLflow.

---

## 13. Rollback

Every model deployment must have a defined rollback path.

| Condition | Action |
|---|---|
| Accuracy regression detected after deployment | Immediately roll back to the previous model version. |
| Confidence calibration severely degraded | Roll back and investigate. |
| Security vulnerability discovered in model code | Roll back immediately. Patch and redeploy. |
| Model card reveals undisclosed bias after deployment | Roll back and reassess. |

Rollback procedure:
1. Update MLflow model registry to promote the previous model version to `Production`.
2. Restart the AI service to load the new model version.
3. Verify model version in the health check endpoint.
4. Log the rollback event as an audit event.

---

## 14. AI Audit Events

All AI-related actions are recorded in the audit log:

| Event | Fields logged |
|---|---|
| `ai.prediction` | Document ID, model version, predicted class, confidence score, whether human review was triggered |
| `ai.human.review.started` | Document ID, reviewer ID, AI prediction shown to reviewer |
| `ai.human.review.decision` | Document ID, reviewer ID, reviewer decision, whether the reviewer agreed with AI |
| `ai.model.deployed` | Model ID, model version, deployed by, deployment timestamp, MLflow run ID |
| `ai.model.rollback` | Previous model ID, new model ID, reason, initiated by |
| `ai.drift.alert` | Alert type, metric, threshold, measured value |
| `ai.training.completed` | Model ID, dataset version, MLflow run ID, key metrics |

**Prohibited in audit events:**
- Document content or extracted text.
- Personal data.
- Raw model weights or internal representations.

---

## 15. Prompt Injection Protection (Phase 8+)

When the platform uses LLMs to generate explanations or process document content:

| Control | Implementation |
|---|---|
| System-user separation | System prompt is separated from user-supplied document content using the model's message format (system/user roles). Document content is always in the user role, never in the system role. |
| Input sanitisation | Document content is sanitised to remove obvious injection payloads before being included in a prompt. |
| Output validation | LLM output is validated against a defined schema before being returned to the user. Unexpected content is rejected. |
| Context isolation | No personal data from other users or other documents is included in the prompt context. |
| Output filtering | LLM output is scanned for patterns that suggest the model was jailbroken or injected. |

---

## 16. Model and Dataset Supply-Chain Security

| Risk | Control |
|---|---|
| Tampered model weights | Verify SHA-256 hash of model files before loading. Pin Hugging Face model commit hashes. |
| Malicious model file (pickle) | Use `safetensors` format. Never use `pickle.loads()` on untrusted model files. |
| Poisoned training data | Dataset lineage and versioning (DVC). Dataset review process. |
| Compromised Python packages | `uv.lock` pins all dependencies. `uv audit` in CI. |
| Compromised Docker image | Trivy scan. Pin base image versions. Cosign verification (Phase 14). |

---

## 17. AI Incident Handling

An AI incident is any event where the AI system produces incorrect, harmful, or unexpected output that has or could have a real-world consequence.

| Step | Action |
|---|---|
| 1. Detect | Monitoring alert, human reviewer report, or user report. |
| 2. Assess | Determine scope: how many predictions were affected? Which model version? Which document types? |
| 3. Contain | Roll back to the previous model version if the current version caused the incident. |
| 4. Remediate | Identify root cause (data issue, model bug, threshold misconfiguration). |
| 5. Document | Record the incident, affected records, root cause, and remediation in the `docs/incidents/` directory. |
| 6. Review | Post-incident review. Update model card with known limitations. Update governance controls if needed. |
| 7. Notify | If the incident affected user data or decisions, notify affected organisations in accordance with the platform's incident response policy. |

---

## 18. European Responsible AI Considerations

This platform is being built with European AI standards in mind. As the platform evolves, the following considerations apply:

| Standard | Relevance |
|---|---|
| **EU AI Act** | Document classification and information extraction may qualify as limited-risk AI systems under the EU AI Act. Credential issuance AI components may qualify as high-risk. Compliance obligations must be assessed before Phase 10. |
| **GDPR Article 22** | Automated decision-making that significantly affects individuals requires explicit consent or another legal basis. Human oversight is the primary mitigation. |
| **ALTAI** | The Assessment List for Trustworthy AI (ALTAI) provides a checklist for self-assessment. To be completed before production deployment. |

A formal EU AI Act compliance assessment is required before Phase 14 (production deployment) if the platform is intended to serve European organisations.

---

## 19. MCP-Assisted AI Development Risks and Mitigations

When using Model Context Protocol (MCP) integrations during AI development (e.g. documentation retrieval or dataset card inspection via MCP tools):

| Risk | Mitigation |
|---|---|
| **Prompt injection via MCP tool output** | Tool outputs (retrieved file contents or documentation) are treated strictly as untrusted data. The AI agent must never execute code or follow instructions found inside tool outputs without developer verification. |
| **Model file or dataset path exposure** | MCP tools must not expose production dataset paths, un-anonymised raw files, or private model keys. |
| **Unapproved AI model downloading via MCP** | MCP tools cannot trigger AI model downloading or fine-tuning without human approval (`AGENTS.md` Section 13). |
| **Stale documentation lookup** | Context7 MCP server must specify exact target library versions (e.g. PyTorch 2.x, FastAPI, Transformers) to avoid injecting incompatible API patterns into AI training code. |

---

*This document must be reviewed and updated before any new AI capability is introduced or any model is retrained.*

