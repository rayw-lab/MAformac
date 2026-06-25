#!/usr/bin/env python3

import json
import sys
from collections import Counter
from pathlib import Path


ALLOWED_BEHAVIOR_CLASSES = {
    "tool_call",
    "clarify_missing_slot",
    "refusal_no_available_tool",
    "refusal_safety_or_policy",
    "already_state_noop",
}
NO_CALL_BEHAVIOR_CLASSES = ALLOWED_BEHAVIOR_CLASSES - {"tool_call"}
ALLOWED_CLARIFY_TAGS = {"ambiguous"}


def load_catalog_names(path: Path) -> set[str]:
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, list):
        raise SystemExit(f"{path}: expected top-level list")
    names = set()
    for index, item in enumerate(data, 1):
        try:
            name = item["function"]["name"]
        except Exception as exc:  # noqa: BLE001
            raise SystemExit(f"{path}: catalog row {index} missing function.name: {exc}") from exc
        if not isinstance(name, str) or not name:
            raise SystemExit(f"{path}: catalog row {index} has invalid function.name={name!r}")
        names.add(name)
    return names


def external_layer_candidate(row: dict) -> str:
    risk_ids = row.get("source_refs", {}).get("risk_rule_ids", [])
    sample_kind = row.get("tags", {}).get("sample_kind", "")
    bucket = row.get("tags", {}).get("bucket")
    behavior_class = row.get("behavior_class")
    if risk_ids:
        return "safety"
    if behavior_class == "refusal_no_available_tool":
        return "unsupported"
    if bucket == "coverage" or "coverage" in sample_kind or "fuzz" in sample_kind:
        return "demo_fuzz"
    if behavior_class == "clarify_missing_slot":
        return "clarify"
    return "golden"


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: check_c6_case_shape.py <contracts/c6-bench-cases.jsonl> <generated/D_domain.tools.demo.json>", file=sys.stderr)
        return 64

    jsonl_path = Path(sys.argv[1])
    catalog_path = Path(sys.argv[2])
    rows = []
    for line_no, raw in enumerate(jsonl_path.read_text(encoding="utf-8").splitlines(), 1):
        if raw.strip():
            rows.append((line_no, json.loads(raw)))

    catalog_names = load_catalog_names(catalog_path)
    errors: list[str] = []
    behavior_counts: Counter[str] = Counter()
    external_counts: Counter[str] = Counter()

    for line_no, row in rows:
        case_id = row.get("case_id", f"<line:{line_no}>")
        behavior_class = row.get("behavior_class")
        expected_tool_calls = row.get("expected_tool_calls", [])
        expect_no_call = row.get("expect_no_call")
        expected_state_delta = row.get("expected_state_delta", {})
        pre_state = row.get("pre_state", {})
        clarify_tag = row.get("clarify_tag")
        risk_ids = row.get("source_refs", {}).get("risk_rule_ids", [])
        sample_kind = row.get("tags", {}).get("sample_kind", "")
        bucket = row.get("tags", {}).get("bucket")

        if not behavior_class:
            errors.append(f"{case_id}: missing behavior_class")
            continue
        if behavior_class == "direct_no_call":
            errors.append(f"{case_id}: direct_no_call is forbidden")
            continue
        if behavior_class not in ALLOWED_BEHAVIOR_CLASSES:
            errors.append(f"{case_id}: invalid behavior_class={behavior_class!r}")
            continue

        if behavior_class == "tool_call":
            if not expected_tool_calls:
                errors.append(f"{case_id}: tool_call requires nonempty expected_tool_calls")
        elif expected_tool_calls:
            errors.append(f"{case_id}: {behavior_class} must not carry expected_tool_calls")

        if behavior_class == "clarify_missing_slot":
            if clarify_tag not in ALLOWED_CLARIFY_TAGS:
                errors.append(f"{case_id}: clarify_missing_slot requires clarify_tag in {sorted(ALLOWED_CLARIFY_TAGS)}, got {clarify_tag!r}")
            if risk_ids:
                errors.append(f"{case_id}: clarify_missing_slot cannot also carry risk_rule_ids")

        if behavior_class == "refusal_safety_or_policy" and not risk_ids:
            errors.append(f"{case_id}: refusal_safety_or_policy requires nonempty source_refs.risk_rule_ids")

        if behavior_class == "refusal_no_available_tool" and risk_ids:
            errors.append(f"{case_id}: refusal_no_available_tool must keep source_refs.risk_rule_ids empty")

        if behavior_class == "already_state_noop":
            if not expected_state_delta:
                errors.append(f"{case_id}: already_state_noop requires nonempty expected_state_delta")
            for key, expected_value in expected_state_delta.items():
                if key not in pre_state:
                    errors.append(f"{case_id}: already_state_noop missing pre_state[{key!r}]")
                    continue
                if str(pre_state[key]) != str(expected_value):
                    errors.append(
                        f"{case_id}: already_state_noop requires pre_state[{key!r}] == expected_state_delta[{key!r}] ({pre_state[key]!r} != {expected_value!r})"
                    )

        if not isinstance(expect_no_call, bool):
            errors.append(f"{case_id}: expect_no_call must be boolean, got {expect_no_call!r}")
        elif behavior_class in NO_CALL_BEHAVIOR_CLASSES and expect_no_call is not True:
            errors.append(f"{case_id}: {behavior_class} requires expect_no_call=true")
        elif behavior_class == "tool_call" and expect_no_call is not False:
            errors.append(f"{case_id}: tool_call requires expect_no_call=false")

        if expected_tool_calls == [] and behavior_class not in NO_CALL_BEHAVIOR_CLASSES:
            errors.append(f"{case_id}: expected_tool_calls=[] cannot collapse into behavior_class={behavior_class}")

        for call in expected_tool_calls:
            name = call.get("name")
            if name not in catalog_names:
                errors.append(f"{case_id}: unknown expected_tool_calls name {name!r}")
        for alt in row.get("alternatives", []):
            for call in alt.get("expected_tool_calls", []):
                name = call.get("name")
                if name not in catalog_names:
                    errors.append(f"{case_id}: unknown alternative expected_tool_calls name {name!r}")

        layer = external_layer_candidate(row)
        if layer == "golden" and (bucket == "coverage" or "coverage" in sample_kind or "fuzz" in sample_kind):
            errors.append(f"{case_id}: coverage/demo_fuzz row must not enter golden layer")

        behavior_counts[behavior_class] += 1
        external_counts[layer] += 1

    print(f"rows={len(rows)}")
    print("behavior_class_counts=" + json.dumps(dict(sorted(behavior_counts.items())), ensure_ascii=False, sort_keys=True))
    print("shape_diagnostic_candidate_counts=" + json.dumps(dict(sorted(external_counts.items())), ensure_ascii=False, sort_keys=True))

    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
