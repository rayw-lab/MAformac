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
        let resolvedValue = try resolveSourceUnit(ir: ir, rawCall: rawCall)
        // Keep value.* keys out of slots once unit lives on ContractValue (unique field).
        let projectedSlots = ir.slots.filter {
            (projectedSlotKeys.contains($0.key) || valueArgumentKeys.contains($0.key))
                && $0.key != "value.sourceUnit"
        }
        return ToolCallFrame(
            traceID: traceID,
            agentID: "vehicle-control",
            capabilityID: "cabin.\(ir.device)",
            toolName: ir.sourceToolName,
            device: ir.device,
            actionPrimitive: ir.actionPrimitive,
            slots: projectedSlots,
            value: resolvedValue,
            candidateSource: .modelRouter,
            rawPayload: redactedRawPayload(
                for: rawCall,
                slotProjected: !projectedSlotKeys.isEmpty && projectedSlotKeys != Set(ir.slots.keys)
            ),
            doNotAutoPowerOn: ir.doNotAutoPowerOn
        )
    }

    /// End-to-end sourceUnit: prefer `ContractValue`, recover from slot/raw arg, conflict → fail-closed.
    private static func resolveSourceUnit(ir: ToolContractIR, rawCall: C6ToolCall) throws -> ContractValue {
        let fromValue = ir.value.sourceUnit
        let fromSlot = ir.slots["value.sourceUnit"].flatMap(ContractSourceUnit.init(rawValue:))
        let fromRaw = rawCall.arguments["value.sourceUnit"].flatMap(ContractSourceUnit.init(rawValue:))
        let present = [fromValue, fromSlot, fromRaw].compactMap { $0 }
        if Set(present).count > 1 {
            throw DDomainToolPlanFailure.bridgeFailed(ir.sourceToolName)
        }
        guard let unit = fromValue ?? fromSlot ?? fromRaw else {
            return ir.value
        }
        if ir.value.sourceUnit == unit {
            return ir.value
        }
        return ContractValue(
            ref: ir.value.ref,
            direct: ir.value.direct,
            offset: ir.value.offset,
            type: ir.value.type,
            sourceUnit: unit
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
