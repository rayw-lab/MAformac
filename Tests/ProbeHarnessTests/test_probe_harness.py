import json
import tempfile
import unittest
from pathlib import Path

import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "Tools" / "ProbeHarness"))

import probe_harness as harness


class FakeRunner:
    def generate(self, *, model_path, adapter_path, user_text, contract):
        prompt = (
            "<|im_start|>system\n"
            f"{harness.SYSTEM_PROMPT}<|im_end|>\n"
            "<|im_start|>user\n"
            f"{user_text}<|im_end|>\n"
            "<|im_start|>assistant\n"
            "<think>\n\n</think>\n\n"
        )
        if adapter_path is None:
            return harness.GenerationResult(prompt=prompt, raw_generation="NO_TOOL")
        if "打开车窗" in user_text:
            return harness.GenerationResult(prompt=prompt, raw_generation='<tool_call>{"name":"open_window","arguments":{}}</tool_call>')
        return harness.GenerationResult(prompt=prompt, raw_generation='<tool_call>{"name":"raise_ac_temperature_by_exp","arguments":{}}</tool_call>')


def valid_decode_payload(**overrides):
    payload = {
        "temperature": 0,
        "max_tokens": 160,
        "stop_tokens": ["</tool_call>", "\n", "\n\n", "\r\n"],
        "tokenizer_wrapper": "mlx_lm_tokenizer_wrapper",
        "prompt_skeleton_id": "qwen3_patched_no_think_chat_template",
        "thinking": "no_think_block",
        "parser_id": "p3h_tool_call_json_ordered_v2",
        "tool_call_cardinality": "ordered_multi_call",
        "output_boundary": "raw_generation_and_truncated_output",
    }
    payload.update(overrides)
    return payload


class ProbeHarnessTests(unittest.TestCase):
    def test_decode_contract_missing_parameter_fails_closed(self):
        with self.assertRaisesRegex(harness.HarnessError, "decode_contract_missing:max_tokens"):
            payload = valid_decode_payload()
            payload.pop("max_tokens")
            harness.DecodeContract.from_payload(payload)

    def test_decode_contract_missing_stop_family_fails_closed(self):
        with self.assertRaisesRegex(harness.HarnessError, "decode_contract_missing_required_stop_tokens"):
            harness.DecodeContract.from_payload(valid_decode_payload(stop_tokens=["</tool_call>"]))

    def test_decode_contract_missing_prompt_parser_fields_fail_closed(self):
        with self.assertRaisesRegex(harness.HarnessError, "decode_contract_missing:parser_id"):
            payload = valid_decode_payload()
            payload.pop("parser_id")
            harness.DecodeContract.from_payload(payload)

    def test_paired_base_adapter_summary_shape(self):
        cases = [
            {
                "case_id": "CASE-1",
                "input_zh": "有点冷",
                "behavior_class": "tool_call",
                "expected_tool_calls": [{"name": "raise_ac_temperature_by_exp", "arguments": {}}],
                "tags": {"bucket": "action"},
            },
            {
                "case_id": "CASE-2",
                "input_zh": "打开车窗",
                "behavior_class": "tool_call",
                "expected_tool_calls": [{"name": "open_window", "arguments": {}}],
                "tags": {"bucket": "action"},
            },
        ]
        with tempfile.TemporaryDirectory() as tmp:
            output_dir = Path(tmp)
            base = harness.run_arm(
                arm_name="base",
                model_path=Path("base"),
                adapter_path=None,
                cases=cases,
                contract=harness.DEFAULT_DECODE_CONTRACT,
                output_dir=output_dir,
                runner=FakeRunner(),
            )
            adapter = harness.run_arm(
                arm_name="adapter",
                model_path=Path("base"),
                adapter_path=Path("adapter"),
                cases=cases,
                contract=harness.DEFAULT_DECODE_CONTRACT,
                output_dir=output_dir,
                runner=FakeRunner(),
            )
            paired = harness.paired_summary(base, adapter)

        self.assertEqual(base["empty_tool_call_outputs"], 2)
        self.assertEqual(adapter["empty_tool_call_outputs"], 0)
        self.assertEqual(paired["paired_axes"], [{"axis": "action", "base_empty": 2, "adapter_empty": 0, "delta": -2}])

    def test_leading_newline_tool_call_survives_stop_truncation(self):
        raw = '\n\n<tool_call>{"name":"raise_ac_temperature_by_exp","arguments":{}}</tool_call>\n'
        truncated = harness.truncate_at_stop_token(raw, harness.DEFAULT_DECODE_CONTRACT.stop_tokens)

        self.assertTrue(truncated.startswith("<tool_call>"))
        self.assertEqual(harness.extracted_tool_names(truncated), ["raise_ac_temperature_by_exp"])
        self.assertTrue(harness.has_tool_call(truncated))

    def test_generate_kwargs_accepts_mlx_lm_var_keyword_signature_with_greedy_sampler(self):
        def fake_generate(model, tokenizer, prompt, verbose=False, **kwargs):
            return ""

        def fake_generate_step(prompt, model, *, max_tokens=256, sampler=None):
            return iter(())

        previous = fake_generate.__globals__.get("generate_step")
        fake_generate.__globals__["generate_step"] = fake_generate_step

        def restore_generate_step():
            if previous is None:
                fake_generate.__globals__.pop("generate_step", None)
            else:
                fake_generate.__globals__["generate_step"] = previous

        self.addCleanup(restore_generate_step)

        kwargs = harness.generate_kwargs_for_contract(
            fake_generate,
            prompt="prompt",
            contract=harness.DEFAULT_DECODE_CONTRACT,
        )

        self.assertEqual(kwargs["prompt"], "prompt")
        self.assertEqual(kwargs["max_tokens"], 160)
        self.assertIsNone(kwargs["sampler"])
        self.assertNotIn("temp", kwargs)
        self.assertFalse(kwargs["verbose"])

    def test_prompt_skeleton_requires_empty_think_block(self):
        valid_prompt = "<|im_start|>assistant\n<think>\n\n</think>\n\n"
        harness.validate_prompt_skeleton(valid_prompt, harness.DEFAULT_DECODE_CONTRACT)
        with self.assertRaisesRegex(harness.HarnessError, "invalid_probe_prompt_missing_empty_think_block"):
            harness.validate_prompt_skeleton("<|im_start|>assistant\n", harness.DEFAULT_DECODE_CONTRACT)

    def test_multi_call_parser_preserves_ordered_calls(self):
        case = {
            "case_id": "C6-MP-028",
            "expected_tool_calls": [
                {"name": "open_ac", "arguments": {}},
                {"name": "adjust_ac_temperature_to_number", "arguments": {"temperature": "24"}},
            ],
        }
        raw = (
            '<tool_call>{"name":"open_ac","arguments":{}}</tool_call>\n'
            '<tool_call>{"name":"adjust_ac_temperature_to_number","arguments":{"temperature":"24"}}</tool_call>'
        )
        parsed = harness.parse_tool_calls(raw)

        self.assertEqual(parsed["observed_tool_names"], [call["name"] for call in case["expected_tool_calls"]])
        self.assertEqual(parsed["tool_call_count"], 2)
        self.assertEqual(parsed["parse_errors"], [])

    def test_paired_mode_requires_adapter_unless_base_only_smoke(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            case_path = root / "cases.jsonl"
            case_path.write_text(
                json.dumps({"case_id": "CASE-1", "input_zh": "打开空调", "behavior_class": "tool_call"}, ensure_ascii=False) + "\n",
                encoding="utf-8",
            )
            contract_path = root / "decode.json"
            contract_path.write_text(json.dumps(valid_decode_payload(), ensure_ascii=False), encoding="utf-8")
            with self.assertRaisesRegex(harness.HarnessError, "adapter_required_for_paired_probe"):
                harness.main(
                    [
                        "--cases",
                        str(case_path),
                        "--base-model",
                        "base",
                        "--decode-contract",
                        str(contract_path),
                        "--output-dir",
                        str(root / "out"),
                    ]
                )

    def test_overlap_summary_three_metric_families(self):
        cases = [
            {
                "case_id": "CASE-1",
                "input_zh": "有点冷",
                "expected_tool_calls": [{"name": "raise_ac_temperature_by_exp", "arguments": {}}],
                "tags": {"bucket": "action"},
            },
            {
                "case_id": "CASE-2",
                "input_zh": "device=window; primitive=power_on; 请按这个语义执行",
                "expected_tool_calls": [{"name": "open_window", "arguments": {}}],
                "tags": {"bucket": "action"},
            },
        ]
        train_rows = [
            {
                "messages": [{"role": "user", "content": "有点冷"}],
                "expected_tool_calls": [{"name": "raise_ac_temperature_by_exp", "arguments": {}}],
            },
            {
                "messages": [{"role": "user", "content": "另一句话"}],
                "tools": [{"type": "function", "function": {"name": "open_window"}}],
            },
        ]
        summary = harness.overlap_summary(cases, train_rows)

        self.assertEqual(summary["per_case_tool_overlap_count"], 2)
        self.assertEqual(summary["unique_expected_tool_overlap_count"], 2)
        self.assertEqual(summary["expected_calls_overlap_count"], 2)
        self.assertEqual(summary["utterance_overlap_count"], 1)
        self.assertEqual(summary["natural_vs_protocol"], {"natural": 1, "protocol": 1})

    def test_cli_overlap_path_writes_receipt_without_model_when_contract_invalid(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            contract_path = root / "decode.json"
            payload = valid_decode_payload()
            payload.pop("max_tokens")
            contract_path.write_text(json.dumps(payload), encoding="utf-8")
            with self.assertRaises(harness.HarnessError):
                harness.main(
                    [
                        "--cases",
                        str(root / "missing.jsonl"),
                        "--base-model",
                        "base",
                        "--decode-contract",
                        str(contract_path),
                        "--output-dir",
                        str(root / "out"),
                    ]
                )


if __name__ == "__main__":
    unittest.main()
