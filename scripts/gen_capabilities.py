#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

import yaml


REPO_ROOT = Path(__file__).resolve().parents[1]
CAPABILITIES_PATH = REPO_ROOT / "contracts" / "capabilities.yaml"
AGENTS_PATH = REPO_ROOT / "contracts" / "agents.yaml"
OUTPUT_PATH = REPO_ROOT / "Core" / "Generated" / "GeneratedCapabilityCatalog.swift"


SURFACE_POLICY_CASES = {
    "primary_panel": ".primaryPanel",
    "overlay_card": ".overlayCard",
    "split_panel": ".splitPanel",
    "fullscreen": ".fullscreen",
}


class ContractLoader(yaml.SafeLoader):
    pass


for key, resolvers in list(ContractLoader.yaml_implicit_resolvers.items()):
    ContractLoader.yaml_implicit_resolvers[key] = [
        (tag, regexp)
        for tag, regexp in resolvers
        if tag != "tag:yaml.org,2002:bool"
    ]


def swift_string(value: object) -> str:
    return json.dumps(str(value), ensure_ascii=False)


def swift_bool(value: object) -> str:
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, str):
        normalized = value.lower()
        if normalized == "true":
            return "true"
        if normalized == "false":
            return "false"
    return "true" if bool(value) else "false"


def swift_optional_int(value: object) -> str:
    if value is None:
        return "nil"
    return str(int(value))


def swift_string_array(values: list[object] | None) -> str:
    values = values or []
    return "[" + ", ".join(swift_string(value) for value in values) + "]"


def swift_state_transforms(transforms: list[dict[str, object]] | None) -> str:
    transforms = transforms or []
    if not transforms:
        return "[]"
    entries = []
    for t in transforms:
        unchanged_skip = swift_bool(t.get("unchanged_skip", False))
        ambient_composite = swift_bool(t.get("ambient_composite", False))
        entries.append(
            f"GeneratedStateTransform("
            f"field: {swift_string(t['field'])}, "
            f"stateCell: {swift_string(t['state_cell'])}, "
            f"unchangedSkip: {unchanged_skip}, "
            f"ambientComposite: {ambient_composite})"
        )
    return "[" + ", ".join(entries) + "]"


def swift_range_dict(values: dict[str, dict[str, int]] | None) -> str:
    values = values or {}
    if not values:
        return "[:]"
    entries = []
    for name in sorted(values):
        range_value = values[name]
        entries.append(
            f"{swift_string(name)}: GeneratedIntegerRange("
            f"minimum: {int(range_value['minimum'])}, "
            f"maximum: {int(range_value['maximum'])})"
        )
    return "[" + ", ".join(entries) + "]"


def swift_enum_dict(values: dict[str, list[object]] | None) -> str:
    values = values or {}
    if not values:
        return "[:]"
    entries = [
        f"{swift_string(name)}: {swift_string_array(values[name])}"
        for name in sorted(values)
    ]
    return "[" + ", ".join(entries) + "]"


def swift_property_dict(properties: dict[str, dict[str, object]] | None) -> str:
    properties = properties or {}
    if not properties:
        return "[:]"
    entries = []
    for name in sorted(properties):
        prop = properties[name]
        entries.append(
            f"{swift_string(name)}: GeneratedToolProperty("
            f"type: {swift_string(prop.get('type', ''))}, "
            f"enumValues: {swift_string_array(prop.get('enum'))}, "
            f"minimum: {swift_optional_int(prop.get('minimum'))}, "
            f"maximum: {swift_optional_int(prop.get('maximum'))})"
        )
    return "[" + ", ".join(entries) + "]"


def surface_policy_literal(raw_value: str) -> str:
    if raw_value not in SURFACE_POLICY_CASES:
        raise ValueError(f"Unsupported surface_policy: {raw_value}")
    return SURFACE_POLICY_CASES[raw_value]


def capability_literal(capability: dict[str, object]) -> str:
    tool_schema = capability["tool_schema"]
    parameters = tool_schema["parameters"]
    reference_binding = capability["reference_binding"]
    execution = capability["execution"]
    demo_guard = capability["demo_guard"]

    return f"""        GeneratedCapabilityContract(
            id: {swift_string(capability["id"])},
            status: {swift_string(capability["status"])},
            displayZH: {swift_string(capability["display_zh"])},
            toolSchema: GeneratedToolSchema(
                name: {swift_string(tool_schema["name"])},
                description: {swift_string(tool_schema["description"])},
                properties: {swift_property_dict(parameters.get("properties"))},
                required: {swift_string_array(parameters.get("required"))}
            ),
            referenceBinding: GeneratedReferenceBinding(
                readable: {swift_bool(reference_binding.get("readable"))},
                writable: {swift_bool(reference_binding.get("writable"))},
                valueType: {swift_string(reference_binding.get("type", ""))},
                allowedValues: {swift_string_array(reference_binding.get("allowed_values"))}
            ),
            execution: GeneratedExecutionRule(
                connector: {swift_string(execution.get("connector", ""))},
                mockBehavior: {swift_string(execution.get("mock_behavior", ""))},
                stateCell: {swift_string(execution.get("state_cell", ""))},
                relatedStateCells: {swift_string_array(execution.get("related_state_cells"))},
                idempotent: {swift_bool(execution.get("idempotent"))},
                exclusiveBus: {swift_string(execution.get("exclusive_bus", ""))},
                stateTransforms: {swift_state_transforms(execution.get("state_transforms"))}
            ),
            demoGuard: GeneratedDemoGuardRule(
                riskLevel: {swift_string(demo_guard.get("risk_level", ""))},
                confirmPolicy: {swift_string(demo_guard.get("confirm_policy", ""))},
                writable: {swift_bool(demo_guard.get("writable"))},
                ranges: {swift_range_dict(demo_guard.get("range"))},
                enumValues: {swift_enum_dict(demo_guard.get("enum"))},
                preconditions: {swift_string_array(demo_guard.get("preconditions"))}
            )
        )"""


def agent_literal(agent: dict[str, object]) -> str:
    return f"""        GeneratedAgentContract(
            id: {swift_string(agent["id"])},
            displayZH: {swift_string(agent["display_zh"])},
            connector: {swift_string(agent["connector"])},
            enabled: {swift_bool(agent["enabled"])},
            availability: {swift_string(agent["availability"])},
            capabilityIDs: {swift_string_array(agent.get("capability_ids"))},
            surfacePolicy: {surface_policy_literal(agent["surface_policy"])}
        )"""


def swift_string_dict(values: dict[str, str]) -> str:
    if not values:
        return "[:]"
    entries = [
        f"{swift_string(key)}: {swift_string(values[key])}"
        for key in sorted(values)
    ]
    return "[" + ", ".join(entries) + "]"


def swift_surface_policy_dict(values: dict[str, str]) -> str:
    if not values:
        return "[:]"
    entries = [
        f"{swift_string(key)}: {surface_policy_literal(values[key])}"
        for key in sorted(values)
    ]
    return "[" + ", ".join(entries) + "]"


def build() -> str:
    capabilities_doc = yaml.load(CAPABILITIES_PATH.read_text(encoding="utf-8"), Loader=ContractLoader)
    agents_doc = yaml.load(AGENTS_PATH.read_text(encoding="utf-8"), Loader=ContractLoader)
    capabilities = capabilities_doc["capabilities"]
    agents = agents_doc["agents"]

    tool_name_to_capability_id = {
        capability["tool_schema"]["name"]: capability["id"]
        for capability in capabilities
    }

    capability_id_to_agent_id: dict[str, str] = {}
    capability_id_to_surface_policy: dict[str, str] = {}
    for agent in agents:
        for capability_id in agent.get("capability_ids", []):
            capability_id_to_agent_id[capability_id] = agent["id"]
            capability_id_to_surface_policy[capability_id] = agent["surface_policy"]

    tool_name_to_agent_id = {
        tool_name: capability_id_to_agent_id[capability_id]
        for tool_name, capability_id in tool_name_to_capability_id.items()
    }
    tool_name_to_surface_policy = {
        tool_name: capability_id_to_surface_policy[capability_id]
        for tool_name, capability_id in tool_name_to_capability_id.items()
    }

    capability_entries = ",\n".join(capability_literal(capability) for capability in capabilities)
    agent_entries = ",\n".join(agent_literal(agent) for agent in agents)

    return f"""// GENERATED from contracts/capabilities.yaml and contracts/agents.yaml — do not edit.
import Foundation

public struct GeneratedIntegerRange: Equatable, Sendable {{
    public let minimum: Int
    public let maximum: Int
}}

public struct GeneratedToolProperty: Equatable, Sendable {{
    public let type: String
    public let enumValues: [String]
    public let minimum: Int?
    public let maximum: Int?
}}

public struct GeneratedToolSchema: Equatable, Sendable {{
    public let name: String
    public let description: String
    public let properties: [String: GeneratedToolProperty]
    public let required: [String]
}}

public struct GeneratedReferenceBinding: Equatable, Sendable {{
    public let readable: Bool
    public let writable: Bool
    public let valueType: String
    public let allowedValues: [String]
}}

public struct GeneratedStateTransform: Equatable, Sendable {{
    public let field: String
    public let stateCell: String
    /// When true and the field value equals "unchanged", skip writing this cell.
    public let unchangedSkip: Bool
    /// When true, apply ambient composite logic (power:on → write color; power:off → write "off").
    public let ambientComposite: Bool
}}

public struct GeneratedExecutionRule: Equatable, Sendable {{
    public let connector: String
    public let mockBehavior: String
    public let stateCell: String
    public let relatedStateCells: [String]
    public let idempotent: Bool
    public let exclusiveBus: String
    /// Declarative field→state_cell mapping for multi-cell mock transitions.
    public let stateTransforms: [GeneratedStateTransform]
}}

public struct GeneratedDemoGuardRule: Equatable, Sendable {{
    public let riskLevel: String
    public let confirmPolicy: String
    public let writable: Bool
    public let ranges: [String: GeneratedIntegerRange]
    public let enumValues: [String: [String]]
    public let preconditions: [String]
}}

public struct GeneratedCapabilityContract: Equatable, Sendable, Identifiable {{
    public let id: String
    public let status: String
    public let displayZH: String
    public let toolSchema: GeneratedToolSchema
    public let referenceBinding: GeneratedReferenceBinding
    public let execution: GeneratedExecutionRule
    public let demoGuard: GeneratedDemoGuardRule
}}

public struct GeneratedAgentContract: Equatable, Sendable, Identifiable {{
    public let id: String
    public let displayZH: String
    public let connector: String
    public let enabled: Bool
    public let availability: String
    public let capabilityIDs: [String]
    public let surfacePolicy: SurfacePolicy
}}

public enum GeneratedCapabilityCatalog {{
    public static let capabilities: [GeneratedCapabilityContract] = [
{capability_entries}
    ]

    public static let agents: [GeneratedAgentContract] = [
{agent_entries}
    ]

    public static let toolNameToCapabilityID: [String: String] = {swift_string_dict(tool_name_to_capability_id)}
    public static let capabilityIDToAgentID: [String: String] = {swift_string_dict(capability_id_to_agent_id)}
    public static let capabilityIDToSurfacePolicy: [String: SurfacePolicy] = {swift_surface_policy_dict(capability_id_to_surface_policy)}
    public static let toolNameToAgentID: [String: String] = {swift_string_dict(tool_name_to_agent_id)}
    public static let toolNameToSurfacePolicy: [String: SurfacePolicy] = {swift_surface_policy_dict(tool_name_to_surface_policy)}

    public static func capability(id: String) -> GeneratedCapabilityContract? {{
        capabilities.first {{ $0.id == id }}
    }}

    public static func capability(toolName: String) -> GeneratedCapabilityContract? {{
        guard let capabilityID = toolNameToCapabilityID[toolName] else {{
            return nil
        }}
        return capability(id: capabilityID)
    }}
}}
"""


def main() -> None:
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_PATH.write_text(build(), encoding="utf-8")


if __name__ == "__main__":
    main()
