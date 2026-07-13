#!/usr/bin/env python3
"""Unit tests for C6CorpusLineage (B7 shipping 45+12=57).

Coverage (minimum required by completion delta):
  - clean 57 / 45 / 12 + exact ID set + no invented manual rows
  - deletion of one manual_trap
  - duplicate id
  - cross-source collision
  - behavior_class change
  - external_layer change
  - only-45 (generated only)
  - reorder-only (unordered set same; ordered/materialization hash differs)
  - missing case_id fail-closed
  - quarantine isolates mutation trap_note rows
"""
from __future__ import annotations

import copy
import json
import sys
import tempfile
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT / "Tools"))
from C6CorpusLineage import (  # noqa: E402
    ALLOWED_BEHAVIOR_CLASSES,
    EXPECTED_ASSEMBLED_COUNT,
    EXPECTED_GENERATED_COUNT,
    EXPECTED_MANUAL_TRAP_COUNT,
    FORBIDDEN_BEHAVIOR_CLASSES,
    assemble,
    assembled_sha256,
    build_receipt,
    default_sources,
    load_source,
    ordered_id_list_sha256,
    shipping_count_errors,
    tracked_id_set,
    unordered_id_set_sha256,
)
from C6CorpusLineage import _validate_row  # noqa: E402


def _tmp_source(kind, rows):
    d = Path(tempfile.mkdtemp(prefix="c6-lineage-test-"))
    p = d / f"src.{kind}.jsonl"
    p.write_text(
        "\n".join(json.dumps(r, ensure_ascii=False) for r in rows) + "\n",
        encoding="utf-8",
    )
    return p


def _good_row(case_id, kind="generated", **extra):
    row = {
        "case_id": case_id,
        "behavior_class": "tool_call",
        "clarify_tag": "implicit",
        "expect_no_call": False,
        "expected_state_delta": {"ac.power": "on"},
        "expected_tool_calls": [{"arguments": {}, "name": "open_ac"}],
        "failure_class": "none",
        "input_zh": "x",
        "pre_state": {"ac.power": "off"},
        "readback_assertion": {"contains": []},
        "source_refs": {
            "risk_rule_ids": [],
            "scenario_ids": [],
            "semantic_contract_ids": [],
            "state_cell_ids": [],
        },
        "tags": {
            "bucket": "action",
            "contract_device": "ac",
            "must_not_train": True,
            "must_pass": True,
            "sample_kind": "fixture",
        },
        "source_kind": kind,
    }
    row.update(extra)
    return row


def test_allowed_behavior_classes():
    assert "tool_call" in ALLOWED_BEHAVIOR_CLASSES
    assert "direct_no_call" in FORBIDDEN_BEHAVIOR_CLASSES
    assert "direct_no_call" not in ALLOWED_BEHAVIOR_CLASSES


def test_expected_shipping_constants():
    assert EXPECTED_GENERATED_COUNT == 45
    assert EXPECTED_MANUAL_TRAP_COUNT == 12
    assert EXPECTED_ASSEMBLED_COUNT == 57
    assert EXPECTED_GENERATED_COUNT + EXPECTED_MANUAL_TRAP_COUNT == EXPECTED_ASSEMBLED_COUNT


def test_clean_shipping_sources_45_12_57():
    """Live shipping sources: exact 45 generated + 12 manual_trap = 57."""
    sources = default_sources()
    assert len(sources) == 2
    assert sources[0].source_kind == "generated"
    assert sources[1].source_kind == "manual_trap"
    assert len(sources[0].rows) == EXPECTED_GENERATED_COUNT
    assert len(sources[1].rows) == EXPECTED_MANUAL_TRAP_COUNT

    res = assemble(sources)
    assert not res.errors, res.errors
    assert len(res.assembled_rows) == EXPECTED_ASSEMBLED_COUNT
    assert len(res.quarantined) == 0
    assert res.row_conservation_ok is True
    assert res.id_conservation_ok is True

    gen = [r for r in res.assembled_rows if r.get("source_kind") == "generated"]
    mt = [r for r in res.assembled_rows if r.get("source_kind") == "manual_trap"]
    assert len(gen) == 45
    assert len(mt) == 12
    assert all(r["case_id"].startswith("C6-TRAP-") for r in mt)
    assert all(not r["case_id"].startswith("C6-TRAP-") for r in gen)

    # exact ID set equals tracked 57; no invented C6-MANUAL-*
    assembled_ids = {r["case_id"] for r in res.assembled_rows}
    tracked = tracked_id_set()
    assert assembled_ids == tracked
    assert not any(cid.startswith("C6-MANUAL-") for cid in assembled_ids)

    ship_errs = shipping_count_errors(res)
    assert not ship_errs, ship_errs

    # stable sort
    ids = [r["case_id"] for r in res.assembled_rows]
    assert ids == sorted(ids)


def test_lossless_stable_assembly_synthetic():
    g = [_good_row(f"C6-G-{i}") for i in range(5)]
    m = [_good_row(f"C6-TRAP-T-{i}", kind="manual_trap") for i in range(3)]
    res = assemble(
        [
            load_source(_tmp_source("generated", g), "generated"),
            load_source(_tmp_source("manual_trap", m), "manual_trap"),
        ]
    )
    assert not res.errors, res.errors
    assert len(res.assembled_rows) == 8
    ids = [r["case_id"] for r in res.assembled_rows]
    assert ids == sorted(ids)
    assert res.row_conservation_ok is True
    assert res.id_conservation_ok is True


def test_recomputable_hashes_stable():
    g = [_good_row(f"C6-G-{i}") for i in range(4)]
    m = [_good_row(f"C6-TRAP-T-{i}", kind="manual_trap") for i in range(2)]
    srcs = lambda: [
        load_source(_tmp_source("generated", g), "generated"),
        load_source(_tmp_source("manual_trap", m), "manual_trap"),
    ]
    r1 = assemble(srcs())
    r2 = assemble(srcs())
    assert r1.unordered_id_set_sha256 == r2.unordered_id_set_sha256
    rc1 = build_receipt(r1)
    rc2 = build_receipt(r2)
    assert rc1["assembled"]["sha256"] == rc2["assembled"]["sha256"]
    assert (
        rc1["hashes"]["unordered_id_set_sha256"]
        == rc2["hashes"]["unordered_id_set_sha256"]
    )


def test_validate_row_rejects_forbidden_and_invalid():
    bad = dict(_good_row("C6-X-1"))
    bad["behavior_class"] = "direct_no_call"
    errs = _validate_row(bad, "manual_trap", 1)
    assert any("forbidden" in e for e in errs)
    bad2 = dict(_good_row("C6-X-2"))
    bad2["behavior_class"] = "nonsense"
    errs2 = _validate_row(bad2, "manual_trap", 2)
    assert any("invalid" in e for e in errs2)


# ---- deliberate-red / mutation coverage ----


def test_deletion_one_manual_trap_fails_shipping_counts():
    """Delete one manual_trap → assembled 56, ID set missing one vs tracked."""
    sources = default_sources()
    gen, mt = sources
    assert len(mt.rows) == 12
    mt_minus = copy.deepcopy(mt)
    mt_minus.rows = mt.rows[:-1]  # drop one
    res = assemble([gen, mt_minus])
    assert not res.errors, res.errors
    assert len(res.assembled_rows) == 56
    ship_errs = shipping_count_errors(res)
    assert ship_errs, "deleting one manual_trap must fail shipping count/ID checks"
    assert any("manual_trap count" in e or "assembled count" in e or "ID set" in e for e in ship_errs)


def test_duplicate_id_fails_closed():
    g = [_good_row("C6-DUP-1"), _good_row("C6-DUP-1")]  # within-source dup
    res = assemble([load_source(_tmp_source("generated", g), "generated")])
    assert res.errors, "duplicate case_id must fail-closed"
    assert any("duplicate" in e for e in res.errors)


def test_cross_source_collision_fails_closed():
    g = [_good_row("C6-COLLIDE-1", kind="generated")]
    m = [_good_row("C6-COLLIDE-1", kind="manual_trap")]
    res = assemble(
        [
            load_source(_tmp_source("generated", g), "generated"),
            load_source(_tmp_source("manual_trap", m), "manual_trap"),
        ]
    )
    assert res.errors, "cross-source duplicate case_id must fail-closed"
    assert any("duplicate" in e for e in res.errors)


def test_behavior_class_change_fails_closed():
    """Mutating behavior_class to forbidden/invalid must fail-closed."""
    g = [_good_row("C6-BC-1")]
    g[0]["behavior_class"] = "direct_no_call"
    res = assemble([load_source(_tmp_source("generated", g), "generated")])
    assert res.errors, "forbidden behavior_class must fail-closed"
    assert any("forbidden" in e or "invalid" in e for e in res.errors)

    g2 = [_good_row("C6-BC-2")]
    g2[0]["behavior_class"] = "not_a_real_class"
    res2 = assemble([load_source(_tmp_source("generated", g2), "generated")])
    assert res2.errors
    assert any("invalid" in e for e in res2.errors)


def test_external_layer_change_changes_materialization_hash():
    """external_layer is lineage metadata; changing it changes packaging hash,
    not the unordered ID set / content-stripped equality of case ids.
    """
    base = _good_row(
        "C6-TRAP-EL-1",
        kind="manual_trap",
        external_layer="live_tracked",
    )
    mutated = copy.deepcopy(base)
    mutated["external_layer"] = "mutated_external_layer"

    r1 = assemble(
        [load_source(_tmp_source("manual_trap", [base]), "manual_trap")]
    )
    r2 = assemble(
        [load_source(_tmp_source("manual_trap", [mutated]), "manual_trap")]
    )
    assert not r1.errors and not r2.errors
    assert r1.unordered_id_set_sha256 == r2.unordered_id_set_sha256
    assert assembled_sha256(r1.assembled_rows) != assembled_sha256(r2.assembled_rows), (
        "external_layer change must alter packaging/materialization hash"
    )


def test_only_45_generated_fails_shipping():
    """only-regenerate 45 (no manual_trap) must fail exact-57 shipping checks."""
    sources = default_sources()
    gen_only = [sources[0]]
    res = assemble(gen_only)
    assert not res.errors, res.errors
    assert len(res.assembled_rows) == 45
    ship_errs = shipping_count_errors(res)
    assert ship_errs, "only-45 must fail shipping checks"
    assert any(
        "manual_trap count" in e or "assembled count" in e or "ID set" in e
        for e in ship_errs
    )


def test_reorder_only_unordered_same_ordered_differs():
    """Reorder-only: unordered ID set hash identical; ordered list hash differs
    when materialization order is reversed BEFORE the stable-sort assembler.
    After assemble, both are sorted so ordered becomes equal — so we probe the
    pre-assemble ordered_id_list_sha256 of the raw row lists.
    """
    rows_a = [_good_row(f"C6-R-{i}") for i in (1, 2, 3, 4)]
    rows_b = list(reversed(rows_a))
    assert unordered_id_set_sha256(rows_a) == unordered_id_set_sha256(rows_b)
    assert ordered_id_list_sha256(rows_a) != ordered_id_list_sha256(rows_b), (
        "reorder-only must change ordered/materialization hash while unordered set stays same"
    )
    # After assemble both converge to the same ordered materialization
    r1 = assemble([load_source(_tmp_source("generated", rows_a), "generated")])
    r2 = assemble([load_source(_tmp_source("generated", rows_b), "generated")])
    assert r1.unordered_id_set_sha256 == r2.unordered_id_set_sha256
    assert r1.ordered_id_list_sha256 == r2.ordered_id_list_sha256
    assert assembled_sha256(r1.assembled_rows) == assembled_sha256(r2.assembled_rows)


def test_missing_case_id_fails_closed():
    bad = dict(_good_row("C6-TMP"))
    del bad["case_id"]
    res = assemble([load_source(_tmp_source("generated", [bad]), "generated")])
    assert res.errors, "missing case_id must fail-closed"
    assert any("missing case_id" in e for e in res.errors)


def test_quarantine_isolates_mutation_trap_not_merge():
    g = [_good_row("C6-Q-1")]
    trap = {
        "case_id": "C6-MUT-1",
        "behavior_class": "tool_call",
        "clarify_tag": "implicit",
        "expect_no_call": False,
        "expected_state_delta": {"nonexistent.cell": "99"},
        "expected_tool_calls": [{"arguments": {}, "name": "open_ac"}],
        "failure_class": "none",
        "input_zh": "x",
        "pre_state": {},
        "readback_assertion": {"contains": []},
        "source_refs": {
            "risk_rule_ids": [],
            "scenario_ids": [],
            "semantic_contract_ids": [],
            "state_cell_ids": ["nonexistent.cell"],
        },
        "tags": {
            "bucket": "action",
            "contract_device": "ac",
            "must_not_train": False,
            "must_pass": False,
            "sample_kind": "trap-deliberate-red",
        },
        "source_kind": "trap",
        "trap_note": "deliberate-red: bad state cell ref",
    }
    res = assemble(
        [
            load_source(_tmp_source("generated", g), "generated"),
            load_source(_tmp_source("trap", [trap]), "trap"),
        ]
    )
    assert len(res.quarantined) == 1, "mutation trap row must be quarantined"
    ids = [r["case_id"] for r in res.assembled_rows]
    assert "C6-MUT-1" not in ids, "mutation trap must NOT be merged"
    assert "C6-Q-1" in ids


def test_no_invented_manual_rows_in_shipping():
    sources = default_sources()
    res = assemble(sources)
    invented = [
        r["case_id"]
        for r in res.assembled_rows
        if str(r.get("case_id", "")).startswith("C6-MANUAL-")
    ]
    assert invented == [], f"invented manual rows present: {invented}"


def main():
    tests = [
        v
        for k, v in sorted(globals().items())
        if k.startswith("test_") and callable(v)
    ]
    failures = []
    for t in tests:
        try:
            t()
            print(f"  ok  {t.__name__}")
        except Exception as exc:  # noqa: BLE001
            failures.append(f"{t.__name__}: {exc}")
            print(f"  FAIL {t.__name__}: {exc}")
    if failures:
        print(f"test_c6_corpus_lineage_candidate FAILED ({len(failures)})")
        return 1
    print(f"test_c6_corpus_lineage_candidate=ok ({len(tests)} tests)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
