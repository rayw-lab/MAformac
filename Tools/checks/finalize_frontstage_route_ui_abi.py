#!/usr/bin/env python3
"""Export, verify, and atomically publish two frontstage UI ABI receipts."""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any


ATTACHMENT_NAMES = {
    1: "frontstage-route-turn-0001.json",
    2: "frontstage-route-turn-0002.json",
}
TEST_IDENTIFIER = "FrontstageRouteUITests/testReleaseCustomerTwoTurnRunIdentityContract()"


class FinalizeError(RuntimeError):
    pass


def _load_manifest(export_directory: Path) -> list[dict[str, Any]]:
    try:
        manifest = json.loads((export_directory / "manifest.json").read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise FinalizeError("E_ATTACHMENT_MANIFEST") from error
    if not isinstance(manifest, list):
        raise FinalizeError("E_ATTACHMENT_MANIFEST")
    return manifest


def _attachment_paths(export_directory: Path) -> dict[int, Path]:
    matches: dict[int, list[Path]] = {1: [], 2: []}
    export_root = export_directory.resolve()
    for test in _load_manifest(export_directory):
        if not isinstance(test, dict) or test.get("testIdentifier") != TEST_IDENTIFIER:
            continue
        attachments = test.get("attachments")
        if not isinstance(attachments, list):
            raise FinalizeError("E_ATTACHMENT_MANIFEST")
        for attachment in attachments:
            if not isinstance(attachment, dict):
                raise FinalizeError("E_ATTACHMENT_MANIFEST")
            for sequence, expected_name in ATTACHMENT_NAMES.items():
                # Xcode 26.x xcresulttool 会把 suggestedHumanReadableName 改写成
                # `<name>_0_<UUID>.json` 导出形态；按【词干前缀 + 边界】匹配，
                # 每个 sequence 仍必须恰好命中一条（下方 len!=1 检查不放宽）。
                readable = attachment.get("suggestedHumanReadableName")
                stem = expected_name.removesuffix(".json")
                if not isinstance(readable, str) or not (
                    readable == expected_name
                    or re.fullmatch(re.escape(stem) + r"[_.].*", readable)
                ):
                    continue
                exported_name = attachment.get("exportedFileName")
                if not isinstance(exported_name, str) or Path(exported_name).name != exported_name:
                    raise FinalizeError("E_ATTACHMENT_PATH")
                candidate = (export_directory / exported_name).resolve()
                if candidate.parent != export_root or not candidate.is_file():
                    raise FinalizeError("E_ATTACHMENT_PATH")
                matches[sequence].append(candidate)
    if any(len(paths) != 1 for paths in matches.values()):
        raise FinalizeError("E_ATTACHMENT_SET")
    return {sequence: paths[0] for sequence, paths in matches.items()}


def _load_receipt(path: Path) -> dict[str, Any]:
    try:
        receipt = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise FinalizeError("E_RECEIPT_JSON") from error
    if not isinstance(receipt, dict):
        raise FinalizeError("E_RECEIPT_JSON")
    return receipt


def _validate_pair(receipts: dict[int, dict[str, Any]]) -> None:
    first = receipts[1]
    second = receipts[2]
    same_fields = (
        "run_id",
        "run_nonce",
        "source_head_sha",
        "tested_checkout_sha",
        "session_id",
        "matrix_source_sha256",
        "runtime_contract_bundle_digest",
        "app_executable_sha256",
    )
    if first.get("sequence") != 1 or second.get("sequence") != 2:
        raise FinalizeError("E_RECEIPT_PAIR")
    if any(first.get(field) != second.get(field) for field in same_fields):
        raise FinalizeError("E_RECEIPT_PAIR")
    if first.get("turn_id") == second.get("turn_id"):
        raise FinalizeError("E_RECEIPT_PAIR")
    if first.get("event_id") == second.get("event_id"):
        raise FinalizeError("E_RECEIPT_PAIR")


def _run_owner_checker(
    *,
    receipt: Path,
    checker_path: Path,
    schema_path: Path,
    matrix_path: Path,
    runtime_bundle_manifest_path: Path,
    app_executable: Path,
    expected_head: str,
    expected_run_id: str,
    expected_run_nonce: str,
) -> None:
    result = subprocess.run(
        [
            sys.executable,
            str(checker_path),
            "--receipt",
            str(receipt),
            "--schema",
            str(schema_path),
            "--matrix",
            str(matrix_path),
            "--runtime-bundle-manifest",
            str(runtime_bundle_manifest_path),
            "--app-executable",
            str(app_executable),
            "--expected-head",
            expected_head,
            "--expected-run-id",
            expected_run_id,
            "--expected-run-nonce",
            expected_run_nonce,
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        raise FinalizeError("E_OWNER_CHECKER")


def finalize_exported_attachments(
    *,
    export_directory: Path,
    owner_directory: Path,
    checker_path: Path,
    schema_path: Path,
    matrix_path: Path,
    runtime_bundle_manifest_path: Path,
    app_executable: Path,
    expected_head: str,
    expected_run_id: str,
    expected_run_nonce: str,
) -> dict[str, Any]:
    attachments = _attachment_paths(export_directory)
    receipts = {sequence: _load_receipt(path) for sequence, path in attachments.items()}
    _validate_pair(receipts)
    for sequence in (1, 2):
        _run_owner_checker(
            receipt=attachments[sequence],
            checker_path=checker_path,
            schema_path=schema_path,
            matrix_path=matrix_path,
            runtime_bundle_manifest_path=runtime_bundle_manifest_path,
            app_executable=app_executable,
            expected_head=expected_head,
            expected_run_id=expected_run_id,
            expected_run_nonce=expected_run_nonce,
        )

    owner_directory.mkdir(parents=True, exist_ok=True)
    copies_directory = owner_directory / "copies"
    if copies_directory.exists():
        raise FinalizeError("E_OWNER_COPIES_EXISTS")
    staging = Path(tempfile.mkdtemp(prefix=".frontstage-copies-", dir=owner_directory))
    try:
        for sequence in (1, 2):
            shutil.copyfile(attachments[sequence], staging / f"turn-{sequence:04d}.json")
        os.replace(staging, copies_directory)
    except BaseException:
        shutil.rmtree(staging, ignore_errors=True)
        raise
    return {
        "status": "PASS",
        "owner_checker_pass_count": 2,
        "copies": [str(copies_directory / f"turn-{sequence:04d}.json") for sequence in (1, 2)],
    }


def _export_attachments(xcresult: Path, output: Path) -> None:
    result = subprocess.run(
        [
            "xcrun",
            "xcresulttool",
            "export",
            "attachments",
            "--path",
            str(xcresult),
            "--output-path",
            str(output),
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        raise FinalizeError("E_XCRESULT_EXPORT")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--xcresult", type=Path, required=True)
    parser.add_argument("--owner-dir", type=Path, required=True)
    parser.add_argument("--checker", type=Path, required=True)
    parser.add_argument("--schema", type=Path, required=True)
    parser.add_argument("--matrix", type=Path, required=True)
    parser.add_argument("--runtime-bundle-manifest", type=Path, required=True)
    parser.add_argument("--app-executable", type=Path, required=True)
    parser.add_argument("--expected-head", required=True)
    parser.add_argument("--expected-run-id", required=True)
    parser.add_argument("--expected-run-nonce", required=True)
    args = parser.parse_args()

    try:
        with tempfile.TemporaryDirectory(prefix="frontstage-xcresult-attachments-") as temp:
            export_directory = Path(temp) / "export"
            _export_attachments(args.xcresult, export_directory)
            report = finalize_exported_attachments(
                export_directory=export_directory,
                owner_directory=args.owner_dir,
                checker_path=args.checker,
                schema_path=args.schema,
                matrix_path=args.matrix,
                runtime_bundle_manifest_path=args.runtime_bundle_manifest,
                app_executable=args.app_executable,
                expected_head=args.expected_head,
                expected_run_id=args.expected_run_id,
                expected_run_nonce=args.expected_run_nonce,
            )
    except FinalizeError as error:
        print(json.dumps({"status": "FAIL", "error": str(error)}, sort_keys=True))
        return 1
    print(json.dumps(report, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
