# Lens 3: A2 Codegen Design: Scaling 534 D-Domain Tools from Contract to Three-Level IR

# A2 Codegen Design: D-Domain Tool Directory with Three-Level Intermediate Representation

## Executive Summary

**Scope**: Translate 3990-row semantic-function-contract.jsonl (671 unique devices, 130+ action primitives, 3 service domains) into a declarative, generative architecture that produces 534+ named D-domain tools organized via a three-level IR pyramid: **Domain (空调, 座椅, 屏幕, ...) → ServiceGroup (carControl, cmd, airControl) → Tool (set_cabin_ac, adjust_seat_position, ...)**.

**Current State (Hardcoded Monolith)**:
- ToolContractCompiler has 6 hardcoded D-domain tools (lines 71-90 in ToolContractCompiler.swift)
- ToolContractNormalizer has 6 hardcoded switch cases + 8 device-specific handlers (145-286)
- ToolContractStateApplier has 8 device-specific state handlers (288-475)
- Python codegen produces only B_frame schema + 6 stub D_domain tools (no mapping IR)

**A2 Target (Data-Driven, Declarative)**:
- Generate DeviceFamily IR (space, 座椅, 屏幕, ...) with per-family tool routers
- Produce ToolRoute IR (map tool_name → [device + action_primitive permutations])
- Emit polymorphic normalizer dispatch table (device + action_primitive → normalizer fn ID)
- Generate state applier lookup (device → applier fn ID + property mappings)
- Produce JSON manifests for train/eval/runtime parity verification

**A2 Weight**: Heavy-tier (est. 40-60 files changed/created, 8-12K lines added, 3-5K lines deleted). Major refactoring of runtime contract matching & state application.

---

## Part 1: Codegen Input Contract Analysis

### 1.1 Contract Row Fields (31 Top-Level Keys)

Per /Users/wanglei/workspace/MAformac/contracts/semantic-function-contract.jsonl:

**Identity & Traceability** (8 fields):
- `contract_row_id` (string, unique per row): e.g., "c1_airControl_000002"
- `canonical_semantic_id` (string): deduplication anchor, e.g., "sem_bc27d0edf840c1f8"
- `dedupe_group_id` (string): group multiple rows representing same semantic action
- `dedupe_role` (string): "primary" | "variant", indicates whether this row is canonical
- `source_row_no` (integer): original sheet row number
- `external_evidence_ref` (string): lineage to snapshot, e.g., "snapshot:c1-2026-06-19-...:airControl:2"
- `source_row_hash` (string): SHA256 of original data for mutation detection
- `example_utterance_hash` (string): fingerprint of voice example

**Device & Service Binding** (5 fields, **CODEGEN KEY INPUT**):
- `device` (string): low-level hardware device name, e.g., "ac_temperature", "seat_lumbar_support", "window", "screen_brightness"
- `ds_protocol.service` (string): high-level service domain = "carControl" (2656 rows) | "cmd" (1156 rows) | "airControl" (178 rows)
- `ds_protocol.intent` (string): semantic intent name, e.g., "adjust_ac_temperature_to_number" (~1538 unique)
- `action_code` (string): normalized action code, e.g., "power_on", "set_mode"
- `action_primitive` (string): execution-level action type (130+ vocab), e.g., "power_on", "adjust_to_number", "set_mode"

**Value Semantics** (4 fields, **CODEGEN KEY INPUT**):
- `value.type` (string): "STATE" | "SPOT" | "PERCENT" | "EXP" | "ENUM" — parameterization style
- `value.direct` (string): literal/direct value, e.g., "24" for temperature, "red" for color
- `value.offset` (string): delta/increment value, e.g., "warmer", "brighter"
- `value.ref` (string): reference path in state model

**Argument Binding** (2 fields, **CODEGEN KEY INPUT**):
- `slot_keys` (array of strings): named argument keys accepted by this contract, e.g., ["direction"], ["position"], []
- `slot` (string): primary slot name if slot_keys is non-empty; "none" otherwise

**Execution Metadata** (6 fields):
- `exec_tier` (string): "L2" (lower level) | "L1" (training data) — indicates tier of evidence
- `execution_range_ref` (string): optional bound range, e.g., "temp=16-30"
- `range` (string): material candidate values, e.g., "direction=主驾|副驾|..." (pipe-separated enum)
- `range_class` (string): "material_candidate" | "none" — whether range is from data
- `risk` (string): risk classification (typically empty or "HIGH")
- `clarify_tag` (string): "implicit" | other — whether semantics require clarification

**Quality & Flags** (6 fields):
- `fc_flags.free`, `fc_flags.fuzzy`: boolean flags for model confidence
- `fc_flags.free_hash`, `fc_flags.fuzzy_hash`: SHA256 of flag computation
- `primary_selection_rule_version` (string): dedup resolution rule version
- `evidence_ref_kind` (string): "snapshot" | source type
- `redaction_state` (string): "example_hash_only" | full state
- `example_utterance_kind` (string): "source_example" | "generated"

**Relationships** (1 field):
- `second_turn_refs` (array): dialogue continuation IDs, e.g., ["trans_25f..."]

---

### 1.2 High-Value Contract Characteristics

**Unique Device Count**: 671 devices across corpus
```
座椅: 34 devices (seat_backrest, seat_lumbar_support, seat_ventilation_windspeed, ...)
屏幕: 53 devices (screen_brightness, backlight_brightness, button_brightness, ...)
灯光氛围: 37 devices (atmosphere_lamp_brightness, atmosphere_lamp_change_speed, ...)
空调: 23 devices (ac, ac_temperature, ac_windspeed, ac_mode, ...)
音量: 30 devices (volume, ...)
车门: 11 devices (door, ...)
```
(from /Users/wanglei/workspace/MAformac/generated/10-family-device-map.json)

**Action Primitive Distribution** (130+ types):
```
power_on:             553 rows (14%)
power_off:            551 rows (14%)
set_mode:             709 rows (18%)
adjust_to_number:     448 rows (11%)
by_percent:           333 rows (8%)
increase_by_exp:      252 rows (6%)
decrease_by_exp:      188 rows (5%)
... (120 more types)
```

**Service Domain Split**:
```
carControl: 2656 rows (67%) — vehicle control (seat, door, window, etc.)
cmd:        1156 rows (29%) — multimedia & screen commands
airControl:  178 rows (4%)  — HVAC control (AC modes, fan, defog)
```

**Dedup Efficiency**: canonical_semantic_id groups multiple device/action combinations representing same user intent; dedupe_role="primary" marks canonical row per group.

---

## Part 2: Three-Level IR Architecture

### 2.1 Level 1: DeviceFamily IR

**Purpose**: Group 671 devices into coherent semantic families, enabling family-level tool routing.

**Structure** (generated file: `generated/1-device-family-ir.json`):

```json
{
  "device_families": [
    {
      "family_name": "空调",
      "family_zh_name": "Air Conditioning Control",
      "service_domain": "airControl",
      "devices": [
        {
          "device_name": "ac",
          "exec_tier": "L2",
          "risk_level": "",
          "action_primitives": ["power_on", "power_off"],
          "slots": [],
          "value_type_profile": ["STATE"]
        },
        {
          "device_name": "ac_temperature",
          "exec_tier": "L2",
          "risk_level": "",
          "action_primitives": ["adjust_to_number", "increase_by_exp", "decrease_by_exp"],
          "slots": [],
          "value_type_profile": ["SPOT", "EXP"]
        },
        ...
      ],
      "tool_name": "set_cabin_ac",
      "tool_description": "Control cabin air conditioning (temperature, mode, fan speed)"
    },
    ...
  ]
}
```

**Cardinality**: ~10-15 families (空调, 座椅, 屏幕, 灯光氛围, 音量, 车门, 车窗, 雨刮, 天窗遮阳帘, 香氛, etc.)

**Derivation**: Extract unique values from generated/10-family-device-map.json, augment with per-family tool name mapping, and cross-reference service_domain.

---

### 2.2 Level 2: ServiceGroup IR

**Purpose**: Organize tools by service boundary and enable service-specific routing logic.

**Structure** (generated file: `generated/2-service-group-ir.json`):

```json
{
  "service_groups": [
    {
      "service_name": "carControl",
      "tool_count": 28,
      "device_families": ["座椅", "车门", "车窗", "雨刮", "天窗遮阳帘", ...],
      "tools": [
        {
          "tool_name": "set_cabin_ac",
          "family": "空调",
          "description": "Control cabin air conditioning",
          "target_devices": ["ac", "ac_temperature", "ac_windspeed", ...],
          "normalizer_dispatch_id": "normalize_ac_group",
          "state_applier_dispatch_id": "apply_ac_group"
        },
        ...
      ]
    },
    {
      "service_name": "airControl",
      "tool_count": 4,
      "device_families": ["空调"],
      "tools": [...]
    },
    {
      "service_name": "cmd",
      "tool_count": 12,
      "device_families": ["屏幕", "音量", "灯光氛围"],
      "tools": [...]
    }
  ]
}
```

**Key Insight**: Service groups map 1:N to tool names; enables runtime dispatch on (service_name, tool_name) → normalizer & state applier.

---

### 2.3 Level 3: ToolRoute IR

**Purpose**: Map each D-domain tool name to the set of (device, action_primitive) permutations it handles, plus argument schema.

**Structure** (generated file: `generated/3-tool-route-ir.jsonl`):

One JSONL line per D-domain tool, with permutation matrix:

```json
{
  "tool_name": "set_cabin_ac",
  "description": "Control cabin air conditioning (power, temperature, fan speed)",
  "service_domain": "carControl",
  "device_family": "空调",
  "routes": [
    {
      "device": "ac",
      "action_primitives": ["power_on", "power_off"],
      "slot_keys": [],
      "value_types": ["STATE"],
      "normalizer_fn": "normalize_ac_power",
      "state_applier_fn": "apply_ac_power"
    },
    {
      "device": "ac_temperature",
      "action_primitives": ["adjust_to_number", "increase_by_exp", "decrease_by_exp"],
      "slot_keys": [],
      "value_types": ["SPOT", "EXP"],
      "normalizer_fn": "normalize_ac_temperature",
      "state_applier_fn": "apply_ac_temperature"
    },
    {
      "device": "ac_windspeed",
      "action_primitives": ["adjust_to_number", "increase_by_exp", "decrease_by_exp"],
      "slot_keys": [],
      "value_types": ["SPOT", "EXP"],
      "normalizer_fn": "normalize_ac_windspeed",
      "state_applier_fn": "apply_ac_windspeed"
    }
  ],
  "arguments_schema": {
    "power": {"type": "string", "enum": ["on", "off", "unchanged"]},
    "target_temperature": {"type": "string"},
    "delta": {"type": "string", "enum": ["warmer", "cooler", "none"]},
    "level": {"type": "string"}
  }
}
```

**Cardinality**: ~534 unique (device, action_primitive, slot_keys) tuples, rollable into ~50-100 D-domain tools.

**Derivation**: Group contract rows by (canonical_semantic_id, dedupe_group_id); for each group take primary row; extract routes via cartesian product of (target_device, action_primitive_set) per tool.

---

## Part 3: Codegen Input → Output Pipeline

### 3.1 Python Codegen (gen_tool_contract.py Enhancement)

**Current Scope** (118 lines):
- Read JSONL contract (3990 rows)
- Extract unique devices, action_primitives, value_types, slot_keys
- Generate B_frame.frame_schema.json (hardcoded 6 D-domain tools)
- Generate D_domain.tools.json (stub tool definitions)

**A2 Scope** (est. ~400 lines, 2-3 sub-functions per level):

```python
def gen_device_family_ir(rows: List[dict]) -> dict:
  """
  Input: semantic-function-contract.jsonl rows
  Output: 1-device-family-ir.json
  
  Logic:
    - Load 10-family-device-map.json (device → family mapping)
    - Group rows by device_family
    - For each family, extract unique (device, action_primitive, value_type) combos
    - Deduplicate via canonical_semantic_id + dedupe_role="primary"
    - Emit family IR with per-family tool name
  """
  pass

def gen_service_group_ir(family_ir: dict, rows: List[dict]) -> dict:
  """
  Input: 1-device-family-ir.json + semantic-function-contract.jsonl
  Output: 2-service-group-ir.json
  
  Logic:
    - Group families by ds_protocol.service domain
    - For each service_domain, assign tool_name based on family (heuristic or lookup table)
    - Count tools per service
    - Emit service IR
  """
  pass

def gen_tool_route_ir(family_ir: dict, service_group_ir: dict, rows: List[dict]) -> List[dict]:
  """
  Input: 1-device-family-ir.json, 2-service-group-ir.json, semantic-function-contract.jsonl
  Output: 3-tool-route-ir.jsonl (one line per tool)
  
  Logic:
    - For each tool in service_group_ir:
      - Extract all rows matching (tool_family, service_domain)
      - Group by canonical_semantic_id; take primary per group
      - For each row, extract (device, action_primitive_set, slot_keys, value_types)
      - Derive normalizer_fn name (e.g., "normalize_ac_temperature")
      - Derive state_applier_fn name (e.g., "apply_ac_temperature")
      - Emit route with permutation matrix
  """
  pass

def gen_frame_schema(rows: List[dict]) -> List[dict]:
  """
  [EXISTING] Extract unique (device, action_primitive, value_type, slot_keys)
  Output: B_frame.frame_schema.json
  """
  pass

def gen_d_domain_schemas(service_group_ir: dict, tool_route_ir: List[dict]) -> List[dict]:
  """
  [ENHANCED] Produce full D-domain tool schemas instead of stubs
  Input: 2-service-group-ir.json, 3-tool-route-ir.jsonl
  Output: D_domain.tools.json
  
  Logic:
    - For each tool in 3-tool-route-ir.jsonl:
      - Extract arguments_schema from all routes
      - Generate full parameter schema (no longer empty)
      - Emit tool definition with description
  """
  pass

def gen_normalizer_dispatch_table(tool_route_ir: List[dict]) -> dict:
  """
  [NEW] Produce normalizer dispatch IR for runtime
  Input: 3-tool-route-ir.jsonl
  Output: generated/normalizer-dispatch-table.json
  
  Structure:
    {
      "dispatch_map": [
        {
          "key": "carControl:set_cabin_ac:ac:power_on",
          "handler_name": "normalize_ac_power",
          "target_device": "ac",
          "action_primitive": "power_on"
        },
        ...
      ]
    }
  
  This maps (service, tool_name, device, action_primitive) → normalizer function ID
  for runtime dispatch in ToolContractNormalizer.
  """
  pass

def gen_state_applier_dispatch_table(tool_route_ir: List[dict]) -> dict:
  """
  [NEW] Produce state applier dispatch IR for runtime
  Input: 3-tool-route-ir.jsonl
  Output: generated/state-applier-dispatch-table.json
  
  Structure:
    {
      "dispatch_map": [
        {
          "key": "ac:power_on",
          "handler_name": "apply_ac_power",
          "state_keys": ["ac.power"],
          "state_defaults": {"ac.power": "off"}
        },
        ...
      ]
    }
  
  This maps (device, action_primitive) → state applier function ID
  for runtime dispatch in ToolContractStateApplier.
  """
  pass

def main():
  rows = read_jsonl(Path(args.contract))
  
  # Generate IR pyramid
  family_ir = gen_device_family_ir(rows)
  write_json(output_dir / "1-device-family-ir.json", family_ir)
  
  service_group_ir = gen_service_group_ir(family_ir, rows)
  write_json(output_dir / "2-service-group-ir.json", service_group_ir)
  
  tool_route_ir = gen_tool_route_ir(family_ir, service_group_ir, rows)
  write_jsonl(output_dir / "3-tool-route-ir.jsonl", tool_route_ir)
  
  # Generate dispatch tables
  normalizer_dispatch = gen_normalizer_dispatch_table(tool_route_ir)
  write_json(output_dir / "normalizer-dispatch-table.json", normalizer_dispatch)
  
  state_applier_dispatch = gen_state_applier_dispatch_table(tool_route_ir)
  write_json(output_dir / "state-applier-dispatch-table.json", state_applier_dispatch)
  
  # Generate schemas
  b_frame = gen_frame_schema(rows)
  write_json(output_dir / "B_frame.frame_schema.json", b_frame)
  
  d_domain = gen_d_domain_schemas(service_group_ir, tool_route_ir)
  write_json(output_dir / "D_domain.tools.json", d_domain)
```

---

### 3.2 Swift Compiler Refactor (ToolContractCompiler.swift)

**Current State**:
- Lines 71-90: hardcoded 6 tool names in dDomainSurfaceNames()
- Lines 145-172: hardcoded 6 switch cases in ToolContractNormalizer.normalize()
- Lines 199-268: hardcoded 8 normalizer functions (normalizeAC, normalizeWindow, etc.)
- Lines 288-475: hardcoded 8 state applier functions (applyAC, applyTemperature, etc.)

**A2 Refactor**:

#### 3.2.1 Load Dispatch Tables at Compiler Init

```swift
public struct ToolContractCompiler: Sendable {
  // EXISTING
  public var devices: [String]
  public var actionPrimitives: [String]
  public var valueTypes: [String]
  public var slotKeys: [String]
  
  // NEW: Dispatch table maps
  private var normalizerDispatch: [String: NormalizerHandler]
  private var stateApplierDispatch: [String: StateApplierHandler]
  
  public init(
    rows: [SemanticContractRow],
    normalizerDispatchJSON: String? = nil,
    stateApplierDispatchJSON: String? = nil
  ) {
    // Existing logic
    self.devices = Self.unique(rows.map(\.device))
    self.actionPrimitives = Self.unique(rows.map(\.actionPrimitive))
    self.valueTypes = Self.unique(rows.map { $0.value.type })
    self.slotKeys = Self.unique(rows.flatMap(\.slotKeys))
    
    // NEW: Load dispatch tables from generated JSON
    if let json = normalizerDispatchJSON {
      self.normalizerDispatch = Self.parseNormalizerDispatch(json)
    } else {
      self.normalizerDispatch = [:] // Empty, fallback to legacy hardcoded
    }
    
    if let json = stateApplierDispatchJSON {
      self.stateApplierDispatch = Self.parseStateApplierDispatch(json)
    } else {
      self.stateApplierDispatch = [:] // Empty, fallback to legacy hardcoded
    }
  }
}
```

#### 3.2.2 Replace dDomainSurfaceNames() with Data-Driven Lookup

```swift
private func dDomainSurfaceNames() -> [String] {
  // LEGACY (lines 71-90): hardcoded if-checks for 6 devices
  // NEW: Load from generated/2-service-group-ir.json at runtime
  
  // Fallback if dispatch table unavailable:
  var names: Set<String> = []
  if devices.contains("ac") || devices.contains("ac_temperature") {
    names.insert("set_cabin_ac")
    names.insert("query_cabin_comfort")
  }
  if devices.contains("ac_windspeed") {
    names.insert("set_cabin_fan")
  }
  if devices.contains("window") {
    names.insert("set_cabin_window")
  }
  if devices.contains("screen_brightness") {
    names.insert("set_cabin_screen_brightness")
  }
  if devices & {"atmosphere_lamp_color", "atmosphere_lamp_brightness"} {
    names.insert("set_cabin_ambient_light")
  }
  return names.sorted()
}
```

#### 3.2.3 Replace ToolContractNormalizer Switch with Dispatch Lookup

```swift
public enum ToolContractNormalizer {
  public static func normalize(_ call: C6ToolCall) -> [ToolContractIR] {
    // LEGACY (lines 147-172): hardcoded switch on call.name
    // NEW: Lookup in dispatch table
    
    // Fallback to legacy if dispatch table empty:
    switch call.name {
    case "tool_call_frame":
      return normalizeFrame(call)
    case "set_cabin_ac":
      return normalizeAC(call)
    case "set_cabin_window":
      return normalizeWindow(call)
    // ... (6 hardcoded cases)
    default:
      return []
    }
  }
  
  // REFACTORED: Dispatch-driven normalize
  public static func normalize(_ call: C6ToolCall, dispatch: [String: NormalizerHandler]) -> [ToolContractIR] {
    let key = "\(call.name):\(call.arguments["device"] ?? "")"
    if let handler = dispatch[key] {
      return handler(call)
    } else {
      // Fallback to legacy hardcoded logic
      return normalize(call) // Call overload above
    }
  }
}
```

#### 3.2.4 Consolidate 8 State Applier Functions into Dispatch Lookup

```swift
public enum ToolContractStateApplier {
  public static func apply(
    toolCalls: [C6ToolCall],
    to preState: [String: String],
    stateCells: StateCellContractLookup,
    dispatch: [String: StateApplierHandler] = [:]
  ) -> [String: String] {
    var state = preState
    for call in toolCalls {
      for ir in ToolContractNormalizer.normalize(call) {
        // LEGACY: hardcoded switch on ir.device (lines 303-422)
        // NEW: Lookup in dispatch table
        
        let key = "\(ir.device):\(ir.actionPrimitive)"
        if let handler = dispatch[key] {
          handler(&state, ir, stateCells)
        } else {
          // Fallback to legacy
          applyLegacy(ir, state: &state, stateCells: stateCells)
        }
      }
    }
    return state
  }
}
```

---

## Part 4: Hardcoded Bindings Elimination

### 4.1 Six D-Domain Tool Names (ToolContractCompiler.swift:71-90)

**Current Bindings**:
```swift
if devices.contains("ac") || devices.contains("ac_temperature") {
  names.insert("set_cabin_ac")
  names.insert("query_cabin_comfort")
}
if devices.contains("ac_windspeed") {
  names.insert("set_cabin_fan")
}
if devices.contains("window") {
  names.insert("set_cabin_window")
}
if devices.contains("screen_brightness") {
  names.insert("set_cabin_screen_brightness")
}
if devices & {"atmosphere_lamp_color", "atmosphere_lamp_brightness"} {
  names.insert("set_cabin_ambient_light")
}
```

**A2 Replacement**: Load from generated/2-service-group-ir.json, which includes all tools:
```json
{
  "service_groups": [
    {
      "service_name": "carControl",
      "tools": [
        {"tool_name": "set_cabin_ac", "family": "空调"},
        {"tool_name": "set_cabin_fan", "family": "空调"},
        // ... (28 tools)
      ]
    }
  ]
}
```

**Elimination Method**: Load at compiler init; fallback to legacy hardcoded logic if JSON unavailable (for backwards compatibility during migration).

---

### 4.2 Six Switch Cases in ToolContractNormalizer (ToolContractCompiler.swift:147-172)

**Current Bindings**:
```swift
switch call.name {
case "tool_call_frame":
  return normalizeFrame(call)
case "set_cabin_ac":
  return normalizeAC(call)
case "set_cabin_window":
  return normalizeWindow(call)
case "set_cabin_screen_brightness":
  return normalizeScreen(call)
case "set_cabin_ambient_light":
  return normalizeAmbient(call)
case "set_cabin_fan":
  return normalizeFan(call)
case "query_cabin_comfort":
  return [...]
default:
  return []
}
```

**A2 Replacement**: Load from generated/normalizer-dispatch-table.json:
```json
{
  "dispatch_map": [
    {"key": "carControl:set_cabin_ac:ac:power_on", "handler_name": "normalize_ac_power"},
    {"key": "carControl:set_cabin_ac:ac_temperature:adjust_to_number", "handler_name": "normalize_ac_temperature"},
    // ... (534+ entries)
  ]
}
```

**Dispatch Signature**:
```swift
typealias NormalizerHandler = (C6ToolCall) -> [ToolContractIR]
var normalizerDispatch: [String: NormalizerHandler]
```

---

### 4.3 Eight Normalizer Functions (ToolContractCompiler.swift:199-268)

**Current Functions**:
1. normalizeAC (lines 199-212, 14 lines)
2. normalizeWindow (lines 214-227, 14 lines)
3. normalizeScreen (lines 229-240, 12 lines)
4. normalizeAmbient (lines 242-255, 14 lines)
5. normalizeFan (lines 257-268, 12 lines)
6. normalizeFrame (lines 175-196, 22 lines)

**Subtotal**: ~88 lines of device-specific normalization logic

**A2 Replacement Strategy**:

Instead of 8 monolithic functions, generate ~50-100 **slim normalizer functions** via Python codegen, each handling a specific (device + action_primitive_class) pair:

```swift
// Generated: Sources/MAformac/Generated/Normalizers.swift
// Auto-generated from 3-tool-route-ir.jsonl

private func normalize_ac_power(_ call: C6ToolCall) -> [ToolContractIR] {
  guard let power = call.arguments["power"] else { return [] }
  return [
    ToolContractIR(
      sourceToolName: call.name,
      device: "ac",
      actionPrimitive: power == "off" ? "power_off" : "power_on",
      value: ContractValue(offset: power, type: "STATE")
    )
  ]
}

private func normalize_ac_temperature(_ call: C6ToolCall) -> [ToolContractIR] {
  var result: [ToolContractIR] = []
  if let temp = call.arguments["target_temperature"] {
    result.append(ToolContractIR(
      sourceToolName: call.name,
      device: "ac_temperature",
      actionPrimitive: "adjust_to_number",
      value: ContractValue(direct: temp, type: "SPOT")
    ))
  }
  if let delta = call.arguments["delta"], delta != "none" {
    let action = delta == "warmer" ? "increase_by_exp" : "decrease_by_exp"
    result.append(ToolContractIR(
      sourceToolName: call.name,
      device: "ac_temperature",
      actionPrimitive: action,
      value: ContractValue(offset: delta, type: "EXP")
    ))
  }
  return result
}

// ... (~50 more generated functions)
```

**Benefits**:
- Each function is self-documenting (fine-grained, single responsibility)
- Easier to test independently
- Extensible: adding new device requires only adding one generator function
- Dispatch table routes (service, tool_name, device, action_primitive) → function name at runtime

---

### 4.4 Eight State Applier Functions (ToolContractCompiler.swift:324-411)

**Current Functions**:
1. applyAC (lines 324-330, 7 lines)
2. applyTemperature (lines 332-346, 15 lines)
3. applyFan (lines 348-359, 12 lines)
4. applyWindow (lines 361-379, 19 lines)
5. applyScreen (lines 381-392, 12 lines)
6. applyAmbientColor (lines 394-402, 9 lines)
7. applyAmbientBrightness (lines 404-411, 8 lines)

**Subtotal**: ~82 lines of device-specific state mutation logic

**A2 Replacement Strategy**:

Generate ~50-100 **slim state applier functions**, each handling (device + action_primitive_class) → state cell mutations:

```swift
// Generated: Sources/MAformac/Generated/StateAppliers.swift

private func apply_ac_power(_ ir: ToolContractIR, state: inout [String: String]) {
  if isOff(ir.actionPrimitive, value: ir.value) {
    state["ac.power"] = "off"
  } else if isOn(ir.actionPrimitive, value: ir.value) {
    state["ac.power"] = "on"
  }
}

private func apply_ac_temperature(_ ir: ToolContractIR, state: inout [String: String]) {
  if let target = targetNumber(ir) {
    state["ac.temp_setpoint[主驾]"] = target
    state["ac.power"] = "on"
    return
  }
  let current = Int(state["ac.temp_setpoint[主驾]"] ?? "24") ?? 24
  if ir.actionPrimitive == "increase_by_exp" {
    state["ac.temp_setpoint[主驾]"] = String(current + 2)
    state["ac.power"] = "on"
  } else if ir.actionPrimitive == "decrease_by_exp" {
    state["ac.temp_setpoint[主驾]"] = String(current - 2)
    state["ac.power"] = "on"
  }
}

// ... (~50 more generated functions)
```

**Dispatch Signature**:
```swift
typealias StateApplierHandler = (inout [String: String], ToolContractIR, StateCellContractLookup) -> Void
var stateApplierDispatch: [String: StateApplierHandler]
```

---

## Part 5: Generated Artifact Placement & Verification Gates

### 5.1 Generated File Inventory (A2 Scope)

**New Files** (committed to repo, verified in CI):

| File | Size Est. | Format | Purpose |
|------|-----------|--------|---------|
| `generated/1-device-family-ir.json` | 50 KB | JSON | Device grouping IR (671 devices → ~15 families) |
| `generated/2-service-group-ir.json` | 30 KB | JSON | Service domain IR (3 services → ~50 tools) |
| `generated/3-tool-route-ir.jsonl` | 100 KB | JSONL | Tool-to-device routing (534 tuples) |
| `generated/normalizer-dispatch-table.json` | 80 KB | JSON | Runtime (device, action_prim) → normalizer fn |
| `generated/state-applier-dispatch-table.json` | 60 KB | JSON | Runtime (device, action_prim) → state applier fn |
| `Sources/MAformac/Generated/Normalizers.swift` | 150 KB | Swift | ~50-100 generated normalizer functions |
| `Sources/MAformac/Generated/StateAppliers.swift` | 120 KB | Swift | ~50-100 generated state applier functions |
| `generated/codegen-manifest.json` | 10 KB | JSON | Parity verification manifest |

**Total New**: ~600 KB, 7 files

**Modified Files** (existing logic preserved via fallback):

| File | Lines Changed | Nature |
|------|---------------|--------|
| `scripts/gen_tool_contract.py` | +400 | Add IR pyramid generation |
| `Core/Contracts/ToolContractCompiler.swift` | +200 / -50 | Load dispatch tables, fallback logic |
| `Makefile` | +5 | New regen-generated target |

**Deleted Files**: None (backwards compat via fallback)

### 5.2 Gitignore Policy

**Decision**: Commit all generated IR & dispatch tables to repo.

**Rationale**:
1. Parity verification (verify_refs.py) can check train/eval/runtime consistency
2. CI gate enforces regeneration before merge (via `make diff`)
3. Fallback logic in Swift compiler makes generated files optional at runtime

**.gitignore Changes**: None (generated/ already committed)

---

### 5.3 Verify Gate: Train/Eval/Runtime Parity

**Current Gate** (Makefile:19): `verify → verify-source → regen → verify-refs → verify-cross-section → diff → test`

**A2 Enhancement**: New `verify-tool-surface-parity` gate

```bash
# scripts/verify_tool_surface_parity.py
def verify_train_eval_runtime_parity():
    """
    Ensure contract consistency across three execution tiers.
    
    1. TRAIN (semantic-function-contract.jsonl):
       - Load 3990 contract rows
       - Compute unique (device, action_primitive, value.type) set
       - Hash as train_surface_hash
    
    2. EVAL (3-tool-route-ir.jsonl):
       - Load 534 generated tool routes
       - Flatten to (device, action_primitive, value.type) set
       - Hash as eval_surface_hash
    
    3. RUNTIME (normalizer-dispatch-table.json + state-applier-dispatch-table.json):
       - Load dispatch tables
       - Extract (device, action_primitive) set
       - Hash as runtime_surface_hash
    
    4. PARITY CHECK:
       - train_surface_hash == eval_surface_hash (all contract rows covered by routes)
       - eval_surface_hash == runtime_surface_hash (all routes have dispatch handlers)
       - report uncovered rows, unreachable routes, missing handlers
    
    Exit 1 if any mismatch.
    """
    pass

# Makefile addition:
verify-tool-surface-parity: .venv/.deps.stamp
	$(PYTHON) scripts/verify_tool_surface_parity.py
```

**Integration**: Add to Makefile line 19 chain:
```makefile
verify: .venv/.deps.stamp verify-source regen verify-refs verify-tool-surface-parity verify-cross-section diff test
```

---

## Part 6: File-Level Classification (Reuse vs. Rewrite vs. New)

### 6.1 Reuse (No Changes)

| File | Reason |
|------|--------|
| `Core/Contracts/ContractLookups.swift` | SemanticContractRow, ExecutionRange, StateCellDefinition, StateCellContractLookup unchanged |
| `contracts/semantic-function-contract.jsonl` | Input data, no modification |
| `generated/10-family-device-map.json` | Existing artifact, still useful for codegen |
| `Makefile` | Core structure preserved; only add new targets |
| `scripts/verify_refs.py` | Existing verification logic still applicable |
| `scripts/test_quarantine.py` | Unrelated to codegen |
| `scripts/test_fc_flags.py` | Unrelated to codegen |

### 6.2 Rewrite (Significant Changes)

| File | Current | A2 | Rationale |
|------|---------|-----|-----------|
| `scripts/gen_tool_contract.py` | 118 lines | ~400 lines | Add 6 new IR generation functions + dispatch table export |
| `Core/Contracts/ToolContractCompiler.swift` | 512 lines | ~650 lines | Add dispatch table loading, fallback logic; preserve legacy |

### 6.3 New (Create)

| File | Type | Est. Lines | Purpose |
|------|------|-----------|---------|
| `Sources/MAformac/Generated/Normalizers.swift` | Swift | ~150-200 | 50-100 generated normalizer functions |
| `Sources/MAformac/Generated/StateAppliers.swift` | Swift | ~120-150 | 50-100 generated state applier functions |
| `sources/MAformac/Generated/DispatchTableLoader.swift` | Swift | ~100 | Load generated dispatch tables at runtime |
| `scripts/gen_normalizers.py` | Python | ~200 | Template-driven generation of Swift normalizer code |
| `scripts/gen_state_appliers.py` | Python | ~200 | Template-driven generation of Swift state applier code |
| `scripts/verify_tool_surface_parity.py` | Python | ~150 | Parity verification gate |
| `docs/a2-codegen-design.md` | Markdown | ~300 | Design documentation (this doc) |

**Total New Code**: ~1200-1500 lines of Swift, ~550 lines of Python, ~300 lines of docs.

---

## Part 7: A2 Scope Quantification (Heavy-Tier Estimation)

### 7.1 Files Changed/Created

**Summary**:
- Files to reuse: 7
- Files to rewrite: 2
- Files to create: 7
- **Total touched**: 16 files

### 7.2 Lines of Code Impact

**Additions**:
- Python codegen (gen_tool_contract.py + new scripts): ~1100 lines
- Swift generated code (Normalizers.swift, StateAppliers.swift): ~300 lines
- Swift runtime support (DispatchTableLoader.swift, fallback logic): ~100 lines
- Documentation: ~300 lines
- **Total added**: ~1800 lines

**Deletions**:
- ToolContractNormalizer hardcoded switch (6 cases): ~26 lines
- Eight normalizer functions (normalizeAC, normalizeWindow, etc.): ~88 lines
- Eight state applier functions (applyAC, applyTemperature, etc.): ~82 lines
- **Total deleted**: ~196 lines

**Net impact**: +1604 lines (+314% code growth in Contracts module)

### 7.3 Complexity Metrics

| Metric | Value | Assessment |
|--------|-------|------------|
| **Cyclomatic complexity (removed)** | 8 → 1 per function | -87.5% (fewer branches) |
| **Coupling reduction** | 6 hardcoded tools → data-driven | -100% hardcoding |
| **Test coverage expansion** | +2 new test files for parity verification | Improved observability |
| **Runtime dispatch overhead** | JSON map lookup O(1) + function call | Negligible (<1ms) |

### 7.4 Risk Profile

**Tier 1 Risks** (High):
1. **IR contract breakage**: If generated dispatch tables malformed, normalizer/applier dispatch fails silently → wrong state mutations
   - Mitigation: Parity verification gate (exit 1 on mismatch)
2. **Backwards compatibility**: Legacy hardcoded logic must survive if generated JSON missing
   - Mitigation: Fallback to hardcoded switch in both Normalizer and StateApplier
3. **Generator correctness**: Codegen bug (e.g., missing device in dispatch table) causes training data loss
   - Mitigation: Unit tests on gen_tool_contract.py; CI blocks on verify-tool-surface-parity

**Tier 2 Risks** (Medium):
1. **Generated code bloat**: 50-100 functions in Normalizers.swift difficult to review
   - Mitigation: Template-driven generation (single template + per-route instantiation); inline comments
2. **Maintenance burden**: Each new device requires codegen changes
   - Mitigation: IR schema extensible; codegen updates contract automatically

**Tier 3 Risks** (Low):
1. **Performance regression**: Dispatch table lookup slower than hardcoded switch
   - Mitigation: O(1) map lookup, negligible (<1ms per call)

### 7.5 Heavy-Tier Justification

**A2 Qualifies as Heavy Because**:

1. **Scope**: 16 files touched; 1800+ lines added; rewrites core normalizer/applier logic (40% of contract module)
2. **Complexity**: Three-level IR pyramid introduces new data model; runtime dispatch replaces static switch
3. **Criticality**: ToolContractCompiler is hot path in training/eval/runtime loops; any regression cascades to downstream
4. **Interdependencies**: Changes to Normalizer affect ToolContractStateApplier, which affects mock vehicle state logic
5. **Test burden**: New parity verification gate requires ~150 lines of test code + manual verification of dispatch table correctness
6. **Documentation**: Design document required to onboard future maintainers to three-level IR architecture

**Comparable Projects**:
- "Major refactoring of execution engine" (L1 classification): Yes, normalizer & applier are core execution logic
- "New paradigm (data-driven vs. hardcoded)": Yes, IR shift from imperative to declarative
- "Project-wide ripple effects": Yes, contract changes touch training, eval, runtime consistently

---

## Part 8: Implementation Roadmap (A2 Phases)

### Phase 1: Data Codegen (Week 1)

**Goal**: Generate 1-device-family-ir.json, 2-service-group-ir.json, 3-tool-route-ir.jsonl

**Tasks**:
1. Implement gen_device_family_ir() in Python
2. Implement gen_service_group_ir() in Python
3. Implement gen_tool_route_ir() in Python
4. Test on semantic-function-contract.jsonl; verify all 534 tool-device routes
5. Commit generated IR to repo

**Exit Criteria**:
- `make regen` produces all 3 IR files without error
- IR files validated against contract (row count, device coverage, action_primitive coverage)

### Phase 2: Dispatch Table Codegen (Week 1-2)

**Goal**: Generate normalizer-dispatch-table.json, state-applier-dispatch-table.json, manifest.json

**Tasks**:
1. Implement gen_normalizer_dispatch_table() in Python
2. Implement gen_state_applier_dispatch_table() in Python
3. Implement gen_codegen_manifest() for parity verification
4. Test dispatch table correctness (all routes have handlers)
5. Commit dispatch tables to repo

**Exit Criteria**:
- Dispatch tables load correctly in ToolContractCompiler init
- verify-tool-surface-parity gate passes (no uncovered rows)

### Phase 3: Swift Code Generation (Week 2-3)

**Goal**: Generate Normalizers.swift, StateAppliers.swift, DispatchTableLoader.swift

**Tasks**:
1. Design Swift code generation templates (gen_normalizers.py, gen_state_appliers.py)
2. Generate ~50-100 normalizer functions from 3-tool-route-ir.jsonl
3. Generate ~50-100 state applier functions from 3-tool-route-ir.jsonl
4. Implement DispatchTableLoader.swift for runtime loading
5. Test generated functions (smoke test normalizer output, state mutations)

**Exit Criteria**:
- Generated Swift code compiles without warnings
- Unit tests for ~5 generated functions pass

### Phase 4: Swift Compiler Refactor (Week 3-4)

**Goal**: Integrate dispatch tables into ToolContractCompiler; preserve backwards compat

**Tasks**:
1. Add dispatch table loading to ToolContractCompiler.init()
2. Refactor dDomainSurfaceNames() to load from 2-service-group-ir.json (with fallback)
3. Refactor ToolContractNormalizer to dispatch via normalizer-dispatch-table.json (with fallback)
4. Refactor ToolContractStateApplier to dispatch via state-applier-dispatch-table.json (with fallback)
5. Integration test: run full contract normalization on semantic-function-contract.jsonl

**Exit Criteria**:
- All existing tests still pass
- Dispatch-driven path produces identical IR/state mutations as hardcoded path
- No performance regression

### Phase 5: Verification Gate & CI Integration (Week 4)

**Goal**: Implement verify-tool-surface-parity gate; integrate into Makefile

**Tasks**:
1. Implement verify_tool_surface_parity.py (parity verification logic)
2. Add to Makefile verify target
3. Test gate on semantic-function-contract.jsonl
4. Update CI to enforce gate before merge

**Exit Criteria**:
- Gate passes on current semantic-function-contract.jsonl
- Gate fails if rows removed from contract (parity broken)

### Phase 6: Documentation & Cleanup (Week 4-5)

**Goal**: Finalize design docs, clean up test artifacts

**Tasks**:
1. Update CONTEXT.md with three-level IR architecture
2. Write ADR: "Data-Driven Tool Routing via Codegen" (why, trade-offs, alternatives)
3. Add inline comments to generated code templates
4. Review & delete any spike/prototype code
5. Final integration test: run full pipeline end-to-end

**Exit Criteria**:
- All code reviewed and merged
- Design documented in CONTEXT.md & ADRs
- CI passes on all branches

---

## Part 9: Contract Fields Used by Codegen (Specification)

### Essential Fields (Codegen Depends On)

1. **device** (string): Hardware device identifier
   - Used in: dDomainSurfaceNames(), tool-to-device routing
   - Cardinality: 671 unique values
   - Example: "ac", "window", "screen_brightness"

2. **action_primitive** (string): Execution action type
   - Used in: dispatch table key, normalizer dispatch
   - Cardinality: 130+ unique values
   - Example: "power_on", "adjust_to_number"

3. **ds_protocol.service** (string): Service domain
   - Used in: service-group IR, tool grouping
   - Cardinality: 3 values (carControl, cmd, airControl)

4. **ds_protocol.intent** (string): Semantic intent name
   - Used in: tool naming, route IR
   - Cardinality: ~1538 unique values

5. **value.type** (string): Value parameterization style
   - Used in: frame schema, route IR
   - Cardinality: ~5 values (STATE, SPOT, PERCENT, EXP, ENUM)

6. **slot_keys** (array of strings): Named argument keys
   - Used in: frame schema, normalizer dispatch
   - Cardinality: ~50 unique slot names

7. **slot** (string): Primary slot name
   - Used in: route IR, contract grouping
   - Value: slot_keys[0] or "none"

8. **canonical_semantic_id** (string): Dedup anchor
   - Used in: deduplication (take primary row per group)
   - Cardinality: ~2000 unique groups

9. **dedupe_role** (string): "primary" | "variant"
   - Used in: dedup filtering (select primary row)
   - Value: "primary" or other

### Supporting Fields (Codegen References)

10. **contract_row_id** (string): Unique row identifier
    - Used in: debugging, audit trail

11. **exec_tier** (string): Execution tier level
    - Used in: device family IR, risk metadata

12. **risk** (string): Risk classification
    - Used in: device family IR, filtering

13. **execution_range_ref** (string): Optional bound range
    - Used in: route IR, state applier constraints

14. **range** (string): Material candidate values (enum)
    - Used in: frame schema properties, argument validation

### Unused by Codegen

- redaction_state, example_utterance_hash, evidence_ref_kind, second_turn_refs, fc_flags, primary_selection_rule_version, range_class, range_ref_kind, source_row_hash, source_row_no, source_sheet, clarify_tag, action_code, example_utterance_kind, dedupe_group_id, external_evidence_ref

---

## Conclusion

**A2 Codegen Plan delivers**:

1. **Eliminates 6 hardcoded tool bindings**: Replaced with data-driven 2-service-group-ir.json
2. **Eliminates 6 hardcoded normalizer switch cases**: Replaced with dispatch table + generated functions
3. **Eliminates 8 hardcoded state applier functions**: Replaced with dispatch table + generated functions
4. **Scales to 534 D-domain tools**: Three-level IR (family → service → tool) enables unbounded expansion
5. **Maintains backwards compatibility**: Fallback logic preserves legacy hardcoded path if generated JSON unavailable
6. **Enables parity verification**: New verify-tool-surface-parity gate ensures train/eval/runtime consistency
7. **Heavy-tier scope**: ~1800 lines added, 16 files touched, 40% of contract module logic reimplemented as data-driven

**Timeline**: 5-6 weeks (1 week per phase + overlap)

**Risk Mitigation**: Dispatch table validation, backwards-compat fallback, parity verification gate, comprehensive testing.
