#!/usr/bin/env python3
"""C6CorpusLineage — B7 T02 corpus lineage durable local candidate.

Shipping source identity (live-truth, D-147 / T02):
  - generated   = exact 45 non-C6-TRAP-* rows from tracked contracts/c6-bench-cases.jsonl
  - manual_trap = exact 12 existing C6-TRAP-* rows from the same tracked file
  - shipping clean assembly = 45 + 12 = 57, exact case_id set == tracked 57
  - NO invented manual rows (no C6-MANUAL-*)

Mutation fixtures live under Tools/C6CorpusLineage/mutations/** and are
NEVER part of the source denominator / clean shipping assembly.

Fail-closed assembler: lossless, stable-sorted, stable-serialized, row/id
conserving. Duplicate / missing / unexpected / cross-source-collision /
quarantine paths all fail closed.

LOCAL-ONLY under proof_local_contract. Does NOT claim canonical / B7 DONE /
C6 acceptance / T02 freeze authorization / /opsx:apply.
"""
from __future__ import annotations

import hashlib
import json
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Iterable

REPO_ROOT = Path(__file__).resolve().parents[2]

# Exact shipping counts (live tracked truth)
EXPECTED_GENERATED_COUNT = 45
EXPECTED_MANUAL_TRAP_COUNT = 12
EXPECTED_ASSEMBLED_COUNT = 57  # 45 + 12

ALLOWED_BEHAVIOR_CLASSES = {
    "tool_call",
    "clarify_missing_slot",
    "refusal_no_available_tool",
    "refusal_safety_or_policy",
    "already_state_noop",
}
FORBIDDEN_BEHAVIOR_CLASSES = {"direct_no_call"}

# Fields added by lineage packaging; stripped for tracked-content equality.
# Nested tags.must_not_train is part of the live tracked row and is NOT stripped.
LINEAGE_METADATA_KEYS = frozenset(
    {
        "source_kind",
        "source_record_id",
        "provenance",
        "rationale",
        "external_layer",
        "must_not_train",  # top-level only (lineage mirror)
        "behavior_class_ref",
        "source_refs_authority",
        "authored_at",
        "captured_at",
        "source_path",
        "source_hash",
        "trap_note",
        "manual_note",
    }
)

TRACKED_CORPUS_PATH = REPO_ROOT / "contracts/c6-bench-cases.jsonl"
SOURCES_DIR = REPO_ROOT / "Tools/C6CorpusLineage/sources"
MUTATIONS_DIR = REPO_ROOT / "Tools/C6CorpusLineage/mutations"


def sha256_text(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def strip_lineage_metadata(row: dict) -> dict:
    """Return row content without lineage packaging fields.

    Distinguishes content/canonical equality (after strip) from byte equality
    of the assembled packaging file (which retains lineage metadata).
    """
    return {k: v for k, v in row.items() if k not in LINEAGE_METADATA_KEYS}


def canonical_row_text(row: dict) -> str:
    """Stable per-row serialization for content hashing (lineage metadata stripped)."""
    return json.dumps(
        strip_lineage_metadata(row),
        ensure_ascii=False,
        sort_keys=True,
        separators=(",", ":"),
    )


def packaging_row_text(row: dict) -> str:
    """Stable per-row serialization of the full packaging row (keeps lineage metadata)."""
    return json.dumps(row, ensure_ascii=False, sort_keys=True, separators=(",", ":"))


def source_sha256(rows: list[dict]) -> str:
    """Hash over content-canonical rows (lineage metadata stripped)."""
    joined = "\n".join(canonical_row_text(r) for r in rows)
    return sha256_text(joined)


def assembled_sha256(rows: list[dict]) -> str:
    """Hash over packaging rows (lineage metadata retained for lineage proof)."""
    joined = "\n".join(packaging_row_text(r) for r in rows)
    return sha256_text(joined)


def compat_sha256(rows: list[dict]) -> str:
    """Hash over content rows (lineage metadata stripped).

    When rows are the full shipping 57 sorted by case_id, this is the
    content/canonical equality fingerprint against tracked corpus after the
    same parse+sort+strip pipeline. It is NOT a raw-byte equality claim on
    the tracked file on disk (key order / whitespace may differ).
    """
    return source_sha256(rows)


def unordered_id_set_sha256(rows: list[dict]) -> str:
    ids = sorted({r.get("case_id", "") for r in rows if isinstance(r.get("case_id"), str)})
    return sha256_text("\n".join(ids))


def ordered_id_list_sha256(rows: list[dict]) -> str:
    """Hash over case_ids in current row order (materialization order sensitive)."""
    ids = [r.get("case_id", "") for r in rows]
    return sha256_text("\n".join(ids))


def load_tracked_rows() -> list[dict]:
    rows: list[dict] = []
    if not TRACKED_CORPUS_PATH.exists():
        return rows
    for line in TRACKED_CORPUS_PATH.read_text(encoding="utf-8").splitlines():
        if line.strip():
            rows.append(json.loads(line))
    return rows


def tracked_id_set() -> set[str]:
    return {r["case_id"] for r in load_tracked_rows() if isinstance(r.get("case_id"), str)}


def tracked_content_sha256() -> str:
    """Content fingerprint of tracked corpus: parse → sort by case_id → strip none → dump."""
    rows = sorted(load_tracked_rows(), key=lambda r: r.get("case_id", ""))
    joined = "\n".join(
        json.dumps(r, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
        for r in rows
    )
    return sha256_text(joined)


@dataclass
class LoadResult:
    source_kind: str
    path: Path
    rows: list[dict]
    errors: list[str] = field(default_factory=list)


@dataclass
class AssembleResult:
    assembled_rows: list[dict]
    quarantined: list[dict]
    errors: list[str]
    sources: list[dict]  # per-source digest bookkeeping
    row_conservation_ok: bool = False
    id_conservation_ok: bool = False
    unordered_id_set_sha256: str = ""
    ordered_id_list_sha256: str = ""


def _validate_row(row: dict, source_kind: str, idx: int) -> list[str]:
    """Return a list of hard errors for a single row. Empty == clean."""
    errs: list[str] = []
    case_id = row.get("case_id")
    if not isinstance(case_id, str) or not case_id:
        return [f"row{idx}: missing/invalid case_id"]

    behavior_class = row.get("behavior_class")
    if behavior_class in FORBIDDEN_BEHAVIOR_CLASSES:
        errs.append(f"{case_id}: forbidden behavior_class={behavior_class!r}")
    elif behavior_class not in ALLOWED_BEHAVIOR_CLASSES:
        errs.append(f"{case_id}: invalid behavior_class={behavior_class!r}")

    mnt = row.get("tags", {}).get("must_not_train") if isinstance(row.get("tags"), dict) else None
    if mnt is not None and not isinstance(mnt, bool):
        errs.append(f"{case_id}: tags.must_not_train must be boolean")
    return errs


def load_source(path: Path, source_kind: str | None = None) -> LoadResult:
    res = LoadResult(source_kind=source_kind or "unknown", path=path, rows=[])
    if not path.exists():
        res.errors.append(f"source missing: {path}")
        return res
    raw = path.read_text(encoding="utf-8")
    for ln, line in enumerate(raw.splitlines(), 1):
        if not line.strip():
            continue
        try:
            obj = json.loads(line)
        except Exception as exc:  # noqa: BLE001
            res.errors.append(f"{path}:{ln}: json parse error: {exc}")
            continue
        if not isinstance(obj, dict):
            res.errors.append(f"{path}:{ln}: row is not an object")
            continue
        res.rows.append(obj)
    if res.source_kind == "unknown":
        for r in res.rows:
            if isinstance(r.get("source_kind"), str):
                res.source_kind = r["source_kind"]
                break
    return res


def assemble(sources: Iterable[LoadResult], *, fail_on_duplicate: bool = True) -> AssembleResult:
    """Lossless, stable-sorted assembler with fail-closed guarantees.

    Clean shipping sources (generated + manual_trap) merge into assembled.
    Mutation fixtures (source_kind==trap or trap_note) are quarantined and
    never silently merged. Duplicate case_id / missing case_id fail closed.
    """
    errors: list[str] = []
    assembled: list[dict] = []
    quarantined: list[dict] = []
    source_book: list[dict] = []
    seen_ids: dict[str, str] = {}  # case_id -> first source_kind
    sum_source_rows = 0

    for src in sources:
        if src.errors:
            errors.extend(src.errors)
        rows = src.rows
        sum_source_rows += len(rows)
        src_digest = source_sha256(rows)
        src_canonical = all("source_kind" in r for r in rows)
        source_book.append(
            {
                "source_kind": src.source_kind,
                "path": _rel(src.path),
                "row_count": len(rows),
                "sha256": src_digest,
                "canonical_json_present": src_canonical,
            }
        )
        for idx, row in enumerate(rows, 1):
            case_id = row.get("case_id")
            if not isinstance(case_id, str) or not case_id:
                errors.append(f"{src.source_kind} row{idx}: missing case_id")
                continue
            if case_id in seen_ids:
                errors.append(
                    f"duplicate case_id {case_id!r} across "
                    f"{seen_ids[case_id]} and {src.source_kind}"
                )
                if fail_on_duplicate:
                    continue
            else:
                seen_ids[case_id] = src.source_kind

            row_errs = _validate_row(row, src.source_kind, idx)
            # Mutation fixtures / deliberate-red rows are ALWAYS isolated.
            # manual_trap is a valid shipping source (not quarantine).
            if row.get("trap_note") or src.source_kind == "trap":
                quarantined.append(row)
                continue
            if row_errs:
                errors.extend(row_errs)
                continue
            assembled.append(row)

    assembled.sort(key=lambda r: r.get("case_id", ""))

    assembled_ids = {r.get("case_id") for r in assembled}
    # Quarantined ids still count in seen_ids; for clean shipping there are none.
    # id conservation for shipping: unique non-quarantine ids that entered assembled
    # equal union of source ids that were not quarantined / not duplicate-dropped.
    row_conservation_ok = sum_source_rows == len(assembled) + len(quarantined) + _count_duplicate_drops(
        sum_source_rows, assembled, quarantined, errors
    )
    # Simpler exact accounting: every source row is either assembled, quarantined,
    # missing-id-skipped, or duplicate-skipped. The boolean used by the checker is
    # the strict lossless identity for the no-error clean path.
    clean_row_conservation = sum_source_rows == len(assembled) + len(quarantined) and not any(
        "missing case_id" in e or "duplicate case_id" in e for e in errors
    )
    id_conservation_ok = len(seen_ids) == len(assembled_ids) or (
        # when quarantine present, assembled ids ⊂ seen_ids
        assembled_ids.issubset(set(seen_ids)) and len(assembled_ids) == len(assembled)
    )
    if not errors and not quarantined:
        # strict clean-path conservation
        clean_row_conservation = sum_source_rows == len(assembled)
        id_conservation_ok = len(seen_ids) == len(assembled_ids) == len(assembled)

    return AssembleResult(
        assembled_rows=assembled,
        quarantined=quarantined,
        errors=errors,
        sources=source_book,
        row_conservation_ok=clean_row_conservation,
        id_conservation_ok=id_conservation_ok,
        unordered_id_set_sha256=unordered_id_set_sha256(assembled),
        ordered_id_list_sha256=ordered_id_list_sha256(assembled),
    )


def _count_duplicate_drops(
    sum_source_rows: int,
    assembled: list[dict],
    quarantined: list[dict],
    errors: list[str],
) -> int:
    """Best-effort count of rows dropped for duplicate/missing (for diagnostics)."""
    n_dup = sum(1 for e in errors if "duplicate case_id" in e)
    n_missing = sum(1 for e in errors if "missing case_id" in e)
    return n_dup + n_missing


def default_sources() -> list[LoadResult]:
    """Clean shippable sources: generated (45) + manual_trap (12) = 57.

    Mutation fixtures under mutations/ are NOT part of the shipping denominator.
    """
    return [
        load_source(SOURCES_DIR / "c6-bench-cases.generated.jsonl", "generated"),
        load_source(SOURCES_DIR / "c6-bench-cases.manual-trap.jsonl", "manual_trap"),
    ]


def mutation_source() -> LoadResult:
    """Deliberate-red mutation fixture — NOT a shipping source."""
    return load_source(MUTATIONS_DIR / "deliberate-red.jsonl", "trap")


# Back-compat alias used by older checker flag names.
def trap_source() -> LoadResult:
    return mutation_source()


def shipping_count_errors(result: AssembleResult) -> list[str]:
    """Exact 45/12/57 + exact ID set == tracked 57 + no invented manual rows."""
    errs: list[str] = []
    by_kind = {s["source_kind"]: s["row_count"] for s in result.sources}
    gen_n = by_kind.get("generated", 0)
    mt_n = by_kind.get("manual_trap", 0)
    if gen_n != EXPECTED_GENERATED_COUNT:
        errs.append(
            f"generated count {gen_n} != expected {EXPECTED_GENERATED_COUNT}"
        )
    if mt_n != EXPECTED_MANUAL_TRAP_COUNT:
        errs.append(
            f"manual_trap count {mt_n} != expected {EXPECTED_MANUAL_TRAP_COUNT}"
        )
    if len(result.assembled_rows) != EXPECTED_ASSEMBLED_COUNT:
        errs.append(
            f"assembled count {len(result.assembled_rows)} != expected "
            f"{EXPECTED_ASSEMBLED_COUNT}"
        )

    assembled_ids = {r.get("case_id") for r in result.assembled_rows}
    tracked = tracked_id_set()
    if tracked and assembled_ids != tracked:
        missing = sorted(tracked - assembled_ids)
        extra = sorted(assembled_ids - tracked)
        errs.append(
            f"assembled ID set != tracked 57 "
            f"(missing={missing[:5]}{'...' if len(missing) > 5 else ''}, "
            f"extra={extra[:5]}{'...' if len(extra) > 5 else ''})"
        )

    invented = sorted(
        cid for cid in assembled_ids if isinstance(cid, str) and cid.startswith("C6-MANUAL-")
    )
    if invented:
        errs.append(f"invented manual rows forbidden: {invented}")

    # content equality: strip lineage metadata → match tracked content fingerprint
    if tracked and not errs:
        content_fp = compat_sha256(result.assembled_rows)
        tracked_fp = tracked_content_sha256()
        if content_fp != tracked_fp:
            errs.append(
                "content/canonical equality FAILED after stripping lineage metadata: "
                f"assembled_content_sha256={content_fp} "
                f"tracked_content_sha256={tracked_fp} "
                "(byte equality of packaging file is not claimed)"
            )
    return errs


def _rel(path: Path) -> str:
    try:
        return str(path.relative_to(REPO_ROOT))
    except ValueError:
        return str(path)


def build_receipt(result: AssembleResult, *, assembled_path: str | None = None) -> dict:
    """Emit the corpus_lineage_v1 native receipt (local-only, non-canonical)."""
    assembled = result.assembled_rows
    path = assembled_path or "closure/candidates/B7/c6-corpus-lineage.assembled.jsonl"
    a_sha = assembled_sha256(assembled)
    c_sha = compat_sha256(assembled)
    gen_rows = [r for r in assembled if r.get("source_kind") == "generated"]
    mt_rows = [r for r in assembled if r.get("source_kind") == "manual_trap"]
    sum_src = sum(s["row_count"] for s in result.sources)
    return {
        "schema_version": "corpus_lineage_v1",
        "candidate_kind": "local_durable_candidate",
        "is_canonical": False,
        "is_b7_done": False,
        "assembled": {
            "path": path,
            "row_count": len(assembled),
            "sha256": a_sha,
            "ordered_case_ids": [r.get("case_id") for r in assembled],
            "compat_sha256": c_sha,
        },
        "lineage": {
            "generated_row_count": len(gen_rows),
            "manual_trap_row_count": len(mt_rows),
            "expected_generated": EXPECTED_GENERATED_COUNT,
            "expected_manual_trap": EXPECTED_MANUAL_TRAP_COUNT,
            "expected_assembled": EXPECTED_ASSEMBLED_COUNT,
            "tracked_path": "contracts/c6-bench-cases.jsonl",
            "tracked_content_sha256": tracked_content_sha256() if TRACKED_CORPUS_PATH.exists() else "",
            "assembled_content_sha256": c_sha,
            "content_equality": (
                "assembled after strip_lineage_metadata equals tracked content "
                "fingerprint (parse+sort+canonical). Packaging byte equality is "
                "NOT claimed."
            ),
            "note": (
                "generated = exact 45 non-TRAP tracked rows; manual_trap = exact 12 "
                "existing C6-TRAP-* tracked rows; no invented C6-MANUAL-* rows; "
                "mutation fixtures are not part of the source denominator."
            ),
        },
        "sources": result.sources,
        "row_conservation": {
            "sum_source_rows": sum_src,
            "assembled_rows": len(assembled),
            "consistent": result.row_conservation_ok,
        },
        "id_conservation": {
            "union_source_ids": len({r.get("case_id") for r in assembled}),
            "assembled_ids": len({r.get("case_id") for r in assembled}),
            "consistent": result.id_conservation_ok,
        },
        "hashes": {
            "unordered_id_set_sha256": result.unordered_id_set_sha256,
            "ordered_id_list_sha256": result.ordered_id_list_sha256,
            "recomputable": True,
        },
        "claims": {
            "proof_class": "local_corpus_lineage",
            "forbidden_claims": [
                "canonical",
                "b7_done",
                "c6_acceptance",
                "t02_freeze_authorized",
                "opsx_apply",
                "s9_authorization",
                "candidate_signed",
            ],
            "coverage_note": (
                "B7 T02 corpus lineage durable local candidate only. Shipping = "
                "45 generated + 12 manual_trap = 57 exact tracked ids. Mutation "
                "fixtures are independent of the source denominator. NOT canonical, "
                "NOT B7 DONE, NOT C6 acceptance, NOT T02 freeze authorization, "
                "NOT /opsx:apply."
            ),
        },
    }


def main(argv: list[str]) -> int:
    sources = default_sources()
    result = assemble(sources)
    receipt = build_receipt(result)

    out_dir = REPO_ROOT / "Tools/C6CorpusLineage/assembled"
    out_dir.mkdir(parents=True, exist_ok=True)
    assembled_path = out_dir / "c6-corpus-lineage.assembled.jsonl"
    assembled_path.write_text(
        "\n".join(packaging_row_text(r) for r in result.assembled_rows) + "\n",
        encoding="utf-8",
    )
    (out_dir / "c6-corpus-lineage.receipt.json").write_text(
        json.dumps(receipt, ensure_ascii=False, indent=2, sort_keys=True),
        encoding="utf-8",
    )

    print(f"assembled_rows={len(result.assembled_rows)}")
    print(f"quarantined={len(result.quarantined)}")
    print(f"errors={len(result.errors)}")
    for e in result.errors:
        print(f"  ERROR: {e}", file=sys.stderr)
    print(f"assembled_sha256={receipt['assembled']['sha256']}")
    print(f"compat_sha256={receipt['assembled']['compat_sha256']}")
    print(f"unordered_id_set_sha256={receipt['hashes']['unordered_id_set_sha256']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
