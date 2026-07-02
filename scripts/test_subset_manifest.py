#!/usr/bin/env python3
"""Regression tests for E-2 subset manifest codegen."""

import json
import subprocess
import sys
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts" / "gen_subset_manifest.py"


def run_cmd(args, cwd=ROOT, expect_ok=True):
    result = subprocess.run(args, cwd=cwd, text=True, capture_output=True)
    if expect_ok and result.returncode != 0:
        raise AssertionError(f"command failed: {' '.join(map(str, args))}\n{result.stdout}\n{result.stderr}")
    if not expect_ok and result.returncode == 0:
        raise AssertionError(f"command unexpectedly passed: {' '.join(map(str, args))}\n{result.stdout}")
    return result


def load_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def test_real_catalog_single_group_coverage_and_digest_identity():
    with tempfile.TemporaryDirectory() as tmp:
        out = Path(tmp)
        run_cmd([
            sys.executable,
            str(SCRIPT),
            "--emit",
            "--output-dir",
            str(out),
            "--tokenizer-mode",
            "none",
        ])
        manifest = load_json(out / "subset-policy-manifest.json")
        artifacts = load_json(out / "subset-grammar-artifacts.json")
        catalog = load_json(ROOT / "generated" / "D_domain.tools.demo.json")
        expected_tools = {item["function"]["name"] for item in catalog}

        singles = [entry for entry in manifest["entries"] if entry["mount_mode"] == "single_group"]
        single_tools = [tool for entry in singles for tool in entry["tool_ids_ordered"]]
        assert len(single_tools) == len(set(single_tools))
        assert set(single_tools) == expected_tools

        by_key = {(item["mount_mode"], item["group_id"]): item for item in artifacts["artifacts"]}
        artifact_keys = {(entry["mount_mode"], entry["group_id"]) for entry in manifest["entries"] if entry["mount_mode"] != "sg_pair"}
        assert set(by_key) == artifact_keys
        for entry in manifest["entries"]:
            if entry["mount_mode"] == "sg_pair":
                continue
            artifact = by_key[(entry["mount_mode"], entry["group_id"])]
            assert entry["grammar_artifact_digest"] == artifact["grammar_artifact_digest"]
            assert entry["no_tool_outlet_digest"] == artifacts["meta"]["no_tool_outlet_digest"]

        assert manifest["meta"]["tool_count"] == 562
        assert manifest["meta"]["runtime_trimming"] == "forbidden"


def test_fixture_digest_stable():
    with tempfile.TemporaryDirectory() as tmp:
        tmp_path = Path(tmp)
        catalog = tmp_path / "catalog.json"
        scenario = tmp_path / "scenarios.yaml"
        catalog.write_text(json.dumps([
            tool("open_ac", "ac", "ac", "ac", {}),
            tool("close_ac", "ac", "ac", "ac", {}),
            tool("open_window", "window", "window", "window", {}),
        ], ensure_ascii=False), encoding="utf-8")
        scenario.write_text("scenes: []\n", encoding="utf-8")
        first = tmp_path / "first"
        second = tmp_path / "second"
        base = [
            sys.executable,
            str(SCRIPT),
            "--catalog",
            str(catalog),
            "--demo-scenarios",
            str(scenario),
            "--emit",
            "--tokenizer-mode",
            "none",
            "--output-dir",
        ]
        run_cmd(base + [str(first)])
        run_cmd(base + [str(second)])
        assert (first / "subset-policy-manifest.json").read_bytes() == (second / "subset-policy-manifest.json").read_bytes()
        assert (first / "subset-grammar-artifacts.json").read_bytes() == (second / "subset-grammar-artifacts.json").read_bytes()


def test_budget_gate_fails_closed_for_over_cap_single_group():
    with tempfile.TemporaryDirectory() as tmp:
        tmp_path = Path(tmp)
        catalog = tmp_path / "catalog.json"
        scenario = tmp_path / "scenarios.yaml"
        huge_enum = [f"value_{index}" for index in range(80)]
        catalog.write_text(json.dumps([
            tool("huge_door_tool", "door", "door", "door", {"slot": {"type": "string", "enum": huge_enum}}),
        ], ensure_ascii=False), encoding="utf-8")
        scenario.write_text("scenes: []\n", encoding="utf-8")
        result = run_cmd([
            sys.executable,
            str(SCRIPT),
            "--catalog",
            str(catalog),
            "--demo-scenarios",
            str(scenario),
            "--check",
            "--verify-budget",
            "--tokenizer-mode",
            "char",
            "--budget-cap",
            "20",
        ], expect_ok=False)
        assert "budget cap fail-closed" in result.stderr


def tool(name, domain, sg, ir_device, properties):
    return {
        "type": "function",
        "_domain": domain,
        "_sg": sg,
        "_ir": {"device": ir_device, "ir_primitives": ["power_on"], "value_types": []},
        "function": {
            "name": name,
            "description": "fixture tool",
            "parameters": {
                "type": "object",
                "additionalProperties": False,
                "properties": properties,
            },
        },
    }


def main() -> int:
    tests = [
        test_real_catalog_single_group_coverage_and_digest_identity,
        test_fixture_digest_stable,
        test_budget_gate_fails_closed_for_over_cap_single_group,
    ]
    for test in tests:
        test()
        print(f"OK {test.__name__}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
