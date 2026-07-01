import XCTest
@testable import MAformacCore

final class C5TinyAblationHarnessTests: XCTestCase {
    func testTinyAblationDryRunPassesWhenMockMetricIsBelowTarget() {
        let verdict = C5TinyAblationHarness().evaluate(
            metrics: C5TinyAblationMetrics(sampleCount: 34, emptyToolCallOutputs: 4)
        )

        XCTAssertEqual(verdict.status, "dry_run_pass")
        XCTAssertTrue(verdict.passed)
        XCTAssertEqual(verdict.reason, "dry_run_metric_target_met")
        XCTAssertEqual(verdict.metricSource, .fixture)
        XCTAssertEqual(verdict.baselineEmptyToolCallOutputs, 28)
        XCTAssertEqual(verdict.baselineDenominator, 34)
        XCTAssertEqual(verdict.targetEmptyToolCallOutputsStrictlyBelow, 5)
        XCTAssertEqual(verdict.stepwiseAxes, C5HeldOutOverlapAxis.allCases.map(\.rawValue))
    }

    func testTinyAblationDryRunBlocksWhenMetricHitsThreshold() {
        let verdict = C5TinyAblationHarness().evaluate(
            metrics: C5TinyAblationMetrics(sampleCount: 34, emptyToolCallOutputs: 5)
        )

        XCTAssertEqual(verdict.status, "blocked")
        XCTAssertFalse(verdict.passed)
        XCTAssertEqual(verdict.reason, "empty_tool_call_outputs_not_below_target")
    }

    func testTinyAblationDryRunBlocksOutOfRangeSampleCount() {
        let verdict = C5TinyAblationHarness().evaluate(
            metrics: C5TinyAblationMetrics(sampleCount: 19, emptyToolCallOutputs: 0)
        )

        XCTAssertEqual(verdict.status, "blocked")
        XCTAssertFalse(verdict.passed)
        XCTAssertEqual(verdict.reason, "dry_run_sample_count_out_of_range")
    }

    func testTinyAblationRealMetricSourceIsBlockedByR7() {
        let verdict = C5TinyAblationHarness().evaluate(
            metrics: C5TinyAblationMetrics(sampleCount: 34, emptyToolCallOutputs: 0, metricSource: .realBlocked)
        )

        XCTAssertEqual(verdict.status, "blocked")
        XCTAssertFalse(verdict.passed)
        XCTAssertEqual(verdict.metricSource, .realBlocked)
        XCTAssertEqual(verdict.reason, "real_ablation_blocked_by_r7")
    }
}
