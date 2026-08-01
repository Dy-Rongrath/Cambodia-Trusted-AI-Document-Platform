# Task Template: AI Experiment

> Use this template for every new model training experiment. Complete all sections before starting training.

---

## Objective

[What is being trained, fine-tuned, or evaluated, and why.]

## Dataset

- **Dataset name and version:** [From DATA_GOVERNANCE.md / dataset card]
- **DVC path:** [DVC path to dataset]
- **Dataset card link:** [docs/datasets/DATASET-XXX.md]
- **Approved for use:** ☐ Yes — confirmed in dataset card and approved by [reviewer].

## Base model

- **Model name:** [e.g., google/mt5-small]
- **Hugging Face commit hash:** [Pinned commit hash — NOT a tag or branch]
- **Model card link:** [HuggingFace model card URL]
- **Hash verified:** ☐ Yes — will verify before loading.

## Experiment configuration

```yaml
# Paste key hyperparameters here — NOT the full config file
model: google/mt5-small
task: sequence_classification
num_labels: [N]
learning_rate: 2e-5
num_epochs: 5
batch_size: 16
max_length: 512
peft: LoRA
lora_rank: 8
lora_alpha: 16
seed: 42
```

## MLflow tracking

- **Experiment name:** [e.g., document-classification-v1]
- **Run name:** [e.g., mt5-small-lora-r8-lr2e5]
- **Metrics to log:** accuracy, macro_f1, per_class_f1, khmer_accuracy, calibration_error, latency_p95

## Evaluation plan

- [ ] Evaluate on held-out **test set** (never validation set for final evaluation).
- [ ] Evaluate Khmer-only subset separately.
- [ ] Evaluate English-only subset separately.
- [ ] Compare against current production model (if one exists).
- [ ] Check confidence calibration.
- [ ] Measure inference latency (P95).

## Success criteria

| Metric | Minimum to proceed |
|---|---|
| Overall accuracy | ≥ [threshold from AI_GOVERNANCE.md] |
| Khmer accuracy | ≥ [threshold from AI_GOVERNANCE.md] |
| Macro F1 | ≥ [threshold] |
| Latency P95 | < 5 seconds |

## Resource requirements

- **Compute:** [CPU / GPU — local / cloud]
- **Estimated training time:** [estimate]
- **Storage for checkpoints:** [estimate]
- **Approval required for paid compute:** ☐ Yes / ☐ No (local only)

## Privacy and data governance compliance

- [ ] Dataset contains no real personal data.
- [ ] Dataset card is complete and approved.
- [ ] DVC version of dataset is pinned and logged in MLflow.
- [ ] No model outputs contain personal data.
- [ ] Training script does not log document content.

## Post-experiment actions

- [ ] MLflow run ID recorded: [run ID]
- [ ] Model card completed for this experiment.
- [ ] Evaluation results compared against baselines.
- [ ] If results meet thresholds: propose deployment (requires separate approval).
- [ ] If results do not meet thresholds: document findings and propose next experiment.
