#!/usr/bin/env python3
"""demo-progress gauge — NON-GATING user-goal oriented panel.

Three explicit layers (w2 fix; ban single 「可演」 number):
  1. actionDemoProven       — matrix checker receipt / cells (machine SSOT)
  2. runtime_path_reachable — app registry scenarios with runtime path true
  3. operator_pass          — app registry scenarios with operator ceremony + evidence

Always exits 0. Never a CI gate. See design DESIGN-DEMO-PROGRESS-GAUGE-by-w1.md.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

HEX40 = re.compile(r"^[0-9a-f]{40}$")
BAR_WIDTH = 20

# Fixed delta copy (zh) — two/three layer denominators are not comparable by subtraction.
DELTA_LINES = [
    "delta: 三层字段语义不同，禁止合成单数「可演」KPI，禁止 R-A 相减。",
    "  L1 actionDemoProven = 矩阵格四源 proven（checker 机器派生）。",
    "  L2 runtime_path_reachable = 登记场景声明 runtime 路径可达（force-state/smoke/runner）。",
    "  L3 operator_pass = 人工 ceremony + 录屏/截图证据完整。",
    "机械绿≠可演：matrix status=PASS 可与 actionDemoProven=0/120 并存。",
]


def _repo_root_from(start: Path) -> Path:
    return start.resolve().parents[2] if start.name == "demo_progress_gauge.py" else start.resolve()


def git_head(repo: Path) -> str:
    try:
        out = subprocess.run(
            ["git", "rev-parse", "HEAD"],
            cwd=repo,
            capture_output=True,
            text=True,
            check=False,
            timeout=10,
        )
        if out.returncode == 0:
            return out.stdout.strip()
    except (OSError, subprocess.SubprocessError):
        pass
    return "UNKNOWN"


def bar(num: int, den: int) -> str:
    if den <= 0:
        return "[" + "░" * BAR_WIDTH + "]  n/a"
    frac = max(0.0, min(1.0, num / den))
    filled = int(round(BAR_WIDTH * frac))
    filled = min(BAR_WIDTH, max(0, filled))
    return f"[{'█' * filled}{'░' * (BAR_WIDTH - filled)}]  {frac * 100:5.1f}%"


def load_json(path: Path) -> Any | None:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return None


def read_action_demo_proven(
    *,
    receipt_path: Path,
    matrix_path: Path,
) -> dict[str, Any]:
    """L1: actionDemoProven_count / row_count from checker receipt or matrix recompute."""
    if receipt_path.is_file():
        data = load_json(receipt_path)
        if isinstance(data, dict) and "actionDemoProven_count" in data and "row_count" in data:
            try:
                num = int(data["actionDemoProven_count"])
                den = int(data["row_count"])
            except (TypeError, ValueError):
                num, den = 0, 0
            return {
                "num": num,
                "den": den,
                "source": f"receipt:{receipt_path.as_posix()}",
                "matrix_status": data.get("status"),
                "primary_class_counts": data.get("primary_class_counts") or {},
                "degraded": False,
            }

    matrix = load_json(matrix_path) if matrix_path.is_file() else None
    if isinstance(matrix, dict) and isinstance(matrix.get("cells"), list):
        cells = matrix["cells"]
        num = sum(1 for c in cells if isinstance(c, dict) and c.get("actionDemoProven") is True)
        den = len(cells)
        summary = matrix.get("summary") if isinstance(matrix.get("summary"), dict) else {}
        return {
            "num": num,
            "den": den,
            "source": f"matrix_file_recompute:{matrix_path.as_posix()}",
            "matrix_status": None,
            "primary_class_counts": summary.get("primary_class_counts") or {},
            "degraded": False,
        }

    return {
        "num": 0,
        "den": 0,
        "source": "MISSING:receipt_and_matrix",
        "matrix_status": None,
        "primary_class_counts": {},
        "degraded": True,
    }


def _parse_simple_yaml_registry(text: str) -> dict[str, Any]:
    """Minimal YAML subset parser for our registry (no external PyYAML required for gauge).

    Supports only the schema we ship: top-level keys, meta map, scenarios list of maps
    with nested layers/evidence. Falls back to json if text starts with '{'.
    Prefer JSON sibling if present; for YAML we use a tiny state machine.
    """
    text = text.lstrip()
    if text.startswith("{") or text.startswith("["):
        return json.loads(text)

    # Prefer stdlib-free approach: require scenarios as JSON block after marker, OR use pyyaml if present.
    try:
        import yaml  # type: ignore

        data = yaml.safe_load(text)
        if isinstance(data, dict):
            return data
    except Exception:
        pass

    # Fallback: empty registry if cannot parse
    return {"schema_version": "demo_progress_app_scenarios_v1", "scenarios": [], "_parse": "failed"}


def evidence_complete(evidence: dict[str, Any], repo: Path) -> tuple[bool, list[str]]:
    reasons: list[str] = []
    if not isinstance(evidence, dict):
        return False, ["evidence_not_object"]
    operator = evidence.get("operator")
    if not isinstance(operator, str) or not operator.strip():
        reasons.append("missing_operator")
    head = evidence.get("basis_head")
    if not isinstance(head, str) or HEX40.match(head) is None:
        reasons.append("bad_basis_head")
    recording = evidence.get("recording_path")
    shots = evidence.get("screenshot_paths") or []
    path_ok = False
    if isinstance(recording, str) and recording.strip():
        p = Path(recording)
        if not p.is_absolute():
            p = repo / p
        if p.is_file():
            path_ok = True
        else:
            reasons.append("recording_missing_on_disk")
    if isinstance(shots, list):
        for s in shots:
            if not isinstance(s, str) or not s.strip():
                continue
            p = Path(s)
            if not p.is_absolute():
                p = repo / p
            if p.is_file():
                path_ok = True
                break
    if not path_ok and "recording_missing_on_disk" not in reasons:
        # allow registration-only dry path for soft warning when no paths given
        if not (isinstance(recording, str) and recording.strip()) and not (
            isinstance(shots, list) and any(isinstance(x, str) and x.strip() for x in shots)
        ):
            reasons.append("no_evidence_path")
    return (len(reasons) == 0), reasons


def read_app_layers(*, registry_path: Path, repo: Path) -> dict[str, Any]:
    """L2 runtime_path_reachable + L3 operator_pass from app registry."""
    if not registry_path.is_file():
        return {
            "registry_status": "MISSING",
            "source": f"MISSING:{registry_path.as_posix()}",
            "runtime_path_reachable": {"num": 0, "den": 0},
            "operator_pass": {"num": 0, "den": 0},
            "invalid": [],
            "degraded": True,
            "scenarios_total": 0,
        }

    raw = registry_path.read_text(encoding="utf-8")
    data = _parse_simple_yaml_registry(raw)
    scenarios = data.get("scenarios") if isinstance(data, dict) else None
    if not isinstance(scenarios, list):
        scenarios = []

    den = 0
    rt_num = 0
    op_num = 0
    invalid: list[str] = []

    for sc in scenarios:
        if not isinstance(sc, dict):
            continue
        if sc.get("count_in_denominator") is False:
            continue
        den += 1
        sid = str(sc.get("id") or f"idx{den}")
        layers = sc.get("layers") if isinstance(sc.get("layers"), dict) else {}
        # L2
        if layers.get("runtime_path_reachable") is True:
            rt_num += 1
        # L3 — require explicit operator_pass true + evidence complete
        if layers.get("operator_pass") is True:
            ok, reasons = evidence_complete(sc.get("evidence") or {}, repo)
            if ok:
                op_num += 1
            else:
                invalid.append(f"{sid}:operator_pass_claimed_but_evidence_incomplete:{','.join(reasons)}")

    parse_failed = isinstance(data, dict) and data.get("_parse") == "failed"
    return {
        "registry_status": "PARSE_FAILED" if parse_failed else ("EMPTY" if den == 0 else "OK"),
        "source": registry_path.as_posix(),
        "runtime_path_reachable": {"num": rt_num, "den": den},
        "operator_pass": {"num": op_num, "den": den},
        "invalid": invalid,
        "degraded": parse_failed,
        "scenarios_total": den,
    }


def optional_refresh(repo: Path) -> list[str]:
    """Best-effort re-run matrix check; never raise; always observational."""
    lines: list[str] = []
    py = repo / ".venv" / "bin" / "python"
    python = str(py) if py.is_file() else sys.executable
    receipt_dir = repo / ".build" / "c1-run" / "receipts" / "c1"
    receipt_dir.mkdir(parents=True, exist_ok=True)
    receipt = receipt_dir / "capability-matrix.json"
    matrix = repo / "contracts" / "demo-capability-matrix.json"
    checker = repo / "Tools" / "checks" / "check_capability_matrix.py"
    probe = receipt_dir / "runtime-action-readback-probes.json"
    if not checker.is_file() or not matrix.is_file():
        lines.append("refresh: SKIP (checker or matrix missing)")
        return lines
    cmd = [
        python,
        str(checker),
        "check",
        "--matrix",
        str(matrix),
        "--receipt",
        str(receipt),
    ]
    if probe.is_file():
        cmd.extend(["--action-probe-receipt", str(probe)])
    try:
        proc = subprocess.run(cmd, cwd=repo, capture_output=True, text=True, timeout=120)
        lines.append(f"refresh: checker rc={proc.returncode} (ignored for gauge exit)")
    except (OSError, subprocess.SubprocessError) as exc:
        lines.append(f"refresh: FAILED {exc!r} (ignored)")
    return lines


def format_report(
    *,
    head: str,
    l1: dict[str, Any],
    app: dict[str, Any],
    extra_lines: list[str] | None = None,
) -> str:
    now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    l2 = app["runtime_path_reachable"]
    l3 = app["operator_pass"]
    lines = [
        "=== MAformac demo-progress (NON-GATING / user-goal gauge) ===",
        f"basis_head: {head}    generated_at: {now}",
        "fields: actionDemoProven | runtime_path_reachable | operator_pass  (no single '可演')",
        "",
        f"[actionDemoProven]       {l1['num']:>3}/{l1['den']:<3}  {bar(l1['num'], l1['den'])}",
        f"  source: {l1['source']}",
    ]
    if l1.get("matrix_status") is not None:
        lines.append(f"  matrix_status: {l1['matrix_status']}")
    pcc = l1.get("primary_class_counts") or {}
    if pcc:
        compact = " ".join(f"{k}={v}" for k, v in sorted(pcc.items()))
        lines.append(f"  primary_class: {compact}")
    lines += [
        "",
        f"[runtime_path_reachable] {l2['num']:>3}/{l2['den']:<3}  {bar(l2['num'], l2['den'])}",
        f"  source: {app['source']}",
        f"  registry_status: {app['registry_status']}",
        "",
        f"[operator_pass]          {l3['num']:>3}/{l3['den']:<3}  {bar(l3['num'], l3['den'])}",
        f"  source: {app['source']}",
        f"  registry_status: {app['registry_status']}",
    ]
    if app.get("invalid"):
        lines.append("  invalid_operator_pass_claims:")
        for item in app["invalid"]:
            lines.append(f"    - {item}")
    lines.append("")
    lines.extend(DELTA_LINES)
    lines += [
        "",
        "gate_orientation: USER_GOAL (verification-economics) — not compliance gate",
        "non_claims: not_ci_gate, not_single_demoable_kpi, not_v_pass, not_c6_acceptance, not_operator_pass_ceremony_ssot",
    ]
    if l1.get("degraded") or app.get("degraded"):
        lines.append("status: DEGRADED (still exit 0)")
    else:
        lines.append("status: OK (observational)")
    if extra_lines:
        lines.append("")
        lines.extend(extra_lines)
    return "\n".join(lines) + "\n"


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--repo", type=Path, default=None, help="repo root (default: auto from script path)")
    p.add_argument(
        "--receipt",
        type=Path,
        default=None,
        help="capability-matrix checker receipt JSON",
    )
    p.add_argument(
        "--matrix",
        type=Path,
        default=None,
        help="contracts/demo-capability-matrix.json",
    )
    p.add_argument(
        "--app-registry",
        type=Path,
        default=None,
        help="contracts/demo-progress-app-scenarios.yaml",
    )
    p.add_argument(
        "--refresh",
        action="store_true",
        help="best-effort re-run matrix checker before read (never fails gauge)",
    )
    return p


def main(argv: list[str] | None = None) -> int:
    # Hard contract: never non-zero. Outer try ensures it.
    try:
        args = build_parser().parse_args(argv)
        script_path = Path(__file__).resolve()
        repo = (args.repo or script_path.parents[2]).resolve()
        receipt = args.receipt or (repo / ".build/c1-run/receipts/c1/capability-matrix.json")
        matrix = args.matrix or (repo / "contracts/demo-capability-matrix.json")
        registry = args.app_registry or (repo / "contracts/demo-progress-app-scenarios.yaml")
        # Resolve relative paths against repo
        if not receipt.is_absolute():
            receipt = repo / receipt
        if not matrix.is_absolute():
            matrix = repo / matrix
        if not registry.is_absolute():
            registry = repo / registry

        extra: list[str] = []
        if args.refresh:
            extra.extend(optional_refresh(repo))

        head = git_head(repo)
        l1 = read_action_demo_proven(receipt_path=receipt, matrix_path=matrix)
        app = read_app_layers(registry_path=registry, repo=repo)
        sys.stdout.write(format_report(head=head, l1=l1, app=app, extra_lines=extra or None))
    except Exception as exc:  # noqa: BLE001 — gauge must never fail closed
        sys.stdout.write(
            "=== MAformac demo-progress (NON-GATING) ===\n"
            f"status: DEGRADED\nerror: {exc!r}\n"
            "gate_orientation: USER_GOAL\n"
            "non_claims: not_ci_gate\n"
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
