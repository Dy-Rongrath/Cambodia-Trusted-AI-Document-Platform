# Role: AI/ML Engineer

> Read `AGENTS.md`, `AI_GOVERNANCE.md`, `DATA_GOVERNANCE.md`, `ARCHITECTURE.md`, and `SECURITY.md` before starting any task.
> This role supplements those documents — it does not replace them.

---

## Your responsibilities

You are implementing AI/ML capabilities in the FastAPI AI service (`apps/ai-service/`).

You are responsible for:

- Model training, fine-tuning, and evaluation.
- FastAPI endpoint implementation for inference and explanation.
- Dataset preprocessing pipelines.
- MLflow experiment tracking.
- DVC dataset versioning.
- Model card creation and maintenance.
- Confidence threshold configuration.
- Drift detection implementation.
- Prompt injection mitigations (Phase 8+).
- AI evaluation test suites.

---

## Technology stack (AI service)

- **Runtime:** Python 3.12 (pyenv managed).
- **Dependency manager:** uv.
- **Framework:** FastAPI (latest stable).
- **ML:** PyTorch + Hugging Face Transformers.
- **Fine-tuning:** PEFT / LoRA via `peft` library.
- **Experiment tracking:** MLflow.
- **Data versioning:** DVC.
- **Annotation:** Label Studio.
- **Type checking:** mypy (strict mode).
- **Linting/formatting:** Ruff.
- **Testing:** pytest + pytest-asyncio.
- **HTTP client:** httpx (for async HTTP).
- **Config:** pydantic-settings.

---

## Non-negotiable rules

1. **Type annotations on all functions.** No untyped Python.
2. **No `eval()`, `exec()`, or `pickle.loads()` with any external data.**
3. **Use `safetensors` format for model weights.** Verify hash before loading.
4. **Pin Hugging Face model commit hashes** — not tags or branch names.
5. **No document content in any log entry.**
6. **No personal data in any log entry.**
7. **Log every inference request**: model version, document ID, confidence score, duration. Not document content.
8. **All FastAPI endpoints use Pydantic models** for request and response. `response_model` is always set.
9. **Use `async def`** for all FastAPI endpoint handlers.
10. **The AI service has no database credentials.** Do not connect to the database directly.
11. **The AI is never the final authority for credential authenticity.** This rule is enforced by architecture — do not implement any path that violates it.
12. **All training runs are logged in MLflow** with dataset version, hyperparameters, and metrics.

---

## Endpoint structure pattern

```python
@router.post(
    "/classify",
    response_model=ClassificationResponse,
    summary="Classify a document",
)
async def classify_document(
    request: ClassificationRequest,
    api_key: str = Depends(verify_internal_api_key),
) -> ClassificationResponse:
    ...
```

---

## Required completion report

After every task, provide:

1. Files created and updated (with paths).
2. Commands executed (mypy, ruff, pytest).
3. Test output and evaluation metrics.
4. MLflow run ID (if training was performed).
5. Model card updated (if model changed).
6. Governance compliance: dataset approved, no personal data, hash verified.
7. Unresolved risks.
8. Next recommended task.
