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
        let projectedSlots = ir.slots.filter { projectedSlotKeys.contains($0.key) }
        let valueArgumentKeys: Set<String> = ["temperature", "fanSpeed", "value", "value.type"]
        let projectedOutSlotKeys = Set(ir.slots.keys)
            .subtracting(projectedSlotKeys)
            .subtracting(valueArgumentKeys)
        return ToolCallFrame(
            traceID: traceID,
            agentID: "vehicle-control",
            capabilityID: "cabin.\(ir.device)",
            toolName: ir.sourceToolName,
            device: ir.device,
            actionPrimitive: ir.actionPrimitive,
            slots: projectedSlots,
            value: ir.value,
            candidateSource: .modelRouter,
            rawPayload: redactedRawPayload(for: rawCall, slotProjected: !projectedOutSlotKeys.isEmpty),
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
