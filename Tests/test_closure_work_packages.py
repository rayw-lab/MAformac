"""Executable O1/O2 positive and mandatory-negative contracts."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

import pytest


REPO = Path(__file__).resolve().parents[1]
CHECKER = REPO / "scripts" / "check_closure_work_packages.py"
REGISTRY = REPO / "contracts" / "closure-work-packages.v1.yaml"
ROADMAP = REPO / "docs" / "roadmap-2026-07-11-v6-closure-baseline.md"
RESOURCE_POLICY = REPO / "contracts" / "closure-execution-window.v1.yaml"
NEGATIVE_DIR = REPO / "Tests" / "Fixtures" / "closure-registry" / "negative"


def run_checker(tmp_path: Path, *extra: str) -> subprocess.CompletedProcess[str]:
    receipt = tmp_path / "closure-registry-check.v1.json"
    return subprocess.run(
        [
            sys.executable,
            str(CHECKER),
            "check",
            "--registry",
            str(REGISTRY),
            "--roadmap",
            str(ROADMAP),
            "--o6-policy",
            str(RESOURCE_POLICY),
            "--receipt",
            str(receipt),
            *extra,
        ],
        cwd=REPO,
        text=True,
        capture_output=True,
        check=False,
    )


def read_receipt(tmp_path: Path) -> dict[str, object]:
    return json.loads((tmp_path / "closure-registry-check.v1.json").read_text(encoding="utf-8"))


def test_current_29_package_registry_passes(tmp_path: Path) -> None:
    result = run_checker(tmp_path)

    assert result.returncode == 0, result.stderr
    receipt = read_receipt(tmp_path)
    assert receipt["status"] == "PASS"
    assert receipt["package_count"] == 29
    assert receipt["hard_leaf_denominator"] == 28
    assert receipt["root_reach"] == "29/29"
    assert receipt["resource_pair_encoding"] == "unordered_canonical_single_row"
    assert receipt["lease_states"] == ["running"]


@pytest.mark.parametrize(
    ("fixture_name", "expected_rc", "expected_errors"),
    [
        ("fake-ready-w2.fixture.yaml", 65, {"E_READY_PREREQUISITE"}),
        ("duplicate-counting-b6.fixture.yaml", 66, {"E_COUNTING", "E_RECEIPT_ALIAS"}),
        ("resource-conflict-s8-build.fixture.yaml", 67, {"E_RESOURCE_CONFLICT"}),
        ("handwritten-count-token.fixture.yaml", 68, {"E_HANDWRITTEN_COUNT"}),
    ],
)
def test_required_negative_fixture_reds_in_real_checker(
    tmp_path: Path,
    fixture_name: str,
    expected_rc: int,
    expected_errors: set[str],
) -> None:
    fixture = NEGATIVE_DIR / fixture_name
    result = run_checker(tmp_path, "--fixture", str(fixture))

    assert result.returncode == expected_rc, result.stderr
    receipt = read_receipt(tmp_path)
    assert receipt["status"] == "BLOCKED"
    assert expected_errors.issubset(set(receipt["errors"]))
