import Foundation

public struct C5TinyAblationMetrics: Codable, Equatable, Sendable {
    public var sampleCount: Int
    public var emptyToolCallOutputs: Int
    public var metricSource: C5TinyAblationMetricSource

    public init(sampleCount: Int, emptyToolCallOutputs: Int, metricSource: C5TinyAblationMetricSource = .fixture) {
        self.sampleCount = sampleCount
        self.emptyToolCallOutputs = emptyToolCallOutputs
        self.metricSource = metricSource
    }

    enum CodingKeys: String, CodingKey {
        case sampleCount = "sample_count"
        case emptyToolCallOutputs = "empty_tool_call_outputs"
        case metricSource = "metric_source"
    }
}

public enum C5TinyAblationMetricSource: String, Codable, Equatable, Sendable {
    case mock
    case fixture
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

    enum CodingKeys: String, CodingKey {
        case status
        case passed
        case reason
        case metricSource = "metric_source"
        case baselineEmptyToolCallOutputs = "baseline_empty_tool_call_outputs"
        case baselineDenominator = "baseline_denominator"
        case targetEmptyToolCallOutputsStrictlyBelow = "target_empty_tool_call_outputs_strictly_below"
        case stepwiseAxes = "stepwise_axes"
    }
}

public struct C5TinyAblationHarness: Sendable {
    public static let baselineEmptyToolCallOutputs = 28
    public static let baselineDenominator = 34
    public static let targetEmptyToolCallOutputsStrictlyBelow = 5
    public static let allowedDryRunSampleRange = 20...50
    public static let stepwiseAxes = C5HeldOutOverlapAxis.allCases.map(\.rawValue)

    public init() {}

    // R7: tooling-only dry-run. Real 20-50 sample overfit ablation is training and remains BLOCKED.
    public func evaluate(metrics: C5TinyAblationMetrics) -> C5TinyAblationVerdict {
        guard metrics.metricSource != .realBlocked else {
            return C5TinyAblationVerdict(
                status: "blocked",
                passed: false,
                reason: "real_ablation_blocked_by_r7",
                metricSource: metrics.metricSource,
                baselineEmptyToolCallOutputs: Self.baselineEmptyToolCallOutputs,
                baselineDenominator: Self.baselineDenominator,
                targetEmptyToolCallOutputsStrictlyBelow: Self.targetEmptyToolCallOutputsStrictlyBelow,
                stepwiseAxes: Self.stepwiseAxes
            )
        }
        let sampleRangeOK = Self.allowedDryRunSampleRange.contains(metrics.sampleCount)
        let targetMet = metrics.emptyToolCallOutputs < Self.targetEmptyToolCallOutputsStrictlyBelow
        let passed = sampleRangeOK && targetMet
        let reason: String
        if !sampleRangeOK {
            reason = "dry_run_sample_count_out_of_range"
        } else if !targetMet {
            reason = "empty_tool_call_outputs_not_below_target"
        } else {
            reason = "dry_run_metric_target_met"
        }
        return C5TinyAblationVerdict(
            status: passed ? "dry_run_pass" : "blocked",
            passed: passed,
            reason: reason,
            metricSource: metrics.metricSource,
            baselineEmptyToolCallOutputs: Self.baselineEmptyToolCallOutputs,
            baselineDenominator: Self.baselineDenominator,
            targetEmptyToolCallOutputsStrictlyBelow: Self.targetEmptyToolCallOutputsStrictlyBelow,
            stepwiseAxes: Self.stepwiseAxes
        )
    }
}
