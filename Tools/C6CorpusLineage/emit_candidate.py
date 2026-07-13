#!/usr/bin/env python3
"""Emit the B7 T02 corpus-lineage durable LOCAL candidate artifacts.

Writes into closure/candidates/B7/:
  - c6-corpus-lineage.assembled.jsonl   (57 lossless, stable-sorted rows)
  - c6-corpus-lineage.receipt.json     (native corpus_lineage_v1)
  - c6-corpus-lineage.envelope.json   (closure exit envelope, self-marked)

Shipping = 45 generated + 12 manual_trap = 57 exact tracked ids.
Self-marked: NOT canonical, NOT B7 DONE, proof_class=local_corpus_lineage.
Does NOT claim /opsx:apply, T02 freeze authorization, or C6 acceptance.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO_ROOT / "Tools"))
from C6CorpusLineage import (  # noqa: E402
    EXPECTED_ASSEMBLED_COUNT,
    assemble,
    build_receipt,
    default_sources,
    packaging_row_text,
    shipping_count_errors,
)

CANDIDATE_DIR = REPO_ROOT / "closure/candidates/B7"
ASSEMBLED_REL = "closure/candidates/B7/c6-corpus-lineage.assembled.jsonl"


def main() -> int:
    CANDIDATE_DIR.mkdir(parents=True, exist_ok=True)
    result = assemble(default_sources())
    if result.errors:
        print("refusing to emit candidate: assembly errors", file=sys.stderr)
        for e in result.errors:
            print(f"  - {e}", file=sys.stderr)
        return 1

    ship_errs = shipping_count_errors(result)
    if ship_errs:
        print("refusing to emit candidate: shipping count/ID errors", file=sys.stderr)
        for e in ship_errs:
            print(f"  - {e}", file=sys.stderr)
        return 1

    receipt = build_receipt(result, assembled_path=ASSEMBLED_REL)
    assembled = result.assembled_rows
    assert len(assembled) == EXPECTED_ASSEMBLED_COUNT

    # 1) assembled corpus (lossless, stable-sorted, stable-serialized packaging)
    (CANDIDATE_DIR / "c6-corpus-lineage.assembled.jsonl").write_text(
        "\n".join(packaging_row_text(r) for r in assembled) + "\n",
        encoding="utf-8",
    )

    # 2) native receipt
    (CANDIDATE_DIR / "c6-corpus-lineage.receipt.json").write_text(
        json.dumps(receipt, ensure_ascii=False, indent=2, sort_keys=True),
        encoding="utf-8",
    )

    # 3) closure exit envelope — self-marked NON-canonical / NON-DONE
    envelope = {
        "schema_version": "closure_package_exit_envelope_v1",
        "registry_schema_major": "closure_work_packages_v1",
        "registry_digest": "39d8ee006983b3d06bbe45e7986753b228da0c7fcc5ccdb05e5b31b5c22e36ce",
        "package_id": "B7",
        "package_revision": 1,
        "native_receipt_schema_id": "corpus_lineage_v1",
        "native_receipt": {
            "root": "build",
            "path": "closure/candidates/B7/c6-corpus-lineage.receipt.json",
            "sha256": _sha256_file(CANDIDATE_DIR / "c6-corpus-lineage.receipt.json"),
        },
        "native_receipt_digest": _sha256_file(
            CANDIDATE_DIR / "c6-corpus-lineage.receipt.json"
        ),
        # DELIBERATE: candidate is NOT canonical and NOT B7 DONE.
        "status": "CANDIDATE_LOCAL_ONLY",
        "subject_schema_id": "corpus_subject_v1",
        "subject": [
            {
                "key": "assembled_sha256",
                "value_type": "sha256",
                "value": receipt["assembled"]["sha256"],
            },
            {
                "key": "compat_sha256",
                "value_type": "sha256",
                "value": receipt["assembled"]["compat_sha256"],
            },
            {
                "key": "unordered_id_set_sha256",
                "value_type": "sha256",
                "value": receipt["hashes"]["unordered_id_set_sha256"],
            },
            {
                "key": "source_digests",
                "value_type": "string",
                "value": json.dumps(
                    {s["source_kind"]: s["sha256"] for s in receipt["sources"]},
                    ensure_ascii=False,
                    sort_keys=True,
                ),
            },
            {
                "key": "source_row_counts",
                "value_type": "string",
                "value": json.dumps(
                    {s["source_kind"]: s["row_count"] for s in receipt["sources"]},
                    ensure_ascii=False,
                    sort_keys=True,
                ),
            },
            {"key": "lineage_recomputable", "value_type": "boolean", "value": True},
            {"key": "is_canonical", "value_type": "boolean", "value": False},
            {"key": "is_b7_done", "value_type": "boolean", "value": False},
            {
                "key": "carrier",
                "value_type": "string",
                "value": "openspec/changes/add-b7-corpus-lineage-candidate",
            },
        ],
    }
    (CANDIDATE_DIR / "c6-corpus-lineage.envelope.json").write_text(
        json.dumps(envelope, ensure_ascii=False, indent=2, sort_keys=True),
        encoding="utf-8",
    )

    print(f"emitted candidate to {CANDIDATE_DIR}")
    print(f"  assembled_rows={len(assembled)} (expected {EXPECTED_ASSEMBLED_COUNT})")
    print(f"  is_canonical=False  is_b7_done=False  status=CANDIDATE_LOCAL_ONLY")
    print(f"  assembled_sha256={receipt['assembled']['sha256']}")
    print(f"  compat_sha256={receipt['assembled']['compat_sha256']}")
    print(f"  unordered_id_set_sha256={receipt['hashes']['unordered_id_set_sha256']}")
    for s in receipt["sources"]:
        print(f"  source {s['source_kind']} rows={s['row_count']}")
    return 0


def _sha256_file(p: Path) -> str:
    import hashlib

    return hashlib.sha256(p.read_bytes()).hexdigest()


if __name__ == "__main__":
    raise SystemExit(main())
