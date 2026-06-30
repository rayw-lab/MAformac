import Foundation

enum StateCellInteractionGesture: String, Equatable {
    case none
    case ring
    case stepper
    case toggle
    case badgeOptions = "badge_options"
}

enum StateCellInteractionWritebackPath: String, Equatable {
    case none
    case expandedFamilyCardToMockStore = "ExpandedFamilyCard->ContentView.applyMockTransition->DemoVehicleStateStore.applyMockTransition"
}

struct StateCellInteractionPolicy: Equatable {
    var stateKey: String
    var base: String
    var scope: String?
    var family: FamilyCardID?
    var primaryCellBase: String?
    var isPrimaryCell: Bool
    var uiValueType: UIValueType?
    var executionRange: ExecutionRange?
    var enumOptions: [String]
    var gesture: StateCellInteractionGesture
    var canWriteBack: Bool
    var writebackPath: StateCellInteractionWritebackPath
    var catalogReadback: String?
    var proofClass: StagePresentationProofClass
}

enum StateCellInteractionPolicyProjector {
    static func policy(
        for cell: DemoVehicleStateCell,
        catalog: StateCellPresentationCatalog = .shared,
        proofClass: StagePresentationProofClass = .localMock
    ) -> StateCellInteractionPolicy {
        let scopedKey = ScopedStateKey(cell.key)
        let base = scopedKey.base
        let family = FamilyCardIDMapper.familyCardID(forBase: base)
        let primaryCellBase = family.map { FamilyPrimaryCellMapper.primaryCellBase(for: $0) }
        let uiValueType = UIValueTypeMapper.mappedUIValueType(forBase: base)
        let executionRange = ValueRangeMapper.executionRange(forBase: base, catalog: catalog)
        let enumOptions = uiValueType == .badge ? BadgeOptionMapper.options(forBase: base, catalog: catalog) : []
        let canWriteBack = family != nil && canWriteBackToMockStore(
            uiValueType: uiValueType,
            executionRange: executionRange,
            enumOptions: enumOptions,
            base: base,
            catalog: catalog
        )
        let catalogReadback = catalog.renderReadback(
            stateKey: cell.key,
            scope: scopedKey.scope,
            value: cell.actualValue
        )

        return StateCellInteractionPolicy(
            stateKey: cell.key,
            base: base,
            scope: scopedKey.scope,
            family: family,
            primaryCellBase: primaryCellBase,
            isPrimaryCell: primaryCellBase == base,
            uiValueType: uiValueType,
            executionRange: executionRange,
            enumOptions: enumOptions,
            gesture: gesture(uiValueType: uiValueType, canWriteBack: canWriteBack),
            canWriteBack: canWriteBack,
            writebackPath: canWriteBack ? .expandedFamilyCardToMockStore : .none,
            catalogReadback: catalogReadback,
            proofClass: proofClass
        )
    }

    static func policies(
        for cells: [DemoVehicleStateCell],
        catalog: StateCellPresentationCatalog = .shared,
        proofClass: StagePresentationProofClass = .localMock
    ) -> [StateCellInteractionPolicy] {
        cells
            .map { policy(for: $0, catalog: catalog, proofClass: proofClass) }
            .sorted { $0.stateKey < $1.stateKey }
    }

    private static func canWriteBackToMockStore(
        uiValueType: UIValueType?,
        executionRange: ExecutionRange?,
        enumOptions: [String],
        base: String,
        catalog: StateCellPresentationCatalog
    ) -> Bool {
        switch uiValueType {
        case .dial, .percent, .stepper:
            return executionRange != nil
        case .toggle:
            return catalog.enumValues(for: base)?.count == 2
        case .badge:
            return !enumOptions.isEmpty
        case nil:
            return false
        }
    }

    private static func gesture(
        uiValueType: UIValueType?,
        canWriteBack: Bool
    ) -> StateCellInteractionGesture {
        guard canWriteBack else { return .none }
        switch uiValueType {
        case .dial, .percent:
            return .ring
        case .stepper:
            return .stepper
        case .toggle:
            return .toggle
        case .badge:
            return .badgeOptions
        case nil:
            return .none
        }
    }
}
