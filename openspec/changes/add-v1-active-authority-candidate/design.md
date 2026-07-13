# Add V1 Active Authority Candidate — Design

> DRAFT. Architecture decisions for the V1 active authority candidate change.

## AD-V1-001: Authority identity is `c6_active_authority_v1`

The authority identity is a single const string matching the `native_schema_id` in the closure registry V1 entry. This enables mechanical join between the closure package exit receipt and the authority document.

## AD-V1-002: Freshness policy is `immutable_digest`

Once signed (status=RATIFIED), the authority document is frozen. Amendments require a superseding authority version with a higher `authority_version`. This prevents silent drift of measurement yardsticks during S10 verdict evaluation.

## AD-V1-003: Subject tuple covers all load-bearing authority fields

The subject array in the closure-package-exit-envelope must include: authority_id, authority_version, ratification_decision, ratification_receipt_sha256, all four layer thresholds, behavior class count, demo-fuzz family count, governance axis count, readback field count, contract bundle component count, and the authority digest. This ensures the exit receipt is self-verifying without loading the full authority document.

## AD-V1-004: Candidate status is the initial state

The authority starts as `CANDIDATE`. Transition to `RATIFIED` requires explicit human signoff (the V1 package's operator ceremony path). This prevents the authority from being used as a signed yardstick before governance completes.

## AD-V1-005: Source checker validates schema, refs, subject integrity, and source_members

The source checker (`check_c6_active_authority_candidate.py`) validates:
1. Required structural fields (including exact `source_members`)
2. All ratification refs have non-placeholder / non-all-zero SHA256 values
3. All decision refs reference ratified D-entries
4. Subject values match the D-147 exact set (7-family roster, 5 behavior classes, 5 governance axes, 7 readback fields, 7 contract components) — subject mismatch fail-closed
5. Digest is self-consistent (sha256 of canonical JSON of the subject + metadata fields)
6. Exact machine-readable `source_members` (unique role/id/path/locator/sha256 + subject_bindings): live path exists, live hash exact, exact member set; stale/duplicate/missing/ambiguous/all-zero/placeholder fail-closed

## AD-V1-010: source_members is the only D-147/T01 → live file mapping SSOT

`source_members[]` on the authority candidate is the machine-readable exact mapping from D-147/T01 decisions to live files. README prose and design tables are narrative only and SHALL NOT substitute for the manifest.

## AD-V1-006: Hard-layer denominators start at zero

The `hard_layer_denominators` in the candidate are set to 0 because the C6 bench corpus has not yet been rebuilt with the four-layer split. Actual denominators will be populated when the rebuild-c6 construction lane produces the corpus. The authority schema is forward-compatible: denominator fields accept any non-negative integer.

## AD-V1-007: Demo-fuzz family roster matches G2-038-C1 exact set

The seven-family roster (`ac_temperature`, `window`, `screen_brightness`, `atmosphere_lamp_color`, `atmosphere_lamp_brightness`, `ac_windspeed`, `car_door`) is the exact set ratified by D-147 G2-038-C1 (option B, `tags.contract_device` family). This is the canonical roster for demo-fuzz family-v2 extinction guard.

## AD-V1-008: Contract bundle component IDs are fixed

The seven component IDs (`c1_semantic_function_contract`, `c2_renderer_state_cells`, `c6_bench_cases`, `qwen_tool_call_format`, `d_domain_ir_map`, `d_domain_demo_tool_catalog`, `risk_policy`) match the AD-C6-009 contract bundle fingerprint design. These are the minimum set of contract inputs that define the C6 measurement context.

## AD-V1-009: No existing files are modified

This change creates only new files in the writable set. No existing OpenSpec carriers, specs, registry entries, Makefile targets, or test suites are modified. This preserves the isolation guarantee for the V1 authority candidate.

## Non-Goals

- No modification of `contracts/closure-work-packages.v1.yaml` (V1 remains `planned`)
- No modification of `Makefile` (verify-c6-authority-source and verify-c6-active-authority targets remain `planned`)
- No model runs, C6 acceptance, or quality calibration
