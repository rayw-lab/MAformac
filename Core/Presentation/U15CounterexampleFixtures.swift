import Foundation

struct U15CounterexampleFixture: Equatable {
    let id: String
    let title: String
    let resultKind: DemoRuntimeResultKind
    let snapshot: StagePresentationSnapshot
    let proofIntent: String
}

enum U15CounterexampleFixtures {
    static let expectedResultKinds: [DemoRuntimeResultKind] = [
        .clarifyMissingSlot,
        .refusalNoAvailableTool,
        .refusalSafetyOrPolicy,
        .partialAcceptPartialRefuse
    ]

    static let all: [U15CounterexampleFixture] = expectedResultKinds.map(fixture)

    private static func fixture(for kind: DemoRuntimeResultKind) -> U15CounterexampleFixture {
        let entry = DemoRuntimeResultPresentationMatrix.entry(for: kind)

        switch kind {
        case .clarifyMissingSlot:
            return makeFixture(
                id: "clarify-missing-slot",
                title: "缺槽追问",
                resultKind: kind,
                cells: [
                    DemoVehicleStateCell(
                        key: "window.position[待确认]",
                        actualValue: "50",
                        revision: 1,
                        visualState: entry.visualState
                    )
                ],
                activeCells: [.window: "window.position[待确认]"],
                proofIntent: "参数缺槽时必须呈现可继续的追问，不误染成成功。"
            )
        case .refusalNoAvailableTool:
            return makeFixture(
                id: "refusal-no-available-tool",
                title: "无可用工具拒绝",
                resultKind: kind,
                cells: [
                    DemoVehicleStateCell(
                        key: "fragrance.power",
                        actualValue: "off",
                        revision: 1,
                        visualState: entry.visualState
                    )
                ],
                activeCells: [.fragrance: "fragrance.power"],
                refusedCell: "fragrance.power",
                proofIntent: "能力不在 allowlist 时必须硬拒绝，不伪造成执行失败。"
            )
        case .refusalSafetyOrPolicy:
            return makeFixture(
                id: "refusal-safety-policy",
                title: "安全策略拒绝",
                resultKind: kind,
                cells: [
                    DemoVehicleStateCell(
                        key: "door.tailgate_height[尾门]",
                        actualValue: "0",
                        revision: 1,
                        visualState: entry.visualState
                    )
                ],
                activeCells: [.door: "door.tailgate_height[尾门]"],
                refusedCell: "door.tailgate_height[尾门]",
                context: DemoContext(
                    vehicle: DemoVehicleContext(speed: 30, gear: "D"),
                    environment: DemoEnvironmentContext(weather: "晴", timePeriod: "日间")
                ),
                proofIntent: "安全门控拒绝必须显著区分于普通不可用能力。"
            )
        case .partialAcceptPartialRefuse:
            return makeFixture(
                id: "partial-accept-partial-refuse",
                title: "部分接受部分拒绝",
                resultKind: kind,
                cells: [
                    DemoVehicleStateCell(
                        key: "ambient.color",
                        actualValue: "浅蓝紫",
                        revision: 2,
                        visualState: .satisfied
                    ),
                    DemoVehicleStateCell(
                        key: "sunroof.position[全景天窗]",
                        actualValue: "0",
                        revision: 1,
                        visualState: entry.visualState
                    )
                ],
                activeCells: [
                    .ambient: "ambient.color",
                    .sunroofShade: "sunroof.position[全景天窗]"
                ],
                refusedCell: "sunroof.position[全景天窗]",
                proofIntent: "多意图中成功和拒绝必须共存呈现，不把局部失败吞掉。"
            )
        case .acceptedToolCall, .alreadyStateNoop, .runtimeError, .cancelled:
            preconditionFailure("U15 fixture only covers counterexample result kinds: \(kind.rawValue)")
        }
    }

    private static func makeFixture(
        id: String,
        title: String,
        resultKind: DemoRuntimeResultKind,
        cells: [DemoVehicleStateCell],
        activeCells: [FamilyCardID: String],
        refusedCell: String? = nil,
        context: DemoContext = .idle,
        proofIntent: String
    ) -> U15CounterexampleFixture {
        let entry = DemoRuntimeResultPresentationMatrix.entry(for: resultKind)
        let snapshot = StagePresentationSnapshot(
            traceId: "u15-\(id)",
            storeCells: cells,
            activeCells: activeCells,
            refusedCell: refusedCell,
            scopeOrigins: Dictionary(uniqueKeysWithValues: cells.map { ($0.key, ScopeOrigin.explicit) }),
            context: context,
            orbState: .think,
            voiceState: entry.ttsState,
            dialogText: entry.dialogText,
            readbacks: [],
            resultKind: resultKind,
            proofClass: .staticPreview
        )

        return U15CounterexampleFixture(
            id: id,
            title: title,
            resultKind: resultKind,
            snapshot: snapshot,
            proofIntent: proofIntent
        )
    }
}
