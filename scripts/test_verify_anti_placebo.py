#!/usr/bin/env python3
"""Behavior tests for the anti-placebo repository checker."""

from __future__ import annotations
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from verify_anti_placebo import check_verify_e2e, check_wp21_product_gate  # noqa: E402


VALID_WP21_SOURCE = """
final class DemoSliceProductBehaviorGateTests {
    struct Harness {
        let speech = RecordingSpeechSynthesisEngine()
    }
    func test01_openAC_powerOn() async throws {
        let result = try await h.route.route(text: "打开空调")
        XCTAssertEqual(result.execution?.runnerCallCount, 1)
    }
    func test03a_freshDefaultTemp24StillPowersOn() async throws {
        let result = try await h.route.route(text: "把空调调到24度")
        XCTAssertEqual(result.execution?.runnerCallCount, 1)
    }
    func test07_alreadyOn_noDuplicateMutation() async throws {
        let result = try await h.route.route(text: "打开空调")
        XCTAssertEqual(result.execution?.runnerCallCount, 0)
    }
    func test12_multiIntent_gap_rejected() async throws {
        let result = try await h.route.route(text: "打开空调并打开车窗")
        XCTAssertNil(result.execution)
    }
    func testWP21BatchA_window() {
        let route = DemoSliceRoute(
        let result = route.route(text: "window")
        XCTAssertEqual(result.execution?.runnerCallCount, 1)
        let displays = VehicleCardDisplay.displays(from: h.store.cells)
        XCTAssertEqual(h.store.cell(for: "window")?.actualValue, "70")
        XCTAssertFalse(result.execution!.payload.readbacks.isEmpty)
        XCTAssertEqual(result.execution!.payload.mutationCount, 1)
    }
    func testWP21BatchB_ambient() {
        let result = try await h.route.route(text: "打开氛围灯")
        XCTAssertEqual(result.execution?.runnerCallCount, 1)
        XCTAssertEqual(h.store.cell(for: "ambient")?.actualValue, "on")
        XCTAssertFalse(result.execution!.payload.readbacks.isEmpty)
        XCTAssertEqual(result.execution!.payload.mutationCount, 1)
        _ = VehicleCardDisplay.displays(from: h.store.cells)
        _ = DemoSliceRoute(
    }
    func testWP21BatchC_seat() {
        let result = try await h.route.route(text: "打开副驾座椅加热")
        XCTAssertEqual(result.execution?.runnerCallCount, 1)
        XCTAssertEqual(h.store.cell(for: "seat")?.actualValue, "1")
        XCTAssertFalse(result.execution!.payload.readbacks.isEmpty)
        XCTAssertEqual(result.execution!.payload.mutationCount, 1)
        _ = VehicleCardDisplay.displays(from: h.store.cells)
        _ = DemoSliceRoute(
    }
}
"""

VALID_WP21_MAKEFILE = """
verify-e2e: verify-e2e-product-behavior verify-e2e-wp21-window verify-e2e-wp21-ambient verify-e2e-wp21-seat
\tpython3 scripts/verify_anti_placebo.py
verify-e2e-product-behavior:
\tswift test --filter DemoSliceProductBehaviorGateTests
verify-e2e-wp21-window:
\tswift test --filter DemoSliceProductBehaviorGateTests/testWP21BatchA_
verify-e2e-wp21-ambient:
\tswift test --filter DemoSliceProductBehaviorGateTests/testWP21BatchB_
verify-e2e-wp21-seat:
\tswift test --filter DemoSliceProductBehaviorGateTests/testWP21BatchC_
"""

WP21_ONLY_MAKEFILE = """
verify-e2e: verify-e2e-wp21-window verify-e2e-wp21-ambient verify-e2e-wp21-seat
\tpython3 scripts/verify_anti_placebo.py
verify-e2e-wp21-window:
\tswift test --filter DemoSliceProductBehaviorGateTests/testWP21BatchA_
verify-e2e-wp21-ambient:
\tswift test --filter DemoSliceProductBehaviorGateTests/testWP21BatchB_
verify-e2e-wp21-seat:
\tswift test --filter DemoSliceProductBehaviorGateTests/testWP21BatchC_
"""


def write_wp21_fixture(root: Path, source: str = VALID_WP21_SOURCE, makefile: str = VALID_WP21_MAKEFILE) -> None:
    tests = root / "Tests" / "MAformacCoreTests"
    tests.mkdir(parents=True)
    (tests / "DemoSliceProductBehaviorGateTests.swift").write_text(source, encoding="utf-8")
    (root / "Makefile").write_text(makefile, encoding="utf-8")


class VerifyAntiPlaceboBehaviorTests(unittest.TestCase):
    def test_normal_makefile_and_workflow_pass(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "Makefile").write_text("verify-e2e:\n\ttrue\n", encoding="utf-8")
            workflow = root / ".github" / "workflows"
            workflow.mkdir(parents=True)
            (workflow / "verify.yml").write_text(
                "steps:\n  - name: e2e\n    run: make verify-e2e\n",
                encoding="utf-8",
            )
            self.assertEqual(check_verify_e2e(root), [])

    def test_missing_or_renamed_target_fails_closed(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "Makefile").write_text("verify-product-e2e:\n\ttrue\n", encoding="utf-8")
            workflow = root / ".github" / "workflows"
            workflow.mkdir(parents=True)
            (workflow / "verify.yml").write_text(
                "steps:\n  - run: make verify-e2e\n", encoding="utf-8"
            )
            failures = check_verify_e2e(root)
            self.assertTrue(failures)
            self.assertIn("verify-e2e target missing", failures[0])

    def test_workflow_without_make_verify_e2e_fails(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "Makefile").write_text("verify-e2e:\n\ttrue\n", encoding="utf-8")
            workflow = root / ".github" / "workflows"
            workflow.mkdir(parents=True)
            (workflow / "verify.yml").write_text(
                "steps:\n  - run: make verify-ci\n", encoding="utf-8"
            )
            self.assertEqual(check_verify_e2e(root), [".github/workflows/verify.yml"])

    def test_wp21_valid_data_flow_gate_passes(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            write_wp21_fixture(root)
            self.assertEqual(check_wp21_product_gate(root), [])

    def test_wp21_missing_any_required_anchor_fails_closed(self) -> None:
        replacements = (
            ("DemoSliceRoute(", "DemoRoute("),
            (".route(text:", ".send(text:"),
            ("runnerCallCount", "calls"),
            (".store.cell", ".state.cell"),
            ("payload.readbacks", "payload.messages"),
            ("mutationCount", "writes"),
            ("VehicleCardDisplay.displays", "PlaceboDisplay.displays"),
        )
        for old, new in replacements:
            with self.subTest(anchor=old), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                write_wp21_fixture(root, VALID_WP21_SOURCE.replace(old, new))
                self.assertTrue(check_wp21_product_gate(root))

    def test_wp21_missing_batch_prefix_fails_closed(self) -> None:
        for prefix in ("testWP21BatchA_", "testWP21BatchB_", "testWP21BatchC_"):
            with self.subTest(prefix=prefix), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                write_wp21_fixture(root, VALID_WP21_SOURCE.replace(prefix, "testRemoved_"))
                self.assertTrue(check_wp21_product_gate(root))

    def test_missing_golden_prefix_fails_closed(self) -> None:
        for prefix in (
            "test01_openAC_",
            "test03a_freshDefaultTemp24",
            "test07_alreadyOn_",
            "test12_multiIntent_",
        ):
            with self.subTest(prefix=prefix), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                write_wp21_fixture(root, VALID_WP21_SOURCE.replace(prefix, "testRemoved_"))
                failures = check_wp21_product_gate(root)
                self.assertTrue(failures)
                self.assertTrue(any("Missing golden test prefix" in item for item in failures))

    def test_empty_wp21_batch_body_fails_closed(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = VALID_WP21_SOURCE.replace(
                """func testWP21BatchB_ambient() {
        let result = try await h.route.route(text: "打开氛围灯")
        XCTAssertEqual(result.execution?.runnerCallCount, 1)
        XCTAssertEqual(h.store.cell(for: "ambient")?.actualValue, "on")
        XCTAssertFalse(result.execution!.payload.readbacks.isEmpty)
        XCTAssertEqual(result.execution!.payload.mutationCount, 1)
        _ = VehicleCardDisplay.displays(from: h.store.cells)
        _ = DemoSliceRoute(
    }""",
                "func testWP21BatchB_ambient() {}",
            )
            write_wp21_fixture(root, source)
            failures = check_wp21_product_gate(root)
            self.assertTrue(failures)
            self.assertTrue(any("Empty WP21 batch body" in item for item in failures))

    def test_wp21_only_verify_e2e_recipe_fails_closed(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            write_wp21_fixture(root, makefile=WP21_ONLY_MAKEFILE)
            failures = check_wp21_product_gate(root)
            self.assertTrue(failures)
            self.assertTrue(
                any("verify-e2e-product-behavior" in item for item in failures),
                failures,
            )

    def test_wp21_forbidden_bypass_patterns_fail_closed(self) -> None:
        snippets = (
            "let frame = ToolCallFrame()",
            "run(planDecoder: decoder)",
            "run(preset: value)",
            "run(modelBackend: backend)",
            "let backend = MLXLocalToolPlanBackend()",
            "let route: TenFamilyRoute? = nil",
            "let tailgate = true",
            "let sunroof = true",
        )
        for snippet in snippets:
            with self.subTest(snippet=snippet), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                source = VALID_WP21_SOURCE.replace("\n}", f"\n    {snippet}\n}}")
                write_wp21_fixture(root, source)
                self.assertTrue(check_wp21_product_gate(root))

    def test_wp21_speech_assertion_fails_closed(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = VALID_WP21_SOURCE.replace(
                "\n}",
                "\n    func testVoice() { XCTAssertEqual(speech.spokenTexts.count, 1) }\n}",
            )
            write_wp21_fixture(root, source)
            self.assertTrue(check_wp21_product_gate(root))

    def test_wp21_comments_and_strings_cannot_satisfy_anchors(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = """
            struct Harness { let speech = RecordingSpeechSynthesisEngine() }
            // DemoSliceRoute( .route(text: runnerCallCount h.store.cell payload.readbacks mutationCount
            let placebo = "func testWP21BatchA_ func testWP21BatchB_ func testWP21BatchC_ DemoSliceRoute( .route(text: runnerCallCount h.store.cell payload.readbacks mutationCount"
            """
            write_wp21_fixture(root, source)
            self.assertTrue(check_wp21_product_gate(root))

    def test_wp21_missing_or_placebo_make_target_fails_closed(self) -> None:
        for target in (
            "verify-e2e-product-behavior",
            "verify-e2e-wp21-window",
            "verify-e2e-wp21-ambient",
            "verify-e2e-wp21-seat",
        ):
            with self.subTest(target=target), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                write_wp21_fixture(root, makefile=VALID_WP21_MAKEFILE.replace(target, f"missing-{target}"))
                self.assertTrue(check_wp21_product_gate(root))
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            makefile = VALID_WP21_MAKEFILE.replace(
                "swift test --filter DemoSliceProductBehaviorGateTests/testWP21BatchA_",
                "true",
            )
            write_wp21_fixture(root, makefile=makefile)
            self.assertTrue(check_wp21_product_gate(root))


if __name__ == "__main__":
    unittest.main()
