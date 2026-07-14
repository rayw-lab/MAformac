#!/usr/bin/env python3
"""Negative + positive tests for the V1 ratification-packet exporter.

Positive: the exporter emits a candidate-only, drift-free, byte-stable packet.

Required negative gates (must be RED / fail-closed):
  1. source digest drift   -> mutate candidate digest -> exporter refuses
  2. threshold drift       -> golden/safety != 1.0 -> refuse
  3. status/canonical forgery -> is_canonical=true or is_v1_done=true fails
  4. missing field         -> packet missing authority_binding fails self_check
  5. operator/signature prefill -> ceremony prefill fields fail
  6. forged authority digest on packet -> exact recompute fails
  7. forged receipt sha on packet -> exact recompute fails
  8. missing ref fail-closed -> missing/unreadable refs refuse emit
  9. source status / decision-ref / threshold monkeypatch drift -> refuse
 10. unknown extra fields -> rejected
 11. --check byte-drift -> coherent subject+digest mutation fails check
 12. schema extra/missing -> stdlib (or jsonschema) enforces additionalProperties/required

Run: python3 -B scripts/test_export_c6_active_authority_ratification_packet.py
"""
from __future__ import annotations

import copy
import hashlib
import importlib.util
import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
EXPORTER = REPO_ROOT / "Tools" / "C6ActiveAuthority" / "export_ratification_packet.py"
SCHEMA = (
    REPO_ROOT
    / "contracts"
    / "c6-active-authority"
    / "ratification-packet.v1.schema.json"
)
CANDIDATE = REPO_ROOT / "contracts" / "c6-active-authority" / "authority.v1.candidate.json"
COMMITTED = (
    REPO_ROOT
    / "closure"
    / "candidates"
    / "V1"
    / "V1.v1.ratification-packet.candidate.json"
)
ZERO_SHA = "0" * 64
ALT_SHA = "b" * 64


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
    """Strict stdlib validator: type/required/const/enum/pattern/array/object/additionalProperties."""
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
            if not stdlib_errs:
                stdlib_errs = [f"jsonschema: {exc.message}"]
    except ImportError:
        pass
    return stdlib_errs


def test_positive() -> None:
    with tempfile.TemporaryDirectory() as tmp:
        p = Path(tmp) / "V1.packet.json"
        r = run_exporter(["--out", str(p)])
        assert r.returncode == 0, f"exporter failed: {r.stderr}"
        fresh = p.read_bytes()
    committed = COMMITTED.read_bytes()
    assert fresh == committed, "packet not byte-stable vs committed (drift in export)"
    pkt = json.loads(fresh.decode("utf-8"))
    assert pkt["status"] == "CANDIDATE_PACKET_ONLY"
    assert pkt["observed_status"] == "CANDIDATE"
    assert pkt["target_status"] == "RATIFIED"
    assert pkt["is_canonical"] is False
    assert pkt["is_v1_done"] is False
    assert pkt["requires_operator_ceremony"] is True
    for forbidden in ("operator", "signature", "signed_at", "ratified_at", "ceremony"):
        assert forbidden not in pkt, f"forbidden prefill field {forbidden!r} present"
    assert pkt["authority_binding"]["digest_sha256"] != ZERO_SHA
    for ref in pkt["receipt_refs"]:
        assert ref["sha256"] != ZERO_SHA
    rc = run_exporter(["--check"])
    assert rc.returncode == 0, f"--check failed: {rc.stderr}"


def test_source_digest_drift() -> None:
    """Mutate the live candidate digest; exporter must refuse to emit."""
    mod = _load_mod("c6exp_v1a")
    original = CANDIDATE.read_text(encoding="utf-8")
    try:
        doc = json.loads(original)
        d = doc["digest"]["sha256"]
        doc["digest"]["sha256"] = ("0" if d[0] != "0" else "1") + d[1:]
        CANDIDATE.write_text(json.dumps(doc, indent=2), encoding="utf-8")
        _pkt, errors = mod.build_packet()
        assert errors, "digest drift must produce errors and refuse emit"
        assert any("digest" in e.lower() for e in errors), errors
    finally:
        CANDIDATE.write_text(original, encoding="utf-8")


def test_threshold_drift() -> None:
    """Tamper golden threshold to 0.95; exporter must refuse (threshold drift)."""
    mod = _load_mod("c6exp_v1b")
    original = CANDIDATE.read_text(encoding="utf-8")
    try:
        doc = json.loads(original)
        doc["subject"]["four_layer_thresholds"]["golden"] = 0.95
        CANDIDATE.write_text(json.dumps(doc, indent=2), encoding="utf-8")
        _pkt, errors = mod.build_packet()
        assert errors, "threshold drift must produce errors and refuse emit"
        assert any("golden" in e for e in errors), errors
    finally:
        CANDIDATE.write_text(original, encoding="utf-8")


def test_status_canonical_forgery() -> None:
    """A packet claiming canonical / V1 done must fail self_check."""
    mod = _load_mod("c6exp_v1c")
    pkt, errors = mod.build_packet()
    assert not errors
    forged = copy.deepcopy(pkt)
    forged["is_canonical"] = True
    forged["is_v1_done"] = True
    forged["requires_operator_ceremony"] = False
    forged["status"] = "RATIFIED"
    forged["observed_status"] = "RATIFIED"
    check_errs = mod.self_check(forged)
    assert check_errs, "forged canonical/RATIFIED packet must fail self_check"


def test_missing_field() -> None:
    """A packet missing authority_binding must fail structural self_check."""
    mod = _load_mod("c6exp_v1d")
    pkt, errors = mod.build_packet()
    assert not errors
    bad = copy.deepcopy(pkt)
    del bad["authority_binding"]
    check_errs = mod.self_check(bad)
    assert check_errs, "missing authority_binding must fail self_check"
    assert any("authority_binding" in e for e in check_errs), check_errs
    real = load_packet()
    assert "authority_binding" in real, "committed packet missing authority_binding"


def test_operator_signature_prefill() -> None:
    """Prefilling operator/signature/time fields must be rejected as forgery."""
    mod = _load_mod("c6exp_v1e")
    pkt, errors = mod.build_packet()
    assert not errors
    prefilled = copy.deepcopy(pkt)
    prefilled["operator"] = "leige"
    prefilled["signature"] = ZERO_SHA
    prefilled["signed_at"] = "2026-07-14T00:00:00+08:00"
    prefilled["ratified_at"] = "2026-07-14T00:00:00+08:00"
    prefilled["ceremony"] = {"completed": True}
    check_errs = mod.self_check(prefilled)
    assert check_errs, "operator/signature/time prefill must fail self_check"
    assert any(
        "operator" in e
        or "signature" in e
        or "signed_at" in e
        or "ratified_at" in e
        or "ceremony" in e
        for e in check_errs
    ), check_errs


def test_forged_authority_digest() -> None:
    """Packet with forged authority digest must fail exact recompute self_check."""
    mod = _load_mod("c6exp_v1f")
    pkt, errors = mod.build_packet()
    assert not errors
    forged = copy.deepcopy(pkt)
    forged["authority_binding"]["digest_sha256"] = ALT_SHA
    check_errs = mod.self_check(forged)
    assert check_errs, "forged authority digest must fail self_check"
    assert any(
        "digest" in e.lower() or "authority" in e.lower() or "recompute" in e.lower()
        for e in check_errs
    ), check_errs


def test_forged_receipt_sha() -> None:
    """Packet with forged receipt_refs sha must fail exact recompute self_check."""
    mod = _load_mod("c6exp_v1g")
    pkt, errors = mod.build_packet()
    assert not errors
    forged = copy.deepcopy(pkt)
    assert forged["receipt_refs"], "precondition: receipt_refs present"
    forged["receipt_refs"][0]["sha256"] = ALT_SHA
    check_errs = mod.self_check(forged)
    assert check_errs, "forged receipt sha must fail self_check"
    assert any(
        "receipt" in e.lower()
        or "sha" in e.lower()
        or "recompute" in e.lower()
        or "ref" in e.lower()
        for e in check_errs
    ), check_errs


def test_missing_ref_fail_closed() -> None:
    """Missing refs must fail closed; never emit all-zero sha as valid evidence."""
    mod = _load_mod("c6exp_v1h")
    missing = {
        "path": "docs/does-not-exist-for-v1-fail-closed-probe.md",
        "locator": "missing",
    }
    resolved, err = mod._resolve_ref_strict(missing)
    assert err, "missing ref must return error"
    assert resolved is None
    original = list(mod.RECEIPT_REFS)
    try:
        mod.RECEIPT_REFS = [missing]
        _pkt, errors = mod.build_packet()
        assert errors, "missing receipt ref must refuse emit"
        assert any("missing" in e.lower() or "ref" in e.lower() for e in errors), errors
        assert not any(ZERO_SHA in e and "ok" in e.lower() for e in errors)
    finally:
        mod.RECEIPT_REFS = original


def test_source_status_and_decision_ref_drift() -> None:
    """Monkeypatch source status/decision required_state must fail closed."""
    mod = _load_mod("c6exp_v1i")
    original = CANDIDATE.read_text(encoding="utf-8")
    try:
        doc = json.loads(original)
        doc["status"] = "RATIFIED"
        CANDIDATE.write_text(json.dumps(doc, indent=2), encoding="utf-8")
        _pkt, errors = mod.build_packet()
        assert errors, "source status!=CANDIDATE must refuse"
        assert any("CANDIDATE" in e or "status" in e.lower() for e in errors), errors
    finally:
        CANDIDATE.write_text(original, encoding="utf-8")

    try:
        doc = json.loads(original)
        for d in doc.get("decision_refs", []):
            if d.get("decision_id") == "D-147":
                d["required_state"] = "proposed"
        CANDIDATE.write_text(json.dumps(doc, indent=2), encoding="utf-8")
        _pkt, errors = mod.build_packet()
        assert errors, "decision required_state drift must refuse"
        assert any("required_state" in e or "D-147" in e for e in errors), errors
    finally:
        CANDIDATE.write_text(original, encoding="utf-8")

    try:
        doc = json.loads(original)
        doc["source_members"] = []
        CANDIDATE.write_text(json.dumps(doc, indent=2), encoding="utf-8")
        _pkt, errors = mod.build_packet()
        assert errors, "empty source_members must refuse"
        assert any("source_members" in e for e in errors), errors
    finally:
        CANDIDATE.write_text(original, encoding="utf-8")


def test_unknown_extra_fields() -> None:
    """Unknown top-level fields must fail self_check."""
    mod = _load_mod("c6exp_v1j")
    pkt, errors = mod.build_packet()
    assert not errors
    bad = copy.deepcopy(pkt)
    bad["canonical_receipt"] = {"path": "fake"}
    bad["operator_identity"] = "forged"
    check_errs = mod.self_check(bad)
    assert check_errs, "unknown extra fields must fail self_check"
    assert any(
        "unknown" in e.lower() or "extra" in e.lower() or "forbidden" in e.lower()
        for e in check_errs
    ), check_errs


def test_check_mode_byte_drift() -> None:
    """--check must fail when live rebuild differs from committed packet.

    Coherent mutation: change subject text + recompute declared digest so source
    still self-consistent, but committed packet is stale.
    """
    original_cand = CANDIDATE.read_text(encoding="utf-8")
    original_pkt = COMMITTED.read_bytes()
    try:
        sys.path.insert(0, str(REPO_ROOT / "scripts"))
        import check_c6_active_authority_candidate as auth_checker  # noqa: E402

        doc = json.loads(original_cand)
        # Coherent subject mutation that changes digest while keeping thresholds.
        roster = doc["subject"]["demo_fuzz_family_roster"]
        # Rotate roster order (same set content may or may not change digest depending
        # on canonicalization). Force a subject string field change instead.
        doc["subject"]["notes_for_drift_probe"] = "deliberate-red-coherent-mutation"
        # Thresholds remain valid so only digest identity changes.
        doc["digest"]["sha256"] = auth_checker.compute_digest(doc)
        CANDIDATE.write_text(json.dumps(doc, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

        # Leave COMMITTED packet as-is (stale). --check must fail.
        rc = run_exporter(["--check"])
        assert rc.returncode != 0, (
            "--check must be nonzero when live source mutated with recomputed digest "
            "but committed packet not updated"
        )
    finally:
        CANDIDATE.write_text(original_cand, encoding="utf-8")
        COMMITTED.write_bytes(original_pkt)


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
    del bad["authority_binding"]
    errs = _validate_schema(bad, schema)
    assert errs, "schema must reject missing authority_binding"
    assert any("authority_binding" in e for e in errs), errs


def test_schema_rejects_zero_digest() -> None:
    """Schema pattern must reject all-zero authority digest."""
    pkt = load_packet()
    schema = json.loads(SCHEMA.read_text(encoding="utf-8"))
    bad = copy.deepcopy(pkt)
    bad["authority_binding"]["digest_sha256"] = ZERO_SHA
    errs = _validate_schema(bad, schema)
    assert errs, "schema must reject all-zero digest_sha256"


def test_out_of_repo_absolute_etc_hosts_rejected() -> None:
    """/etc/hosts (existing absolute file) must fail closed — not allowlisted."""
    mod = _load_mod("c6exp_v1_oor1")
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
    """Any other existing absolute file must fail closed."""
    mod = _load_mod("c6exp_v1_oor2")
    other = Path("/etc/passwd")
    assert other.is_file(), "precondition: /etc/passwd must exist"
    resolved, err = mod._resolve_ref_strict(
        {"path": str(other), "locator": "evil_passwd"}
    )
    assert resolved is None and err, "non-allowlisted absolute file must be rejected"


def test_symlink_escape_absolute_ref_rejected() -> None:
    """Absolute symlink that resolves outside allowlist must fail closed."""
    mod = _load_mod("c6exp_v1_oor3")
    with tempfile.TemporaryDirectory() as tmp:
        link = Path(tmp) / "escape-hosts"
        link.symlink_to("/etc/hosts")
        resolved, err = mod._resolve_ref_strict(
            {"path": str(link), "locator": "symlink_escape"}
        )
        assert resolved is None and err, "symlink escape via absolute path must fail"


def test_unknown_extra_ref_and_duplicate_ref_rejected() -> None:
    """Extra unknown locator and duplicate refs must fail exact set self_check."""
    mod = _load_mod("c6exp_v1_oor4")
    pkt, errors = mod.build_packet()
    assert not errors
    bad_extra = copy.deepcopy(pkt)
    bad_extra["receipt_refs"] = list(bad_extra["receipt_refs"]) + [
        {
            "path": "docs/commander-log/decisions.md",
            "locator": "unknown_extra",
            "sha256": bad_extra["receipt_refs"][0]["sha256"],
        }
    ]
    check_extra = mod.self_check(bad_extra)
    assert check_extra, "extra unknown ref must fail self_check"

    bad_dup = copy.deepcopy(pkt)
    first = copy.deepcopy(bad_dup["receipt_refs"][0])
    bad_dup["receipt_refs"] = [first, copy.deepcopy(first)]
    check_dup = mod.self_check(bad_dup)
    assert check_dup, "duplicate ref set must fail self_check"

    bad_miss = copy.deepcopy(pkt)
    bad_miss["receipt_refs"] = [bad_miss["receipt_refs"][0]]
    check_miss = mod.self_check(bad_miss)
    assert check_miss, "missing ref must fail exact set self_check"


def test_source_members_zero_sha_rejected() -> None:
    """source_members with all-zero sha must refuse emit."""
    mod = _load_mod("c6exp_v1_sm1")
    original = CANDIDATE.read_text(encoding="utf-8")
    try:
        doc = json.loads(original)
        doc["source_members"][0]["sha256"] = ZERO_SHA
        # Legacy digest intentionally unchanged (source_members not in digest).
        CANDIDATE.write_text(json.dumps(doc, indent=2), encoding="utf-8")
        _pkt, errors = mod.build_packet()
        assert errors, "zero sha source_members must refuse emit"
        assert any(
            "source_members" in e.lower() or "zero" in e.lower() or "sha" in e.lower()
            for e in errors
        ), errors
    finally:
        CANDIDATE.write_text(original, encoding="utf-8")


def test_source_members_wrong_sha_rejected() -> None:
    """source_members with wrong live sha must refuse emit even if digest recomputed."""
    mod = _load_mod("c6exp_v1_sm2")
    original = CANDIDATE.read_text(encoding="utf-8")
    try:
        sys.path.insert(0, str(REPO_ROOT / "scripts"))
        import check_c6_active_authority_candidate as auth_checker  # noqa: E402

        doc = json.loads(original)
        doc["source_members"][0]["sha256"] = ALT_SHA
        # Recompute legacy authority digest (still excludes source_members).
        doc["digest"]["sha256"] = auth_checker.compute_digest(doc)
        CANDIDATE.write_text(json.dumps(doc, indent=2), encoding="utf-8")
        _pkt, errors = mod.build_packet()
        assert errors, "wrong source_members sha must refuse even with recomputed digest"
        assert any(
            "source_members" in e.lower() or "sha" in e.lower() or "mismatch" in e.lower()
            for e in errors
        ), errors
    finally:
        CANDIDATE.write_text(original, encoding="utf-8")


def test_source_members_etc_hosts_path_rejected() -> None:
    """source_members path=/etc/hosts must fail closed."""
    mod = _load_mod("c6exp_v1_sm3")
    original = CANDIDATE.read_text(encoding="utf-8")
    try:
        doc = json.loads(original)
        # Keep member_id so expected set membership is about path mismatch / allowlist.
        doc["source_members"][0]["path"] = "/etc/hosts"
        CANDIDATE.write_text(json.dumps(doc, indent=2), encoding="utf-8")
        _pkt, errors = mod.build_packet()
        assert errors, "/etc/hosts source_members path must refuse"
        assert any(
            "path" in e.lower()
            or "allowlist" in e.lower()
            or "hosts" in e.lower()
            or "fail-closed" in e.lower()
            or "mismatch" in e.lower()
            for e in errors
        ), errors
    finally:
        CANDIDATE.write_text(original, encoding="utf-8")


def test_source_members_wrong_role_rejected() -> None:
    """source_members with wrong role must refuse emit."""
    mod = _load_mod("c6exp_v1_sm4")
    original = CANDIDATE.read_text(encoding="utf-8")
    try:
        doc = json.loads(original)
        doc["source_members"][0]["role"] = "forged_role"
        CANDIDATE.write_text(json.dumps(doc, indent=2), encoding="utf-8")
        _pkt, errors = mod.build_packet()
        assert errors, "wrong role must refuse"
        assert any("role" in e.lower() for e in errors), errors
    finally:
        CANDIDATE.write_text(original, encoding="utf-8")


def test_source_members_missing_extra_duplicate_order() -> None:
    """Missing / extra / duplicate / reordered source_members must refuse."""
    mod = _load_mod("c6exp_v1_sm5")
    original = CANDIDATE.read_text(encoding="utf-8")
    try:
        # Missing member.
        doc = json.loads(original)
        doc["source_members"] = doc["source_members"][1:]
        CANDIDATE.write_text(json.dumps(doc, indent=2), encoding="utf-8")
        _pkt, errors = mod.build_packet()
        assert errors, "missing source_member must refuse"
        assert any(
            "missing" in e.lower() or "source_members" in e.lower() for e in errors
        ), errors
    finally:
        CANDIDATE.write_text(original, encoding="utf-8")

    try:
        # Extra unknown member.
        doc = json.loads(original)
        extra = copy.deepcopy(doc["source_members"][0])
        extra["member_id"] = "forged_extra_member"
        doc["source_members"] = list(doc["source_members"]) + [extra]
        CANDIDATE.write_text(json.dumps(doc, indent=2), encoding="utf-8")
        _pkt, errors = mod.build_packet()
        assert errors, "extra source_member must refuse"
        assert any(
            "extra" in e.lower() or "unknown" in e.lower() for e in errors
        ), errors
    finally:
        CANDIDATE.write_text(original, encoding="utf-8")

    try:
        # Duplicate member_id.
        doc = json.loads(original)
        dup = copy.deepcopy(doc["source_members"][0])
        doc["source_members"] = list(doc["source_members"]) + [dup]
        CANDIDATE.write_text(json.dumps(doc, indent=2), encoding="utf-8")
        _pkt, errors = mod.build_packet()
        assert errors, "duplicate source_member must refuse"
        assert any(
            "duplicate" in e.lower() or "extra" in e.lower() or "order" in e.lower()
            for e in errors
        ), errors
    finally:
        CANDIDATE.write_text(original, encoding="utf-8")

    try:
        # Reordered (contractual order).
        doc = json.loads(original)
        members = list(doc["source_members"])
        members[0], members[1] = members[1], members[0]
        doc["source_members"] = members
        CANDIDATE.write_text(json.dumps(doc, indent=2), encoding="utf-8")
        _pkt, errors = mod.build_packet()
        assert errors, "reordered source_members must refuse"
        assert any("order" in e.lower() for e in errors), errors
    finally:
        CANDIDATE.write_text(original, encoding="utf-8")


def test_source_members_binding_packet_self_check() -> None:
    """Packet source_members_binding drift must fail self_check independent of digest."""
    mod = _load_mod("c6exp_v1_sm6")
    pkt, errors = mod.build_packet()
    assert not errors
    assert "source_members_binding" in pkt
    assert pkt["source_members_binding"]["member_count"] == 7
    assert len(pkt["source_members_binding"]["members"]) == 7

    forged = copy.deepcopy(pkt)
    forged["source_members_binding"]["digest_sha256"] = ALT_SHA
    check_errs = mod.self_check(forged)
    assert check_errs, "forged source_members_binding digest must fail self_check"
    assert any(
        "source_members" in e.lower() or "binding" in e.lower() for e in check_errs
    ), check_errs

    forged2 = copy.deepcopy(pkt)
    forged2["source_members_binding"]["members"][0]["sha256"] = ALT_SHA
    check_errs2 = mod.self_check(forged2)
    assert check_errs2, "forged source_members_binding member sha must fail self_check"


def main() -> int:
    tests = [
        test_positive,
        test_source_digest_drift,
        test_threshold_drift,
        test_status_canonical_forgery,
        test_missing_field,
        test_operator_signature_prefill,
        test_forged_authority_digest,
        test_forged_receipt_sha,
        test_missing_ref_fail_closed,
        test_source_status_and_decision_ref_drift,
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
        test_source_members_zero_sha_rejected,
        test_source_members_wrong_sha_rejected,
        test_source_members_etc_hosts_path_rejected,
        test_source_members_wrong_role_rejected,
        test_source_members_missing_extra_duplicate_order,
        test_source_members_binding_packet_self_check,
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
        print(f"test_export_c6_active_authority_ratification_packet FAILED ({len(failures)})")
        return 1
    print(f"test_export_c6_active_authority_ratification_packet=ok ({len(tests)} tests)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
