import Foundation

/// `ExecutionRange` 的 UIUE 控件渲染适配（min/max/step 由 A2 `Core/Contracts/ContractLookups.swift` 定义，
/// 此处只加控件需要的 computed）。🔴 §28 一手源 + derivation 铁律2：复用 A2 类型 + A2 单一解析，**不重复定义/不重复解析**。
extension ExecutionRange {
    /// Gauge value 闭区间（Double；防 min>max 异常）。
    var closed: ClosedRange<Double> { Double(min)...Double(Swift.max(min, max)) }
    /// stepper 离散档数（(max-min)/step；step≤0 返 0）。
    var stepCount: Int { step > 0 ? (max - min) / step : 0 }
}

/// base → 控件数值范围（dial/percent/stepper 用）；从 contract `execution_range` 读 = 真 SSOT。
/// enum/只读 base（无 execution_range，如 ac.power/ambient.color/vehicle.gear）返 nil（toggle/badge 不需范围）。
enum ValueRangeMapper {
    static func executionRange(forBase base: String, catalog: StateCellPresentationCatalog = .shared) -> ExecutionRange? {
        catalog.executionRange(for: base)
    }

    static func range(forBase base: String, catalog: StateCellPresentationCatalog = .shared) -> ClosedRange<Double>? {
        catalog.executionRange(for: base)?.closed
    }

    static func stepCount(forBase base: String, catalog: StateCellPresentationCatalog = .shared) -> Int {
        catalog.executionRange(for: base)?.stepCount ?? 0
    }

    /// 钳制实际值到值域（防 Gauge value 越界异常渲染）；无 range 的 base 原样返回。
    static func clamp(_ value: Double, forBase base: String, catalog: StateCellPresentationCatalog = .shared) -> Double {
        guard let r = range(forBase: base, catalog: catalog) else { return value }
        return value.clamped(to: r)
    }
}

extension Double {
    /// 钳制到闭区间（Gauge value 越界会异常渲染/裁切）。
    func clamped(to range: ClosedRange<Double>) -> Double {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
