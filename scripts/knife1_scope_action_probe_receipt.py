#!/usr/bin/env python3
"""Build a deterministically scoped action-probe receipt.

Default (no arguments) keeps the legacy S10 knife: exactly matrix_id=4,
written to runtime-action-readback-probes-scoped-4.json.

Pass ``--matrix-ids`` (comma-separated, e.g. ``1,4``) to scope an exact set.
The scoped receipt contains exactly one case per requested matrix id, in the
canonical ascending order of the requested ids; any other case count is a
fail-closed error so scope contamination (extra/missing/duplicate cases) can
never silently pass.
"""

import argparse
import json
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
SOURCE_RECEIPT = REPO_ROOT / ".build" / "c1-run" / "receipts" / "c1" / "runtime-action-readback-probes.json"
LEGACY_TARGET_RECEIPT = REPO_ROOT / ".build" / "c1-run" / "receipts" / "c1" / "runtime-action-readback-probes-scoped-4.json"


def parse_matrix_ids(raw: str) -> list[int]:
    ids: list[int] = []
    for token in raw.split(","):
        token = token.strip()
        if not token.isdigit():
            raise ValueError(f"E_SCOPE_MATRIX_ID_INVALID: {token!r}")
        value = int(token)
        if value <= 0:
            raise ValueError(f"E_SCOPE_MATRIX_ID_NONPOSITIVE: {value}")
        if value in ids:
            raise ValueError(f"E_SCOPE_MATRIX_ID_DUPLICATE: {value}")
        ids.append(value)
    if not ids:
        raise ValueError("E_SCOPE_MATRIX_IDS_EMPTY")
    return ids


def default_target(matrix_ids: list[int]) -> Path:
    if matrix_ids == [4]:
        return LEGACY_TARGET_RECEIPT
    suffix = "-".join(str(i) for i in sorted(matrix_ids))
    return SOURCE_RECEIPT.with_name(f"runtime-action-readback-probes-scoped-{suffix}.json")


def scope_receipt(source_data: dict, matrix_ids: list[int], knife: str) -> dict:
    cases_by_matrix_id: dict[int, list[dict]] = {}
    for case in source_data.get("cases", []):
        matrix_id = case.get("matrixID") if isinstance(case, dict) else None
        cases_by_matrix_id.setdefault(matrix_id, []).append(case)

    scoped_cases: list[dict] = []
    for matrix_id in sorted(matrix_ids):
        matches = cases_by_matrix_id.get(matrix_id, [])
        if len(matches) != 1:
            raise ValueError(
                f"E_SCOPE_CASE_COUNT_INVALID: matrix_id={matrix_id} expected exactly 1 case, found {len(matches)}"
            )
        scoped_cases.append(matches[0])

    scoped_data = dict(source_data)
    scoped_data["scope"] = {
        "matrix_ids": sorted(matrix_ids),
        "knife": knife,
    }
    scoped_data["cases"] = scoped_cases
    scoped_data["caseCount"] = len(scoped_cases)
    return scoped_data


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--matrix-ids", default="4", help="comma-separated matrix ids to scope (default: 4)")
    parser.add_argument("--knife", default="s10_knife1", help="scope knife label recorded in the receipt")
    parser.add_argument("--source", type=Path, default=SOURCE_RECEIPT, help="source receipt path")
    parser.add_argument("--output", type=Path, default=None, help="target receipt path (default derived from matrix ids)")
    args = parser.parse_args(argv)

    try:
        matrix_ids = parse_matrix_ids(args.matrix_ids)
    except ValueError as error:
        print(str(error), file=sys.stderr)
        return 1

    source_data = json.loads(args.source.read_text(encoding="utf-8"))
    try:
        scoped_data = scope_receipt(source_data, matrix_ids, args.knife)
    except ValueError as error:
        print(str(error), file=sys.stderr)
        return 1

    target = args.output or default_target(matrix_ids)
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(json.dumps(scoped_data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"Wrote scoped receipt matrix_ids={sorted(matrix_ids)} (caseCount={scoped_data['caseCount']}) to {target}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
