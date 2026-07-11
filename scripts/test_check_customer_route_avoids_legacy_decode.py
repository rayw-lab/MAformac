import importlib.util
from pathlib import Path
import tempfile
import unittest

CHECKER = Path(__file__).with_name("check_customer_route_avoids_legacy_decode.py")
SPEC = importlib.util.spec_from_file_location("customer_decode_checker", CHECKER)
assert SPEC and SPEC.loader
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class CustomerDecodeCheckerTests(unittest.TestCase):
    def test_repo_passes(self) -> None:
        self.assertEqual(MODULE.check(), [])

    def test_legacy_customer_parser_call_fails(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "Core/LLM").mkdir(parents=True)
            (root / "Core/LLM/DDomainToolPlanBackend.swift").write_text(
                "let parsed = DDomainToolCallParser.parse(completion)\n"
            )
            (root / "Core/LLM/DDomainToolCallParser.swift").write_text(
                "public static func parse(_ completion: String) {}\n"
            )
            (root / "Core/LLM/DemoNLURouter.swift").write_text("backend.generateToolPlan()\n")
            failures = MODULE.check(root)
        self.assertTrue(any("typed envelope" in item for item in failures))
        self.assertTrue(any("bare-string" in item for item in failures))

    def test_runtime_legacy_adapter_call_fails(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "Core/LLM").mkdir(parents=True)
            (root / "Core/Execution").mkdir(parents=True)
            (root / "Core/LLM/DDomainToolPlanBackend.swift").write_text(
                "DDomainToolCallParser.parse(envelope, policy: policy)\n"
            )
            (root / "Core/LLM/DDomainToolCallParser.swift").write_text(
                "public static func parse(_ envelope: DDomainCompletionEnvelope) {}\n"
            )
            (root / "Core/LLM/DemoNLURouter.swift").write_text("backend.generateToolPlan()\n")
            (root / "Core/Execution/Runner.swift").write_text(
                "DDomainToolPlanBackend(completionProvider: { _ in completion })\n"
            )
            failures = MODULE.check(root)
        self.assertTrue(any("Core/Execution/Runner.swift" in item for item in failures))


if __name__ == "__main__":
    unittest.main()
