## ADDED Requirements

### Requirement: S10 action probes use product acceptance route

S10 knife action readback probes SHALL execute through a declared product acceptance route (`acceptanceRouteID`) matching the customer text entry path used in demo behavior gates. Diagnostic `default_runtime` paths without product routing SHALL NOT satisfy S10 knife pass criteria.

#### Scenario: Refusal on non-product path fails probe

- **GIVEN** an action probe for matrix_id=4 utterance `空调调到26度`
- **WHEN** the harness records `resultKind=refusal_no_available_tool` with zero tool calls on a diagnostic path
- **THEN** the probe test SHALL fail
- **AND** the receipt SHALL NOT be used to mark `readbackProbePass` passed

#### Scenario: Accepted product route with state delta passes

- **GIVEN** the same probe runs on the declared product acceptance route
- **WHEN** exactly one `adjust_ac_temperature_to_number` call mutates `ac.temp_setpoint[主驾]` from 24 to 26
- **AND** readback confirms actualValue 26 with verified reconciliation
- **THEN** the probe test SHALL pass
- **AND** the receipt MAY be used for scoped basis update

### Requirement: Action probe tests assert execution outcomes

Action readback probe tests SHALL hard-assert expected state delta, confirmed state, readback values, tool call count, and accepted result kind. Emitting an observation receipt without assertions SHALL NOT constitute pass.

#### Scenario: Receipt-only without assertions fails CI

- **GIVEN** a probe harness writes a receipt where temperature remains 24
- **WHEN** CI runs the probe test target
- **THEN** the test SHALL fail before closeout
- **AND** governance SHALL NOT treat the run as knife 1 green
