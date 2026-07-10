import copy
import hashlib
import json
import sys
import tempfile
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT / "Tools" / "S8ReceiptChain"))

from s8_g1_receipt import (  # noqa: E402
    REQUIRED_PRELAUNCH_CHECKS,
    ReceiptError,
    build_completion_manifest,
    canonical_sha256,
    main,
    validate_start_receipt,
)


def sha256_bytes(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest()


class S8G1ReceiptTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tempdir = tempfile.TemporaryDirectory()
        self.root = Path(self.tempdir.name)
        self.run_dir = self.root / "s8-run"
        self.run_dir.mkdir()
        self.base_model = self.root / "base-model"
        self.base_model.mkdir()

        (self.base_model / "config.json").write_text(
            json.dumps({"model_type": "qwen3", "hidden_size": 2048}) + "\n",
            encoding="utf-8",
        )
        (self.base_model / "model.safetensors").write_bytes(b"base-weights")
        (self.base_model / "tokenizer.json").write_bytes(b"tokenizer")
        (self.base_model / "tokenizer_config.json").write_text(
            json.dumps({"chat_template": "{{ messages }}"}) + "\n",
            encoding="utf-8",
        )

        self.adapter_dir = self.run_dir / "adapters-rank16"
        self.adapter_dir.mkdir()
        self.checkpoints = []
        for iteration in (600, 1200, 1800):
            checkpoint = self.adapter_dir / f"{iteration:07d}_adapters.safetensors"
            checkpoint.write_bytes(f"checkpoint-{iteration}".encode("utf-8"))
            self.checkpoints.append(checkpoint)
        self.final_adapter = self.adapter_dir / "adapters.safetensors"
        self.final_adapter.write_bytes(b"final-adapter")
        (self.adapter_dir / "adapter_config.json").write_text(
            json.dumps(
                {
                    "adapter_path": str(self.adapter_dir),
                    "data": str(self.run_dir / "mlx-data"),
                    "fine_tune_type": "lora",
                    "num_layers": -1,
                    "resume_adapter_file": None,
                    "lora_parameters": {
                        "rank": 16,
                        "scale": 20.0,
                        "dropout": 0.0,
                        "keys": ["self_attn.q_proj", "self_attn.v_proj"],
                    },
                },
                sort_keys=True,
            )
            + "\n",
            encoding="utf-8",
        )

        self.metrics = self.run_dir / "metrics.jsonl"
        rows = [
            {"event": "run_metadata", "training_loop_source_sha256": "a" * 64},
            {"event": "val", "iteration": 1},
            {"event": "optimizer_update", "iteration": 600},
            {"event": "train_report", "iteration": 1200},
            {"event": "train_report", "iteration": 1800},
        ]
        self.metrics.write_text(
            "\n".join(json.dumps(row, sort_keys=True) for row in rows) + "\n",
            encoding="utf-8",
        )

        self.recipe = self.root / "s8-recipe-1800.yaml"
        self.recipe.write_text("training_recipe:\n  iters: 1800\n", encoding="utf-8")
        self.command_file = self.run_dir / "train.command.txt"
        self.command_file.write_text("python train.py --iters 1800\n", encoding="utf-8")
        self.training_loop = self.run_dir / "c5_mlx_train_loop.snapshot.py"
        self.training_loop.write_text("print('fixture')\n", encoding="utf-8")
        self.decode_contract = self.root / "decode-contract.json"
        self.decode_contract.write_text('{"temperature":0}\n', encoding="utf-8")
        self.tool_catalog = self.root / "mounted-tools.json"
        self.tool_catalog.write_text('{"tools":["set_cabin_ac"]}\n', encoding="utf-8")

        self.trainpack = self.root / "mlx-data"
        self.trainpack.mkdir()
        for split in ("train", "valid", "test"):
            (self.trainpack / f"{split}.jsonl").write_text(
                json.dumps({"split": split}) + "\n", encoding="utf-8"
            )

        self.flight_status = self.run_dir / "flight-status.json"
        self.flight_status.write_text(
            json.dumps(
                {
                    "schema_version": "s8_flight_status_v1",
                    "run_dir": str(self.run_dir),
                    "terminal_status": "COMPLETED",
                    "max_iter": 1800,
                    "trainer_exit_code": 0,
                },
                sort_keys=True,
            )
            + "\n",
            encoding="utf-8",
        )
        self.rc_sidecar = self.run_dir / "trainer.rc"
        self.rc_sidecar.write_text("0\n", encoding="utf-8")
        self.pid_sidecar = self.run_dir / "trainer.pid"
        self.pid_sidecar.write_text("4242\n", encoding="utf-8")
        self.checkpoint_manifest = self.run_dir / "checkpoint-manifest.sha256"
        self.checkpoint_manifest.write_text(
            "".join(
                f"{sha256_bytes(path.read_bytes())}  {path}\n"
                for path in [*self.checkpoints, self.final_adapter]
            ),
            encoding="utf-8",
        )

        self.start_receipt = {
            "schema_version": "s8_launch_basis_receipt_v2",
            "artifact_kind": "s8_flight_launch_basis",
            "status": "LAUNCHED",
            "mode": "launch",
            "run_dir": str(self.run_dir),
            "trainer_pid": "4242",
            "launch_identity": {
                "run_id": "s8-fixture",
                "nonce": "58c8b1df-7702-47d5-b68b-e0ce0466e667",
                "trainer_pid": "4242",
            },
            "fresh_full": {
                "resume_adapter_file": None,
                "prelaunch_inventory": {
                    "run_dir_existed": False,
                    "checked": list(REQUIRED_PRELAUNCH_CHECKS),
                    "present": [],
                    "empty": True,
                },
            },
            "basis": {"recipe": {"path": str(self.recipe), "sha256": sha256_bytes(self.recipe.read_bytes())}},
            "rendered": {
                "base_model": str(self.base_model),
                "command_file": str(self.command_file),
                "source_mlx_data": str(self.trainpack),
                "train_loop": str(self.training_loop),
            },
            "gate_strength_delta": "strengthened",
        }
        self.start_receipt_path = self.run_dir / "s8-launch-basis-receipt.json"
        self.start_receipt_path.write_text(
            json.dumps(self.start_receipt, indent=2, sort_keys=True) + "\n",
            encoding="utf-8",
        )

    def tearDown(self) -> None:
        self.tempdir.cleanup()

    def test_start_preflight_rejects_missing_nonce(self) -> None:
        candidate = copy.deepcopy(self.start_receipt)
        del candidate["launch_identity"]["nonce"]
        with self.assertRaisesRegex(ReceiptError, "E_START_NONCE_MISSING"):
            validate_start_receipt(candidate, require_launched=True)

    def test_start_preflight_rejects_missing_inventory(self) -> None:
        candidate = copy.deepcopy(self.start_receipt)
        del candidate["fresh_full"]["prelaunch_inventory"]
        with self.assertRaisesRegex(ReceiptError, "E_PRELAUNCH_INVENTORY_MISSING"):
            validate_start_receipt(candidate, require_launched=True)

    def test_start_preflight_rejects_incomplete_inventory_checked_set(self) -> None:
        candidate = copy.deepcopy(self.start_receipt)
        candidate["fresh_full"]["prelaunch_inventory"]["checked"] = ["metrics.jsonl"]
        with self.assertRaisesRegex(ReceiptError, "E_PRELAUNCH_INVENTORY_INCOMPLETE"):
            validate_start_receipt(candidate, require_launched=True)

    def test_start_preflight_rejects_non_null_resume_adapter(self) -> None:
        candidate = copy.deepcopy(self.start_receipt)
        candidate["fresh_full"]["resume_adapter_file"] = "old/adapters.safetensors"
        with self.assertRaisesRegex(ReceiptError, "E_RESUME_ADAPTER_FORBIDDEN"):
            validate_start_receipt(candidate, require_launched=True)

    def test_start_preflight_rejects_missing_explicit_resume_null(self) -> None:
        candidate = copy.deepcopy(self.start_receipt)
        del candidate["fresh_full"]["resume_adapter_file"]
        with self.assertRaisesRegex(ReceiptError, "E_RESUME_ADAPTER_FORBIDDEN"):
            validate_start_receipt(candidate, require_launched=True)

    def test_completion_manifest_joins_start_and_recomputes_subject(self) -> None:
        manifest = build_completion_manifest(
            run_dir=self.run_dir,
            start_receipt_path=self.start_receipt_path,
            flight_status_path=self.flight_status,
            trainer_rc_sidecar=self.rc_sidecar,
            decode_contract_path=self.decode_contract,
            mounted_tool_catalog_path=self.tool_catalog,
            repo_head="b" * 40,
            model_id="mlx-community/Qwen3-1.7B-4bit",
        )

        self.assertEqual(manifest["status"], "G1_FRESH_FULL_SEALED")
        self.assertEqual(manifest["gate_strength_delta"], "strengthened")
        self.assertEqual(manifest["start_receipt"]["nonce"], self.start_receipt["launch_identity"]["nonce"])
        self.assertEqual(manifest["start_receipt"]["trainer_pid"], "4242")
        self.assertEqual(
            manifest["start_receipt"]["sha256"],
            sha256_bytes(self.start_receipt_path.read_bytes()),
        )
        self.assertEqual(manifest["completion"]["trainer_exit_code"], 0)
        self.assertTrue(manifest["completion"]["metrics_iteration_monotonic"])
        self.assertTrue(manifest["completion"]["checkpoint_iteration_monotonic"])
        self.assertEqual(manifest["completion"]["max_iter"], 1800)
        self.assertEqual(
            manifest["model_subject_sha256"],
            canonical_sha256(manifest["model_subject"]),
        )

    def test_completion_manifest_rejects_missing_rc_sidecar(self) -> None:
        self.rc_sidecar.unlink()
        with self.assertRaisesRegex(ReceiptError, "E_TRAINER_RC_SIDECAR_MISSING"):
            build_completion_manifest(
                run_dir=self.run_dir,
                start_receipt_path=self.start_receipt_path,
                flight_status_path=self.flight_status,
                trainer_rc_sidecar=self.rc_sidecar,
                decode_contract_path=self.decode_contract,
                mounted_tool_catalog_path=self.tool_catalog,
                repo_head="b" * 40,
                model_id="mlx-community/Qwen3-1.7B-4bit",
            )

    def test_completion_manifest_rejects_non_monotonic_metrics(self) -> None:
        self.metrics.write_text(
            "\n".join(
                [
                    json.dumps({"event": "run_metadata"}),
                    json.dumps({"event": "train_report", "iteration": 1200}),
                    json.dumps({"event": "train_report", "iteration": 600}),
                    json.dumps({"event": "train_report", "iteration": 1800}),
                ]
            )
            + "\n",
            encoding="utf-8",
        )
        with self.assertRaisesRegex(ReceiptError, "E_METRICS_ITERATION_NON_MONOTONIC"):
            build_completion_manifest(
                run_dir=self.run_dir,
                start_receipt_path=self.start_receipt_path,
                flight_status_path=self.flight_status,
                trainer_rc_sidecar=self.rc_sidecar,
                decode_contract_path=self.decode_contract,
                mounted_tool_catalog_path=self.tool_catalog,
                repo_head="b" * 40,
                model_id="mlx-community/Qwen3-1.7B-4bit",
            )

    def seal_cli_args(self, output: Path) -> list[str]:
        return [
            "seal",
            "--run-dir",
            str(self.run_dir),
            "--start-receipt",
            str(self.start_receipt_path),
            "--flight-status",
            str(self.flight_status),
            "--trainer-rc-sidecar",
            str(self.rc_sidecar),
            "--decode-contract",
            str(self.decode_contract),
            "--mounted-tool-catalog",
            str(self.tool_catalog),
            "--repo-head",
            "b" * 40,
            "--model-id",
            "mlx-community/Qwen3-1.7B-4bit",
            "--output",
            str(output),
        ]

    def test_seal_cli_writes_manifest_after_all_gates_pass(self) -> None:
        output = self.run_dir / "s8-model-artifact-manifest.v1.json"
        self.assertEqual(main(self.seal_cli_args(output)), 0)
        manifest = json.loads(output.read_text(encoding="utf-8"))
        self.assertEqual(manifest["status"], "G1_FRESH_FULL_SEALED")

    def test_seal_cli_failure_does_not_write_success_manifest(self) -> None:
        candidate = copy.deepcopy(self.start_receipt)
        del candidate["launch_identity"]["nonce"]
        self.start_receipt_path.write_text(
            json.dumps(candidate, indent=2, sort_keys=True) + "\n",
            encoding="utf-8",
        )
        output = self.run_dir / "s8-model-artifact-manifest.v1.json"
        self.assertEqual(main(self.seal_cli_args(output)), 70)
        self.assertFalse(output.exists())


if __name__ == "__main__":
    unittest.main()
