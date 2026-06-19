import Foundation

public enum DemoActionError: Error, Equatable {
    case unsupportedTool(String)
    case missingArgument(String)
    case guardDenied(String)
    case allowedValueViolation(stateCell: String, value: String)
}

public struct DemoActionExecutor: Sendable {
    public init() {}

    @MainActor
    public func applyMockTransition(_ frame: ToolCallFrame, store: DemoVehicleStateStore) throws -> DemoActionReadback {
        guard let capability = GeneratedCapabilityCatalog.capability(toolName: frame.toolName) else {
            throw DemoActionError.unsupportedTool(frame.toolName)
        }

        switch capability.execution.mockBehavior {
        case "update_mock_state":
            return try applyTransforms(frame: frame, capability: capability, store: store)
        case "read_mock_state":
            return store.readback(for: capability.execution.stateCell)
        default:
            throw DemoActionError.unsupportedTool(frame.toolName)
        }
    }

    // MARK: - Transform-driven multi-cell execution

    @MainActor
    private func applyTransforms(
        frame: ToolCallFrame,
        capability: GeneratedCapabilityContract,
        store: DemoVehicleStateStore
    ) throws -> DemoActionReadback {
        let transforms = capability.execution.stateTransforms

        // Fall back to legacy single-cell path when no transforms are defined.
        // This preserves compatibility with capabilities that have not yet defined
        // state_transforms in capabilities.yaml.
        if transforms.isEmpty {
            let value = try legacyDesiredValue(from: frame, capability: capability)
            return store.applyMockTransition(
                DemoMockTransition(key: capability.execution.stateCell, desiredValue: value)
            )
        }

        var primaryTransition: DemoMockTransition?
        var secondaryTransitions: [DemoMockTransition] = []

        for transform in transforms {
            guard let fieldValue = frame.arguments[transform.field] else {
                // Field not present in arguments — skip (optional field).
                continue
            }

            // Determine the value to write for this state cell.
            let writeValue: String
            if transform.ambientComposite {
                // Composite ambient light semantic:
                //   power:off  → write "off" to lighting.ambient
                //   power:on   → write color field value if present, else "on"
                //   power:unchanged → skip
                guard let scalarPower = fieldValue.scalarString else { continue }
                if scalarPower == "unchanged" { continue }
                if scalarPower == "off" {
                    writeValue = "off"
                } else {
                    // power:on — use color if provided, otherwise "on" (edge case)
                    if let colorValue = frame.arguments["color"]?.scalarString {
                        writeValue = colorValue
                    } else {
                        writeValue = "on"
                    }
                }
            } else {
                guard let scalar = fieldValue.scalarString else { continue }
                // unchanged_skip: skip writing this cell when field value is "unchanged"
                if transform.unchangedSkip, scalar == "unchanged" { continue }
                writeValue = scalar
            }

            // F3: validate write value against reference_binding.allowed_values
            let allowedValues = capability.referenceBinding.allowedValues
            if !allowedValues.isEmpty, !allowedValues.contains(writeValue) {
                // Only enforce allowed_values on the primary state_cell (the readback anchor)
                if transform.stateCell == capability.execution.stateCell {
                    throw DemoActionError.allowedValueViolation(stateCell: transform.stateCell, value: writeValue)
                }
                // Secondary cells (e.g. hvac.temperature) have their own valid ranges — skip check
            }

            let transition = DemoMockTransition(key: transform.stateCell, desiredValue: writeValue)

            if transform.stateCell == capability.execution.stateCell {
                primaryTransition = transition
            } else {
                secondaryTransitions.append(transition)
            }
        }

        guard let primary = primaryTransition else {
            // Primary cell was skipped (e.g. power:unchanged). Apply any secondary transitions
            // (e.g. target_temperature still writes hvac.temperature), then return current
            // readback of the primary state cell without modifying it.
            for transition in secondaryTransitions {
                store.applyMockTransition(transition)
            }
            return store.readback(for: capability.execution.stateCell)
        }

        return store.applyMockTransitions(primary: primary, secondary: secondaryTransitions)
    }

    // MARK: - Legacy fallback (capabilities without state_transforms)

    private func legacyDesiredValue(
        from frame: ToolCallFrame,
        capability: GeneratedCapabilityContract
    ) throws -> String {
        for key in capability.toolSchema.required {
            if let value = frame.arguments[key]?.scalarString {
                return value
            }
        }
        throw DemoActionError.missingArgument(capability.toolSchema.required.first ?? "value")
    }
}

