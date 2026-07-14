from __future__ import annotations

from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
SPINE_PACKAGE = Path(__file__).resolve().parent
CONTRACTS_DIR = REPO_ROOT / "contracts" / "c6-eval-spine"
FIXTURES_DIR = SPINE_PACKAGE / "fixtures"
HOLDOUT_PATH = FIXTURES_DIR / "holdout" / "eval-holdout.jsonl"
HOLDOUT_PIN_PATH = FIXTURES_DIR / "holdout" / "holdout.pin.json"

# D-127 frozen holdout pin (exact bytes of source holdout).
HOLDOUT_SHA256 = "77853caea4598f334fb4a7ed89eafc348746adf333d647306aa94f0b68da2f64"
HOLDOUT_ROW_COUNT = 61
HOLDOUT_BUCKETS = {
    "primary_can_question": 33,
    "topic_fronted": 9,
    "negative_can_question": 10,
    "particle_tail": 9,
}

# B7 candidate digests from closure/candidates/B7 receipt (live at design time).
B7_ASSEMBLED_SHA256 = "6952a7e8f9526242d9b948538653f82603351aa24b6910050e59c9c39778a3a7"
B7_COMPAT_SHA256 = "47806412a9b168595e732bf116a293a5582cf566d0fb63173d48343bd11fecfa"
B7_UNORDERED_ID_SET_SHA256 = "e40555682fb2a5ef65d6737a8aa0c39f69bd702de23d5b98266e2f397c566f76"
B7_RECEIPT_PATH = REPO_ROOT / "closure/candidates/B7/c6-corpus-lineage.receipt.json"

# V1 candidate
V1_AUTHORITY_PATH = REPO_ROOT / "contracts/c6-active-authority/authority.v1.candidate.json"
V1_AUTHORITY_DIGEST = "adc6b42c84f1c43c491db7dd5dadd0f283bedcf877f85862ab3bd3fb6c2be686"

ALLOWED_BEHAVIOR_CLASSES = frozenset(
    {
        "tool_call",
        "clarify_missing_slot",
        "refusal_no_available_tool",
        "refusal_safety_or_policy",
        "already_state_noop",
    }
)

PLAN_P_READBACK_FIELDS = (
    "model_hard_pass_basis",
    "model_hard_failed",
    "readback_applicable",
    "readback_match",
    "readback_hard_failed",
    "readback_excluded_from_model_hard_pass",
    "renderer_contract_digest",
)

# AD-C6-014
COMPARISON_SEEDS = (17, 29, 43)

FORBIDDEN_CLAIM_KEYS = frozenset(
    {
        "b2_done",
        "b3_done",
        "b4_done",
        "package_b2_done",
        "package_b3_done_true",
        "package_b4_done",
        "s9_real_done",
        "s10_real_done",
        "c6_acceptance",
        "v_pass",
        "candidate_signed",
        "operator_pass",
    }
)

EXPOSURE_CHECKER = REPO_ROOT / "scripts" / "check_train_eval_exposure.py"

SCORER_ID_FIXTURE = "fixture_scorer_v1"
PARSER_ID_FIXTURE = "fixture_parser_v1"
PROMPT_POLICY_ID = "fixture_prompt_policy_v1"
