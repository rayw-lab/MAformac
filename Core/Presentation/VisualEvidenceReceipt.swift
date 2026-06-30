import Foundation

enum VisualEvidenceKind: String, CaseIterable, Codable, Equatable, Sendable {
    case tapStep = "tap_step"
    case toggle
    case badgeCycle = "badge_cycle"
    case continuousDrag = "continuous_drag"
    case terminalVisualOnly = "terminal_visual_only"

    var isAutomatedTapEvidence: Bool {
        switch self {
        case .tapStep, .toggle, .badgeCycle:
            return true
        case .continuousDrag, .terminalVisualOnly:
            return false
        }
    }

    var provesProcessMutationWithoutOperator: Bool {
        switch self {
        case .tapStep, .toggle, .badgeCycle:
            return true
        case .continuousDrag, .terminalVisualOnly:
            return false
        }
    }
}

struct VisualEvidenceSample: Equatable {
    let id: String
    let label: String
    let family: FamilyCardID
    let evidenceKind: VisualEvidenceKind
    let cellKey: String
    let beforeValue: String
    let afterValue: String
    let expectedValueType: UIValueType

    var base: String {
        ScopedStateKey(cellKey).base
    }
}

enum VisualEvidenceSampleMatrix {
    static let automatedActionSamples: [VisualEvidenceSample] = [
        VisualEvidenceSample(
            id: "fan-speed-step",
            label: "风量 stepper tap",
            family: .ac,
            evidenceKind: .tapStep,
            cellKey: "ac.fan_speed[主驾]",
            beforeValue: "1",
            afterValue: "2",
            expectedValueType: .stepper
        ),
        VisualEvidenceSample(
            id: "ac-power-toggle",
            label: "空调开关 toggle tap",
            family: .ac,
            evidenceKind: .toggle,
            cellKey: "ac.power",
            beforeValue: "off",
            afterValue: "on",
            expectedValueType: .toggle
        ),
        VisualEvidenceSample(
            id: "ambient-color-badge-cycle",
            label: "灯光色彩 badge cycle tap",
            family: .ambient,
            evidenceKind: .badgeCycle,
            cellKey: "ambient.color",
            beforeValue: "白",
            afterValue: "浅蓝紫",
            expectedValueType: .badge
        )
    ]

    static let representativeFamilySamples: [VisualEvidenceSample] = [
        VisualEvidenceSample(
            id: "fan-representative",
            label: "风量代表样本",
            family: .ac,
            evidenceKind: .tapStep,
            cellKey: "ac.fan_speed[主驾]",
            beforeValue: "1",
            afterValue: "2",
            expectedValueType: .stepper
        ),
        VisualEvidenceSample(
            id: "seat-representative",
            label: "座椅代表样本",
            family: .seat,
            evidenceKind: .tapStep,
            cellKey: "seat.heat_level[主驾]",
            beforeValue: "0",
            afterValue: "1",
            expectedValueType: .stepper
        ),
        VisualEvidenceSample(
            id: "window-representative",
            label: "车窗代表样本",
            family: .window,
            evidenceKind: .tapStep,
            cellKey: "window.position[主驾]",
            beforeValue: "0",
            afterValue: "20",
            expectedValueType: .percent
        ),
        VisualEvidenceSample(
            id: "light-representative",
            label: "灯光代表样本",
            family: .ambient,
            evidenceKind: .badgeCycle,
            cellKey: "ambient.color",
            beforeValue: "白",
            afterValue: "浅蓝紫",
            expectedValueType: .badge
        )
    ]
}
