# R2b S2 batch3 lane-g Generation Receipt

status: generation_complete_data_only
artifact_kind: lane_generation_receipt
proof_class: local_generation_stage_data_only
lane_id: r2b-s2-lane-g
batch_id: r2b-s2-batch3

## Generator
- vendor/source: anthropic
- model: claude-opus-4-8 (Opus generation-only lane; feedback-opus-generation-only)
- generation mode: scripted, deterministic, re-runnable (`_scratch/gen_lane_g.py`) with segmented flush
- prompt package: wave2-negatives/batch-package/lane-prompt-package.md#S2 Batch3 Addendum: lane-g / lane-h
- batch order: wave2-negatives/batch-package/r2b-s2-batch3-order.json (lane-g block)
- tool surface: `_scratch/tool_catalog.json` (byte-identical copy of lane-e authoritative D-domain catalog; all volume/wiper/seat tool names verified as C1 semantic-function-contract.jsonl intents)

## Row Accounting (75 = volume15 + wiper45 + seat15)
- volume: positive9 query0 refusal1 already_state1 unsupported2 followup2
- wiper: positive31 query0 refusal3 already_state5 unsupported3 followup3
- seat: positive10 query0 refusal1 already_state2 unsupported1 followup1
- class totals: {'positive': 50, 'already_state': 8, 'refusal': 5, 'unsupported': 6, 'followup': 6}

## Contrastive Pair Floors (fresh, G_ prefix, no collision with sivd_*/scr_*/wrf1_*/win_*/volume_VRA_*/atmos_*/vol_qva_*/*_E*/*_F*/ac_*/door_*/seat_heat_1/seat_massage_1/wiper_OC/WRA_*)
- volume_relative_vs_absolute: 2 groups (min 2) — numeric_value_constant=true (value held, absolute-vs-relative cue)
- volume_already_state_noop: 1 group (min 1) — noop mate NO_TOOL, action mate visible adjust cue; state-vs-action (not numeric)
- wiper_front_rear_position_slot: 4 groups (min 4) — front/rear position(前/后) is the only changed slot cue, speed value held; numeric_value_constant=true; position_scan_required=true
- wiper_unsafe_refusal: 2 groups (min 2) — unsafe-context refusal NO_TOOL, safe-context mate keeps same close_wiper op; safety-context (not numeric)
- seat_query_style_unsupported: 1 group (min 1) — query-style unsupported NO_TOOL (no C1 seat query intent), action mate open_seat_heat; query-style-vs-action (not numeric)
- seat_already_state_noop: 1 group (min 1) — noop mate NO_TOOL, action mate open_seat_ventilation; state-vs-action (not numeric)

## D-087 Query Boundary (batch3 = ZERO query)
- query rows: 0 (batch3 has no query class; volume query bucket exhausted in batch2 as lane-e 8 + lane-f 12)
- seat/wiper query-style utterances -> unsupported + NO_TOOL + no_call.reason=no_available_query_tool + target_tool_present=false + query_reclass_reason_for_unsupported_query_style
- NO query_* tool mounted or expected anywhere in the lane (no query_current_volume, no query_seat_*, query_wiper_*, query_door_*)

## R2B-NVC-01
- structured `numeric_value_constant` present ONLY on value-bearing pair rows (volume_relative_vs_absolute=true; wiper_front_rear_position_slot=true — speed value held, front/rear position is the cue)
- legal values only: boolean true or string "value_is_cue"; evidence prose is NOT the field
- volume_already_state_noop / wiper_unsafe_refusal / seat_query_style_unsupported / seat_already_state_noop and all non-pair rows carry NO numeric_value_constant field (their discriminating cue is state/safety/query-style, not a numeric axis)

## deviation_ref interpretation
- `required_row_fields` lists `deviation_ref:D-087`; interpreted as: field `deviation_ref` present on every row with value `D-087` referencing the batch3 query-reclassification authority.

## Streaming Flush (permanent from batch2)
- 5 segments (<=15 rows each), flushed after each family block / 15-row segment: volume(1-15), wiper(16-30), wiper(31-45), wiper(46-60), seat(61-75)
- segment files: candidates.segment-01..05.jsonl, value_change_ledger.segment-01..05.jsonl, segment_manifest-01..05.json, segment_SHA256SUMS.txt
- deterministic merge validated sample_id uniqueness + row counts + ledger parity + hash presence + candidate_row_sha parity

## No-call Envelope
- candidate_no_call_rows=19 query_rows=0 denom(excl query)=75 ratio=0.2533
- refusal_no_call_envelope_status = waiver_required
- NOTE: candidate pool ratio 0.2533 matches order.json batch_self_check candidate_no_call_ratio_excluding_query=0.2533 and exceeds the train-pack 20% cap BY DESIGN. This is a CANDIDATE pool, not a train pack. Assembler must downsample/stratify or obtain commander waiver before training. No training authorized.

## Stopped / Waived Items
- none. All 75 rows authored within contract; no `generation_blocked_*` conditions hit.
- No query tool fabricated for any family. No mandatory_first carry created (batch3 forbids). No volume query_current_volume row (bucket exhausted in batch2).

## Pending Controller Fields (NOT self-forged)
- main_pin_sha, recipe_manifest_sha, quota_config_sha = generation-stage PENDING placeholders; controller/prepare pipeline recomputes.
- prompt_hash / expected_tool_call_signature / tool_schema_digest / candidate_row_sha computed generation-stage over actual row bytes (own recipe, byte-identical to lane-c/d/e recipe); controller recomputes/verifies before judge.

## Mechanical Self-Audit
- `_scratch/audit_lane_g.py` result: ALL_GATES_PASS (exit 0)

## Non-claims
- generation stage only; NOT train-ready, NOT candidate-signed, NOT V-PASS, NOT run-auth. Judge (OpenAI-family) + DataGate + controller normalization NOT run by this lane.
