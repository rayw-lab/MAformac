#!/usr/bin/env python3
"""Fail-closed checker for the B7 T02 corpus-lineage durable local candidate.

Clean shipping mode (default):
  - sources = generated (45) + manual_trap (12) = 57
  - exact ID set == tracked contracts/c6-bench-cases.jsonl 57
  - no invented C6-MANUAL-* rows
  - content equality after stripping lineage metadata
  - row/id conservation, recomputable hashes, stable across two runs
  - exits 0 (GREEN)

Mutation mode (--with-mutations / --with-trap):
  - includes mutations/deliberate-red.jsonl (NOT a source denominator member)
  - MUST exit nonzero and list violations

Local-only (proof_local_contract); does NOT claim canonical/B7 DONE/C6.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT / "Tools"))
from C6CorpusLineage import (  # noqa: E402
    EXPECTED_ASSEMBLED_COUNT,
    EXPECTED_GENERATED_COUNT,
    EXPECTED_MANUAL_TRAP_COUNT,
    assemble,
    build_receipt,
    default_sources,
    load_source,
    mutation_source,
    shipping_count_errors,
    source_sha256,
)


def main() -> int:
    import argparse

    ap = argparse.ArgumentParser(
        description="B7 T02 corpus-lineage fail-closed checker"
    )
    ap.add_argument(
        "--with-mutations",
        action="store_true",
        help="include mutations/deliberate-red.jsonl; the gate MUST turn RED",
    )
    ap.add_argument(
        "--with-trap",
        action="store_true",
        help="alias of --with-mutations (historical name)",
    )
    ap.add_argument(
        "--source",
        type=str,
        action="append",
        default=[],
        help="extra source path (kind from source_kind field); repeatable",
    )
    args = ap.parse_args()
    mutation_mode = bool(args.with_mutations or args.with_trap)

    sources = default_sources()
    if mutation_mode:
        sources = sources + [mutation_source()]
    for extra in args.source:
        p = Path(extra)
        kind = None
        for line in p.read_text(encoding="utf-8").splitlines():
            if line.strip():
                kind = json.loads(line).get("source_kind")
                break
        sources.append(load_source(p, kind or "manual_trap"))

    result = assemble(sources)
    receipt = build_receipt(result)

    errors = list(result.errors)
    if result.row_conservation_ok is False and not mutation_mode:
        errors.append(
            f"row conservation FAILED: "
            f"sum_source={sum(s['row_count'] for s in result.sources)} "
            f"assembled={len(result.assembled_rows)} "
            f"quarantined={len(result.quarantined)}"
        )
    if result.id_conservation_ok is False and not mutation_mode:
        errors.append("id conservation FAILED: union(source ids) != assembled ids")

    if mutation_mode:
        # Mutation mode must turn RED: either assembly errors or quarantine non-empty.
        if not result.errors and not result.quarantined:
            errors.append(
                "mutation mode produced no errors and empty quarantine — "
                "deliberate-red fixture must trip fail-closed"
            )
        if not result.quarantined and any(
            "trap" in (s.get("source_kind") or "") for s in result.sources
        ):
            # trap rows without trap_note still should quarantine via source_kind==trap
            pass
    else:
        # Clean shipping invariants: exact 45/12/57 + exact ID set + no invented rows
        errors.extend(shipping_count_errors(result))
        if result.quarantined:
            errors.append(
                f"clean shipping must have empty quarantine, got {len(result.quarantined)}"
            )

    # stability / recomputability: second independent assembly
    result2 = assemble(sources)
    if result2.unordered_id_set_sha256 != result.unordered_id_set_sha256:
        errors.append("unordered id-set hash NOT stable across independent runs")
    if build_receipt(result2)["assembled"]["sha256"] != receipt["assembled"]["sha256"]:
        errors.append("assembled hash NOT stable across independent runs")

    # recomputable: recompute each source hash from disk
    for s in receipt["sources"]:
        # skip mutation fixture path when listed
        path = REPO_ROOT / s["path"]
        if not path.exists():
            errors.append(f"source path missing: {s['path']}")
            continue
        on_disk = load_source(path, s["source_kind"])
        re_digest = source_sha256(on_disk.rows)
        if re_digest != s["sha256"]:
            errors.append(f"source hash NOT recomputable for {s['path']}")

    print(f"mode={'mutations' if mutation_mode else 'clean'}")
    print(f"assembled_rows={len(result.assembled_rows)}")
    print(f"quarantined={len(result.quarantined)}")
    print(f"source_files={len(receipt['sources'])}")
    for s in receipt["sources"]:
        print(
            f"  source {s['source_kind']:12s} rows={s['row_count']} "
            f"sha256={s['sha256'][:16]}..."
        )
    print(f"assembled_sha256={receipt['assembled']['sha256']}")
    print(f"compat_sha256={receipt['assembled']['compat_sha256']}")
    print(f"unordered_id_set_sha256={receipt['hashes']['unordered_id_set_sha256']}")
    if not mutation_mode:
        print(
            f"expected shipping counts: generated={EXPECTED_GENERATED_COUNT} "
            f"manual_trap={EXPECTED_MANUAL_TRAP_COUNT} "
            f"assembled={EXPECTED_ASSEMBLED_COUNT}"
        )

    if errors:
        print("CHECK FAILED (fail-closed):", file=sys.stderr)
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        return 1

    if mutation_mode:
        # unreachable: mutation mode always produces errors above
        print("CHECK FAILED: mutation mode must be RED", file=sys.stderr)
        return 1

    print("CHECK PASSED (local corpus-lineage candidate invariants held)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
