#!/usr/bin/env python3
"""Regression tests for E-2 subset manifest codegen."""

import hashlib
import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts" / "gen_subset_manifest.py"
MAKEFILE = ROOT / "Makefile"
VERIFY_SUBSET_BUDGET_TARGET = "verify-subset-budget"
VERIFY_SUBSET_BUDGET_CHECK_COMMAND = (
    "HF_HUB_OFFLINE=1 $(PYTHON_TOKENIZER) scripts/gen_subset_manifest.py "
    "--check --verify-budget --budget-cap 7200 --tokenizer-mode qwen"
)
sys.path.insert(0, str(ROOT / "scripts"))
import gen_subset_manifest as manifest_generator


def run_cmd(args, cwd=ROOT, expect_ok=True):
    result = subprocess.run(args, cwd=cwd, text=True, capture_output=True)
    if expect_ok and result.returncode != 0:
        raise AssertionError(f"command failed: {' '.join(map(str, args))}\n{result.stdout}\n{result.stderr}")
    if not expect_ok and result.returncode == 0:
        raise AssertionError(f"command unexpectedly passed: {' '.join(map(str, args))}\n{result.stdout}")
    return result


def load_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def make_target_block(makefile_text: str, target: str) -> tuple[str, list[str]]:
    """Return a target header and its tab-prefixed recipe lines.

    The target header intentionally permits prerequisites after the colon so
    adding a prerequisite cannot make the recipe parser silently miss the
    check command.
    """
    match = re.search(rf"^{re.escape(target)}:[^\n]*\n", makefile_text, re.MULTILINE)
    if match is None:
        return "", []

    header = match.group(0).rstrip("\n")
    recipe_lines = []
    for line in makefile_text[match.end():].splitlines():
        if line.startswith("\t"):
            recipe_lines.append(line[1:])
            continue
        if not line:
            continue
        break
    return header, recipe_lines


def verify_generated_subset_wiring_errors(makefile_text: str) -> list[str]:
    generated_header, _ = make_target_block(makefile_text, "verify-generated")
    generated_prerequisites = generated_header.partition(":")[2].split()
    _, subset_budget_recipe = make_target_block(makefile_text, VERIFY_SUBSET_BUDGET_TARGET)

    errors = []
    if VERIFY_SUBSET_BUDGET_TARGET not in generated_prerequisites:
        errors.append("E_VERIFY_GENERATED_SUBSET_CHECK_EDGE")
    if subset_budget_recipe != [VERIFY_SUBSET_BUDGET_CHECK_COMMAND]:
        errors.append("E_VERIFY_SUBSET_BUDGET_CHECK_COMMAND")
    return errors


def test_verify_subset_budget_recipe_accepts_prerequisites():
    makefile_text = MAKEFILE.read_text(encoding="utf-8")
    mutated = makefile_text.replace(
        "verify-subset-budget:\n",
        "verify-subset-budget: .venv/.deps.stamp\n",
        1,
    )
    header, recipe = make_target_block(mutated, VERIFY_SUBSET_BUDGET_TARGET)
    assert header == "verify-subset-budget: .venv/.deps.stamp"
    assert recipe == [VERIFY_SUBSET_BUDGET_CHECK_COMMAND]


def test_verify_generated_wires_subset_budget_check():
    errors = verify_generated_subset_wiring_errors(MAKEFILE.read_text(encoding="utf-8"))
    assert errors == [], errors


def test_verify_generated_wiring_passes_with_prerequisite():
    makefile_text = MAKEFILE.read_text(encoding="utf-8")
    mutated = makefile_text.replace(
        "verify-generated: .venv/.deps.stamp verify-refs test\n",
        "verify-generated: .venv/.deps.stamp verify-refs test verify-subset-budget\n",
        1,
    )
    assert verify_generated_subset_wiring_errors(mutated) == []


def test_verify_generated_subset_check_edge_deleted():
    makefile_text = MAKEFILE.read_text(encoding="utf-8")
    mutated = makefile_text.replace(
        "verify-generated: .venv/.deps.stamp verify-refs test verify-subset-budget\n",
        "verify-generated: .venv/.deps.stamp verify-refs test\n",
        1,
    )
    errors = verify_generated_subset_wiring_errors(mutated)
    assert errors == ["E_VERIFY_GENERATED_SUBSET_CHECK_EDGE"], errors


def test_verify_subset_budget_check_deleted():
    makefile_text = MAKEFILE.read_text(encoding="utf-8")
    mutated = makefile_text.replace(
        VERIFY_SUBSET_BUDGET_CHECK_COMMAND,
        VERIFY_SUBSET_BUDGET_CHECK_COMMAND.replace("--check ", "", 1),
        1,
    )
    errors = verify_generated_subset_wiring_errors(mutated)
    assert errors == ["E_VERIFY_SUBSET_BUDGET_CHECK_COMMAND"], errors


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
        grouping_contract = ROOT / "contracts" / "subset-grouping.yaml"
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
        assert manifest["meta"]["grouping_contract_digest"] == hashlib.sha256(grouping_contract.read_bytes()).hexdigest()


def test_fixture_digest_stable():
    with tempfile.TemporaryDirectory() as tmp:
        tmp_path = Path(tmp)
        catalog = tmp_path / "catalog.json"
        scenario = tmp_path / "scenarios.yaml"
        grouping = tmp_path / "subset-grouping.yaml"
        catalog.write_text(json.dumps([
            tool("open_ac", "ac", "ac", "ac", {}),
            tool("close_ac", "ac", "ac", "ac", {}),
            tool("open_window", "window", "window", "window", {}),
        ], ensure_ascii=False), encoding="utf-8")
        scenario.write_text("scenes: []\n", encoding="utf-8")
        write_grouping(grouping, seat_groups={}, whole_domain_groups=["window"])
        first = tmp_path / "first"
        second = tmp_path / "second"
        base = [
            sys.executable,
            str(SCRIPT),
            "--catalog",
            str(catalog),
            "--demo-scenarios",
            str(scenario),
            "--grouping-contract",
            str(grouping),
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
        grouping = tmp_path / "subset-grouping.yaml"
        huge_enum = [f"value_{index}" for index in range(80)]
        catalog.write_text(json.dumps([
            tool("huge_door_tool", "door", "door", "door", {"slot": {"type": "string", "enum": huge_enum}}),
        ], ensure_ascii=False), encoding="utf-8")
        scenario.write_text("scenes: []\n", encoding="utf-8")
        write_grouping(grouping, seat_groups={}, whole_domain_groups=["door"])
        result = run_cmd([
            sys.executable,
            str(SCRIPT),
            "--catalog",
            str(catalog),
            "--demo-scenarios",
            str(scenario),
            "--grouping-contract",
            str(grouping),
            "--check",
            "--verify-budget",
            "--tokenizer-mode",
            "char",
            "--budget-cap",
            "20",
        ], expect_ok=False)
        assert "budget cap fail-closed" in result.stderr


def test_build_entry_asserts_tool_ids_ordered_unique():
    duplicate_tools = [
        tool("duplicate_ac_tool", "ac", "ac", "ac", {}),
        tool("duplicate_ac_tool", "ac", "ac", "ac", {}),
    ]
    try:
        manifest_generator.build_entry("ac", "single_group", duplicate_tools)
    except AssertionError as exc:
        assert "tool_ids_ordered duplicate in single_group:ac: duplicate_ac_tool" in str(exc)
    else:
        raise AssertionError("build_entry accepted duplicate tool_ids_ordered")


def test_grouping_contract_seat_closure_fails_closed():
    with tempfile.TemporaryDirectory() as tmp:
        tmp_path = Path(tmp)
        catalog = tmp_path / "catalog.json"
        scenario = tmp_path / "scenarios.yaml"
        grouping = tmp_path / "subset-grouping.yaml"
        catalog.write_text(json.dumps([
            tool("seat_heat_on", "seat", "seat_heat", "seat_heat", {}),
            tool("seat_vent_on", "seat", "seat_ventilation", "seat_ventilation", {}),
        ], ensure_ascii=False), encoding="utf-8")
        scenario.write_text("scenes: []\n", encoding="utf-8")

        write_grouping(grouping, seat_groups={"seat.heat": ["seat_heat", "seat_missing"]}, whole_domain_groups=[])
        result = run_cmd([
            sys.executable,
            str(SCRIPT),
            "--catalog",
            str(catalog),
            "--demo-scenarios",
            str(scenario),
            "--grouping-contract",
            str(grouping),
            "--check",
            "--tokenizer-mode",
            "none",
        ], expect_ok=False)
        assert "maps _sg not in catalog" in result.stderr

        write_grouping(grouping, seat_groups={"seat.heat": ["seat_heat"]}, whole_domain_groups=[])
        result = run_cmd([
            sys.executable,
            str(SCRIPT),
            "--catalog",
            str(catalog),
            "--demo-scenarios",
            str(scenario),
            "--grouping-contract",
            str(grouping),
            "--check",
            "--tokenizer-mode",
            "none",
        ], expect_ok=False)
        assert "new catalog _sg requires contract update" in result.stderr


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


def write_grouping(path: Path, seat_groups: dict[str, list[str]], whole_domain_groups: list[str]) -> None:
    lines = [
        "meta:",
        "  authority: authored_design_input_not_derived",
        "single_group_policy:",
        "  seat_groups:",
    ]
    if seat_groups:
        for group_id, sgs in seat_groups.items():
            lines.append(f"    {group_id}:")
            for sg in sgs:
                lines.append(f"      - {sg}")
    else:
        lines.append("    {}")
    lines.append("  whole_domain_groups:")
    if whole_domain_groups:
        for domain in whole_domain_groups:
            lines.append(f"    - {domain}")
    else:
        lines.append("    []")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    tests = [
        test_verify_subset_budget_recipe_accepts_prerequisites,
        test_verify_generated_wires_subset_budget_check,
        test_verify_generated_wiring_passes_with_prerequisite,
        test_verify_generated_subset_check_edge_deleted,
        test_verify_subset_budget_check_deleted,
        test_real_catalog_single_group_coverage_and_digest_identity,
        test_fixture_digest_stable,
        test_budget_gate_fails_closed_for_over_cap_single_group,
        test_build_entry_asserts_tool_ids_ordered_unique,
        test_grouping_contract_seat_closure_fails_closed,
    ]
    for test in tests:
        test()
        print(f"OK {test.__name__}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
