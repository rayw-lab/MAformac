#!/usr/bin/env python3
import base64
import json
import pathlib
import subprocess
import tempfile

SCRIPT = pathlib.Path(__file__).with_name("check_w20a_claim_envelope.py")
RECEIPT_MARKER = "W20A_RUNTIME_RECEIPT_JSON_BASE64="


def receipt() -> dict:
    return {
        "schema_version": "runtime_adapter_mount_receipt.v2",
        "runtime_target": "ios_sim",
        "mount_verdict": "pass",
        "adapter_sha": "9373fd4174922c4e697f188e24756758ec5a236eb6ae944dfaf115450363d8d6",
        "adapter_config_sha": "adapter-config",
        "base_model_id": "Qwen/Qwen3-1.7B",
        "base_model_digest": "base-model",
        "tokenizer_digest": "tokenizer",
        "code_head_sha": "head",
        "trainpack_sha": "fa5690400f67db9ef237dabdb489f58d1ab69961f14d6733d79f9bd7cad33823",
        "decode_contract_id": "qwen-tool-call-format.v1",
        "ir_map_fingerprint": "ir-map",
        "mounted_demo_catalog_sha": "mounted-catalog",
        "case_ledger_ref": "fixture",
        "provenance": "first_execution",
        "mounted_at": "2026-07-07T00:00:00Z",
        "non_claims": {
            "adapter_learned_qa": False,
            "candidate_status": "unsigned",
            "runtime_qa_safety": "open",
        },
    }


def xcode_stdout(receipt_payload: dict) -> str:
    receipt_b64 = base64.b64encode(json.dumps(receipt_payload, sort_keys=True).encode()).decode()
    return "\n".join(
        [
            "Command line invocation:",
            "    /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild test -project /Users/wanglei/workspace/MAformac/MAformac.xcodeproj -scheme MAformacIOS -destination platform=iOS Simulator,name=iPhone 17 Pro -only-testing:MAformacCoreTests/W20ARuntimeReadbackTests",
            "Test Suite 'W20ARuntimeReadbackTests' started",
            "runtime_target=ios_sim",
            f"{RECEIPT_MARKER}{receipt_b64}",
            "Test Suite 'W20ARuntimeReadbackTests' passed",
            "** TEST SUCCEEDED **",
            "",
        ]
    )


def write_case(root: pathlib.Path, extra_text: str = "") -> None:
    receipt_payload = receipt()
    (root / "runtime-adapter-mount-receipt.v2.json").write_text(
        json.dumps(receipt_payload, sort_keys=True),
        encoding="utf-8",
    )
    (root / "ios-destination-stdout.log").write_text(xcode_stdout(receipt_payload), encoding="utf-8")
    (root / "notes.md").write_text(extra_text, encoding="utf-8")


def run(root: pathlib.Path) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["python3", str(SCRIPT), str(root)],
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )


def assert_pass_allows_unsigned_and_t1_warning() -> None:
    with tempfile.TemporaryDirectory() as tmp:
        root = pathlib.Path(tmp)
        write_case(root, "candidate_status=unsigned\n禁 claim T1 过门\n")
        result = run(root)
        assert result.returncode == 0, result.stderr


def assert_blocks_negative_claims() -> None:
    for text in ["V-PASS achieved", "candidate signed", "adapter_learned_qa=true"]:
        with tempfile.TemporaryDirectory() as tmp:
            root = pathlib.Path(tmp)
            write_case(root, text)
            result = run(root)
            assert result.returncode != 0, text


def assert_blocks_missing_stdout() -> None:
    with tempfile.TemporaryDirectory() as tmp:
        root = pathlib.Path(tmp)
        write_case(root)
        (root / "ios-destination-stdout.log").unlink()
        result = run(root)
        assert result.returncode != 0, result.stdout
        assert "missing ios-destination-stdout.log" in result.stderr, result.stderr


def assert_blocks_fake_stdout() -> None:
    with tempfile.TemporaryDirectory() as tmp:
        root = pathlib.Path(tmp)
        write_case(root)
        (root / "ios-destination-stdout.log").write_text("runtime_target=ios_sim\n", encoding="utf-8")
        result = run(root)
        assert result.returncode != 0, result.stdout
        assert "iOS destination stdout missing marker" in result.stderr, result.stderr


def assert_blocks_stdout_receipt_mismatch() -> None:
    with tempfile.TemporaryDirectory() as tmp:
        root = pathlib.Path(tmp)
        write_case(root)
        altered = receipt()
        altered["code_head_sha"] = "different-head"
        (root / "runtime-adapter-mount-receipt.v2.json").write_text(
            json.dumps(altered, sort_keys=True),
            encoding="utf-8",
        )
        result = run(root)
        assert result.returncode != 0, result.stdout
        assert "receipt artifact does not match" in result.stderr, result.stderr


def main() -> None:
    assert_pass_allows_unsigned_and_t1_warning()
    assert_blocks_negative_claims()
    assert_blocks_missing_stdout()
    assert_blocks_fake_stdout()
    assert_blocks_stdout_receipt_mismatch()
    print("PASS scripts/test_w20a_claim_envelope.py")


if __name__ == "__main__":
    main()
