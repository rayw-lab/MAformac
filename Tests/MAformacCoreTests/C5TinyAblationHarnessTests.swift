import XCTest
@testable import MAformacCore

final class C5TinyAblationHarnessTests: XCTestCase {
    private let signedRunAuthorizationReference = C5TinyAblationHarness.authorizedRunAuthorizationReference

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

    func testTinyAblationRealMetricSourceWithoutReferenceIsBlocked() {
        let verdict = C5TinyAblationHarness().evaluate(
            metrics: C5TinyAblationMetrics(sampleCount: 40, emptyToolCallOutputs: 4, metricSource: .real)
        )

        XCTAssertEqual(verdict.status, "blocked")
        XCTAssertFalse(verdict.passed)
        XCTAssertEqual(verdict.metricSource, .real)
        XCTAssertNil(verdict.runAuthorizationReference)
        XCTAssertEqual(verdict.reason, "real_run_authorization_reference_invalid")
    }

    func testTinyAblationRealMetricSourceWithWrongReferenceIsBlocked() {
        let verdict = C5TinyAblationHarness().evaluate(
            metrics: C5TinyAblationMetrics(
                sampleCount: 40,
                emptyToolCallOutputs: 4,
                metricSource: .real,
                runAuthorizationReference: "/tmp/not-the-signed-r7-run-auth.md"
            )
        )

        XCTAssertEqual(verdict.status, "blocked")
        XCTAssertFalse(verdict.passed)
        XCTAssertEqual(verdict.metricSource, .real)
        XCTAssertEqual(verdict.runAuthorizationReference, "/tmp/not-the-signed-r7-run-auth.md")
        XCTAssertEqual(verdict.reason, "real_run_authorization_reference_invalid")
    }

    func testTinyAblationRealMetricSourceWithSignedReferencePassesWhenBelowTarget() {
        let verdict = C5TinyAblationHarness().evaluate(
            metrics: C5TinyAblationMetrics(
                sampleCount: 40,
                emptyToolCallOutputs: 4,
                metricSource: .real,
                runAuthorizationReference: signedRunAuthorizationReference
            )
        )

        XCTAssertEqual(verdict.status, "real_run_pass")
        XCTAssertTrue(verdict.passed)
        XCTAssertEqual(verdict.metricSource, .real)
        XCTAssertEqual(verdict.runAuthorizationReference, signedRunAuthorizationReference)
        XCTAssertEqual(verdict.reason, "real_run_metric_target_met")
        XCTAssertEqual(verdict.baselineEmptyToolCallOutputs, 28)
        XCTAssertEqual(verdict.baselineDenominator, 34)
        XCTAssertEqual(verdict.targetEmptyToolCallOutputsStrictlyBelow, 5)
    }

    func testTinyAblationRealMetricSourceWithSignedReferenceBlocksAtStrictThreshold() {
        let verdict = C5TinyAblationHarness().evaluate(
            metrics: C5TinyAblationMetrics(
                sampleCount: 40,
                emptyToolCallOutputs: 5,
                metricSource: .real,
                runAuthorizationReference: signedRunAuthorizationReference
            )
        )

        XCTAssertEqual(verdict.status, "blocked")
        XCTAssertFalse(verdict.passed)
        XCTAssertEqual(verdict.metricSource, .real)
        XCTAssertEqual(verdict.runAuthorizationReference, signedRunAuthorizationReference)
        XCTAssertEqual(verdict.reason, "empty_tool_call_outputs_not_below_target")
    }

    func testTinyAblationRealMetricSourceBlocksOutOfRangeSampleCount() {
        let low = C5TinyAblationHarness().evaluate(
            metrics: C5TinyAblationMetrics(
                sampleCount: 19,
                emptyToolCallOutputs: 4,
                metricSource: .real,
                runAuthorizationReference: signedRunAuthorizationReference
            )
        )
        let high = C5TinyAblationHarness().evaluate(
            metrics: C5TinyAblationMetrics(
                sampleCount: 51,
                emptyToolCallOutputs: 4,
                metricSource: .real,
                runAuthorizationReference: signedRunAuthorizationReference
            )
        )

        XCTAssertEqual(low.status, "blocked")
        XCTAssertFalse(low.passed)
        XCTAssertEqual(low.reason, "real_run_sample_count_out_of_range")
        XCTAssertEqual(high.status, "blocked")
        XCTAssertFalse(high.passed)
        XCTAssertEqual(high.reason, "real_run_sample_count_out_of_range")
    }
}
