## 1. Schema & Checker (W6-C1)

- [x] 1.1 Update `contracts/demo-capability-matrix.json` schema to add `rejectionDemoProven: boolean` field (default `false`)
- [x] 1.2 Add `check_capability_matrix.py` rule: reject rows with `primary_class=fast_path_no_match_fallback` + `actionDemoProven=true`
- [x] 1.3 Add `check_capability_matrix.py` rule: enforce `rejectionDemoProven` field exists for all matrix rows
- [x] 1.4 Add `check_capability_matrix.py` rule: verify BF-8 receipts for rejection declare appropriate `matrix_ids` and do not overlap with execution receipts
- [x] 1.5 Update `test_check_capability_matrix.py` with test cases for rejection/execution isolation rules
- [x] 1.6 Run local verify: `make verify-c1-matrix` or equivalent subset passes

**Scope in:** Schema extension, checker rules, unit tests  
**Scope out:** Actual matrix row flips, BF-8 receipts, admission logic  
**Verification:** Unit tests pass; checker rejects test cases with rejection in `actionDemoProven`  
**Non-claims:** ≠ matrix proven flipped · ≠ BF-8 authorized · ≠ readback validated

## 2. Catalog & Manifest (W6-C2)

- [x] 2.1 Add `"open_ac"` to `Core/Contracts/DDomainMountedToolCatalog.swift` `mountedToolNames` set
- [x] 2.2 Update `demo-capability-matrix.json` matrix_id=1: set `mounted_status="mounted"`, `observed=true`, and populate `basis` field
- [x] 2.3 Verify catalog ⊆ manifest: confirm `open_ac` presence in both catalog and matrix_id=1
- [x] 2.4 Document manifest update method (script path or manual-with-justification) in basis field
- [x] 2.5 Confirm 后三族 (window/ambient/seat) remain excluded from catalog and manifest

**Scope in:** Catalog mount, manifest status update, consistency verification  
**Scope out:** Admission logic changes (already exists), readback probes, BF-8  
**Verification:** `DDomainMountedToolCatalog` contains `open_ac`; matrix_id=1 `mounted_status=mounted`; basis documented  
**Non-claims:** ≠ admission routing changed · ≠ readback green · ≠ BF-8 complete · ≠ 后三族 unlocked

## 3. Readback Probe (W6-C3)

- [x] 3.1 Create or update e2e test for utterance "打开空调" targeting matrix_id=1
- [x] 3.2 Verify admission accepts utterance and routes to `open_ac` tool call
- [x] 3.3 Verify tool execution produces observable AC power-on state delta in mock state
- [x] 3.4 Verify readback/TTS contains success language (e.g., "已打开空调")
- [x] 3.5 Run readback probe locally and confirm all assertions pass
- [x] 3.6 Run relevant `make` target subset and confirm green

**Scope in:** E2e behavioral test, state delta verification, readback validation  
**Scope out:** BF-8 authorization, remote Verify binding, proven flip  
**Verification:** Probe passes with hard assertions; state delta observed; readback validated  
**Non-claims:** ≠ BF-8 authorized · ≠ proven flipped · ≠ remote Verify green

## 4. Rejection Utterance Contract (W6-D1 - design/later implementation)

- [ ] 4.1 Document m5 (委婉表达) utterance patterns in `contracts/state-cells.yaml` or equivalent schema
- [ ] 4.2 Document m6 (能否问句) utterance patterns in same schema
- [ ] 4.3 Specify rejection readback language templates for fail-closed responses
- [ ] 4.4 Create readback probe for m5: verify utterance "有点冷" triggers rejection, no state delta, fail-closed readback
- [ ] 4.5 Create readback probe for m6: verify utterance "能调到24度吗" triggers rejection, no state delta, fail-closed readback
- [ ] 4.6 Confirm rejection probes pass with `no_state_mutation` verification

**Scope in:** Utterance contract documentation, rejection readback probes  
**Scope out:** BF-8 for m5/m6, `rejectionDemoProven` flip, admission implementation changes  
**Verification:** Schema/contract documents exist; probes verify no state change + fail-closed readback  
**Non-claims:** ≠ rejection BF-8 complete · ≠ m5/m6 proven flipped · ≠ admission logic implemented

## 5. BF-8 Execution for m1 (W6-E1 - requires human authorization)

- [ ] 5.1 Confirm W6-C3 readback probe passes (prerequisite)
- [ ] 5.2 Confirm remote Verify green at tip (prerequisite)
- [ ] 5.3 Prepare BF-8 authorization request: `matrix_ids=[1]`, `subject=open_ac execution`
- [ ] 5.4 Complete 磊哥 BF-8 human review ceremony
- [ ] 5.5 Generate independent BF-8 receipt (do not reuse matrix_id=4 receipt)
- [ ] 5.6 Flip `demo-capability-matrix.json` matrix_id=1 `actionDemoProven=true`
- [ ] 5.7 Commit changes with receipt path reference

**Scope in:** BF-8 human ceremony, receipt generation, proven flip for m1 execution only  
**Scope out:** m5/m6 rejection BF-8, remote Verify binding (separate task), training  
**Verification:** Receipt exists with correct `matrix_ids` and `subject`; matrix_id=1 `actionDemoProven=true`; commit pushed  
**Non-claims:** ≠ m5/m6 proven · ≠ VFY receipt · ≠ training started · ≠ 后三族 unlocked

## 6. Remote Verify Bind (W6-F1)

- [ ] 6.1 Push tip commit after W6-E1 BF-8 completion
- [ ] 6.2 Wait for remote Actions `verify-c1-matrix` to pass
- [ ] 6.3 Generate VFY receipt binding commit SHA + Actions run URL
- [ ] 6.4 Document receipt path in closeout or governance log

**Scope in:** Remote CI verification, VFY receipt generation  
**Scope out:** Further proven flips, rejection BF-8, implementation work  
**Verification:** Actions green; VFY receipt exists with SHA + URL  
**Non-claims:** ≠ m5/m6 BF-8 · ≠ further execution proven · ≠ training

## 7. Rejection BF-8 for m5+m6 (W6-E2 - deferred, requires W6-D1 + human authorization)

- [ ] 7.1 Confirm W6-D1 rejection utterance contract complete (prerequisite)
- [ ] 7.2 Confirm m5 and m6 rejection readback probes pass (prerequisite)
- [ ] 7.3 Prepare BF-8 authorization request: `matrix_ids=[5,6]`, `subject=rejection fail-closed`
- [ ] 7.4 Complete 磊哥 BF-8 human review ceremony (separate from W6-E1)
- [ ] 7.5 Generate independent BF-8 receipt for rejection
- [ ] 7.6 Flip `demo-capability-matrix.json` matrix_id=5 and matrix_id=6 `rejectionDemoProven=true`
- [ ] 7.7 Commit changes with receipt path reference

**Scope in:** Rejection BF-8 ceremony, receipt generation, `rejectionDemoProven` flip for m5+m6 only  
**Scope out:** Execution proven flips, training, 后三族  
**Verification:** Receipt exists with `matrix_ids=[5,6]` and rejection subject; m5/m6 `rejectionDemoProven=true`; `actionDemoProven` remains `false`  
**Non-claims:** ≠ execution proven changed · ≠ training · ≠ 后三族 · ≠ M5 `actionDemoProven` flipped

## 8. close_ac Matrix Gap Design (W6-B1 - design-only, no implementation)

- [ ] 8.1 Document `close_ac` matrix gap: catalog mounted but matrix lacks representative_tool mapping
- [ ] 8.2 Propose matrix_id assignment for `close_ac` (reserve slot or extend matrix)
- [ ] 8.3 Document admission entry requirements: utterance patterns for "关闭空调"
- [ ] 8.4 Document readback contract for `close_ac` success case
- [ ] 8.5 Add design appendix to this change or create run-root note with proposal
- [ ] 8.6 Mark as design-only: no implementation, no proven flip, no BF-8 until W6-A1/A2 complete

**Scope in:** Design documentation, matrix gap analysis, future proposal  
**Scope out:** Implementation, catalog/matrix changes, admission logic, BF-8, proven flip  
**Verification:** Design document or run-root note exists with complete proposal; marked as non-implementation  
**Non-claims:** ≠ close_ac implemented · ≠ matrix updated · ≠ BF-8 · ≠ proven · ≠ main path blocked

## 9. Governance & Documentation

- [ ] 9.1 Update relevant governance docs to reference `rejectionDemoProven` as separate metric
- [ ] 9.2 Document BF-8 分账 (execution vs rejection) in governance or ceremony docs
- [ ] 9.3 Verify `PHASE2_CODING_GATED` remains in effect (no accidental unlock)
- [ ] 9.4 Confirm 后三族 (window/ambient/seat) remain candidate-only, not mounted/proven
- [ ] 9.5 Confirm training轨道 remains blocked (禁训练)
- [ ] 9.6 Create closeout document with exact subject, verification results, proof class, and non-claims

**Scope in:** Documentation updates, stopline verification, closeout  
**Scope out:** Implementation work, BF-8 ceremonies, proven flips  
**Verification:** Docs updated; stoplines verified; closeout complete with all required sections  
**Non-claims:** ≠ 后三族 proven · ≠ training started · ≠ M5 actionDemoProven flipped · ≠ G9 complete
