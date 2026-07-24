#!/usr/bin/env python3
"""B7 semantic correction: regenerate source corpus from live tracked truth.

Live tracked `contracts/c6-bench-cases.jsonl` has exactly 57 unique ids:
  - 45 non-C6-TRAP-* rows  -> source_kind=generated  (identity-preserving copy)
  - 12 C6-TRAP-* rows      -> source_kind=manual_trap (live manual trap subset)

No row is invented. The candidate's shipping corpus must be exactly the
tracked 57 (45 + 12). The malformed trap.jsonl is NOT a source corpus and is
handled separately as a mutation fixture.

Driven by D-147 / T02 live-truth + generated/manual_trap source separation.
Run from repo root: python3 Tools/C6CorpusLineage/_regenerate_sources.py
"""
from __future__ import annotations

import hashlib
import json
from datetime import date
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
TRACKED = REPO_ROOT / "contracts/c6-bench-cases.jsonl"
SOURCES = REPO_ROOT / "Tools/C6CorpusLineage/sources"
MUTATIONS = REPO_ROOT / "Tools/C6CorpusLineage/mutations"

TRACKED_HASH = hashlib.sha256(TRACKED.read_bytes()).hexdigest()
CAPTURED_AT = "2026-07-13"  # migration capture date (run date); not an authored_at

RATIONALE_BY_PREFIX = {
    "trap-negation": "live manual trap: negation flip must not change the target device/tool",
    "trap-numeric-lure": "live manual trap: numeric anchor (e.g. 26/40) is a lure, target is the delta",
    "trap-correction": "live manual trap: self-correction redirects to a different device/tool",
    "trap-ambiguous": "live manual trap: ambiguous input admits an acceptable alternative control",
    "trap-safety-inheritance": "live manual trap: safety refusal inherited from moving-state rule",
    "trap-low-confidence-asr": "live manual trap: low-confidence ASR -> clarify, not a tool call",
}


def rationale_for(sample_kind: str) -> str:
    for prefix, text in RATIONALE_BY_PREFIX.items():
        if sample_kind.startswith(prefix):
            return text
    return "live manually-authored trap case migrated from tracked corpus"


def load_tracked() -> list[dict]:
    rows: list[dict] = []
    for line in TRACKED.read_text(encoding="utf-8").splitlines():
        if line.strip():
            rows.append(json.loads(line))
    return rows


def main() -> int:
    rows = load_tracked()
    assert len(rows) == 57, f"tracked must be 57 rows, got {len(rows)}"
    ids = [r["case_id"] for r in rows]
    assert len(set(ids)) == 57, "tracked ids must be unique"

    generated, manual_trap = [], []
    for r in rows:
        if r["case_id"].startswith("C6-TRAP-"):
            manual_trap.append(r)
        else:
            generated.append(r)
    assert len(generated) == 45, f"generated must be 45, got {len(generated)}"
    assert len(manual_trap) == 12, f"manual_trap must be 12, got {len(manual_trap)}"

    # --- generated: identity-preserving copy + source_kind ---
    gen_lines = [
        json.dumps({**r, "source_kind": "generated"}, ensure_ascii=False)
        for r in generated
    ]
    (SOURCES / "c6-bench-cases.generated.jsonl").write_text(
        "\n".join(gen_lines) + "\n", encoding="utf-8"
    )

    # --- manual_trap: exact 12 C6-TRAP-* + stable lineage metadata ---
    mt_lines = []
    for r in manual_trap:
        sample_kind = r.get("tags", {}).get("sample_kind", "trap")
        rec = {
            **r,
            "source_kind": "manual_trap",
            "source_record_id": f"c6-lineage-manual-trap:{r['case_id']}",
            "provenance": "tracked contracts/c6-bench-cases.jsonl (C6-TRAP-* rows)",
            "rationale": rationale_for(sample_kind),
            "external_layer": "live_tracked",
            "must_not_train": r.get("tags", {}).get("must_not_train", True),
            "behavior_class_ref": r.get("behavior_class"),
            "source_refs_authority": r.get("source_refs", {}),
            "authored_at": "unknown",
            "captured_at": CAPTURED_AT,
            "source_path": "contracts/c6-bench-cases.jsonl",
            "source_hash": TRACKED_HASH,
        }
        mt_lines.append(json.dumps(rec, ensure_ascii=False))
    (SOURCES / "c6-bench-cases.manual-trap.jsonl").write_text(
        "\n".join(mt_lines) + "\n", encoding="utf-8"
    )

    # remove the old invented manual.jsonl (replaced by manual-trap.jsonl)
    old_manual = SOURCES / "c6-bench-cases.manual.jsonl"
    if old_manual.exists():
        old_manual.unlink()

    # --- move malformed trap.jsonl -> mutations/deliberate-red.jsonl ---
    MUTATIONS.mkdir(parents=True, exist_ok=True)
    trap = SOURCES / "c6-bench-cases.trap.jsonl"
    if trap.exists():
        trap.rename(MUTATIONS / "deliberate-red.jsonl")

    print(f"generated.jsonl   = {len(gen_lines)} rows")
    print(f"manual-trap.jsonl = {len(mt_lines)} rows")
    print(f"tracked_hash      = {TRACKED_HASH}")
    print("old manual.jsonl removed; trap.jsonl -> mutations/deliberate-red.jsonl")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
