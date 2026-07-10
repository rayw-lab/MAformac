#!/usr/bin/env python3
"""Fail-closed S8 G1 start-receipt validation and completion sealing."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Callable, Iterable


REQUIRED_PRELAUNCH_CHECKS = (
    "adapters-rank16",
    "metrics.jsonl",
    "checkpoints",
    "trainer.pid",
    "train.stdout.log",
    "train.stderr.log",
    "c5_mlx_train_loop.snapshot.py",
    "trainer.rc",
    "trainer.supervisor.pid",
    "s8-model-artifact-manifest.v1.json",
)
CHECKPOINT_ITERATIONS = (600, 1200, 1800)
HEX40 = re.compile(r"^[0-9a-f]{40}$")
CHECKPOINT_NAME = re.compile(r"^(\d{7})_adapters\.safetensors$")


class ReceiptError(RuntimeError):
    """A machine-readable fail-closed receipt error."""


def fail(code: str, detail: str) -> None:
    raise ReceiptError(f"{code}: {detail}")


def canonical_bytes(value: Any) -> bytes:
    return json.dumps(
        value,
        ensure_ascii=False,
        sort_keys=True,
        separators=(",", ":"),
    ).encode("utf-8")


def canonical_sha256(value: Any) -> str:
    return hashlib.sha256(canonical_bytes(value)).hexdigest()


def sha256_file(path: Path, code: str = "E_REQUIRED_FILE_MISSING") -> str:
    if not path.exists() or not path.is_file():
        fail(code, str(path))
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def read_json(path: Path, code: str) -> dict[str, Any]:
    if not path.exists() or not path.is_file():
        fail(code, str(path))
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        fail(code, f"{path}: {error}")
    if not isinstance(value, dict):
        fail(code, f"{path}: root must be an object")
    return value


def collect_prelaunch_inventory(run_dir: Path) -> dict[str, Any]:
    present = [
        name for name in REQUIRED_PRELAUNCH_CHECKS if os.path.lexists(run_dir / name)
    ]
    return {
        "run_dir_existed": os.path.lexists(run_dir),
        "checked": list(REQUIRED_PRELAUNCH_CHECKS),
        "present": present,
        "empty": not present,
    }


def validate_start_receipt(
    receipt: dict[str, Any], *, require_launched: bool
) -> dict[str, Any]:
    identity = receipt.get("launch_identity")
    if not isinstance(identity, dict):
        fail("E_START_IDENTITY_MISSING", "launch_identity must be an object")
    run_id = identity.get("run_id")
    if not isinstance(run_id, str) or not run_id.strip():
        fail("E_START_RUN_ID_MISSING", "launch_identity.run_id")
    nonce = identity.get("nonce")
    if not isinstance(nonce, str) or not nonce.strip():
        fail("E_START_NONCE_MISSING", "launch_identity.nonce")

    fresh_full = receipt.get("fresh_full")
    if not isinstance(fresh_full, dict):
        fail("E_FRESH_FULL_MISSING", "fresh_full must be an object")
    if fresh_full.get("resume_adapter_file", "__missing__") is not None:
        fail("E_RESUME_ADAPTER_FORBIDDEN", "fresh_full.resume_adapter_file must be null")
    inventory = fresh_full.get("prelaunch_inventory")
    if not isinstance(inventory, dict):
        fail("E_PRELAUNCH_INVENTORY_MISSING", "fresh_full.prelaunch_inventory")
    checked = inventory.get("checked")
    if not isinstance(checked, list) or not set(REQUIRED_PRELAUNCH_CHECKS).issubset(checked):
        fail("E_PRELAUNCH_INVENTORY_INCOMPLETE", "required checked paths are missing")
    if inventory.get("present") != [] or inventory.get("empty") is not True:
        fail("E_PRELAUNCH_RESIDUE_PRESENT", "present must be [] and empty must be true")
    if not isinstance(inventory.get("run_dir_existed"), bool):
        fail("E_PRELAUNCH_EXISTENCE_MISSING", "run_dir_existed must be boolean")
    if receipt.get("gate_strength_delta") != "strengthened":
        fail("E_GATE_STRENGTH_DELTA_MISSING", "expected strengthened")

    pid = identity.get("trainer_pid")
    if str(receipt.get("trainer_pid")) != str(pid):
        fail("E_START_PID_DUAL_FIELD_MISMATCH", "trainer_pid fields differ")
    if require_launched:
        if receipt.get("mode") != "launch" or receipt.get("status") != "LAUNCHED":
            fail("E_START_NOT_LAUNCHED", "completion seal requires a LAUNCHED receipt")
        if not str(pid).isdigit() or int(str(pid)) <= 0:
            fail("E_START_PID_INVALID", "launch_identity.trainer_pid must be positive")
    elif not isinstance(pid, (str, int)) or not str(pid):
        fail("E_START_PID_MISSING", "launch_identity.trainer_pid")
    return receipt


def _inventory(
    root: Path,
    predicate: Callable[[str], bool],
    *,
    missing_code: str,
) -> dict[str, Any]:
    if not root.exists() or not root.is_dir():
        fail(missing_code, str(root))
    entries: list[dict[str, Any]] = []
    for child in sorted(root.iterdir(), key=lambda item: item.name):
        if not predicate(child.name):
            continue
        if child.is_symlink() and not child.exists():
            fail("E_INVENTORY_BROKEN_SYMLINK", child.name)
        if not child.is_file():
            fail("E_INVENTORY_SPECIAL_FILE", child.name)
        entries.append(
            {
                "relative_path": child.name,
                "file_sha256": sha256_file(child),
                "size_bytes": child.stat().st_size,
            }
        )
    if not entries:
        fail(missing_code, f"no matching files in {root}")
    return {"files": entries, "sha256": canonical_sha256(entries)}


def base_model_inventory(root: Path) -> dict[str, Any]:
    result = _inventory(
        root,
        lambda name: name == "config.json"
        or (name.startswith("model") and ("safetensors" in name or name.endswith(".npz"))),
        missing_code="E_BASE_MODEL_INVENTORY_EMPTY",
    )
    names = {entry["relative_path"] for entry in result["files"]}
    if "config.json" not in names or not any("safetensors" in name or name.endswith(".npz") for name in names):
        fail("E_BASE_MODEL_INVENTORY_INCOMPLETE", "config and weight content are required")
    return result


def tokenizer_inventory(root: Path) -> dict[str, Any]:
    tokenizer_names = {
        "added_tokens.json",
        "merges.txt",
        "special_tokens_map.json",
        "tokenizer.json",
        "tokenizer.model",
        "tokenizer_config.json",
        "vocab.json",
        "chat_template.jinja",
    }
    return _inventory(
        root,
        lambda name: name in tokenizer_names,
        missing_code="E_TOKENIZER_INVENTORY_EMPTY",
    )


def trainpack_inventory(root: Path) -> dict[str, Any]:
    result = _inventory(
        root,
        lambda name: name in {"train.jsonl", "valid.jsonl", "test.jsonl"},
        missing_code="E_TRAINPACK_INVENTORY_EMPTY",
    )
    names = {entry["relative_path"] for entry in result["files"]}
    if names != {"train.jsonl", "valid.jsonl", "test.jsonl"}:
        fail("E_TRAINPACK_INVENTORY_INCOMPLETE", ",".join(sorted(names)))
    return result


def _metrics_evidence(path: Path) -> dict[str, Any]:
    if not path.exists() or not path.is_file():
        fail("E_METRICS_MISSING", str(path))
    rows: list[dict[str, Any]] = []
    for line_number, raw in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if not raw.strip():
            continue
        try:
            row = json.loads(raw)
        except json.JSONDecodeError as error:
            fail("E_METRICS_PARSE", f"line {line_number}: {error}")
        if not isinstance(row, dict):
            fail("E_METRICS_PARSE", f"line {line_number}: expected object")
        rows.append(row)
    if not rows:
        fail("E_METRICS_EMPTY", str(path))
    if rows[0].get("event") != "run_metadata":
        fail("E_METRICS_FIRST_RECORD", "first event must be run_metadata")
    iterations: list[int] = []
    for row in rows:
        if "iteration" not in row:
            continue
        value = row["iteration"]
        if isinstance(value, bool) or not isinstance(value, int):
            fail("E_METRICS_ITERATION_INVALID", repr(value))
        iterations.append(value)
    if not iterations:
        fail("E_METRICS_ITERATION_MISSING", str(path))
    if any(current < previous for previous, current in zip(iterations, iterations[1:])):
        fail("E_METRICS_ITERATION_NON_MONOTONIC", repr(iterations))
    if max(iterations) < 1800:
        fail("E_METRICS_MAX_ITER", str(max(iterations)))
    return {
        "first_record": rows[0],
        "iteration_monotonic": True,
        "max_iter": max(iterations),
        "record_count": len(rows),
        "sha256": sha256_file(path),
    }


def _checkpoint_evidence(adapter_dir: Path, manifest_path: Path) -> dict[str, Any]:
    checkpoints: list[tuple[int, Path]] = []
    for path in adapter_dir.iterdir():
        match = CHECKPOINT_NAME.match(path.name)
        if match:
            checkpoints.append((int(match.group(1)), path))
    checkpoints.sort(key=lambda item: item[0])
    iterations = tuple(iteration for iteration, _ in checkpoints)
    if iterations != CHECKPOINT_ITERATIONS:
        fail("E_CHECKPOINT_SEQUENCE", repr(iterations))
    mtimes = [path.stat().st_mtime_ns for _, path in checkpoints]
    if any(current < previous for previous, current in zip(mtimes, mtimes[1:])):
        fail("E_CHECKPOINT_MTIME_NON_MONOTONIC", repr(mtimes))

    manifest_sha = sha256_file(manifest_path, "E_CHECKPOINT_MANIFEST_MISSING")
    manifest_lines = manifest_path.read_text(encoding="utf-8").splitlines()
    inventory: list[dict[str, Any]] = []
    required_paths = [path for _, path in checkpoints] + [adapter_dir / "adapters.safetensors"]
    for path in required_paths:
        actual_sha = sha256_file(path, "E_FINAL_ADAPTER_MISSING")
        if not any(line.startswith(actual_sha) and str(path) in line for line in manifest_lines):
            fail("E_CHECKPOINT_MANIFEST_MISMATCH", str(path))
        inventory.append(
            {
                "relative_path": path.name,
                "file_sha256": actual_sha,
                "size_bytes": path.stat().st_size,
                "emitted_at_epoch_ns": path.stat().st_mtime_ns,
            }
        )
    return {
        "iterations": list(iterations),
        "iteration_monotonic": True,
        "files": inventory,
        "manifest_sha256": manifest_sha,
    }


def _adapter_runtime_projection(adapter_config: dict[str, Any], base_config_sha256: str) -> dict[str, Any]:
    if "resume_adapter_file" not in adapter_config or adapter_config["resume_adapter_file"] is not None:
        fail("E_ADAPTER_RUNTIME_CONFIG", "resume_adapter_file must be explicit null")
    lora = adapter_config.get("lora_parameters")
    if not isinstance(lora, dict):
        fail("E_ADAPTER_RUNTIME_CONFIG", "lora_parameters missing")
    projection = {
        "fine_tune_type": adapter_config.get("fine_tune_type"),
        "num_layers": adapter_config.get("num_layers"),
        "lora_parameters": {
            "rank": lora.get("rank"),
            "scale": lora.get("scale"),
            "dropout": lora.get("dropout"),
            "keys": lora.get("keys"),
        },
        "base_model_config_sha256": base_config_sha256,
    }
    if projection["fine_tune_type"] != "lora" or projection["num_layers"] is None:
        fail("E_ADAPTER_RUNTIME_CONFIG", "fine_tune_type/num_layers invalid")
    fields = projection["lora_parameters"]
    if any(fields[key] is None for key in ("rank", "scale", "dropout", "keys")):
        fail("E_ADAPTER_RUNTIME_CONFIG", "rank/scale/dropout/keys incomplete")
    if not isinstance(fields["keys"], list) or not fields["keys"]:
        fail("E_ADAPTER_RUNTIME_CONFIG", "keys must be a non-empty list")
    return projection


def _require_sha_match(path: Path, expected: Any, code: str) -> str:
    actual = sha256_file(path, code)
    if expected is not None and expected != actual:
        fail(code, f"expected {expected}, got {actual}")
    return actual


def build_completion_manifest(
    *,
    run_dir: Path,
    start_receipt_path: Path,
    flight_status_path: Path,
    trainer_rc_sidecar: Path,
    decode_contract_path: Path,
    mounted_tool_catalog_path: Path,
    repo_head: str,
    model_id: str,
) -> dict[str, Any]:
    if not HEX40.fullmatch(repo_head):
        fail("E_REPO_HEAD_INVALID", repo_head)
    if not model_id.strip():
        fail("E_MODEL_ID_MISSING", "model_id")

    start = validate_start_receipt(
        read_json(start_receipt_path, "E_START_RECEIPT_MISSING"),
        require_launched=True,
    )
    if Path(start.get("run_dir", "")) != run_dir or Path(start["run_dir"]).resolve() != run_dir.resolve():
        fail("E_START_RUN_DIR_MISMATCH", f"{start.get('run_dir')} != {run_dir}")
    identity = start["launch_identity"]

    status = read_json(flight_status_path, "E_FLIGHT_STATUS_MISSING")
    if status.get("run_dir") != str(run_dir):
        fail("E_FLIGHT_RUN_DIR_MISMATCH", str(status.get("run_dir")))
    if status.get("terminal_status") != "COMPLETED":
        fail("E_TERMINAL_NOT_COMPLETED", str(status.get("terminal_status")))
    max_iter = status.get("max_iter")
    if isinstance(max_iter, bool) or not isinstance(max_iter, int) or max_iter < 1800:
        fail("E_FLIGHT_MAX_ITER", repr(max_iter))
    if status.get("trainer_exit_code") != 0:
        fail("E_FLIGHT_TRAINER_RC", repr(status.get("trainer_exit_code")))

    if not trainer_rc_sidecar.exists():
        fail("E_TRAINER_RC_SIDECAR_MISSING", str(trainer_rc_sidecar))
    try:
        trainer_rc = int(trainer_rc_sidecar.read_text(encoding="utf-8").strip())
    except (OSError, ValueError) as error:
        fail("E_TRAINER_RC_SIDECAR_INVALID", str(error))
    if trainer_rc != 0:
        fail("E_TRAINER_RC_NONZERO", str(trainer_rc))
    trainer_pid_sidecar = run_dir / "trainer.pid"
    if not trainer_pid_sidecar.exists():
        fail("E_TRAINER_PID_SIDECAR_MISSING", str(trainer_pid_sidecar))
    trainer_pid = trainer_pid_sidecar.read_text(encoding="utf-8").strip()
    if trainer_pid != str(identity["trainer_pid"]):
        fail(
            "E_TRAINER_PID_JOIN_MISMATCH",
            f"{trainer_pid!r} != {identity['trainer_pid']!r}",
        )

    rendered = start.get("rendered")
    basis = start.get("basis")
    if not isinstance(rendered, dict) or not isinstance(basis, dict):
        fail("E_START_BASIS_INCOMPLETE", "basis/rendered missing")
    recipe_info = basis.get("recipe")
    if not isinstance(recipe_info, dict):
        fail("E_START_BASIS_INCOMPLETE", "basis.recipe missing")

    base_model_dir = Path(str(rendered.get("base_model", "")))
    trainpack_dir = Path(str(rendered.get("source_mlx_data", "")))
    command_file = Path(str(rendered.get("command_file", "")))
    training_loop = run_dir / "c5_mlx_train_loop.snapshot.py"
    recipe_path = Path(str(recipe_info.get("path", "")))
    adapter_dir = run_dir / "adapters-rank16"
    adapter_config_path = adapter_dir / "adapter_config.json"
    final_adapter_path = adapter_dir / "adapters.safetensors"
    metrics_path = run_dir / "metrics.jsonl"
    checkpoint_manifest_path = run_dir / "checkpoint-manifest.sha256"

    base_inventory = base_model_inventory(base_model_dir)
    tokenizer_files = tokenizer_inventory(base_model_dir)
    trainpack_files = trainpack_inventory(trainpack_dir)
    adapter_config = read_json(adapter_config_path, "E_ADAPTER_CONFIG_MISSING")
    base_config_sha = sha256_file(base_model_dir / "config.json", "E_BASE_CONFIG_MISSING")
    adapter_projection = _adapter_runtime_projection(adapter_config, base_config_sha)
    adapter_runtime_config_digest = canonical_sha256(adapter_projection)
    adapter_digest = sha256_file(final_adapter_path, "E_FINAL_ADAPTER_MISSING")
    metrics = _metrics_evidence(metrics_path)
    checkpoints = _checkpoint_evidence(adapter_dir, checkpoint_manifest_path)

    recipe_sha = _require_sha_match(recipe_path, recipe_info.get("sha256"), "E_RECIPE_SHA_MISMATCH")
    train_command_sha = sha256_file(command_file, "E_TRAIN_COMMAND_MISSING")
    training_loop_sha = sha256_file(training_loop, "E_TRAINING_LOOP_SNAPSHOT_MISSING")
    decode_contract_sha = sha256_file(decode_contract_path, "E_DECODE_CONTRACT_MISSING")
    mounted_catalog_sha = sha256_file(mounted_tool_catalog_path, "E_MOUNTED_TOOL_CATALOG_MISSING")

    model_subject = {
        "kind": "lora_adapter_runtime",
        "model_id": model_id,
        "base_model_digest": base_inventory["sha256"],
        "adapter_digest": adapter_digest,
        "adapter_config_digest": adapter_runtime_config_digest,
        "tokenizer_digest": tokenizer_files["sha256"],
        "decode_contract_sha256": decode_contract_sha,
        "mounted_tool_catalog_sha256": mounted_catalog_sha,
    }
    final_stat = final_adapter_path.stat()
    return {
        "schema_version": "s8_model_artifact_manifest_v1",
        "artifact_kind": "s8_g1_fresh_full_completion_seal",
        "status": "G1_FRESH_FULL_SEALED",
        "proof_class": "local_model_artifact",
        "gate_strength_delta": "strengthened",
        "created_at": datetime.now(timezone.utc).isoformat(),
        "run_dir": str(run_dir),
        "repo_head": repo_head,
        **model_subject,
        "adapter_config_file_sha256": sha256_file(adapter_config_path),
        "adapter_runtime_config_digest": adapter_runtime_config_digest,
        "recipe_sha256": recipe_sha,
        "train_command_sha256": train_command_sha,
        "metrics_sha256": metrics["sha256"],
        "training_loop_sha256": training_loop_sha,
        "checkpoint_manifest_sha256": checkpoints["manifest_sha256"],
        "model_subject": model_subject,
        "model_subject_sha256": canonical_sha256(model_subject),
        "start_receipt": {
            "path": str(start_receipt_path),
            "sha256": sha256_file(start_receipt_path),
            "run_id": identity["run_id"],
            "nonce": identity["nonce"],
            "trainer_pid": identity["trainer_pid"],
        },
        "completion": {
            "terminal_status": status["terminal_status"],
            "max_iter": max_iter,
            "trainer_exit_code": trainer_rc,
            "trainer_pid_sidecar": str(trainer_pid_sidecar),
            "trainer_rc_sidecar": str(trainer_rc_sidecar),
            "metrics_first_record": metrics["first_record"],
            "metrics_iteration_monotonic": metrics["iteration_monotonic"],
            "checkpoint_iteration_monotonic": checkpoints["iteration_monotonic"],
            "checkpoint_iterations": checkpoints["iterations"],
            "final_adapter_emit_timestamp": datetime.fromtimestamp(
                final_stat.st_mtime, timezone.utc
            ).isoformat(),
        },
        "inventories": {
            "base_model": base_inventory,
            "tokenizer": tokenizer_files,
            "trainpack": trainpack_files,
            "checkpoints_and_final_adapter": checkpoints["files"],
            "adapter_runtime_config_projection": adapter_projection,
        },
        "non_claims": [
            "not_candidate_signed",
            "not_c6_vpass",
            "not_s9_executed",
            "not_operator_pass",
        ],
    }


def write_json_atomic(path: Path, value: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.tmp-{os.getpid()}")
    temporary.write_text(
        json.dumps(value, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    os.replace(temporary, path)


def command_inventory(args: argparse.Namespace) -> None:
    print(json.dumps(collect_prelaunch_inventory(args.run_dir), sort_keys=True))


def command_validate_start(args: argparse.Namespace) -> None:
    receipt = read_json(args.receipt, "E_START_RECEIPT_MISSING")
    validate_start_receipt(receipt, require_launched=args.require_launched)
    print("S8_G1_START_RECEIPT_VALID")


def command_seal(args: argparse.Namespace) -> None:
    manifest = build_completion_manifest(
        run_dir=args.run_dir,
        start_receipt_path=args.start_receipt,
        flight_status_path=args.flight_status,
        trainer_rc_sidecar=args.trainer_rc_sidecar,
        decode_contract_path=args.decode_contract,
        mounted_tool_catalog_path=args.mounted_tool_catalog,
        repo_head=args.repo_head,
        model_id=args.model_id,
    )
    write_json_atomic(args.output, manifest)
    print(f"G1_FRESH_FULL_SEALED output={args.output}")


def parser() -> argparse.ArgumentParser:
    root = argparse.ArgumentParser()
    commands = root.add_subparsers(dest="command", required=True)

    inventory = commands.add_parser("inventory")
    inventory.add_argument("--run-dir", type=Path, required=True)
    inventory.set_defaults(handler=command_inventory)

    validate = commands.add_parser("validate-start")
    validate.add_argument("--receipt", type=Path, required=True)
    validate.add_argument("--require-launched", action="store_true")
    validate.set_defaults(handler=command_validate_start)

    seal = commands.add_parser("seal")
    seal.add_argument("--run-dir", type=Path, required=True)
    seal.add_argument("--start-receipt", type=Path, required=True)
    seal.add_argument("--flight-status", type=Path, required=True)
    seal.add_argument("--trainer-rc-sidecar", type=Path, required=True)
    seal.add_argument("--decode-contract", type=Path, required=True)
    seal.add_argument("--mounted-tool-catalog", type=Path, required=True)
    seal.add_argument("--repo-head", required=True)
    seal.add_argument("--model-id", required=True)
    seal.add_argument("--output", type=Path, required=True)
    seal.set_defaults(handler=command_seal)
    return root


def main(argv: Iterable[str] | None = None) -> int:
    args = parser().parse_args(argv)
    try:
        args.handler(args)
    except ReceiptError as error:
        print(f"G1_FRESH_FULL_SEAL_BLOCKED {error}", file=sys.stderr)
        return 70
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
