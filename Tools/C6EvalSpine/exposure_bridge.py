from __future__ import annotations

import json
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any

from .constants import EXPOSURE_CHECKER, FIXTURES_DIR, HOLDOUT_PATH


def run_exposure_gate(
    *,
    trainpack: Path,
    holdout: Path | None = None,
    eval_manifest: Path | None = None,
    report_path: Path | None = None,
) -> dict[str, Any]:
    """Thin subprocess bridge to scripts/check_train_eval_exposure.py.

    Does not modify the existing checker. Returns structured result with rc.
    """
    holdout_path = holdout or HOLDOUT_PATH
    if eval_manifest is None:
        eval_manifest = FIXTURES_DIR / "exposure" / "clean" / "composite-eval-manifest.json"

    with tempfile.TemporaryDirectory(prefix="c6-eval-spine-exposure-") as tmp:
        out = report_path or (Path(tmp) / "exposure-report.json")
        cmd = [
            sys.executable,
            "-B",
            str(EXPOSURE_CHECKER),
            "--trainpack",
            str(trainpack),
            "--eval-manifest",
            str(eval_manifest),
            "--holdout",
            str(holdout_path),
            "--out",
            str(out),
        ]
        proc = subprocess.run(cmd, capture_output=True, text=True, check=False)
        report: dict[str, Any] = {}
        if out.exists():
            try:
                report = json.loads(out.read_text(encoding="utf-8"))
            except json.JSONDecodeError:
                report = {"parse_error": True}

        ok = proc.returncode == 0
        errors: list[dict[str, str]] = []
        if not ok:
            errors.append(
                {
                    "code": "E_EXPOSURE_VIOLATION",
                    "detail": f"exposure checker rc={proc.returncode}",
                }
            )
        return {
            "ok": ok,
            "rc": proc.returncode,
            "stdout": proc.stdout,
            "stderr": proc.stderr,
            "report": report,
            "errors": errors,
            "checker": str(EXPOSURE_CHECKER),
            "trainpack": str(trainpack),
            "holdout": str(holdout_path),
            "eval_manifest": str(eval_manifest),
        }
