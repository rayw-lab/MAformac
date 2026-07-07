# R2b S2 batch2 lane-e Generation Receipt

status: generation_complete_data_only
artifact_kind: lane_generation_receipt
proof_class: local_generation_stage_data_only
lane_id: r2b-s2-lane-e
batch_id: r2b-s2-batch2

## Generator
- vendor/source: anthropic
- model: claude-opus-4-8 (Opus generation-only lane; feedback-opus-generation-only)
- generation mode: scripted, deterministic, re-runnable (`_scratch/gen_lane_e.py`) with segmented flush
- prompt package: wave2-negatives/batch-package/lane-prompt-package.md#S2 Batch2 Addendum: lane-e / lane-f
- batch order: wave2-negatives/batch-package/r2b-s2-batch2-order.json (lane-e block)
- tool surface: `_scratch/tool_catalog.json` (window byte-identical to lane-c-tool-schemas.json; atmosphere_lamp/volume from same authoritative D-domain catalog)

## Row Accounting (75 = window30 + atmosphere_lamp30 + volume15)
- window: positive19 query0 refusal2 already_state3 unsupported3 followup3
- atmosphere_lamp: positive22 query0 refusal1 already_state3 unsupported2 followup2
- volume: positive4 query8 refusal1 already_state1 unsupported0 followup1
- class totals: {'positive': 45, 'refusal': 4, 'already_state': 7, 'unsupported': 5, 'followup': 6, 'query': 8}

## Contrastive Pair Floors (fresh, _E suffix, no collision with sivd_*/scr_*/wrf1_1..4/win_*/volume_VRA_*)
- window_repair_after_F1: 4 groups (min 4) — numeric_value_constant=true, F1 lesson held
- window_to_by_little_number: 4 groups (min 4) — to/by=true, little/number=value_is_cue
- atmos_little_vs_number: 3 groups (min 3; batch2 cumulative target 5 with lane-f) — value_is_cue
- atmos_gear_min_max_vs_number: 2 groups (min 2; batch2 cumulative target 5 with lane-f) — value_is_cue
- volume_query_current_vs_adjust: 2 groups (min 2; batch2 cumulative target 5 with lane-f) — query mate read-only query_current_volume, action mate mutating; not numeric value-bearing (no numeric_value_constant field)

## D-087 Query Boundary
- volume query rows: 8, all `query_current_volume`, non-mutating, has_action_tool_call=false
- window/atmosphere_lamp query-style utterances -> unsupported + NO_TOOL + no_call.reason=no_available_query_tool + target_tool_present=false + query_reclass_reason_for_unsupported_query_style
- no query_window_*/query_atmosphere_lamp_* tool mounted or expected anywhere

## R2B-NVC-01
- structured `numeric_value_constant` present ONLY on value-bearing pair rows (window_repair_after_F1=true; window_to_by_little_number=true|value_is_cue per pair; atmos_little_vs_number / atmos_gear_min_max_vs_number=value_is_cue)
- legal values only: boolean true or string "value_is_cue"; evidence prose is NOT the field
- volume_query_current_vs_adjust and all non-pair rows carry NO numeric_value_constant field (query-vs-action is the cue, not a numeric axis)

## deviation_ref interpretation
- `required_row_fields` lists `deviation_ref:D-087`; interpreted as: field `deviation_ref` present on every row with value `D-087` referencing the batch2 query-reclassification authority (documented so commander can adjudicate口径 if a different literal was intended).

## Streaming Flush (permanent from batch2)
- 5 segments (<=15 rows each), flushed after each family block / 15-row segment
- segment files: candidates.segment-01..05.jsonl, value_change_ledger.segment-01..05.jsonl, segment_manifest-01..05.json, segment_SHA256SUMS.txt
- deterministic merge validated sample_id uniqueness + row counts + ledger parity + hash presence + candidate_row_sha parity

## No-call Envelope
- candidate_no_call_rows=16 query_rows=8 denom(excl query)=67 ratio=0.2388
- refusal_no_call_envelope_status = waiver_required
- NOTE: candidate pool ratio 0.2388 exceeds train-pack 20% cap by design; assembler must downsample/stratify or obtain commander waiver before training. This is a CANDIDATE pool, not a train pack. No training authorized.

## Stopped / Waived Items
- none. All 75 rows authored within contract; no `generation_blocked_*` conditions hit.
- No query tool fabricated for window/atmosphere_lamp/wiper. No mandatory_first carry created (batch2 forbids).

## Pending Controller Fields (NOT self-forged)
- main_pin_sha, recipe_manifest_sha, quota_config_sha = generation-stage PENDING placeholders; controller/prepare pipeline recomputes.
- prompt_hash / expected_tool_call_signature / tool_schema_digest / candidate_row_sha computed generation-stage over actual row bytes (own recipe, verified byte-identical to lane-c/d); controller recomputes/verifies before judge.

## Mechanical Self-Audit
- `_scratch/audit_lane_e.py` result: ALL_GATES_PASS (exit 0)

## Non-claims
- generation stage only; NOT train-ready, NOT candidate-signed, NOT V-PASS, NOT run-auth. Judge (OpenAI-family) + DataGate + controller normalization NOT run by this lane.
