#!/usr/bin/env python3
"""Behavior tests for the anti-placebo repository checker (G7 knife2 meta 真红)."""

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
    func testG3_row167_compound() {
        let result = try await h.route.route(text: "主驾制热调26度")
        XCTAssertEqual(h.route.runnerCallCount, 1)
        XCTAssertEqual(h.store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertFalse(result.execution!.payload.readbacks.isEmpty)
        XCTAssertEqual(result.execution!.payload.mutationCount, 3)
    }
    func testG3_windowSeventyOutOfRange() {
        let beforeRevision = h.store.currentRevision
        let result = try await h.route.route(text: "把主驾车窗再开50%")
        XCTAssertEqual(h.route.runnerCallCount, 1)
        XCTAssertEqual(h.store.currentRevision, beforeRevision)
    }
    func testG7_query_capability() {
        let result = try await h.route.route(text: "空调能调到26度吗")
        XCTAssertEqual(h.route.runnerCallCount, 0)
        XCTAssertEqual(h.store.cells, cellsBefore)
        XCTAssertEqual(result.readOnly!.payload.mutationCount, 0)
        XCTAssertEqual(result.readOnly!.payload.readbacks.first?.spokenText, "空调温度支持18到32度")
    }
    func testG7_replay_sameUtterance() {
        let result = try await h.route.route(text: "打开空调")
        XCTAssertEqual(h.route.runnerCallCount, 1)
        XCTAssertEqual(h.store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(result.execution!.payload.mutationCount, 0)
        XCTAssertEqual(result.execution!.payload.readbacks.map(\\.key), ["ac.power"])
    }
    func testG7_cancel_idleSuanle() {
        let result = try await h.route.route(text: "算了")
        XCTAssertEqual(h.route.runnerCallCount, 0)
        XCTAssertEqual(h.store.currentRevision, revisionBefore)
        XCTAssertEqual(result.readOnly!.payload.mutationCount, 0)
        XCTAssertFalse(result.readOnly!.payload.readbacks.isEmpty)
    }
    func testG7_receipt_acceptedOpenAC() {
        let result = try await h.route.route(text: "打开空调")
        XCTAssertEqual(h.store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(result.execution!.payload.mutationCount, 1)
        _ = RuntimeTurnReceiptAssembler.assembleAndWrite(turn: turn, routeResult: result)
    }
}
"""

VALID_WP21_MAKEFILE = """
verify-e2e: verify-e2e-product-behavior verify-e2e-wp21-window verify-e2e-wp21-ambient verify-e2e-wp21-seat verify-e2e-row167 verify-e2e-query verify-e2e-risk verify-e2e-replay verify-e2e-cancel verify-e2e-receipt
\tpython3 scripts/verify_anti_placebo.py
verify-e2e-product-behavior:
\tpython3 Tools/checks/run_swift_test_exact.py --filter DemoSliceProductBehaviorGateTests --min-count 1
verify-e2e-wp21-window:
\tpython3 Tools/checks/run_swift_test_exact.py --filter DemoSliceProductBehaviorGateTests/testWP21BatchA_ --min-count 1
verify-e2e-wp21-ambient:
\tpython3 Tools/checks/run_swift_test_exact.py --filter DemoSliceProductBehaviorGateTests/testWP21BatchB_ --min-count 1
verify-e2e-wp21-seat:
\tpython3 Tools/checks/run_swift_test_exact.py --filter DemoSliceProductBehaviorGateTests/testWP21BatchC_ --min-count 1
verify-e2e-row167:
\tpython3 Tools/checks/run_swift_test_exact.py --filter DemoSliceProductBehaviorGateTests/testG3_row167_ --min-count 1
verify-e2e-query:
\tpython3 Tools/checks/run_swift_test_exact.py --filter DemoSliceProductBehaviorGateTests/testG7_query_ --min-count 1
verify-e2e-risk:
\tpython3 Tools/checks/run_swift_test_exact.py --filter DemoSliceProductBehaviorGateTests/testG3_window --min-count 1
verify-e2e-replay:
\tpython3 Tools/checks/run_swift_test_exact.py --filter DemoSliceProductBehaviorGateTests/testG7_replay_ --min-count 1
verify-e2e-cancel:
\tpython3 Tools/checks/run_swift_test_exact.py --filter DemoSliceProductBehaviorGateTests/testG7_cancel_ --min-count 1
verify-e2e-receipt:
\tpython3 Tools/checks/run_swift_test_exact.py --filter DemoSliceProductBehaviorGateTests/testG7_receipt_ --min-count 1
"""

WP21_ONLY_MAKEFILE = """
verify-e2e: verify-e2e-wp21-window verify-e2e-wp21-ambient verify-e2e-wp21-seat
\tpython3 scripts/verify_anti_placebo.py
verify-e2e-wp21-window:
\tpython3 Tools/checks/run_swift_test_exact.py --filter DemoSliceProductBehaviorGateTests/testWP21BatchA_ --min-count 1
verify-e2e-wp21-ambient:
\tpython3 Tools/checks/run_swift_test_exact.py --filter DemoSliceProductBehaviorGateTests/testWP21BatchB_ --min-count 1
verify-e2e-wp21-seat:
\tpython3 Tools/checks/run_swift_test_exact.py --filter DemoSliceProductBehaviorGateTests/testWP21BatchC_ --min-count 1
"""

BARE_SWIFT_MAKEFILE = """
verify-e2e: verify-e2e-product-behavior verify-e2e-wp21-window verify-e2e-wp21-ambient verify-e2e-wp21-seat verify-e2e-row167 verify-e2e-query verify-e2e-risk verify-e2e-replay verify-e2e-cancel verify-e2e-receipt
\tpython3 scripts/verify_anti_placebo.py
verify-e2e-product-behavior:
\tswift test --filter DemoSliceProductBehaviorGateTests
verify-e2e-wp21-window:
\tswift test --filter DemoSliceProductBehaviorGateTests/testWP21BatchA_
verify-e2e-wp21-ambient:
\tswift test --filter DemoSliceProductBehaviorGateTests/testWP21BatchB_
verify-e2e-wp21-seat:
\tswift test --filter DemoSliceProductBehaviorGateTests/testWP21BatchC_
verify-e2e-row167:
\tswift test --filter DemoSliceProductBehaviorGateTests/testG3_row167_
verify-e2e-query:
\tswift test --filter DemoSliceProductBehaviorGateTests/testG7_query_
verify-e2e-risk:
\tswift test --filter DemoSliceProductBehaviorGateTests/testG3_window
verify-e2e-replay:
\tswift test --filter DemoSliceProductBehaviorGateTests/testG7_replay_
verify-e2e-cancel:
\tswift test --filter DemoSliceProductBehaviorGateTests/testG7_cancel_
verify-e2e-receipt:
\tswift test --filter DemoSliceProductBehaviorGateTests/testG7_receipt_
"""


def write_wp21_fixture(
    root: Path, source: str = VALID_WP21_SOURCE, makefile: str = VALID_WP21_MAKEFILE
) -> None:
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
        # File-wide structural anchors + per-batch customer-path anchors.
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
            self.assertTrue(any("Empty batch body" in item for item in failures))

    def test_empty_wp21_batch_c_body_fails_closed(self) -> None:
        """G7 knife2: empty Batch C must be an explicit meta true-red fixture."""
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = VALID_WP21_SOURCE.replace(
                """func testWP21BatchC_seat() {
        let result = try await h.route.route(text: "打开副驾座椅加热")
        XCTAssertEqual(result.execution?.runnerCallCount, 1)
        XCTAssertEqual(h.store.cell(for: "seat")?.actualValue, "1")
        XCTAssertFalse(result.execution!.payload.readbacks.isEmpty)
        XCTAssertEqual(result.execution!.payload.mutationCount, 1)
        _ = VehicleCardDisplay.displays(from: h.store.cells)
        _ = DemoSliceRoute(
    }""",
                "func testWP21BatchC_seat() {}",
            )
            write_wp21_fixture(root, source)
            failures = check_wp21_product_gate(root)
            self.assertTrue(failures)
            self.assertTrue(
                any(
                    "Empty batch body" in item and "testWP21BatchC_seat" in item
                    for item in failures
                ),
                failures,
            )

    def test_empty_g7_batch_body_fails_closed(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = VALID_WP21_SOURCE.replace(
                """func testG7_query_capability() {
        let result = try await h.route.route(text: "空调能调到26度吗")
        XCTAssertEqual(h.route.runnerCallCount, 0)
        XCTAssertEqual(h.store.cells, cellsBefore)
        XCTAssertEqual(result.readOnly!.payload.mutationCount, 0)
        XCTAssertEqual(result.readOnly!.payload.readbacks.first?.spokenText, "空调温度支持18到32度")
    }""",
                "func testG7_query_capability() {}",
            )
            write_wp21_fixture(root, source)
            failures = check_wp21_product_gate(root)
            self.assertTrue(failures)
            self.assertTrue(any("Empty batch body" in item for item in failures), failures)

    def test_reverse_generated_expected_fails_closed(self) -> None:
        """expected 从被测 runtime/catalog 反向抄回 → 必须 FAIL。"""
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = VALID_WP21_SOURCE.replace(
                'XCTAssertEqual(result.readOnly!.payload.readbacks.first?.spokenText, "空调温度支持18到32度")',
                "let expectedSpoken = h.route.catalog.capabilitySpokenText\n"
                "        XCTAssertEqual(result.readOnly!.payload.readbacks.first?.spokenText, expectedSpoken)",
            )
            write_wp21_fixture(root, source)
            failures = check_wp21_product_gate(root)
            self.assertTrue(failures)
            self.assertTrue(
                any("Reverse-generated expected" in item for item in failures),
                failures,
            )

    def test_zero_filter_prefix_fails_closed(self) -> None:
        """Makefile filter prefix with zero matching tests must FAIL (0-filter)."""
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = VALID_WP21_SOURCE.replace("testG7_query_", "testG7_queryRemoved_")
            write_wp21_fixture(root, source)
            failures = check_wp21_product_gate(root)
            self.assertTrue(failures)
            self.assertTrue(
                any("0-filter" in item and "testG7_query_" in item for item in failures),
                failures,
            )

    def test_bare_swift_test_filter_recipe_fails_closed(self) -> None:
        """Bare `swift test --filter` can exit 0 on 0-match — must FAIL closed."""
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            write_wp21_fixture(root, makefile=BARE_SWIFT_MAKEFILE)
            failures = check_wp21_product_gate(root)
            self.assertTrue(failures)
            self.assertTrue(
                any("Bare swift test --filter" in item for item in failures),
                failures,
            )

    def test_missing_g7_make_target_fails_closed(self) -> None:
        for target in (
            "verify-e2e-row167",
            "verify-e2e-query",
            "verify-e2e-risk",
            "verify-e2e-replay",
            "verify-e2e-cancel",
            "verify-e2e-receipt",
        ):
            with self.subTest(target=target), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                write_wp21_fixture(
                    root, makefile=VALID_WP21_MAKEFILE.replace(target, f"missing-{target}")
                )
                self.assertTrue(check_wp21_product_gate(root))

    def test_risk_filter_must_keep_testG3_window_coupling(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            makefile = VALID_WP21_MAKEFILE.replace(
                "DemoSliceProductBehaviorGateTests/testG3_window",
                "DemoSliceProductBehaviorGateTests/testG7_risk_",
            )
            write_wp21_fixture(root, makefile=makefile)
            failures = check_wp21_product_gate(root)
            self.assertTrue(failures)
            self.assertTrue(
                any("testG3_window" in item or "Exact runner" in item for item in failures),
                failures,
            )

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

    def test_recipe_missing_test07_coverage_via_narrowed_filter_fails(self) -> None:
        """Full-class target narrowed away from golden/test07 path → FAIL."""
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            makefile = VALID_WP21_MAKEFILE.replace(
                "--filter DemoSliceProductBehaviorGateTests --min-count 1",
                "--filter DemoSliceProductBehaviorGateTests/testWP21BatchA_ --min-count 1",
            )
            write_wp21_fixture(root, makefile=makefile)
            failures = check_wp21_product_gate(root)
            self.assertTrue(failures)
            self.assertTrue(
                any("Narrowed class filter" in item for item in failures),
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
                write_wp21_fixture(
                    root, makefile=VALID_WP21_MAKEFILE.replace(target, f"missing-{target}")
                )
                self.assertTrue(check_wp21_product_gate(root))
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            makefile = VALID_WP21_MAKEFILE.replace(
                "python3 Tools/checks/run_swift_test_exact.py "
                "--filter DemoSliceProductBehaviorGateTests/testWP21BatchA_ --min-count 1",
                "true",
            )
            write_wp21_fixture(root, makefile=makefile)
            self.assertTrue(check_wp21_product_gate(root))


if __name__ == "__main__":
    unittest.main()
