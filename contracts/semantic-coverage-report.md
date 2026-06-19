# Semantic Coverage Report

snapshot_id: `c1-2026-06-19-9b7e4b82`

## Ledger

| metric | value |
|---|---:|
| source_rows | 3990 |
| valid_contract_rows | 3990 |
| quarantined_rows | 0 |
| legacy_mapping_rows | 0 |
| unclassified_rows | 0 |
| canonical_semantics | 3917 |
| dedupe_primary_rows | 3917 |
| dedupe_variant_rows | 73 |
| followup_transition_rows | 3123 |
| followup_unresolved_rows | 27 |
| followup_unresolved_ratio | 0.0086 |
| value_present_rows | 1566 |
| value_absent_rows | 2424 |

## Source Domains

| domain | valid_contract_rows | source_rows |
|---|---:|---:|
| airControl | 178 | 178 |
| carControl | 2656 | 2656 |
| cmd | 1156 | 1156 |

## Device Aggregate

| service | contract_rows |
|---|---:|
| airControl | 178 |
| carControl | 2656 |
| cmd | 1156 |

## XLSX Gate Stats

| sheet | merged_ranges | merged_filled_cells | formula_cells | calculate_dimension |
|---|---:|---:|---:|---|
| airControl | 884 | 2676 | 0 | `A1:AE179` |
| carControl | 10127 | 36325 | 0 | `A1:AE2657` |
| cmd | 5009 | 14371 | 0 | `A1:AE1157` |

## Followup Stats

| sheet | transition_rows | merged_ranges | formula_cells |
|---|---:|---:|---:|
| airControl | 341 | 196 | 0 |
| carControl | 2782 | 1242 | 1 |

## Range Classification

| category | count |
|---|---:|
| placeholder_open | 0 |
| material_conflict | 0 |
| material_candidate | 2483 |
| none | 1507 |

Stage A has no C2 execution range authority yet, so concrete material conflicts are not asserted.

## Quarantine

| reason | count |
|---|---:|
| none | 0 |

## Redaction Notes

- Raw source xlsx files are outside the git repository.
- Raw Chinese example utterances are not written to JSONL/YAML; only normalized hashes are stored.
- Example hashes are integrity identifiers, not anonymization proof.
