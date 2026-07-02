import Foundation

public struct C5TinyAblationMetrics: Codable, Equatable, Sendable {
    public var sampleCount: Int
    public var emptyToolCallOutputs: Int
    public var metricSource: C5TinyAblationMetricSource
    public var runAuthorizationReference: String?

    public init(
        sampleCount: Int,
        emptyToolCallOutputs: Int,
        metricSource: C5TinyAblationMetricSource = .fixture,
        runAuthorizationReference: String? = nil
    ) {
        self.sampleCount = sampleCount
        self.emptyToolCallOutputs = emptyToolCallOutputs
        self.metricSource = metricSource
        self.runAuthorizationReference = runAuthorizationReference
    }

    enum CodingKeys: String, CodingKey {
        case sampleCount = "sample_count"
        case emptyToolCallOutputs = "empty_tool_call_outputs"
        case metricSource = "metric_source"
        case runAuthorizationReference = "run_authorization_reference"
    }
}

public enum C5TinyAblationMetricSource: String, Codable, Equatable, Sendable {
    case mock
    case fixture
    case real
    case realBlocked = "real_blocked"
}

public struct C5TinyAblationVerdict: Codable, Equatable, Sendable {
    public var status: String
    public var passed: Bool
    public var reason: String
    public var metricSource: C5TinyAblationMetricSource
    public var baselineEmptyToolCallOutputs: Int
    public var baselineDenominator: Int
    public var targetEmptyToolCallOutputsStrictlyBelow: Int
    public var stepwiseAxes: [String]
    public var runAuthorizationReference: String?

    enum CodingKeys: String, CodingKey {
        case status
        case passed
        case reason
        case metricSource = "metric_source"
        case baselineEmptyToolCallOutputs = "baseline_empty_tool_call_outputs"
        case baselineDenominator = "baseline_denominator"
        case targetEmptyToolCallOutputsStrictlyBelow = "target_empty_tool_call_outputs_strictly_below"
        case stepwiseAxes = "stepwise_axes"
        case runAuthorizationReference = "run_authorization_reference"
    }
}

public struct C5TinyAblationHarness: Sendable {
    public static let baselineEmptyToolCallOutputs = 28
    public static let baselineDenominator = 34
    public static let targetEmptyToolCallOutputsStrictlyBelow = 5
    public static let allowedDryRunSampleRange = 20...50
    public static let authorizedRunAuthorizationReference = "/Users/wanglei/workspace/MAformac/docs/project/phase0/r-l17-human-review-evidence/R7-renewal-and-tiny-ablation-run-auth-DRAFT.md"
    public static let stepwiseAxes = C5HeldOutOverlapAxis.allCases.map(\.rawValue)

    public init() {}

    // R7: real tiny-ablation remains blocked unless it references the signed run-auth document.
    public func evaluate(metrics: C5TinyAblationMetrics) -> C5TinyAblationVerdict {
        guard metrics.metricSource != .realBlocked else {
            return verdict(metrics: metrics, status: "blocked", passed: false, reason: "real_ablation_blocked_by_r7")
        }
        if metrics.metricSource == .real,
           metrics.runAuthorizationReference != Self.authorizedRunAuthorizationReference {
            return verdict(metrics: metrics, status: "blocked", passed: false, reason: "real_run_authorization_reference_invalid")
        }
        let sampleRangeOK = Self.allowedDryRunSampleRange.contains(metrics.sampleCount)
        let targetMet = metrics.emptyToolCallOutputs < Self.targetEmptyToolCallOutputsStrictlyBelow
        let passed = sampleRangeOK && targetMet
        let reason: String
        if !sampleRangeOK {
            reason = "\(reasonPrefix(for: metrics.metricSource))_sample_count_out_of_range"
        } else if !targetMet {
            reason = "empty_tool_call_outputs_not_below_target"
        } else {
            reason = "\(reasonPrefix(for: metrics.metricSource))_metric_target_met"
        }

        let passStatus = metrics.metricSource == .real ? "real_run_pass" : "dry_run_pass"
        return verdict(
            metrics: metrics,
            status: passed ? passStatus : "blocked",
            passed: passed,
            reason: reason
        )
    }

    private func verdict(metrics: C5TinyAblationMetrics, status: String, passed: Bool, reason: String) -> C5TinyAblationVerdict {
        C5TinyAblationVerdict(
            status: status,
            passed: passed,
            reason: reason,
            metricSource: metrics.metricSource,
            baselineEmptyToolCallOutputs: Self.baselineEmptyToolCallOutputs,
            baselineDenominator: Self.baselineDenominator,
            targetEmptyToolCallOutputsStrictlyBelow: Self.targetEmptyToolCallOutputsStrictlyBelow,
            stepwiseAxes: Self.stepwiseAxes,
            runAuthorizationReference: metrics.runAuthorizationReference
        )
    }

    private func reasonPrefix(for metricSource: C5TinyAblationMetricSource) -> String {
        metricSource == .real ? "real_run" : "dry_run"
    }
}
