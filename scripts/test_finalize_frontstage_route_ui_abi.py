from __future__ import annotations

import hashlib
import importlib.util
import json
import tempfile
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
FINALIZER = REPO_ROOT / "Tools/checks/finalize_frontstage_route_ui_abi.py"


def load_finalizer():
    spec = importlib.util.spec_from_file_location("frontstage_ui_abi_finalizer", FINALIZER)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class FrontstageRouteUIABIFinalizerTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.finalizer = load_finalizer()

    def make_fixture(self, root: Path) -> dict[str, object]:
        export = root / "export"
        export.mkdir()
        owner = root / "owner"
        matrix = root / "matrix.json"
        matrix.write_text('{"matrix":"canonical"}\n', encoding="utf-8")
        manifest = root / "runtime-bundle.json"
        bundle_digest = "b" * 64
        manifest.write_text(
            json.dumps({"runtime_contract_bundle_digest": bundle_digest}),
            encoding="utf-8",
        )
        executable = root / "MAformacMac"
        executable.write_bytes(b"release-app")
        head = "a" * 40
        run_id = "frontstage-abi-run"
        nonce = "0123456789abcdef0123456789abcdef"
        session_id = "session-1"
        attachment_rows = []
        for sequence in (1, 2):
            exported_name = f"random-{sequence}.json"
            receipt = {
                "schema_version": "frontstage_route_receipt.v1",
                "run_id": run_id,
                "run_nonce": nonce,
                "source_head_sha": head,
                "tested_checkout_sha": head,
                "session_id": session_id,
                "turn_id": f"turn-{sequence}",
                "event_id": f"event-{sequence}",
                "sequence": sequence,
                "matrix_id": None,
                "matrix_source_sha256": hashlib.sha256(matrix.read_bytes()).hexdigest(),
                "runtime_contract_bundle_digest": bundle_digest,
                "app_executable_sha256": hashlib.sha256(executable.read_bytes()).hexdigest(),
                "proof_class": "frontstage_route_local_integration",
                "result": "refusal_no_available_tool",
                "state_mutation": False,
                "readback_count": 0,
            }
            (export / exported_name).write_text(json.dumps(receipt), encoding="utf-8")
            attachment_rows.append(
                {
                    "exportedFileName": exported_name,
                    "suggestedHumanReadableName": f"frontstage-route-turn-{sequence:04d}.json",
                    "isAssociatedWithFailure": False,
                }
            )
        (export / "manifest.json").write_text(
            json.dumps(
                [
                    {
                        "testIdentifier": "FrontstageRouteUITests/testReleaseCustomerTwoTurnRunIdentityContract()",
                        "attachments": attachment_rows,
                    }
                ]
            ),
            encoding="utf-8",
        )
        return {
            "export_directory": export,
            "owner_directory": owner,
            "checker_path": REPO_ROOT / "Tools/checks/check_frontstage_route_receipt.py",
            "schema_path": REPO_ROOT / "contracts/schemas/frontstage-route-receipt.schema.json",
            "matrix_path": matrix,
            "runtime_bundle_manifest_path": manifest,
            "app_executable": executable,
            "expected_head": head,
            "expected_run_id": run_id,
            "expected_run_nonce": nonce,
        }

    def test_finalizes_exact_two_attachments_and_runs_both_owner_checks(self) -> None:
        with tempfile.TemporaryDirectory(prefix="frontstage-ui-finalize-") as temp:
            fixture = self.make_fixture(Path(temp))
            report = self.finalizer.finalize_exported_attachments(**fixture)
            self.assertEqual(report["status"], "PASS")
            self.assertEqual(report["owner_checker_pass_count"], 2)
            copies = Path(temp) / "owner/copies"
            self.assertEqual(json.loads((copies / "turn-0001.json").read_text())["sequence"], 1)
            self.assertEqual(json.loads((copies / "turn-0002.json").read_text())["sequence"], 2)

    def test_rewritten_xcresult_attachment_names_map_one_receipt_per_sequence(self) -> None:
        with tempfile.TemporaryDirectory(prefix="frontstage-ui-finalize-") as temp:
            fixture = self.make_fixture(Path(temp))
            manifest_path = Path(fixture["export_directory"]) / "manifest.json"
            manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
            manifest[0]["attachments"][0]["suggestedHumanReadableName"] = (
                "frontstage-route-turn-0001_0_12345678-1234-1234-1234-123456789abc.json"
            )
            manifest[0]["attachments"][1]["suggestedHumanReadableName"] = (
                "frontstage-route-turn-0002_0_abcdefab-cdef-cdef-cdef-abcdefabcdef.json"
            )
            manifest_path.write_text(json.dumps(manifest), encoding="utf-8")

            report = self.finalizer.finalize_exported_attachments(**fixture)

            self.assertEqual(report["status"], "PASS")
            copies = Path(temp) / "owner/copies"
            self.assertEqual(json.loads((copies / "turn-0001.json").read_text())["sequence"], 1)
            self.assertEqual(json.loads((copies / "turn-0002.json").read_text())["sequence"], 2)

    def test_attachment_name_boundary_rejects_evil_suffix_without_owner_copies(self) -> None:
        with tempfile.TemporaryDirectory(prefix="frontstage-ui-finalize-") as temp:
            fixture = self.make_fixture(Path(temp))
            manifest_path = Path(fixture["export_directory"]) / "manifest.json"
            manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
            manifest[0]["attachments"][0]["suggestedHumanReadableName"] = (
                "frontstage-route-turn-0001evil.json"
            )
            manifest_path.write_text(json.dumps(manifest), encoding="utf-8")

            with self.assertRaisesRegex(self.finalizer.FinalizeError, "E_ATTACHMENT_SET"):
                self.finalizer.finalize_exported_attachments(**fixture)
            self.assertFalse((Path(temp) / "owner/copies").exists())

    def test_exact_plus_rewritten_duplicate_for_one_sequence_fails_attachment_set(self) -> None:
        with tempfile.TemporaryDirectory(prefix="frontstage-ui-finalize-") as temp:
            fixture = self.make_fixture(Path(temp))
            export_directory = Path(fixture["export_directory"])
            duplicate_name = "random-1-duplicate.json"
            (export_directory / duplicate_name).write_text(
                (export_directory / "random-1.json").read_text(encoding="utf-8"),
                encoding="utf-8",
            )
            manifest_path = export_directory / "manifest.json"
            manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
            manifest[0]["attachments"].append(
                {
                    "exportedFileName": duplicate_name,
                    "suggestedHumanReadableName": (
                        "frontstage-route-turn-0001_0_12345678-1234-1234-1234-123456789abc.json"
                    ),
                    "isAssociatedWithFailure": False,
                }
            )
            manifest_path.write_text(json.dumps(manifest), encoding="utf-8")

            with self.assertRaisesRegex(self.finalizer.FinalizeError, "E_ATTACHMENT_SET"):
                self.finalizer.finalize_exported_attachments(**fixture)
            self.assertFalse((Path(temp) / "owner/copies").exists())

    def test_missing_or_duplicate_named_attachment_fails_closed_without_owner_copies(self) -> None:
        with tempfile.TemporaryDirectory(prefix="frontstage-ui-finalize-") as temp:
            fixture = self.make_fixture(Path(temp))
            manifest_path = Path(fixture["export_directory"]) / "manifest.json"
            manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
            manifest[0]["attachments"].pop()
            manifest_path.write_text(json.dumps(manifest), encoding="utf-8")
            with self.assertRaisesRegex(self.finalizer.FinalizeError, "E_ATTACHMENT_SET"):
                self.finalizer.finalize_exported_attachments(**fixture)
            self.assertFalse((Path(temp) / "owner/copies").exists())

    def test_owner_checker_failure_does_not_publish_copies(self) -> None:
        with tempfile.TemporaryDirectory(prefix="frontstage-ui-finalize-") as temp:
            fixture = self.make_fixture(Path(temp))
            for sequence in (1, 2):
                receipt_path = Path(fixture["export_directory"]) / f"random-{sequence}.json"
                receipt = json.loads(receipt_path.read_text(encoding="utf-8"))
                receipt["source_head_sha"] = "c" * 40
                receipt_path.write_text(json.dumps(receipt), encoding="utf-8")
            with self.assertRaisesRegex(self.finalizer.FinalizeError, "E_OWNER_CHECKER"):
                self.finalizer.finalize_exported_attachments(**fixture)
            self.assertFalse((Path(temp) / "owner/copies").exists())


if __name__ == "__main__":
    unittest.main()
