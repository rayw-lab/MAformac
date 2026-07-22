import Foundation

public enum ToolContractIRFrameBridge {
    public static func frame(
        from ir: ToolContractIR,
        traceID: String,
        rawCall: C6ToolCall,
        projectedSlotKeys: Set<String> = []
    ) throws -> ToolCallFrame {
        guard !ir.device.isEmpty, !ir.actionPrimitive.isEmpty else {
            throw DDomainToolPlanFailure.bridgeFailed(ir.sourceToolName)
        }
        // value.* (incl. sourceUnit on ContractValue) is carried via `ir.value`, not slot projection.
        let valueArgumentKeys: Set<String> = ["temperature", "fanSpeed", "value", "value.type", "value.sourceUnit"]
        let nonValueSlotKeys = Set(ir.slots.keys).subtracting(valueArgumentKeys)
        let discardedNonValueSlots = nonValueSlotKeys.subtracting(projectedSlotKeys)
        // G2: non-value slots must not be silently dropped by projection.
        if !discardedNonValueSlots.isEmpty {
            throw DDomainToolPlanFailure.bridgeFailed(ir.sourceToolName)
        }
        let projectedSlots = ir.slots.filter {
            projectedSlotKeys.contains($0.key) || valueArgumentKeys.contains($0.key)
        }
        return ToolCallFrame(
            traceID: traceID,
            agentID: "vehicle-control",
            capabilityID: "cabin.\(ir.device)",
            toolName: ir.sourceToolName,
            device: ir.device,
            actionPrimitive: ir.actionPrimitive,
            slots: projectedSlots,
            value: ir.value, // G1: sourceUnit end-to-end passthrough on ContractValue
            candidateSource: .modelRouter,
            rawPayload: redactedRawPayload(
                for: rawCall,
                slotProjected: !projectedSlotKeys.isEmpty && projectedSlotKeys != Set(ir.slots.keys)
            ),
            doNotAutoPowerOn: ir.doNotAutoPowerOn
        )
    }

    private static func redactedRawPayload(for call: C6ToolCall, slotProjected: Bool) -> JSONValue {
        let digestInput = "\(call.name)|\(call.arguments.sorted { $0.key < $1.key })"
        return .object([
            "tool_name": .string(call.name),
            "raw_arguments_sha256": .string(C6Hash.sha256Hex(Data(digestInput.utf8))),
            "slot_projected": .bool(slotProjected)
        ])
    }
}
