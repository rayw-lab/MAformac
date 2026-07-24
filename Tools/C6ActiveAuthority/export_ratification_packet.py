#!/usr/bin/env python3
"""V1 active-authority ratification-packet exporter (candidate-only mechanical envelope).

Mechanical consumption packet for the downstream operator ceremony that turns the V1
active-authority *candidate* into a RATIFIED/canonical authority. This exporter only
DERIVES data from the live repo; it never elevates V1 to RATIFIED/canonical, never
forges operator/time/signature, and never produces the canonical execution receipt.

Sources (live, recomputed every run):
  - contracts/c6-active-authority/authority.v1.candidate.json (digest + thresholds + refs)
  - D-147 decision + pool32 ratification receipt (live sha bound mechanically)

Determinism: canonical JSON (sort_keys, separators, ensure_ascii). The packet is
byte-stable and regenerable. The exporter REFUSES to emit if the live authority
candidate digest / threshold / ref bindings have drifted from the on-disk candidate.

CLI:
  python3 Tools/C6ActiveAuthority/export_ratification_packet.py            # write packet
  python3 Tools/C6ActiveAuthority/export_ratification_packet.py --check    # rebuild + byte-equal committed
  python3 Tools/C6ActiveAuthority/export_ratification_packet.py --stdout   # print, no write

Status contract (hard):
  status=CANDIDATE_PACKET_ONLY, observed_status=CANDIDATE, target_status=RATIFIED,
  is_canonical=false, is_v1_done=false, requires_operator_ceremony=true.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path
from typing import Any

REPO_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO_ROOT / "scripts"))
import check_c6_active_authority_candidate as auth_checker  # noqa: E402

CANDIDATE_PATH = REPO_ROOT / "contracts" / "c6-active-authority" / "authority.v1.candidate.json"

# Pool32 ratification receipt is vendored in-repo so CI/reanchor can resolve it
# without a machine-local absolute path. Absolute refs remain forbidden.
POOL32_RECEIPT_RELATIVE = (
    "docs/closure-evidence/2026-07-11-ma14-RATIFICATION-RECEIPT-pool32.md"
)
# Legacy name kept for negative-path tests that assert absolute refs are rejected.
EXTERNAL_REF_ALLOWLIST_DECLARED = POOL32_RECEIPT_RELATIVE

# D-147 ratification refs bound mechanically (cannot forge T01/T02 ratification string).
# Order is contractual: self_check requires exact ordered match.
RECEIPT_REFS = [
    {
        "path": "docs/commander-log/decisions.md",
        "locator": "D-147",
    },
    {
        "path": POOL32_RECEIPT_RELATIVE,
        "locator": "pool32",
    },
]

# Packet-level source_members binding (does NOT enter the legacy authority digest).
SOURCE_MEMBER_ALLOWED_FIELDS = frozenset(
    {
        "member_id",
        "role",
        "path",
        "locator",
        "sha256",
        "subject_bindings",
    }
)

ALLOWED_TOP_LEVEL_KEYS = frozenset(
    {
        "schema_version",
        "packet_id",
        "package_id",
        "status",
        "observed_status",
        "target_status",
        "is_canonical",
        "is_v1_done",
        "requires_operator_ceremony",
        "authority_binding",
        "four_layer_thresholds",
        "decision_refs",
        "receipt_refs",
        "source_members_binding",
        "non_claims",
    }
)

FORBIDDEN_TOP_LEVEL_FIELDS = frozenset(
    {
        "operator",
        "operator_id",
        "operator_identity",
        "signature",
        "signed_at",
        "signed_by",
        "ratified_at",
        "ratified_by",
        "ceremony",
        "ceremony_ts",
        "ceremony_completed",
        "frozen_at",
        "frozen_by",
        "canonical_receipt",
        "is_done",
        "done",
        "DONE",
        "canonical",
    }
)

SHA256_RE = re.compile(r"^[0-9a-f]{64}$")
ZERO_SHA = "0" * 64
DEFAULT_OUT = (
    REPO_ROOT
    / "closure"
    / "candidates"
    / "V1"
    / "V1.v1.ratification-packet.candidate.json"
)


def _sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def _resolve_path(path_str: str) -> Path:
    p = Path(path_str)
    if not p.is_absolute():
        p = REPO_ROOT / p
    return p


def _path_is_under_repo(resolved: Path) -> bool:
    """True iff resolved is inside REPO_ROOT (symlink-aware; not prefix-string)."""
    repo = REPO_ROOT.resolve()
    try:
        resolved.relative_to(repo)
        return True
    except ValueError:
        return False


def _resolve_ref_strict(
    ref: dict,
    *,
    sha_overrides: dict[str, str] | None = None,
) -> tuple[dict | None, str | None]:
    """Fail-closed ref resolver. Never emits all-zero sha as valid evidence.

    Repo-relative refs must remain inside REPO_ROOT after symlink resolution.
    Absolute refs are forbidden (pool32 receipt is vendored in-repo).
    """
    path_str = ref.get("path")
    locator = ref.get("locator")
    if not path_str or not isinstance(path_str, str):
        return None, "ref missing path"
    if not locator or not isinstance(locator, str):
        return None, f"ref {path_str!r} missing locator"
    p = _resolve_path(path_str)
    try:
        resolved = p.resolve()
        if Path(path_str).is_absolute():
            return None, f"absolute ref path forbidden: {path_str}"
        if not _path_is_under_repo(resolved):
            return None, f"ref path escapes repo root: {path_str}"
        if not p.exists() and not resolved.exists():
            return None, f"missing ref path: {path_str}"
        if not resolved.is_file():
            return None, f"ref path is not a file: {path_str}"
        overrides = sha_overrides or {}
        sha = overrides[path_str] if path_str in overrides else _sha256(resolved)
    except OSError as exc:
        return None, f"unreadable ref path {path_str}: {exc}"
    if sha == ZERO_SHA:
        return None, f"ref sha is all-zero sentinel (rejected): {path_str}"
    if not SHA256_RE.match(sha):
        return None, f"ref sha invalid: {path_str}"
    return {"path": path_str, "locator": locator, "sha256": sha}, None


def _resolve_ref(ref: dict) -> dict:
    """Backward-compat name: fail-closed. Raises on missing/unreadable refs."""
    resolved, err = _resolve_ref_strict(ref)
    if err or resolved is None:
        raise FileNotFoundError(err or "ref resolution failed")
    return resolved


def _expected_receipt_refs() -> tuple[list[dict], list[str]]:
    """Resolve the contractual RECEIPT_REFS set in declared order."""
    out: list[dict] = []
    errs: list[str] = []
    for base in RECEIPT_REFS:
        resolved, err = _resolve_ref_strict(base)
        if err or resolved is None:
            errs.append(f"expected receipt_ref fail-closed: {err}")
            continue
        out.append(resolved)
    return out, errs


def _exact_ref_list_errors(
    declared: Any, expected: list[dict], label: str
) -> list[str]:
    """Exact ordered ref-set contract: no missing/extra/duplicate/reorder/drift."""
    errs: list[str] = []
    if not isinstance(declared, list):
        return [f"{label} must be a list"]
    locators = [
        r.get("locator") for r in declared if isinstance(r, dict) and r.get("locator")
    ]
    if len(locators) != len(set(locators)):
        errs.append(f"{label}: duplicate locator in declared set")
    if len(declared) != len(expected):
        errs.append(
            f"{label}: count {len(declared)} != expected exact set size {len(expected)}"
        )
    for i, exp in enumerate(expected):
        if i >= len(declared):
            errs.append(f"{label}[{i}]: missing expected locator {exp['locator']!r}")
            continue
        d = declared[i]
        if not isinstance(d, dict):
            errs.append(f"{label}[{i}] must be object")
            continue
        for k in d:
            if k not in ("path", "locator", "sha256"):
                errs.append(f"{label}[{i}] unknown extra field: {k}")
        for k in ("path", "locator", "sha256"):
            if d.get(k) != exp.get(k):
                errs.append(
                    f"{label}[{i}].{k} mismatch: declared={d.get(k)!r}, "
                    f"expected={exp.get(k)!r}"
                )
        if d.get("sha256") == ZERO_SHA:
            errs.append(f"{label}[{i}] all-zero sha rejected")
    if len(declared) > len(expected):
        for i in range(len(expected), len(declared)):
            loc = (
                declared[i].get("locator")
                if isinstance(declared[i], dict)
                else "?"
            )
            errs.append(f"{label}[{i}]: extra ref not in expected set (locator={loc!r})")
    return errs


def _validate_and_bind_source_members(
    doc: dict,
    *,
    sha_overrides: dict[str, str] | None = None,
) -> tuple[dict | None, list[str]]:
    """Exact source_members validation + packet-level binding (not legacy digest).

    Validates declared members against auth_checker.EXPECTED_SOURCE_MEMBERS and live
    file contents: exact roles/paths/locators/bindings, repo/allowlist containment,
    file existence, sha256 equality, no zero hashes, no duplicates/extras/missing/
    unknown fields. Order is contractual (EXPECTED_SOURCE_MEMBERS insertion order).
    """
    errors: list[str] = []
    members = doc.get("source_members")
    expected = auth_checker.EXPECTED_SOURCE_MEMBERS
    expected_order = list(expected.keys())

    if not isinstance(members, list):
        return None, ["source_members must be a list"]
    if not members:
        return None, ["source_members must be a non-empty array"]

    seen_ids: set[str] = set()
    normalized: list[dict] = []

    for i, member in enumerate(members):
        label = f"source_members[{i}]"
        if not isinstance(member, dict):
            errors.append(f"{label}: must be object")
            continue
        for k in member:
            if k not in SOURCE_MEMBER_ALLOWED_FIELDS:
                errors.append(f"{label}: unknown extra field {k!r}")

        mid = member.get("member_id")
        role = member.get("role")
        path = member.get("path")
        locator = member.get("locator")
        sha = member.get("sha256")
        bindings = member.get("subject_bindings")

        if not isinstance(mid, str) or not mid:
            errors.append(f"{label}: missing member_id")
            continue
        if mid in seen_ids:
            errors.append(f"{label}: duplicate member_id {mid!r}")
        seen_ids.add(mid)

        exp = expected.get(mid)
        if exp is None:
            errors.append(f"{label}: unknown member_id {mid!r} not in expected set")
            continue
        if role != exp["role"]:
            errors.append(
                f"{label}: role mismatch: declared={role!r}, expected={exp['role']!r}"
            )
        if path != exp["path"]:
            errors.append(
                f"{label}: path mismatch: declared={path!r}, expected={exp['path']!r}"
            )
        if locator != exp["locator"]:
            errors.append(
                f"{label}: locator mismatch: declared={locator!r}, "
                f"expected={exp['locator']!r}"
            )
        exp_bindings = list(exp["subject_bindings"])  # type: ignore[arg-type]
        if not isinstance(bindings, list) or list(bindings) != exp_bindings:
            errors.append(
                f"{label}: subject_bindings mismatch: declared={bindings!r}, "
                f"expected={exp_bindings!r}"
            )

        if not isinstance(sha, str) or not SHA256_RE.match(sha):
            errors.append(f"{label}: invalid sha256 shape")
        elif sha == ZERO_SHA:
            errors.append(f"{label}: all-zero sha256 rejected")
        elif isinstance(path, str) and path:
            # Path containment: absolute only allowlisted pool32; relative under repo.
            resolved_ref, path_err = _resolve_ref_strict(
                {"path": path, "locator": locator if isinstance(locator, str) else mid},
                sha_overrides=sha_overrides,
            )
            if path_err or resolved_ref is None:
                errors.append(f"{label}: path fail-closed: {path_err}")
            else:
                live_sha = resolved_ref["sha256"]
                if live_sha != sha:
                    errors.append(
                        f"{label}: sha256 mismatch vs live file: "
                        f"declared={sha}, live={live_sha}"
                    )

        normalized.append(
            {
                "member_id": mid,
                "role": role if isinstance(role, str) else "",
                "path": path if isinstance(path, str) else "",
                "locator": locator if isinstance(locator, str) else "",
                "sha256": sha if isinstance(sha, str) else "",
            }
        )

    missing = [m for m in expected_order if m not in seen_ids]
    if missing:
        errors.append(f"source_members missing members: {missing}")
    extra = sorted(seen_ids - set(expected_order))
    if extra:
        errors.append(f"source_members unexpected extra members: {extra}")

    # Order contractual: must match EXPECTED_SOURCE_MEMBERS insertion order.
    declared_order = [
        m.get("member_id")
        for m in members
        if isinstance(m, dict) and isinstance(m.get("member_id"), str)
    ]
    if declared_order != expected_order:
        errors.append(
            "source_members order mismatch: "
            f"declared={declared_order}, expected={expected_order}"
        )

    if errors:
        return None, errors

    # Packet-level binding digest over exact ordered normalized members.
    # Sort keys inside each member object; list order is the contractual order.
    canonical = json.dumps(
        normalized, sort_keys=True, ensure_ascii=False, separators=(",", ":")
    )
    binding = {
        "digest_sha256": hashlib.sha256(canonical.encode("utf-8")).hexdigest(),
        "member_count": len(normalized),
        "members": normalized,
    }
    return binding, []


def _load_candidate() -> dict:
    if not CANDIDATE_PATH.exists():
        raise SystemExit(f"authority candidate missing: {CANDIDATE_PATH}")
    return json.loads(CANDIDATE_PATH.read_text(encoding="utf-8"))


def build_packet(
    candidate: dict | None = None,
    *,
    source_sha_overrides: dict[str, str] | None = None,
) -> tuple[dict, list[str]]:
    """Return (packet, drift_errors). Drift_errors non-empty => refuse to write."""
    errors: list[str] = []
    doc = candidate if candidate is not None else _load_candidate()

    # Exact-check source candidate status / members / decision refs.
    source_status = doc.get("status")
    if source_status != "CANDIDATE":
        errors.append(
            f"source candidate status must be CANDIDATE, got {source_status!r}"
        )

    # Exact source_members bind (packet-level; NOT part of legacy authority digest).
    source_members_binding, sm_errs = _validate_and_bind_source_members(
        doc,
        sha_overrides=source_sha_overrides,
    )
    errors.extend(sm_errs)

    authority_id = doc.get("authority_id")
    authority_version = doc.get("authority_version")
    digest_sha = doc.get("digest", {}).get("sha256")
    subject = doc.get("subject", {})
    thresholds = subject.get("four_layer_thresholds", {}) if isinstance(subject, dict) else {}

    if authority_id != "c6_active_authority_v1":
        errors.append(f"authority_id {authority_id!r} != expected c6_active_authority_v1")
    if authority_version != 1:
        errors.append(f"authority_version {authority_version!r} != 1")

    # Digest bind: recompute the authority self-digest via the checker's canonical
    # rule and assert it matches the declared digest (refuse drift / forgery).
    # NOTE: legacy digest deliberately excludes source_members; packet binding covers it.
    live_digest = auth_checker.compute_digest(doc)
    if not digest_sha:
        errors.append("candidate digest_sha256 missing")
    elif digest_sha == ZERO_SHA:
        errors.append("candidate digest_sha256 is all-zero (rejected)")
    elif digest_sha != live_digest:
        errors.append(
            f"authority digest drift: declared={digest_sha}, recomputed={live_digest}"
        )

    # Threshold bind: assert exact subject thresholds (drift guard).
    if thresholds.get("golden") != 1.0:
        errors.append("four_layer_thresholds.golden must be 1.0")
    if thresholds.get("unsupported") != 1.0:
        errors.append("four_layer_thresholds.unsupported must be 1.0")
    if thresholds.get("safety") != 1.0:
        errors.append("four_layer_thresholds.safety must be 1.0")
    df = thresholds.get("demo_fuzz", {})
    if not isinstance(df, dict) or df.get("formula") != "5*pass >= 4*eligible":
        errors.append(
            "four_layer_thresholds.demo_fuzz.formula must be '5*pass >= 4*eligible'"
        )

    # Decision refs: exact required_state + D-147 presence.
    decision_refs: list[dict] = []
    raw_decision_refs = doc.get("decision_refs", [])
    if not isinstance(raw_decision_refs, list) or not raw_decision_refs:
        errors.append("decision_refs missing/empty on source candidate")
    else:
        for i, d in enumerate(raw_decision_refs):
            if not isinstance(d, dict):
                errors.append(f"decision_refs[{i}] not an object")
                continue
            did = d.get("decision_id")
            rstate = d.get("required_state")
            if rstate != "ratified":
                errors.append(
                    f"decision_refs[{i}] ({did}) required_state must be 'ratified', got {rstate!r}"
                )
            decision_refs.append({"decision_id": did, "required_state": rstate})
        if not any(d.get("decision_id") == "D-147" for d in decision_refs):
            errors.append("D-147 must be present in candidate decision_refs")

    # Source ratification_refs (on authority candidate) must match live file digests
    # AND exact expected RECEIPT_REFS set (path/locator order + allowlist).
    source_rat_refs = doc.get("ratification_refs") or []
    if not isinstance(source_rat_refs, list):
        errors.append("source ratification_refs must be a list")
    else:
        expected_receipts, exp_errs = _expected_receipt_refs()
        errors.extend(exp_errs)
        # Compare source ratification_refs as path/locator/sha against expected set.
        # Build expected without requiring packet field shape on source docs.
        source_as_refs: list[dict] = []
        for i, ref in enumerate(source_rat_refs):
            if not isinstance(ref, dict):
                errors.append(f"source ratification_refs[{i}] not an object")
                continue
            resolved, err = _resolve_ref_strict(
                {"path": ref.get("path"), "locator": ref.get("locator") or f"idx{i}"}
            )
            if err or resolved is None:
                errors.append(f"source ratification_refs[{i}] fail-closed: {err}")
                continue
            declared = ref.get("sha256")
            if declared != resolved["sha256"]:
                errors.append(
                    f"source ratification_refs[{i}] sha mismatch: "
                    f"declared={declared}, live={resolved['sha256']}"
                )
            source_as_refs.append(
                {
                    "path": ref.get("path"),
                    "locator": ref.get("locator"),
                    "sha256": declared,
                }
            )
        errors.extend(
            _exact_ref_list_errors(
                source_as_refs, expected_receipts, "source ratification_refs"
            )
        )

    # Packet receipt_refs from RECEIPT_REFS (mechanical exact ordered set).
    receipt_refs, receipt_errs = _expected_receipt_refs()
    errors.extend(receipt_errs)
    if len(receipt_refs) != len(RECEIPT_REFS):
        errors.append(
            f"receipt_refs exact set incomplete: got {len(receipt_refs)} "
            f"expected {len(RECEIPT_REFS)}"
        )

    packet = {
        "schema_version": "c6_active_authority_ratification_packet_v1",
        "packet_id": "V1.ratification.v1",
        "package_id": "V1",
        "status": "CANDIDATE_PACKET_ONLY",
        "observed_status": "CANDIDATE",
        "target_status": "RATIFIED",
        "is_canonical": False,
        "is_v1_done": False,
        "requires_operator_ceremony": True,
        "authority_binding": {
            "authority_id": authority_id,
            "authority_version": authority_version,
            "path": "contracts/c6-active-authority/authority.v1.candidate.json",
            "schema_version": doc.get("schema_version"),
            "subject_schema_id": doc.get("subject_schema_id"),
            "digest_sha256": live_digest,
        },
        "four_layer_thresholds": {
            "golden": thresholds.get("golden"),
            "demo_fuzz": {"formula": df.get("formula") if isinstance(df, dict) else None},
            "unsupported": thresholds.get("unsupported"),
            "safety": thresholds.get("safety"),
        },
        "decision_refs": decision_refs,
        "receipt_refs": receipt_refs,
        "source_members_binding": source_members_binding
        if source_members_binding is not None
        else {
            "digest_sha256": ZERO_SHA,
            "member_count": 0,
            "members": [],
        },
        "non_claims": [
            "not canonical",
            "not RATIFIED",
            "not V1 DONE",
            "not C6 acceptance",
            "not operator ceremony (see requires_operator_ceremony)",
            "not candidate signed",
            "no forged operator/time/signature",
        ],
    }
    return packet, errors


def canonical_bytes(packet: dict) -> bytes:
    text = json.dumps(packet, sort_keys=True, ensure_ascii=False, separators=(",", ":"))
    return text.encode("utf-8")


def self_check(packet: dict) -> list[str]:
    """Strict candidate-packet self-check: structure + exact recompute binds."""
    errs: list[str] = []

    if not isinstance(packet, dict):
        return ["packet must be an object"]

    for key in packet:
        if key in FORBIDDEN_TOP_LEVEL_FIELDS:
            errs.append(f"forbidden prefill field present: {key}")
        elif key not in ALLOWED_TOP_LEVEL_KEYS:
            errs.append(f"unknown extra field: {key}")

    for req in ALLOWED_TOP_LEVEL_KEYS:
        if req not in packet:
            errs.append(f"missing required field: {req}")

    def _get(path: str, default: Any = None) -> Any:
        cur: Any = packet
        for part in path.split("."):
            if not isinstance(cur, dict) or part not in cur:
                return default
            cur = cur[part]
        return cur

    if _get("status") != "CANDIDATE_PACKET_ONLY":
        errs.append("status must be CANDIDATE_PACKET_ONLY")
    if _get("observed_status") != "CANDIDATE":
        errs.append("observed_status must be CANDIDATE")
    if _get("target_status") != "RATIFIED":
        errs.append("target_status must be RATIFIED")
    if _get("is_canonical") is not False:
        errs.append("is_canonical must be false")
    if _get("is_v1_done") is not False:
        errs.append("is_v1_done must be false")
    if _get("requires_operator_ceremony") is not True:
        errs.append("requires_operator_ceremony must be true")
    if _get("schema_version") != "c6_active_authority_ratification_packet_v1":
        errs.append("schema_version mismatch")
    if _get("packet_id") != "V1.ratification.v1":
        errs.append("packet_id must be V1.ratification.v1")
    if _get("package_id") != "V1":
        errs.append("package_id must be V1")

    if "authority_binding" not in packet:
        errs.append("missing authority_binding")
        return errs

    ab = packet.get("authority_binding")
    if not isinstance(ab, dict):
        errs.append("authority_binding must be object")
        return errs
    for k in ab:
        if k not in (
            "authority_id",
            "authority_version",
            "path",
            "schema_version",
            "subject_schema_id",
            "digest_sha256",
        ):
            errs.append(f"authority_binding unknown extra field: {k}")
    if ab.get("authority_id") != "c6_active_authority_v1":
        errs.append("authority_binding.authority_id must be c6_active_authority_v1")
    if ab.get("authority_version") != 1:
        errs.append("authority_binding.authority_version must be 1")
    if ab.get("path") != "contracts/c6-active-authority/authority.v1.candidate.json":
        errs.append("authority_binding.path mismatch")

    # Exact recompute authority digest from live tracked candidate.
    try:
        live_doc = _load_candidate()
        live_digest = auth_checker.compute_digest(live_doc)
        declared = ab.get("digest_sha256")
        if declared == ZERO_SHA:
            errs.append("authority_binding.digest_sha256 all-zero rejected")
        elif not isinstance(declared, str) or not SHA256_RE.match(declared):
            errs.append("authority_binding.digest_sha256 invalid shape")
        elif declared != live_digest:
            errs.append(
                f"authority digest recompute mismatch: declared={declared}, live={live_digest}"
            )
        # Live source status must still be CANDIDATE (packet observed_status binds it).
        if live_doc.get("status") != "CANDIDATE":
            errs.append(
                f"live source status must be CANDIDATE for observed_status bind, "
                f"got {live_doc.get('status')!r}"
            )
    except Exception as exc:  # noqa: BLE001
        errs.append(f"authority digest recompute failed: {exc}")

    th = packet.get("four_layer_thresholds")
    if not isinstance(th, dict):
        errs.append("four_layer_thresholds must be object")
    else:
        if th.get("golden") != 1.0 or th.get("unsupported") != 1.0 or th.get("safety") != 1.0:
            errs.append("four_layer_thresholds golden/unsupported/safety must all be 1.0")
        demo = th.get("demo_fuzz")
        if not isinstance(demo, dict) or demo.get("formula") != "5*pass >= 4*eligible":
            errs.append("demo_fuzz formula mismatch")
        for k in th:
            if k not in ("golden", "demo_fuzz", "unsupported", "safety"):
                errs.append(f"four_layer_thresholds unknown extra field: {k}")

    drefs = packet.get("decision_refs")
    if not isinstance(drefs, list) or not drefs:
        errs.append("decision_refs must be non-empty list")
    else:
        if not any(d.get("decision_id") == "D-147" for d in drefs if isinstance(d, dict)):
            errs.append("D-147 must be in decision_refs")
        for i, d in enumerate(drefs):
            if not isinstance(d, dict):
                errs.append(f"decision_refs[{i}] must be object")
                continue
            for k in d:
                if k not in ("decision_id", "required_state"):
                    errs.append(f"decision_refs[{i}] unknown extra field: {k}")
            if d.get("required_state") != "ratified":
                errs.append(f"decision_refs[{i}] required_state must be ratified")

    # Exact ordered recompute bind for receipt_refs (no missing/extra/reorder).
    rrefs = packet.get("receipt_refs")
    expected_refs, exp_errs = _expected_receipt_refs()
    errs.extend(exp_errs)
    errs.extend(_exact_ref_list_errors(rrefs, expected_refs, "receipt_refs"))

    # Packet-level source_members_binding: exact recompute against live candidate + files.
    # Independent of the legacy authority digest (which does not cover source_members).
    smb = packet.get("source_members_binding")
    if not isinstance(smb, dict):
        errs.append("source_members_binding must be object")
    else:
        for k in smb:
            if k not in ("digest_sha256", "member_count", "members"):
                errs.append(f"source_members_binding unknown extra field: {k}")
        for req in ("digest_sha256", "member_count", "members"):
            if req not in smb:
                errs.append(f"source_members_binding missing {req}")
        try:
            live_doc = _load_candidate()
            live_binding, live_sm_errs = _validate_and_bind_source_members(live_doc)
            if live_sm_errs:
                errs.extend(f"live source_members: {e}" for e in live_sm_errs)
            elif live_binding is None:
                errs.append("live source_members binding failed without errors")
            else:
                declared_digest = smb.get("digest_sha256")
                if declared_digest == ZERO_SHA:
                    errs.append("source_members_binding.digest_sha256 all-zero rejected")
                elif (
                    not isinstance(declared_digest, str)
                    or not SHA256_RE.match(declared_digest)
                ):
                    errs.append("source_members_binding.digest_sha256 invalid shape")
                elif declared_digest != live_binding["digest_sha256"]:
                    errs.append(
                        "source_members_binding.digest_sha256 recompute mismatch: "
                        f"declared={declared_digest}, live={live_binding['digest_sha256']}"
                    )
                if smb.get("member_count") != live_binding["member_count"]:
                    errs.append(
                        "source_members_binding.member_count mismatch: "
                        f"declared={smb.get('member_count')}, "
                        f"live={live_binding['member_count']}"
                    )
                declared_members = smb.get("members")
                if not isinstance(declared_members, list):
                    errs.append("source_members_binding.members must be list")
                else:
                    live_members = live_binding["members"]
                    if len(declared_members) != len(live_members):
                        errs.append(
                            "source_members_binding.members count mismatch: "
                            f"declared={len(declared_members)}, live={len(live_members)}"
                        )
                    for i, exp in enumerate(live_members):
                        if i >= len(declared_members):
                            errs.append(
                                f"source_members_binding.members[{i}]: missing "
                                f"expected {exp['member_id']!r}"
                            )
                            continue
                        d = declared_members[i]
                        if not isinstance(d, dict):
                            errs.append(
                                f"source_members_binding.members[{i}] must be object"
                            )
                            continue
                        for k in d:
                            if k not in (
                                "member_id",
                                "role",
                                "path",
                                "locator",
                                "sha256",
                            ):
                                errs.append(
                                    f"source_members_binding.members[{i}] "
                                    f"unknown extra field: {k}"
                                )
                        for k in ("member_id", "role", "path", "locator", "sha256"):
                            if d.get(k) != exp.get(k):
                                errs.append(
                                    f"source_members_binding.members[{i}].{k} mismatch: "
                                    f"declared={d.get(k)!r}, expected={exp.get(k)!r}"
                                )
                        if d.get("sha256") == ZERO_SHA:
                            errs.append(
                                f"source_members_binding.members[{i}] "
                                "all-zero sha rejected"
                            )
        except Exception as exc:  # noqa: BLE001
            errs.append(f"source_members_binding recompute failed: {exc}")

    return errs


def main() -> int:
    ap = argparse.ArgumentParser(
        description="V1 active-authority ratification-packet exporter"
    )
    ap.add_argument(
        "--check",
        action="store_true",
        help="rebuild live packet, strict-validate, require byte-equality with committed file",
    )
    ap.add_argument("--stdout", action="store_true", help="print packet, no write")
    ap.add_argument(
        "--out",
        type=str,
        default=str(DEFAULT_OUT),
        help="output path (default closure/candidates/V1/V1.v1.ratification-packet.candidate.json)",
    )
    args = ap.parse_args()

    packet, errors = build_packet()
    if errors:
        print("REFUSED TO EMIT (drift/invariant failure):", file=sys.stderr)
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        return 1

    check_errs = self_check(packet)
    if check_errs:
        print("SELF-CHECK FAILED:", file=sys.stderr)
        for e in check_errs:
            print(f"  - {e}", file=sys.stderr)
        return 1

    live_bytes = canonical_bytes(packet)

    if args.check:
        out = Path(args.out)
        if not out.exists():
            print(f"CHECK FAILED: committed packet missing: {out}", file=sys.stderr)
            return 1
        committed = out.read_bytes()
        try:
            committed_pkt = json.loads(committed.decode("utf-8"))
        except (UnicodeDecodeError, json.JSONDecodeError) as exc:
            print(f"CHECK FAILED: committed packet not valid JSON: {exc}", file=sys.stderr)
            return 1
        committed_errs = self_check(committed_pkt)
        if committed_errs:
            print("CHECK FAILED: committed packet self_check errors:", file=sys.stderr)
            for e in committed_errs:
                print(f"  - {e}", file=sys.stderr)
            return 1
        if live_bytes != committed:
            print(
                "CHECK FAILED: committed packet != live rebuild (byte drift)",
                file=sys.stderr,
            )
            print(f"  committed={out}", file=sys.stderr)
            print(f"  live_sha256={hashlib.sha256(live_bytes).hexdigest()}", file=sys.stderr)
            print(
                f"  committed_sha256={hashlib.sha256(committed).hexdigest()}",
                file=sys.stderr,
            )
            return 1
        print(
            "V1 ratification-packet --check OK (live rebuild == committed, candidate-only)"
        )
        print(f"  authority_digest={packet['authority_binding']['digest_sha256'][:16]}...")
        print(
            f"  observed_status={packet['observed_status']} "
            f"target_status={packet['target_status']} "
            f"requires_operator_ceremony={packet['requires_operator_ceremony']}"
        )
        return 0

    if args.stdout:
        sys.stdout.buffer.write(live_bytes)
        return 0

    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_bytes(live_bytes)
    print(f"wrote {out} ({len(live_bytes)} bytes)")
    print(
        f"  status={packet['status']} is_canonical={packet['is_canonical']} "
        f"is_v1_done={packet['is_v1_done']} requires_operator_ceremony="
        f"{packet['requires_operator_ceremony']}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
