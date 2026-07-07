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
            rawPayload: redactedRawPayload(for: rawCall)
        )
    }

    private static func redactedRawPayload(for call: C6ToolCall) -> JSONValue {
        let digestInput = "\(call.name)|\(call.arguments.sorted { $0.key < $1.key })"
        return .object([
            "tool_name": .string(call.name),
            "raw_arguments_sha256": .string(C6Hash.sha256Hex(Data(digestInput.utf8)))
        ])
    }
}
