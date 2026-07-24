#!/usr/bin/env python3
"""B7 T02 corpus-lineage freeze-packet exporter (candidate-only mechanical envelope).

Mechanical consumption packet for the downstream operator ceremony that turns the
B7 corpus-lineage *candidate* into a canonical freeze receipt. This exporter only
DERIVES data from the live repo; it never elevates B7 to DONE/canonical, never
forges T01/T02 ratification, and never produces the canonical execution receipt.

Sources (live, recomputed every run):
  - Tools/C6CorpusLineage.__init__ (assemble / build_receipt / digests)
  - contracts/c6-bench-cases.jsonl (tracked 57, content fingerprint)
  - D-127 frozen holdout pin sha (hard-coded authoritative constant, never recomputed)
  - D-147 ratification refs (docs/commander-log/decisions.md + pool32 receipt)

Determinism: canonical JSON (sort_keys, separators, ensure_ascii). The packet is
byte-stable and regenerable. The exporter REFUSES to emit if any bound source
digest has drifted from live truth (drift guard).

CLI:
  python3 Tools/C6CorpusLineage/export_freeze_packet.py            # write packet to closure/candidates/B7
  python3 Tools/C6CorpusLineage/export_freeze_packet.py --check    # rebuild + strict self-check + byte-equal committed
  python3 Tools/C6CorpusLineage/export_freeze_packet.py --stdout   # print packet, no write

Status contract (hard):
  status=CANDIDATE_PACKET_ONLY, is_canonical=false, is_b7_done=false,
  requires_operator_ceremony=true.
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
sys.path.insert(0, str(REPO_ROOT / "Tools"))
from C6CorpusLineage import (  # noqa: E402
    EXPECTED_ASSEMBLED_COUNT,
    EXPECTED_GENERATED_COUNT,
    EXPECTED_MANUAL_TRAP_COUNT,
    assemble,
    build_receipt,
    default_sources,
    shipping_count_errors,
    tracked_content_sha256,
    tracked_id_set,
)

# Authoritative D-127 FROZEN holdout pin (never recomputed/forged).
HOLDOUT_D127_SHA256 = "77853caea4598f334fb4a7ed89eafc348746adf333d647306aa94f0b68da2f64"

# Pool32 ratification receipt is vendored in-repo so CI/reanchor can resolve it
# without a machine-local absolute path. Absolute refs remain forbidden.
POOL32_RECEIPT_RELATIVE = (
    "docs/closure-evidence/2026-07-11-ma14-RATIFICATION-RECEIPT-pool32.md"
)
# Legacy name kept for negative-path tests that assert absolute refs are rejected.
EXTERNAL_REF_ALLOWLIST_DECLARED = POOL32_RECEIPT_RELATIVE

# D-147 ratification refs bound mechanically (cannot forge T01/T02 ratification string).
# Order is contractual: self_check requires exact ordered match.
RATIFICATION_REFS = [
    {
        "path": "docs/commander-log/decisions.md",
        "locator": "D-147",
    },
    {
        "path": POOL32_RECEIPT_RELATIVE,
        "locator": "pool32",
    },
]

ALLOWED_TOP_LEVEL_KEYS = frozenset(
    {
        "schema_version",
        "packet_id",
        "package_id",
        "status",
        "is_canonical",
        "is_b7_done",
        "requires_operator_ceremony",
        "source_candidate",
        "corpus_binding",
        "holdout_pin",
        "acl",
        "ratification_refs",
        "consistency",
        "non_claims",
    }
)

# Ceremony / identity / completion claims must never appear on a candidate packet.
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
    REPO_ROOT / "closure" / "candidates" / "B7" / "B7.v1.freeze-packet.candidate.json"
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


def _resolve_ref_strict(ref: dict) -> tuple[dict | None, str | None]:
    """Fail-closed ref resolver. Never emits all-zero sha as valid evidence.

    Repo-relative refs must remain inside REPO_ROOT after symlink resolution.
    Absolute refs are forbidden (pool32 receipt is vendored in-repo).

    Returns (resolved_ref, error). On any missing/unreadable/out-of-scope failure,
    resolved_ref is None and error is a non-empty reason.
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
        sha = _sha256(resolved)
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


def _expected_ratification_refs() -> tuple[list[dict], list[str]]:
    """Resolve the contractual RATIFICATION_REFS set in declared order."""
    out: list[dict] = []
    errs: list[str] = []
    for base in RATIFICATION_REFS:
        resolved, err = _resolve_ref_strict(base)
        if err or resolved is None:
            errs.append(f"expected ratification_ref fail-closed: {err}")
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


def build_packet() -> tuple[dict, list[str]]:
    """Return (packet, drift_errors). Drift_errors non-empty => refuse to write."""
    errors: list[str] = []

    sources = default_sources()
    result = assemble(sources)
    receipt = build_receipt(result)

    # Fail-closed shipping invariants must hold on the live candidate.
    ship_errs = shipping_count_errors(result)
    if ship_errs:
        errors.extend(f"shipping_count_errors: {e}" for e in ship_errs)
    if result.errors:
        errors.extend(f"assemble_error: {e}" for e in result.errors)
    if len(result.assembled_rows) != EXPECTED_ASSEMBLED_COUNT:
        errors.append(
            f"assembled_rows {len(result.assembled_rows)} != {EXPECTED_ASSEMBLED_COUNT}"
        )

    assembled = result.assembled_rows
    generated_n = sum(1 for r in assembled if r.get("source_kind") == "generated")
    manual_trap_n = sum(1 for r in assembled if r.get("source_kind") == "manual_trap")

    a_sha = receipt["assembled"]["sha256"]
    c_sha = receipt["assembled"]["compat_sha256"]
    u_sha = receipt["hashes"]["unordered_id_set_sha256"]
    tracked_fp = tracked_content_sha256()

    for label, sha in (
        ("assembled_sha256", a_sha),
        ("compat_sha256", c_sha),
        ("unordered_id_set_sha256", u_sha),
        ("tracked_content_sha256", tracked_fp),
    ):
        if not sha or sha == ZERO_SHA or not SHA256_RE.match(sha):
            errors.append(f"live {label} invalid/zero: {sha!r}")

    # id-set equality vs tracked 57
    assembled_ids = {r.get("case_id") for r in assembled}
    tracked_ids = tracked_id_set()
    id_set_equal = assembled_ids == tracked_ids
    if not id_set_equal:
        errors.append("assembled id set != tracked 57")

    rat_refs, rat_errs = _expected_ratification_refs()
    errors.extend(rat_errs)
    if len(rat_refs) != len(RATIFICATION_REFS):
        errors.append(
            f"ratification_refs exact set incomplete: got {len(rat_refs)} "
            f"expected {len(RATIFICATION_REFS)}"
        )

    packet = {
        "schema_version": "c6_corpus_lineage_freeze_packet_v1",
        "packet_id": "B7.freeze.v1",
        "package_id": "B7",
        "status": "CANDIDATE_PACKET_ONLY",
        "is_canonical": False,
        "is_b7_done": False,
        "requires_operator_ceremony": True,
        "source_candidate": {
            "path": "Tools/C6CorpusLineage/__init__.py",
            "schema_version": "corpus_lineage_v1",
            "candidate_kind": "local_durable_candidate",
            "is_canonical": False,
        },
        "corpus_binding": {
            "row_count": len(assembled),
            "generated_row_count": generated_n,
            "manual_trap_row_count": manual_trap_n,
            "assembled_sha256": a_sha,
            "compat_sha256": c_sha,
            "unordered_id_set_sha256": u_sha,
            "tracked_content_sha256": tracked_fp,
            "id_set_equals_tracked": id_set_equal,
        },
        "holdout_pin": {
            "decision_ref": "D-127",
            "sha256": HOLDOUT_D127_SHA256,
        },
        "acl": {
            "must_not_train": {
                "policy": "shipping_corpus_tags_must_not_train_binding",
                "rows_count": len(assembled),
                "must_not_train_true": sum(
                    1
                    for r in assembled
                    if isinstance(r.get("tags"), dict)
                    and r["tags"].get("must_not_train") is True
                ),
                "must_not_train_false_or_absent": sum(
                    1
                    for r in assembled
                    if not (
                        isinstance(r.get("tags"), dict)
                        and r["tags"].get("must_not_train") is True
                    )
                ),
                "source_field": "tags.must_not_train",
                "note": (
                    "ACL binds the live shipping-corpus must_not_train distribution. "
                    "The exposure checker forbids training/eval reuse of this corpus; "
                    "holdout D-127 is the S9 pin. The frozen FROZEN holdout is separate "
                    "from the shipping corpus and is never part of training exposure."
                ),
            },
            "exposure": {
                "policy": "training_eval_exposure_forbidden_on_shipping_corpus",
                "state": "OPEN_STILL",
            },
        },
        "ratification_refs": rat_refs,
        "consistency": {
            "live_recompute": True,
            "byte_stable": True,
            "reject_hash_drift": True,
        },
        "non_claims": [
            "not canonical",
            "not B7 DONE",
            "not C6 acceptance",
            "not T02 freeze authorization",
            "not operator ceremony (see requires_operator_ceremony)",
            "not S9/S10 authorization",
            "not candidate signed",
        ],
    }
    return packet, errors


def canonical_bytes(packet: dict) -> bytes:
    text = json.dumps(packet, sort_keys=True, ensure_ascii=False, separators=(",", ":"))
    return text.encode("utf-8")


def _live_digests() -> tuple[dict[str, str], list[str]]:
    """Recompute critical digests from live sources for exact-bind self_check."""
    errors: list[str] = []
    try:
        sources = default_sources()
        result = assemble(sources)
        receipt = build_receipt(result)
        live = {
            "assembled_sha256": receipt["assembled"]["sha256"],
            "compat_sha256": receipt["assembled"]["compat_sha256"],
            "unordered_id_set_sha256": receipt["hashes"]["unordered_id_set_sha256"],
            "tracked_content_sha256": tracked_content_sha256(),
            "row_count": str(len(result.assembled_rows)),
            "generated_row_count": str(
                sum(1 for r in result.assembled_rows if r.get("source_kind") == "generated")
            ),
            "manual_trap_row_count": str(
                sum(
                    1
                    for r in result.assembled_rows
                    if r.get("source_kind") == "manual_trap"
                )
            ),
        }
        return live, errors
    except Exception as exc:  # noqa: BLE001
        return {}, [f"live recompute failed: {exc}"]


def self_check(packet: dict) -> list[str]:
    """Strict candidate-packet self-check: structure + exact recompute binds."""
    errs: list[str] = []

    if not isinstance(packet, dict):
        return ["packet must be an object"]

    # Unknown extra fields / forbidden ceremony prefill.
    for key in packet:
        if key in FORBIDDEN_TOP_LEVEL_FIELDS:
            errs.append(f"forbidden prefill field present: {key}")
        elif key not in ALLOWED_TOP_LEVEL_KEYS:
            errs.append(f"unknown extra field: {key}")

    # Required structural fields.
    for req in ALLOWED_TOP_LEVEL_KEYS:
        if req not in packet:
            errs.append(f"missing required field: {req}")
    if errs and any(e.startswith("missing required") for e in errs):
        # Still continue where possible, but avoid KeyError noise on missing cores.
        pass

    def _get(path: str, default: Any = None) -> Any:
        cur: Any = packet
        for part in path.split("."):
            if not isinstance(cur, dict) or part not in cur:
                return default
            cur = cur[part]
        return cur

    if _get("status") != "CANDIDATE_PACKET_ONLY":
        errs.append("status must be CANDIDATE_PACKET_ONLY")
    if _get("is_canonical") is not False:
        errs.append("is_canonical must be false")
    if _get("is_b7_done") is not False:
        errs.append("is_b7_done must be false")
    if _get("requires_operator_ceremony") is not True:
        errs.append("requires_operator_ceremony must be true")
    if _get("schema_version") != "c6_corpus_lineage_freeze_packet_v1":
        errs.append("schema_version must be c6_corpus_lineage_freeze_packet_v1")
    if _get("packet_id") != "B7.freeze.v1":
        errs.append("packet_id must be B7.freeze.v1")
    if _get("package_id") != "B7":
        errs.append("package_id must be B7")

    if "corpus_binding" not in packet:
        errs.append("missing corpus_binding")
        return errs
    if "holdout_pin" not in packet:
        errs.append("missing holdout_pin")
        return errs

    if _get("holdout_pin.sha256") != HOLDOUT_D127_SHA256:
        errs.append("holdout_pin sha256 must equal D-127 frozen pin")
    if _get("holdout_pin.decision_ref") != "D-127":
        errs.append("holdout_pin decision_ref must be D-127")

    cb = packet.get("corpus_binding")
    if not isinstance(cb, dict):
        errs.append("corpus_binding must be object")
        return errs

    if cb.get("row_count") != EXPECTED_ASSEMBLED_COUNT:
        errs.append(f"row_count {cb.get('row_count')} != {EXPECTED_ASSEMBLED_COUNT}")
    if cb.get("generated_row_count") != EXPECTED_GENERATED_COUNT:
        errs.append("generated_row_count != 45")
    if cb.get("manual_trap_row_count") != EXPECTED_MANUAL_TRAP_COUNT:
        errs.append("manual_trap_row_count != 12")
    if cb.get("id_set_equals_tracked") is not True:
        errs.append("id_set_equals_tracked must be true")

    # Exact recompute bind for critical digests (not regex shape only).
    live, live_errs = _live_digests()
    errs.extend(live_errs)
    for key in (
        "assembled_sha256",
        "compat_sha256",
        "unordered_id_set_sha256",
        "tracked_content_sha256",
    ):
        declared = cb.get(key)
        if not isinstance(declared, str) or not SHA256_RE.match(declared):
            errs.append(f"corpus_binding.{key} invalid sha shape")
            continue
        if declared == ZERO_SHA:
            errs.append(f"corpus_binding.{key} all-zero digest rejected")
            continue
        expected = live.get(key)
        if expected is not None and declared != expected:
            errs.append(
                f"digest recompute mismatch {key}: declared={declared}, live={expected}"
            )

    # Exact ordered recompute bind for ratification_refs (no missing/extra/reorder).
    refs = packet.get("ratification_refs")
    expected_refs, exp_errs = _expected_ratification_refs()
    errs.extend(exp_errs)
    errs.extend(_exact_ref_list_errors(refs, expected_refs, "ratification_refs"))

    # source_candidate non-claims.
    sc = packet.get("source_candidate")
    if isinstance(sc, dict):
        if sc.get("is_canonical") is not False:
            errs.append("source_candidate.is_canonical must be false")
        for k in sc:
            if k not in ("path", "schema_version", "candidate_kind", "is_canonical"):
                errs.append(f"source_candidate unknown extra field: {k}")

    return errs


def main() -> int:
    ap = argparse.ArgumentParser(description="B7 T02 corpus-lineage freeze-packet exporter")
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
        help="output path (default closure/candidates/B7/B7.v1.freeze-packet.candidate.json)",
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
        # Validate the committed file itself (not only the rebuild).
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
        print("B7 freeze-packet --check OK (live rebuild == committed, candidate-only)")
        print(
            f"  row_count={packet['corpus_binding']['row_count']} "
            f"(45+12), holdout=D-127 {packet['holdout_pin']['sha256'][:16]}..."
        )
        print(
            f"  assembled_sha256={packet['corpus_binding']['assembled_sha256'][:16]}..."
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
        f"is_b7_done={packet['is_b7_done']} requires_operator_ceremony="
        f"{packet['requires_operator_ceremony']}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
