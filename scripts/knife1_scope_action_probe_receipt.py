#!/usr/bin/env python3
"""Build scoped receipt for matrix_id=4 from runtime-action-readback-probes.json."""

import json
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
SOURCE_RECEIPT = REPO_ROOT / ".build" / "c1-run" / "receipts" / "c1" / "runtime-action-readback-probes.json"
TARGET_RECEIPT = REPO_ROOT / ".build" / "c1-run" / "receipts" / "c1" / "runtime-action-readback-probes-scoped-4.json"

def main() -> None:
    source_data = json.loads(SOURCE_RECEIPT.read_text(encoding="utf-8"))
    scoped_cases = [c for c in source_data.get("cases", []) if c.get("matrixID") == 4]

    scoped_data = dict(source_data)
    scoped_data["scope"] = {
        "matrix_ids": [4],
        "knife": "s10_knife1",
    }
    scoped_data["cases"] = scoped_cases
    scoped_data["caseCount"] = len(scoped_cases)

    TARGET_RECEIPT.parent.mkdir(parents=True, exist_ok=True)
    TARGET_RECEIPT.write_text(json.dumps(scoped_data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"Wrote scoped receipt for matrix_id=4 (caseCount={len(scoped_cases)}) to {TARGET_RECEIPT}")

if __name__ == "__main__":
    main()
