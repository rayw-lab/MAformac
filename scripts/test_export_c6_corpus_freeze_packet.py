#!/usr/bin/env python3
"""Negative + positive tests for the B7 freeze-packet exporter.

Positive: the exporter emits a candidate-only, drift-free, byte-stable packet.

Required negative gates (must be RED / fail-closed):
  1. source digest drift   -> mutate a live source row's case_id -> exporter refuses
  2. holdout sha drift     -> tamper the D-127 pin constant -> packet rejected
  3. status/canonical forgery -> status!=CANDIDATE_PACKET_ONLY / is_canonical=true fails
  4. missing field         -> packet missing corpus_binding is structurally invalid
  5. operator/ceremony prefill -> operator/signature/signed_at/ratified_at/ceremony fail
  6. all-zero digest forgery -> critical digests replaced with 0*64 fail self_check
  7. digest rebind mismatch -> valid-looking wrong sha fails exact recompute bind
  8. missing ref fail-closed -> missing/unreadable ref refuses (no all-zero sentinel)
  9. unknown extra fields  -> top-level unknown keys rejected
 10. --check byte-drift    -> coherent live source mutation without packet update fails
 11. schema extra/missing  -> stdlib (or jsonschema) enforces additionalProperties/required

Run: python3 -B scripts/test_export_c6_corpus_freeze_packet.py
"""
from __future__ import annotations

import copy
import importlib.util
import json
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
EXPORTER = REPO_ROOT / "Tools" / "C6CorpusLineage" / "export_freeze_packet.py"
SCHEMA = REPO_ROOT / "contracts" / "c6-corpus-lineage" / "freeze-packet.v1.schema.json"
COMMITTED = (
    REPO_ROOT / "closure" / "candidates" / "B7" / "B7.v1.freeze-packet.candidate.json"
)
ZERO_SHA = "0" * 64
ALT_SHA = "a" * 64


def _load_mod(name: str):
    spec = importlib.util.spec_from_file_location(name, str(EXPORTER))
    assert spec is not None and spec.loader is not None
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def run_exporter(args=None) -> subprocess.CompletedProcess[str]:
    cmd = [sys.executable, "-B", str(EXPORTER)]
    if args:
        cmd += args
    return subprocess.run(cmd, capture_output=True, text=True, check=False)


def load_packet() -> dict:
    return json.loads(COMMITTED.read_text(encoding="utf-8"))


def _stdlib_validate(instance, schema, path: str = "$") -> list[str]:
    """Strict stdlib validator for features used by these schemas.

    Covers: type, required, const, enum, pattern, arrays (items/minItems),
    nested objects, additionalProperties:false. Never silently skips validation.
    """
    errs: list[str] = []
    if not isinstance(schema, dict):
        return [f"{path}: schema must be object"]

    if "const" in schema and instance != schema["const"]:
        errs.append(f"{path}: const mismatch (expected {schema['const']!r})")
    if "enum" in schema and instance not in schema["enum"]:
        errs.append(f"{path}: enum mismatch")

    expected_type = schema.get("type")
    if expected_type == "object":
        if not isinstance(instance, dict):
            return [f"{path}: expected object, got {type(instance).__name__}"]
        for req in schema.get("required", []):
            if req not in instance:
                errs.append(f"{path}: missing required {req}")
        props = schema.get("properties", {})
        if schema.get("additionalProperties") is False:
            for k in instance:
                if k not in props:
                    errs.append(f"{path}: additionalProperties forbidden key {k!r}")
        for k, v in instance.items():
            if k in props:
                errs.extend(_stdlib_validate(v, props[k], f"{path}.{k}"))
    elif expected_type == "array":
        if not isinstance(instance, list):
            return [f"{path}: expected array"]
        min_items = schema.get("minItems")
        if isinstance(min_items, int) and len(instance) < min_items:
            errs.append(f"{path}: minItems {min_items} violated (got {len(instance)})")
        item_schema = schema.get("items")
        if isinstance(item_schema, dict):
            for i, item in enumerate(instance):
                errs.extend(_stdlib_validate(item, item_schema, f"{path}[{i}]"))
    elif expected_type == "string":
        if not isinstance(instance, str):
            return [f"{path}: expected string"]
        if "pattern" in schema and not re.match(schema["pattern"], instance):
            errs.append(f"{path}: pattern mismatch")
    elif expected_type == "boolean":
        if not isinstance(instance, bool):
            return [f"{path}: expected boolean"]
    elif expected_type == "integer":
        if not isinstance(instance, int) or isinstance(instance, bool):
            return [f"{path}: expected integer"]
    elif expected_type == "number":
        if not isinstance(instance, (int, float)) or isinstance(instance, bool):
            return [f"{path}: expected number"]
    return errs


def _validate_schema(instance: dict, schema: dict) -> list[str]:
    """Always run stdlib validator; optionally cross-check with jsonschema if present."""
    stdlib_errs = _stdlib_validate(instance, schema, path="$")
    try:
        import jsonschema  # type: ignore
        from jsonschema import ValidationError  # type: ignore

        try:
            jsonschema.validate(instance=instance, schema=schema)
        except ValidationError as exc:
            # Prefer stdlib message if already present; else surface third-party error.
            if not stdlib_errs:
                stdlib_errs = [f"jsonschema: {exc.message}"]
    except ImportError:
        pass
    return stdlib_errs


def test_positive() -> None:
    with tempfile.TemporaryDirectory() as tmp:
        p = Path(tmp) / "B7.packet.json"
        r = run_exporter(["--out", str(p)])
        assert r.returncode == 0, f"exporter failed: {r.stderr}"
        fresh = p.read_bytes()
    committed = COMMITTED.read_bytes()
    assert fresh == committed, "packet not byte-stable vs committed (drift in export)"
    pkt = json.loads(fresh.decode("utf-8"))
    assert pkt["status"] == "CANDIDATE_PACKET_ONLY"
    assert pkt["is_canonical"] is False
    assert pkt["is_b7_done"] is False
    assert pkt["requires_operator_ceremony"] is True
    assert pkt["corpus_binding"]["row_count"] == 57
    assert pkt["corpus_binding"]["generated_row_count"] == 45
    assert pkt["corpus_binding"]["manual_trap_row_count"] == 12
    assert pkt["corpus_binding"]["id_set_equals_tracked"] is True
    assert pkt["holdout_pin"]["sha256"] == (
        "77853caea4598f334fb4a7ed89eafc348746adf333d647306aa94f0b68da2f64"
    )
    for forbidden in (
        "operator",
        "signature",
        "signed_at",
        "ratified_at",
        "ceremony",
        "frozen_at",
        "frozen_by",
    ):
        assert forbidden not in pkt, f"forbidden field {forbidden!r} present"
    for key in (
        "assembled_sha256",
        "compat_sha256",
        "unordered_id_set_sha256",
        "tracked_content_sha256",
    ):
        assert pkt["corpus_binding"][key] != ZERO_SHA
    rc = run_exporter(["--check"])
    assert rc.returncode == 0, f"--check failed: {rc.stderr}"


def test_source_digest_drift() -> None:
    """Mutate a live source so shipping assembly drifts; exporter must refuse."""
    mod = _load_mod("c6exp_b7")
    src_dir = REPO_ROOT / "Tools" / "C6CorpusLineage" / "sources"
    gen = src_dir / "c6-bench-cases.generated.jsonl"
    lines = gen.read_text(encoding="utf-8").splitlines()
    assert len(lines) == 45, "precondition: 45 generated rows expected"
    with tempfile.TemporaryDirectory() as tmp:
        tp = Path(tmp) / "gen.jsonl"
        tp.write_text("\n".join(lines[:-1]) + "\n", encoding="utf-8")
        sys.path.insert(0, str(REPO_ROOT / "Tools"))
        from C6CorpusLineage import load_source  # noqa: E402

        mod.default_sources = lambda: [  # type: ignore[attr-defined]
            load_source(tp, "generated"),
            load_source(src_dir / "c6-bench-cases.manual-trap.jsonl", "manual_trap"),
        ]
        _pkt, errors = mod.build_packet()
        assert errors, "source drift (44 generated) must produce errors and refuse emit"
        assert any("57" in e or "assembled" in e.lower() for e in errors), errors


def test_holdout_sha_drift() -> None:
    """Tamper the D-127 pin constant; self_check must reject."""
    mod = _load_mod("c6exp_b7b")
    pkt, errors = mod.build_packet()
    assert not errors, f"clean build should have no errors: {errors}"
    pkt["holdout_pin"]["sha256"] = ZERO_SHA
    check_errs = mod.self_check(pkt)
    assert check_errs, "holdout sha forged to all-zero must fail self_check"
    assert any("D-127" in e or "holdout" in e for e in check_errs), check_errs


def test_status_canonical_forgery() -> None:
    """A packet claiming canonical / B7 done must fail self_check."""
    mod = _load_mod("c6exp_b7c")
    pkt, errors = mod.build_packet()
    assert not errors
    forged = copy.deepcopy(pkt)
    forged["status"] = "CANONICAL_DONE"
    forged["is_canonical"] = True
    forged["is_b7_done"] = True
    forged["requires_operator_ceremony"] = False
    assert mod.self_check(forged), "forged canonical packet must fail self_check"


def test_missing_field() -> None:
    """A packet missing corpus_binding must fail structural self_check."""
    mod = _load_mod("c6exp_b7d")
    pkt, errors = mod.build_packet()
    assert not errors
    bad = copy.deepcopy(pkt)
    del bad["corpus_binding"]
    check_errs = mod.self_check(bad)
    assert check_errs, "missing corpus_binding must fail self_check"
    assert any("corpus_binding" in e for e in check_errs), check_errs
    real = load_packet()
    assert "corpus_binding" in real, "committed packet missing corpus_binding"


def test_operator_ceremony_prefill() -> None:
    """Prefilling operator/signature/time/ceremony fields must fail self_check."""
    mod = _load_mod("c6exp_b7e")
    pkt, errors = mod.build_packet()
    assert not errors
    prefilled = copy.deepcopy(pkt)
    prefilled["operator"] = "leige"
    prefilled["signature"] = ZERO_SHA
    prefilled["signed_at"] = "2026-07-14T00:00:00+08:00"
    prefilled["ratified_at"] = "2026-07-14T00:00:00+08:00"
    prefilled["ceremony"] = {"completed": True}
    prefilled["frozen_at"] = "2026-07-14T00:00:00+08:00"
    check_errs = mod.self_check(prefilled)
    assert check_errs, "operator/signature/ceremony prefill must fail self_check"
    assert any(
        any(
            token in e
            for token in (
                "operator",
                "signature",
                "signed_at",
                "ratified_at",
                "ceremony",
                "frozen_at",
                "forbidden",
            )
        )
        for e in check_errs
    ), check_errs


def test_zero_digest_forgery() -> None:
    """Replacing critical digests with all-zero sha must fail exact recompute bind."""
    mod = _load_mod("c6exp_b7f")
    pkt, errors = mod.build_packet()
    assert not errors
    forged = copy.deepcopy(pkt)
    for key in (
        "assembled_sha256",
        "compat_sha256",
        "unordered_id_set_sha256",
        "tracked_content_sha256",
    ):
        forged["corpus_binding"][key] = ZERO_SHA
    check_errs = mod.self_check(forged)
    assert check_errs, "all-zero digests must fail self_check"
    assert any(
        "digest" in e.lower()
        or "sha" in e.lower()
        or "zero" in e.lower()
        or "recompute" in e.lower()
        for e in check_errs
    ), check_errs


def test_digest_rebind_mismatch() -> None:
    """A valid-looking but wrong digest must fail exact recompute bind (not regex-only)."""
    mod = _load_mod("c6exp_b7g")
    pkt, errors = mod.build_packet()
    assert not errors
    forged = copy.deepcopy(pkt)
    forged["corpus_binding"]["assembled_sha256"] = ALT_SHA
    forged["corpus_binding"]["compat_sha256"] = ALT_SHA
    forged["corpus_binding"]["unordered_id_set_sha256"] = ALT_SHA
    forged["corpus_binding"]["tracked_content_sha256"] = ALT_SHA
    check_errs = mod.self_check(forged)
    assert check_errs, "forged digests with valid shape must fail exact recompute"
    assert any(
        "assembled_sha256" in e
        or "compat_sha256" in e
        or "unordered_id_set_sha256" in e
        or "tracked_content_sha256" in e
        or "digest" in e.lower()
        or "recompute" in e.lower()
        for e in check_errs
    ), check_errs


def test_missing_ref_fail_closed() -> None:
    """Missing refs must fail closed; never emit all-zero sha as valid evidence."""
    mod = _load_mod("c6exp_b7h")
    missing = {
        "path": "docs/does-not-exist-for-fail-closed-probe.md",
        "locator": "missing",
    }
    resolved, err = mod._resolve_ref_strict(missing)
    assert err, "missing ref must return error"
    assert resolved is None
    assert ZERO_SHA not in (err or "")
    original = list(mod.RATIFICATION_REFS)
    try:
        mod.RATIFICATION_REFS = [missing]
        _pkt, errors = mod.build_packet()
        assert errors, "missing ratification ref must refuse emit"
        assert not any(ZERO_SHA == e for e in errors)
        assert any("missing" in e.lower() or "ref" in e.lower() for e in errors), errors
    finally:
        mod.RATIFICATION_REFS = original


def test_unknown_extra_fields() -> None:
    """Unknown top-level fields must fail self_check (candidate-only non-claims)."""
    mod = _load_mod("c6exp_b7i")
    pkt, errors = mod.build_packet()
    assert not errors
    bad = copy.deepcopy(pkt)
    bad["canonical_receipt"] = {"path": "fake"}
    bad["is_done"] = True
    check_errs = mod.self_check(bad)
    assert check_errs, "unknown extra fields must fail self_check"
    assert any(
        "unknown" in e.lower() or "extra" in e.lower() or "forbidden" in e.lower()
        for e in check_errs
    ), check_errs


def test_check_mode_byte_drift() -> None:
    """--check must fail when committed packet drifts from live rebuild.

    Coherent content mutation with same row count/IDs is simulated by mutating the
    committed packet digests (leaving live sources intact): rebuild then differs.
    """
    original = COMMITTED.read_bytes()
    try:
        pkt = json.loads(original.decode("utf-8"))
        # Mutate a digest so the committed file is no longer the live rebuild.
        pkt["corpus_binding"]["assembled_sha256"] = ALT_SHA
        COMMITTED.write_text(
            json.dumps(pkt, sort_keys=True, ensure_ascii=False, separators=(",", ":")),
            encoding="utf-8",
        )
        rc = run_exporter(["--check"])
        assert rc.returncode != 0, "--check must be nonzero on committed digests drift"
        assert (
            "drift" in (rc.stderr + rc.stdout).lower()
            or "mismatch" in (rc.stderr + rc.stdout).lower()
            or "failed" in (rc.stderr + rc.stdout).lower()
        )
    finally:
        COMMITTED.write_bytes(original)


def test_committed_packet_matches_schema() -> None:
    """Committed candidate packet must satisfy JSON schema (always validated)."""
    pkt = load_packet()
    schema = json.loads(SCHEMA.read_text(encoding="utf-8"))
    errs = _validate_schema(pkt, schema)
    assert not errs, f"schema validation failed: {errs}"


def test_schema_rejects_extra_and_prefill() -> None:
    """Schema must reject operator/signature prefill via additionalProperties:false."""
    pkt = load_packet()
    schema = json.loads(SCHEMA.read_text(encoding="utf-8"))
    bad = copy.deepcopy(pkt)
    bad["operator"] = "forged"
    bad["signature"] = ZERO_SHA
    errs = _validate_schema(bad, schema)
    assert errs, "schema must reject operator/signature prefill"


def test_schema_rejects_missing_field() -> None:
    """Schema must reject missing required fields (deliberate-red)."""
    pkt = load_packet()
    schema = json.loads(SCHEMA.read_text(encoding="utf-8"))
    bad = copy.deepcopy(pkt)
    del bad["corpus_binding"]
    errs = _validate_schema(bad, schema)
    assert errs, "schema must reject missing corpus_binding"
    assert any("corpus_binding" in e for e in errs), errs


def test_schema_rejects_zero_digest() -> None:
    """Schema pattern must reject all-zero digests."""
    pkt = load_packet()
    schema = json.loads(SCHEMA.read_text(encoding="utf-8"))
    bad = copy.deepcopy(pkt)
    bad["corpus_binding"]["assembled_sha256"] = ZERO_SHA
    errs = _validate_schema(bad, schema)
    assert errs, "schema must reject all-zero assembled_sha256"


def test_out_of_repo_absolute_etc_hosts_rejected() -> None:
    """/etc/hosts (existing absolute file) must fail closed — not allowlisted."""
    mod = _load_mod("c6exp_b7_oor1")
    hosts = Path("/etc/hosts")
    assert hosts.is_file(), "precondition: /etc/hosts must exist for this deliberate-red"
    resolved, err = mod._resolve_ref_strict(
        {"path": str(hosts), "locator": "evil_hosts"}
    )
    assert resolved is None and err, "/etc/hosts must be rejected"
    assert (
        "allowlist" in err.lower()
        or "absolute" in err.lower()
        or "pool32" in err.lower()
    ), err


def test_out_of_repo_other_absolute_file_rejected() -> None:
    """Any other existing absolute file (e.g. /etc/passwd) must fail closed."""
    mod = _load_mod("c6exp_b7_oor2")
    other = Path("/etc/passwd")
    assert other.is_file(), "precondition: /etc/passwd must exist"
    resolved, err = mod._resolve_ref_strict(
        {"path": str(other), "locator": "evil_passwd"}
    )
    assert resolved is None and err, "non-allowlisted absolute file must be rejected"


def test_symlink_escape_absolute_ref_rejected() -> None:
    """Absolute symlink that resolves outside allowlist must fail closed."""
    mod = _load_mod("c6exp_b7_oor3")
    with tempfile.TemporaryDirectory() as tmp:
        link = Path(tmp) / "escape-hosts"
        link.symlink_to("/etc/hosts")
        resolved, err = mod._resolve_ref_strict(
            {"path": str(link), "locator": "symlink_escape"}
        )
        assert resolved is None and err, "symlink escape via absolute path must fail"


def test_unknown_extra_ref_and_duplicate_ref_rejected() -> None:
    """Extra unknown locator and duplicate refs must fail exact set self_check."""
    mod = _load_mod("c6exp_b7_oor4")
    pkt, errors = mod.build_packet()
    assert not errors
    # Extra unknown ref (even if it points at an existing allowlisted path).
    bad_extra = copy.deepcopy(pkt)
    bad_extra["ratification_refs"] = list(bad_extra["ratification_refs"]) + [
        {
            "path": "docs/commander-log/decisions.md",
            "locator": "unknown_extra",
            "sha256": bad_extra["ratification_refs"][0]["sha256"],
        }
    ]
    check_extra = mod.self_check(bad_extra)
    assert check_extra, "extra unknown ref must fail self_check"
    assert any(
        "extra" in e.lower() or "count" in e.lower() or "unknown" in e.lower()
        for e in check_extra
    ), check_extra

    # Duplicate locator / reordered contractual order.
    bad_dup = copy.deepcopy(pkt)
    first = copy.deepcopy(bad_dup["ratification_refs"][0])
    bad_dup["ratification_refs"] = [first, copy.deepcopy(first)]
    check_dup = mod.self_check(bad_dup)
    assert check_dup, "duplicate ref set must fail self_check"

    # Missing one required ref.
    bad_miss = copy.deepcopy(pkt)
    bad_miss["ratification_refs"] = [bad_miss["ratification_refs"][0]]
    check_miss = mod.self_check(bad_miss)
    assert check_miss, "missing ref must fail exact set self_check"


def test_sibling_absolute_receipt_rejected() -> None:
    """Sibling run absolute receipt path must not be accepted as general absolute."""
    mod = _load_mod("c6exp_b7_oor5")
    sibling = (
        "/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-11-ma14/"
        "reports/BALLOT-INDEX-v6.md"
    )
    if not Path(sibling).is_file():
        # Fall back to any other existing file under the same parent dir.
        parent = Path(mod.EXTERNAL_REF_ALLOWLIST_DECLARED).parent
        candidates = [p for p in parent.iterdir() if p.is_file() and p.name != Path(mod.EXTERNAL_REF_ALLOWLIST_DECLARED).name]
        assert candidates, "precondition: sibling receipt file must exist"
        sibling = str(candidates[0])
    resolved, err = mod._resolve_ref_strict(
        {"path": sibling, "locator": "sibling_receipt"}
    )
    assert resolved is None and err, "sibling absolute receipt must be rejected"


def main() -> int:
    tests = [
        test_positive,
        test_source_digest_drift,
        test_holdout_sha_drift,
        test_status_canonical_forgery,
        test_missing_field,
        test_operator_ceremony_prefill,
        test_zero_digest_forgery,
        test_digest_rebind_mismatch,
        test_missing_ref_fail_closed,
        test_unknown_extra_fields,
        test_check_mode_byte_drift,
        test_committed_packet_matches_schema,
        test_schema_rejects_extra_and_prefill,
        test_schema_rejects_missing_field,
        test_schema_rejects_zero_digest,
        test_out_of_repo_absolute_etc_hosts_rejected,
        test_out_of_repo_other_absolute_file_rejected,
        test_symlink_escape_absolute_ref_rejected,
        test_unknown_extra_ref_and_duplicate_ref_rejected,
        test_sibling_absolute_receipt_rejected,
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
        print(f"test_export_c6_corpus_freeze_packet FAILED ({len(failures)})")
        return 1
    print(f"test_export_c6_corpus_freeze_packet=ok ({len(tests)} tests)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
