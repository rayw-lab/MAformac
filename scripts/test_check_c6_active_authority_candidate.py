#!/usr/bin/env python3
"""
Regression tests for C6 Active Authority Candidate checker.

Positive + deliberate-negative coverage for:
  - valid candidate passes
  - stale source_member sha
  - duplicate source_member id/role
  - missing source_member
  - subject mismatch
  - all-zero sha256
  - plus existing structural negatives
"""

from __future__ import annotations

import copy
import hashlib
import json
import subprocess
import sys
import tempfile
from pathlib import Path

# Import checker helpers for expected sets + live hash recompute.
REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT / "scripts"))
import check_c6_active_authority_candidate as checker  # noqa: E402


CHECKER = REPO_ROOT / "scripts" / "check_c6_active_authority_candidate.py"


def _live_member_entries() -> list[dict]:
    members: list[dict] = []
    for mid, meta in checker.EXPECTED_SOURCE_MEMBERS.items():
        path = str(meta["path"])
        resolved = checker.resolve_member_path(path)
        if not resolved.exists():
            raise FileNotFoundError(f"expected source member missing live path: {resolved}")
        members.append(
            {
                "member_id": mid,
                "role": meta["role"],
                "path": path,
                "locator": meta["locator"],
                "sha256": checker.file_sha256(resolved),
                "subject_bindings": list(meta["subject_bindings"]),  # type: ignore[arg-type]
            }
        )
    # Stable order matching checker expectation iteration order is not required
    # for schema, but keep deterministic order for readability.
    order = list(checker.EXPECTED_SOURCE_MEMBERS.keys())
    members.sort(key=lambda m: order.index(m["member_id"]))
    return members


def base_doc() -> dict:
    """Return a valid base authority document with live source_members."""
    members = _live_member_entries()
    pool32 = next(m for m in members if m["member_id"] == "pool32_ratification_receipt")
    decisions = next(m for m in members if m["member_id"] == "d147_decisions")
    doc = {
        "authority_id": "c6_active_authority_v1",
        "authority_version": 1,
        "schema_version": "c6_active_authority_v1",
        "subject_schema_id": "c6_authority_subject_v1",
        "status": "CANDIDATE",
        "ratification_refs": [
            {
                "path": decisions["path"],
                "locator": decisions["locator"],
                "sha256": decisions["sha256"],
            },
            {
                "path": pool32["path"],
                "locator": pool32["locator"],
                "sha256": pool32["sha256"],
            },
        ],
        "decision_refs": [
            {"decision_id": "D-147", "required_state": "ratified"},
            {"decision_id": "D-144", "required_state": "ratified"},
        ],
        "source_members": members,
        "subject": {
            "four_layer_thresholds": {
                "golden": 1.0,
                "demo_fuzz": {
                    "formula": "5*pass >= 4*eligible",
                    "description": "Integer arithmetic guard",
                },
                "unsupported": 1.0,
                "safety": 1.0,
            },
            "behavior_classes": list(checker.ALLOWED_BEHAVIOR_CLASSES),
            "demo_fuzz_family_roster": list(checker.ALLOWED_FAMILY_ROSTER),
            "governance_axes": list(checker.ALLOWED_GOVERNANCE_AXES),
            "readback_fields": list(checker.ALLOWED_READBACK_FIELDS),
            "contract_bundle_component_ids": list(checker.ALLOWED_CONTRACT_COMPONENTS),
            "hard_layer_denominators": {
                "golden": 0,
                "demo_fuzz": 0,
                "unsupported": 0,
                "safety": 0,
            },
        },
    }
    payload = {
        "authority_id": doc["authority_id"],
        "authority_version": doc["authority_version"],
        "schema_version": doc["schema_version"],
        "subject_schema_id": doc["subject_schema_id"],
        "subject": doc["subject"],
    }
    canonical = json.dumps(payload, sort_keys=True, ensure_ascii=False).encode("utf-8")
    doc["digest"] = {
        "sha256": hashlib.sha256(canonical).hexdigest(),
        "algorithm": "sha256",
    }
    return doc


def run_checker(doc: dict) -> subprocess.CompletedProcess[str]:
    with tempfile.TemporaryDirectory(prefix="c6-auth-test-") as tmp:
        tmp_path = Path(tmp)
        json_path = tmp_path / "authority.json"
        json_path.write_text(
            json.dumps(doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )
        return subprocess.run(
            [sys.executable, "-B", str(CHECKER), str(json_path)],
            capture_output=True,
            text=True,
            check=False,
        )


def expect_pass(name: str, doc: dict, failures: list[str]) -> None:
    result = run_checker(doc)
    if result.returncode != 0:
        failures.append(
            f"{name}: expected rc=0, got rc={result.returncode} "
            f"stderr={result.stderr!r}"
        )


def expect_fail(name: str, doc: dict, needle: str, failures: list[str]) -> None:
    result = run_checker(doc)
    if result.returncode == 0:
        failures.append(f"{name}: expected non-zero rc, got rc=0")
    elif needle not in result.stderr:
        failures.append(
            f"{name}: expected stderr to contain {needle!r}, "
            f"got stderr={result.stderr!r}"
        )


def test_positive() -> None:
    failures: list[str] = []
    expect_pass("positive", base_doc(), failures)
    assert not failures, "\n".join(failures)


def test_missing_field() -> None:
    failures: list[str] = []
    doc = base_doc()
    del doc["subject"]["behavior_classes"]
    expect_fail("missing_behavior_classes", doc, "behavior_classes", failures)
    assert not failures, "\n".join(failures)


def test_wrong_behavior_class() -> None:
    failures: list[str] = []
    doc = base_doc()
    doc["subject"]["behavior_classes"][0] = "direct_no_call"
    # recompute digest so failure is subject-level not digest-level
    doc["digest"]["sha256"] = checker.compute_digest(doc)
    expect_fail("wrong_behavior_class", doc, "direct_no_call", failures)
    assert not failures, "\n".join(failures)


def test_wrong_family_roster() -> None:
    failures: list[str] = []
    doc = base_doc()
    doc["subject"]["demo_fuzz_family_roster"][0] = "hud"
    doc["digest"]["sha256"] = checker.compute_digest(doc)
    expect_fail("wrong_family_roster", doc, "hud", failures)
    assert not failures, "\n".join(failures)


def test_placeholder_sha256() -> None:
    failures: list[str] = []
    doc = base_doc()
    doc["ratification_refs"][0]["sha256"] = "PLACEHOLDER_COMMIT_TIME_SHA256"
    expect_fail("placeholder_sha256", doc, "PLACEHOLDER", failures)
    assert not failures, "\n".join(failures)


def test_wrong_decision_id() -> None:
    failures: list[str] = []
    doc = base_doc()
    doc["decision_refs"][0]["decision_id"] = "X-999"
    expect_fail("wrong_decision_id", doc, "X-999", failures)
    assert not failures, "\n".join(failures)


def test_digest_mismatch() -> None:
    failures: list[str] = []
    doc = base_doc()
    doc["digest"]["sha256"] = "a" * 64
    expect_fail("digest_mismatch", doc, "digest mismatch", failures)
    assert not failures, "\n".join(failures)


def test_empty_ratification_refs() -> None:
    failures: list[str] = []
    doc = base_doc()
    doc["ratification_refs"] = []
    expect_fail("empty_ratification_refs", doc, "ratification_refs", failures)
    assert not failures, "\n".join(failures)


def test_duplicate_family() -> None:
    failures: list[str] = []
    doc = base_doc()
    doc["subject"]["demo_fuzz_family_roster"][6] = "ac_temperature"
    doc["digest"]["sha256"] = checker.compute_digest(doc)
    expect_fail("duplicate_family", doc, "duplicates", failures)
    assert not failures, "\n".join(failures)


def test_wrong_governance_axis() -> None:
    failures: list[str] = []
    doc = base_doc()
    doc["subject"]["governance_axes"][0] = "deployment"
    doc["digest"]["sha256"] = checker.compute_digest(doc)
    expect_fail("wrong_governance_axis", doc, "deployment", failures)
    assert not failures, "\n".join(failures)


def test_wrong_readback_field() -> None:
    failures: list[str] = []
    doc = base_doc()
    doc["subject"]["readback_fields"][0] = "custom_field"
    doc["digest"]["sha256"] = checker.compute_digest(doc)
    expect_fail("wrong_readback_field", doc, "custom_field", failures)
    assert not failures, "\n".join(failures)


def test_wrong_golden_threshold() -> None:
    failures: list[str] = []
    doc = base_doc()
    doc["subject"]["four_layer_thresholds"]["golden"] = 0.95
    doc["digest"]["sha256"] = checker.compute_digest(doc)
    expect_fail("wrong_golden_threshold", doc, "golden", failures)
    assert not failures, "\n".join(failures)


def test_missing_ratification_ref_path() -> None:
    failures: list[str] = []
    doc = base_doc()
    del doc["ratification_refs"][0]["path"]
    expect_fail("missing_ref_path", doc, "path", failures)
    assert not failures, "\n".join(failures)


def test_negative_hard_layer_denominator() -> None:
    failures: list[str] = []
    doc = base_doc()
    doc["subject"]["hard_layer_denominators"]["golden"] = -1
    doc["digest"]["sha256"] = checker.compute_digest(doc)
    expect_fail("negative_denominator", doc, "golden", failures)
    assert not failures, "\n".join(failures)


# ---- deliberate-red fail-closed gates required by completion delta ----

def test_deliberate_red_stale_source_member() -> None:
    failures: list[str] = []
    doc = base_doc()
    # Flip one nibble so live hash no longer matches.
    old = doc["source_members"][0]["sha256"]
    flipped = ("0" if old[0] != "0" else "1") + old[1:]
    doc["source_members"][0]["sha256"] = flipped
    expect_fail("stale_source_member", doc, "stale", failures)
    assert not failures, "\n".join(failures)


def test_deliberate_red_duplicate_source_member() -> None:
    failures: list[str] = []
    doc = base_doc()
    dup = copy.deepcopy(doc["source_members"][0])
    # Keep same member_id to hit duplicate gate; change path/locator so path/locator
    # uniqueness is not the first failure mode for this test.
    dup["path"] = "docs/README.md"
    dup["locator"] = "duplicate-test-locator"
    dup["role"] = "duplicate_role_for_test"
    # Fix sha to live README so we don't fail on missing/stale first.
    resolved = checker.resolve_member_path(dup["path"])
    dup["sha256"] = checker.file_sha256(resolved)
    doc["source_members"].append(dup)
    expect_fail("duplicate_source_member", doc, "duplicate member_id", failures)
    assert not failures, "\n".join(failures)


def test_deliberate_red_missing_source_member() -> None:
    failures: list[str] = []
    doc = base_doc()
    # Drop one required member.
    doc["source_members"] = doc["source_members"][1:]
    expect_fail("missing_source_member", doc, "missing members", failures)
    assert not failures, "\n".join(failures)


def test_deliberate_red_subject_mismatch() -> None:
    failures: list[str] = []
    doc = base_doc()
    # Mutate exact subject set while keeping digest consistent so gate is subject.
    doc["subject"]["behavior_classes"] = [
        "tool_call",
        "clarify_missing_slot",
        "refusal_no_available_tool",
        "refusal_safety_or_policy",
        "tool_call",  # duplicate instead of already_state_noop
    ]
    doc["digest"]["sha256"] = checker.compute_digest(doc)
    expect_fail("subject_mismatch", doc, "subject mismatch", failures)
    assert not failures, "\n".join(failures)


def test_deliberate_red_all_zero_sha256() -> None:
    failures: list[str] = []
    doc = base_doc()
    doc["ratification_refs"][1]["sha256"] = "0" * 64
    expect_fail("all_zero_sha256", doc, "all-zero", failures)
    assert not failures, "\n".join(failures)


def test_deliberate_red_all_zero_source_member() -> None:
    failures: list[str] = []
    doc = base_doc()
    doc["source_members"][2]["sha256"] = "0" * 64
    expect_fail("all_zero_source_member", doc, "all-zero", failures)
    assert not failures, "\n".join(failures)


def test_live_candidate_file_passes() -> None:
    """Direct integration against the durable candidate on disk."""
    path = REPO_ROOT / "contracts" / "c6-active-authority" / "authority.v1.candidate.json"
    if not path.exists():
        raise AssertionError(f"candidate missing: {path}")
    result = subprocess.run(
        [sys.executable, "-B", str(CHECKER), str(path)],
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode == 0, (
        f"live candidate failed rc={result.returncode} stderr={result.stderr!r}"
    )


def main() -> int:
    tests = [
        test_positive,
        test_missing_field,
        test_wrong_behavior_class,
        test_wrong_family_roster,
        test_placeholder_sha256,
        test_wrong_decision_id,
        test_digest_mismatch,
        test_empty_ratification_refs,
        test_duplicate_family,
        test_wrong_governance_axis,
        test_wrong_readback_field,
        test_wrong_golden_threshold,
        test_missing_ratification_ref_path,
        test_negative_hard_layer_denominator,
        test_deliberate_red_stale_source_member,
        test_deliberate_red_duplicate_source_member,
        test_deliberate_red_missing_source_member,
        test_deliberate_red_subject_mismatch,
        test_deliberate_red_all_zero_sha256,
        test_deliberate_red_all_zero_source_member,
        test_live_candidate_file_passes,
    ]
    failures: list[str] = []
    for t in tests:
        try:
            t()
            print(f"  ok  {t.__name__}")
        except Exception as exc:  # noqa: BLE001
            failures.append(f"{t.__name__}: {exc}")
            print(f"  FAIL {t.__name__}: {exc}")
    if failures:
        print(f"test_check_c6_active_authority_candidate FAILED ({len(failures)})")
        return 1
    print(f"test_check_c6_active_authority_candidate=ok ({len(tests)} tests)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
