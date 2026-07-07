# UIUE Merge Battle Plan（2026-07-05）

> **authority**: implementation_plan_not_ssot；本文件是 UIUE 合流执行计划，不是 OpenSpec spec、不是 merge receipt、不是 V/S/U-PASS。
> **mode**: docs-only battle plan；本轮不改 Swift、不改 JSON fixture、不跑 build、不合并分支。
> **revision**: v2 after X4 request-changes；修正 W24 5-file historical anchor 漂移，加入 W50 10-family payload/UIUE consumer/visible smoke hard gate。
> **freshness rule**: 执行前必须重新跑 `git status --short --branch`、`git merge-base main uiue/phase4-default-scope-presentation`、changed-in-both 交集命令、line anchors。本计划引用 W24/W29/W43/W50/X4 与本轮只读探测，若 live main/UIUE 变动则以 live git 为准。
> **current truth at v2**: `/Users/wanglei/workspace/MAformac` 当前工作分支 head `67e720489f25acf6f346867a2cd8a938226977ca`，`main/origin/main=266783468ac38542574ea4787bec650d16ba6b02`，工作树有既有脏改；不能把这个脏工作树当 UIUE merge base。`/Users/wanglei/workspace/MAformac-uiue` branch `uiue/phase4-default-scope-presentation` head `56b0b95a3358f2a65e1cbcd60c3b3cde7ae444a6`，`main=266783468ac38542574ea4787bec650d16ba6b02`，merge-base `2091dbde3a8d6a59a96a419826f5695ed93f9e22`，live changed-in-both=`12`。

## 0. Recommendation

⭐ 推荐路线：**fresh-main selective port**，顺序固定为：

```text
thin Runtime -> Presentation bridge drift contract
  -> fresh main branch after formal-training artifacts are frozen
  -> classify live changed-in-both set（v2 实跑=12；W24 5 文件只是高风险核心，不再是完整清单）
  -> port only UIUE consumer/fixture/visual assets
  -> gates: OpenSpec + Swift/unit + make verify + W50 10-family payload/consumer smoke + iOS simulator visible card/readback smoke
```

反例路线「直接 merge `/Users/wanglei/workspace/MAformac-uiue`」不可取：W24 已给 `PARTIAL / HIGH_MERGE_RISK`，changed-in-both 正中 bridge consumer / fixture manifest / consumer tests / route docs（W24:164-176）。W29 进一步证明 drift 已发生，不是理论风险：schema sha 一致但 manifest 与 4 个 runtime fixture hash 漂移，`visualState` 从 main `changing` 漂到 UIUE `normal`，adapter type name 漂移但不应进共享 payload contract（W29:333-407）。

Direct merge 的最强反方观点也成立一半：直接 merge 会保留 UIUE 6 个领先 commit 的历史、让 Git 机械暴露冲突、并可能让 UIUE visual stack 一次性保持内部一致。但它仍输给 selective port，因为 live changed-in-both 已经从 W24 的 5 个扩到 12 个，冲突面包含 schema/manifest、phase0 receipts、roadmap 与 OpenSpec tasks；这些文件一旦与 bridge code 同批手解，最容易把 simulator/mock 证据、stale route 和 shared payload contract 混成一个假绿。

## 1. Scope Contract

**Goal**

- 把 UIUE 旧树从“开发基底”降级为“资产供体 + 证据源”，在 fresh main 上选择性 port。
- 先用 OpenSpec bridge contract 锁字段面，再做 Swift/fixture/visual port。
- 明确哪些文件 port、哪些弃、顺序、验收门和回滚线。

**Non-goals**

- 不在本计划里启动训练、推理、C6 acceptance、voice 实现、真实 ASR/TTS、mobile/true-device 验收。
- 不把 UIUE 8.C2 simulator/mock `PASS_WITH_NOTES` 升格成 A-2 complete、runtime-ready、UIUE merge、V/S/U-PASS。
- 不把 `StagePresentationSnapshot` 或 UIUE `PresentationSnapshot` 类型名写入共享 payload contract。

**Writable paths for later execution**

- OpenSpec: `openspec/changes/define-runtime-presentation-bridge/` 或新 change `openspec/changes/reconcile-runtime-presentation-public-payload-drift/`
- Main branch port candidate paths:
  - `Core/Presentation/RuntimePresentationPayloadFixtureConsumer.swift`
  - `Core/Presentation/RuntimePresentationConsumerMapping.swift`
  - `Tests/Fixtures/RuntimePresentationPayload/`
  - `Tests/MAformacCoreTests/RuntimePresentationPayloadFixtureConsumerTests.swift`
  - UIUE visual component paths only after bridge parity, to be enumerated from fresh diff.

**No-touch unless separately authorized**

- `Core/Training/`, C5 trainpack, model adapter artifacts, active run dirs.
- UIUE stale route docs copied wholesale into main.
- Any `docs/c5-training-readiness-grill/` untracked overlay from UIUE tree.

## 2. Recommended Route In Detail

### Phase A: Bridge Drift Contract First

Use W29 as propose skeleton and current bridge carrier as context. The change is contract-only.

1. Extend existing `define-runtime-presentation-bridge` if it is still the active carrier; otherwise open `reconcile-runtime-presentation-public-payload-drift`.
2. Lock public payload fields:
   - envelope: `schemaVersion`, `traceID`, `turnID`, optional `eventID`, `isTerminal`
   - outcome: `outcome.result`, optional `behaviorClassSource`, safe `reason`, `missingSlot`, `scopeFailureReason`
   - cards: `key`, `actualValue`, optional `desiredValue`, optional `availability`, optional `source`, `revision`, `visualState`
   - `cardSemantics`, `readbacks`, `reconciliation`, `traceEnvelope`
   - proof class and explicit non-claims
3. Decide the one real semantic drift: terminal accepted/readback-verified runtime fixtures use either `visualState=changing` or `visualState=normal`.
4. Record that manifest/schema/fixture corpus are main-owned; UIUE may copy unchanged or request main-owned update first.

Exit gate for Phase A:

- `openspec validate define-runtime-presentation-bridge --strict`
- Bridge spec includes the visualState owner rule and private-field deny-list.
- No Swift changes are required to declare this gate green.

### Phase B: Fresh Main Selective Port

Start a new branch from current `main` only after the execution owner confirms formal-training state and fresh git truth. Do not reuse the old UIUE branch as base.

Before editing, create the execution receipt section `changed_in_both_live` from:

```bash
cd /Users/wanglei/workspace/MAformac-uiue
base=$(git merge-base main uiue/phase4-default-scope-presentation)
comm -12 \
  <(git diff --name-only "$base"..main | sort) \
  <(git diff --name-only "$base"..uiue/phase4-default-scope-presentation | sort)
```

The v2 probe result is 12 entries, classified in §3. Treat W24's 5-file list as the high-risk core, not as the full inventory.

Port candidates:

| Candidate | Action | Reason |
|---|---|---|
| `Core/Presentation/RuntimePresentationPayloadFixtureConsumer.swift` | **Port/adapt selectively** | The field decoder and fail-closed behavior are useful. Keep main-owned field list; adapt only the local presentation type name required by fresh main. |
| `Core/Presentation/RuntimePresentationConsumerMapping.swift` | **Port only if fresh main lacks equivalent mapping** | It owns finite field/result/proof/private-marker vocab; do not create a second mapping table. |
| `Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json` | **Copy byte-for-byte / main-owned** | v2 live sha is identical on main and UIUE: `0833e599...`. It remains a stable anchor; no UIUE extension without OpenSpec. |
| `Tests/Fixtures/RuntimePresentationPayload/manifest.json` | **Do not take UIUE blindly** | Four runtime fixture sha values differ because `visualState` differs. Regenerate/copy after Phase A decision and after adding W50 10-family fixtures. |
| Four legacy runtime fixture JSON files | **Align to chosen visualState; then copy byte-for-byte** | Main has `changing`, UIUE has `normal`; either value may be chosen, but both trees must converge. |
| W50 10-family runtime payload fixtures | **Add after W50A/B wiring or fixture-path equivalent** | One payload per family: AC/seat/window/door/ambient/screen/volume/wiper/sunroof-or-sunshade/fragrance; all must have card + Chinese readback and pass UIUE consumer decode. |
| `Tests/MAformacCoreTests/RuntimePresentationPayloadFixtureConsumerTests.swift` | **Port strict tests and sibling parity; extend 10-family assertions** | Keep unknown-field fail-closed, timestamp rejection, private marker denial, proof cap, schema/manifest sha checks; add W50 10-family decode/readback/card assertions. |
| UIUE visual/mock-frontstage assets | **Port after bridge parity only** | W24 names useful assets: `PresentationSnapshot`, `MockPresentationSnapshotProvider`, `VehicleCardDisplay`, `ValueRangeMapper`, `DemoVehicleStateStore`, `DebugGallery`, `MicDock`, `DemoControlPanel`, `ContextCapsule`. Enumerate exact fresh diff before edit. |
| `.xcodebuildmcp` UIUE profile | **Use as runbook reference; do not overwrite main profile by default** | UIUE uses `MAformacIOS` + `iPhone 17 Pro Max`; main worktree may have its own simulator. Keep simulator separation to avoid bundle-id collision. |
| R3 `8.C2` closeout/evidence | **Reference, not proof uplift** | Useful as simulator/mock visual evidence only; not mobile/true-device/runtime/voice/model proof. |

Discard / do not port as authority:

- UIUE `docs/CURRENT.md` wholesale.
- UIUE `docs/README.md` wholesale.
- UIUE untracked `docs/c5-training-readiness-grill/`.
- UIUE untracked D12-D19 dispatches as live authority; keep only as historical provenance where D24 source manifest already classifies them.
- Any UIUE-local fixture hash or shared field that has not been accepted by main-owned bridge contract.

### Phase C: Visual/UIUE Port After Contract Parity

Only after Phase A and the live changed-in-both set is classified/reconciled:

1. Inventory UIUE visual assets by `git diff --name-status fresh-main...uiue/phase4-default-scope-presentation`.
2. Port UIUE visual/mock components in small slices:
   - presentation snapshot/provider
   - vehicle card/value mapper/state store
   - debug gallery/control panel/context capsule
   - mic dock/orb display states as UI choreography only
3. Keep proof class on every receipt: simulator/mock/local only.
4. Run W50 10-family payload/consumer gate after unit/verify gates.
5. Run simulator smoke after payload/consumer gate, not before.

## 3. Live Changed-In-Both Set

W24 的 5 文件冲突清单仍是高风险核心，但已经不是完整执行锚。X4 要求按 live git 复算；v2 复算结果如下：

```text
base=2091dbde3a8d6a59a96a419826f5695ed93f9e22
main=266783468ac38542574ea4787bec650d16ba6b02
uiue=56b0b95a3358f2a65e1cbcd60c3b3cde7ae444a6
changed-in-both=12
```

| File | main/uiue status | v2 disposition | Stop line |
|---|---|---|---|
| `Core/Presentation/RuntimePresentationPayloadFixtureConsumer.swift` | M/M; sha differs | **Port/adapt selectively** | No shared contract may mention `StagePresentationSnapshot` or UIUE `PresentationSnapshot`; local type names stay local. |
| `Tests/Fixtures/RuntimePresentationPayload/manifest.json` | M/M; sha differs | **Main-owned regenerate/converge** | Do not accept UIUE manifest hash changes until Phase A chooses `visualState` and W50 10-family fixtures are added/hashed. |
| `Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json` | A/A; byte-identical sha `0833e599...` | **Copy byte-for-byte / main-owned** | Any schema field change requires OpenSpec requirement + manifest update; no UIUE-only schema extension. |
| `Tests/MAformacCoreTests/RuntimePresentationPayloadFixtureConsumerTests.swift` | M/M; sha differs | **Port strict tests; extend for W50** | Keep fail-closed/private/proof/sibling parity tests; add 10-family decode/card/readback assertions before simulator smoke. |
| `docs/CURRENT.md` | M/M; sha differs | **Keep main; no wholesale port** | Do not resurrect D24/UIUE route text as current route authority or overwrite training/F044 current state. |
| `docs/README.md` | M/M; sha differs | **Keep main; union only provenance entries** | Imported UIUE entries must be `historical/provenance` or `simulator_mock_scope_only`; no readiness proof uplift. |
| `docs/project/phase0/r5-d22-runtime-payload-corpus-expansion-uiue-gate3-receipt-2026-06-30.md` | M/M; byte-identical sha `f335d0f...` | **Historical receipt; copy byte-for-byte if needed** | May be cited as provenance only; not a current readiness authority. |
| `docs/project/phase0/r5-d23-shared-schema-checker-uiue-receipt-2026-06-30.md` | A/A; byte-identical sha `3ac73e1...` | **Historical receipt; copy byte-for-byte** | Keep proof class as recorded; no simulator/mock uplift. |
| `docs/project/phase0/r5-d24-route-control-pr-merge-closeout-uiue-2026-06-30.md` | A/A; byte-identical sha `9fad611...` | **Historical closeout; copy byte-for-byte** | Do not make its route-control state current after main has advanced. |
| `docs/project/phase0/r5-d24-uiue-absorption-source-manifest-2026-06-30.md` | A/A; byte-identical sha `2f40312...` | **Source manifest; reference/copy byte-for-byte** | Use as inventory/provenance only; does not authorize merge by itself. |
| `docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md` | M/M; byte-identical sha `b9fc79b...` | **Historical roadmap; reference/copy byte-for-byte** | Must remain historical; no replacement of W43/W49/W50 order. |
| `openspec/changes/ui-presentation/tasks.md` | M/M; byte-identical sha `23ee560...` | **Review before reuse; likely historical/OpenSpec provenance** | Do not revive stale `ui-presentation` tasks as active carrier if `define-runtime-presentation-bridge` is current. |

The next subsections expand the five high-risk non-identical files from W24/X4. The seven byte-identical entries still stay in the execution receipt because Git reports them changed-in-both; their classification is what prevents silent route/proof/schema drift.

### 3.1 `Core/Presentation/RuntimePresentationPayloadFixtureConsumer.swift`

Evidence:

- PR38/main worktree consumer returns `StagePresentationSnapshot` at `RuntimePresentationPayloadFixtureConsumer.swift:14-20` and builds it at `:76-123`.
- UIUE consumer returns `PresentationSnapshot` at `/Users/wanglei/workspace/MAformac-uiue/Core/Presentation/RuntimePresentationPayloadFixtureConsumer.swift:14-20` and builds it at `:76-123`.
- Both sides decode the same public top-level field set at `:23-73`.
- Both sides decode card public fields and deliberately synthesize local `DemoVehicleStateCell.timestamp` at `:164-212`; public `cards[].timestamp` remains forbidden.

Disposition:

- **Keep** the shared decode/validation shape: strict top-level fields, card fields, proof validation, private-marker guard.
- **Do not** make `StagePresentationSnapshot` or `PresentationSnapshot` part of shared contract. That is local adapter naming.
- **Adapt** return type to fresh main's actual presentation type after branch creation.
- **Stop** if a proposed edit adds a new public payload field without OpenSpec requirement and schema/manifest update.

### 3.2 `Tests/Fixtures/RuntimePresentationPayload/manifest.json`

Evidence:

- Both sides bind the same main-owned schema sha `0833e599...` at manifest lines `3-11`.
- PR38/main runtime fixture sha anchors: window `:120-128`, screen `:141-149`, ambient `:162-170`, noop `:183-192`.
- UIUE runtime fixture sha anchors at the same manifest lines differ.
- Fixture JSON drift is concrete: PR38/main has `visualState: changing` at each runtime fixture `:19`; UIUE has `visualState: normal` at each corresponding fixture `:19`.

Disposition:

- **Main owns** `manifest.json` and fixture sha truth after Phase A.
- **Do not** accept UIUE manifest hash changes as a merge resolution.
- **Choose** `changing` or `normal` in OpenSpec first, then regenerate/copy all four runtime fixture JSON files and update manifest sha.
- **Stop** if schema sha stays equal but manifest/fixture sha diverges after the chosen visualState decision.

### 3.3 `Tests/MAformacCoreTests/RuntimePresentationPayloadFixtureConsumerTests.swift`

Evidence:

- Strict timestamp/unknown nested field tests live at `:24-53`.
- Unknown schema/proof/outcome/reconciliation fail-closed tests live at `:57-93`.
- Proof class mapping differs only by local type name: PR38/main uses `StagePresentationProofClass` at `:95-112`; UIUE uses `PresentationProofClass` at `/Users/wanglei/workspace/MAformac-uiue/Tests/MAformacCoreTests/RuntimePresentationPayloadFixtureConsumerTests.swift:95-112`.
- Manifest/schema/public field/private marker checks live at `:238-321`.
- Sibling main/UIUE corpus parity check lives at `:323-337`.

Disposition:

- **Port/keep** the strict tests.
- **Adapt** only type names to fresh main's final presentation API.
- **Add or retain** an explicit assertion for the chosen runtime fixture `visualState` semantics.
- **Keep** sibling parity guard; if the sibling checkout path changes, update path logic rather than deleting the gate.

### 3.4 `docs/CURRENT.md`

Evidence:

- UIUE tree `docs/CURRENT.md:18-30` is D24 absorption / PR #6/#7 route control and states not UIUE runtime/mobile/true-device/product readiness.
- Current main route board has advanced through C5 training readiness / R2b/R3 formal-training sequence; the current repo `docs/CURRENT.md` carries C5/F044 state and still treats UIUE merge as gated.
- W24 already flags UIUE route board as stale/conflicting and says main route authority should win (W24:181-190, W24:280-281).

Disposition:

- **Do not port** UIUE `docs/CURRENT.md`.
- After actual selective port branch passes gates, update main `docs/CURRENT.md` only with the new UIUE merge state and proof cap.
- **Stop** if a docs conflict resolution resurrects D24 PR #6/#7 as current route authority or overwrites formal-training current state.

### 3.5 `docs/README.md`

Evidence:

- Main `docs/README.md:15-22` maps current Post-C6 / bridge / phase0 authority entries.
- UIUE `docs/README.md:16-24` maps UIUE 8.C2/R3/R4/R5 evidence and route docs.
- W24 says route docs conflict because main has advanced through C5/N4 and stale UIUE docs could bury train-readiness authority (W24:181-190).

Disposition:

- **Do not copy** UIUE README wholesale.
- **Union only discoverability entries** that remain historically useful: R3 closeout, D24 source manifest, UIUE residual routing. Mark them `historical/provenance` or `simulator_mock_scope_only`.
- **Keep** main bridge carrier and current training route entries.
- **Stop** if README wording claims UIUE merge, runtime-ready, mobile, true-device, voice-ready, model-ready, V/S/U-PASS, or A-2 complete.

## 4. OpenSpec Propose Skeleton

Preferred implementation: **MODIFIED requirements under existing** `openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md`.

Fallback if the existing carrier is closed/archived before execution: open `reconcile-runtime-presentation-public-payload-drift`.

### Requirement: Public Payload Schema Is Main-Owned And Finite

The system SHALL define the Runtime -> Presentation public payload schema in mainline authority before UIUE consumes or extends it.

#### Scenario: Payload uses only public top-level fields

GIVEN a Runtime -> Presentation payload is serialized  
WHEN a consumer validates it  
THEN the payload SHALL contain only `schemaVersion`, `traceID`, `turnID`, `eventID`, `isTerminal`, `outcome`, `proofClass`, `cards`, `cardSemantics`, `readbacks`, `reconciliation`, and `traceEnvelope` at top level.

#### Scenario: Unknown public field fails closed

GIVEN a payload contains an unknown top-level field or an unknown `cards[]` field  
WHEN the UIUE fixture consumer decodes it  
THEN decoding SHALL fail closed.

### Requirement: Public Payload Excludes Volatile And Private Runtime Fields

The system SHALL omit top-level and card-level timestamps from the public payload while allowing trace-entry timestamps only inside `traceEnvelope.entries`.

#### Scenario: Public projection strips volatility

GIVEN main generates a public fixture from a runtime payload  
WHEN public projection is written  
THEN top-level `timestamp` and `cards[].timestamp` SHALL be absent.

#### Scenario: Private runtime markers are rejected

GIVEN a payload contains adapter-private or durable/raw markers  
WHEN main or UIUE validates it  
THEN validation SHALL reject `DemoRuntimeAdapter`, `RuntimeAdapterBox`, request fingerprints, ledger internals, raw runtime store, raw model output, and training receipt markers.

### Requirement: UIUE Consumes Main-Owned Fixture Schema Without Invention

The system SHALL require UIUE to consume only fields, result names, proof classes, and fixture metadata defined by main-owned schema/manifest artifacts.

#### Scenario: Schema/manifest/corpus parity is mandatory

GIVEN `Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json` or `manifest.json` changes in main  
WHEN UIUE copies or consumes fixtures  
THEN UIUE SHALL either copy the schema/manifest/fixture corpus unchanged or fail parity review.

#### Scenario: New UIUE field requests start in main contract

GIVEN UIUE needs a new shared field, result, visual-state meaning, or fixture hash  
WHEN it is not already in the main-owned schema  
THEN UIUE SHALL request a main-owned contract update before consuming it.

### Requirement: Runtime-Generated Fixture Visual State Is Contract-Owned

The system SHALL treat `cards[].visualState` in shared runtime-generated fixtures as Runtime -> Presentation contract semantics, not UIUE-local styling.

#### Scenario: visualState drift is reported

GIVEN main and UIUE differ on `cards[].visualState` for the same fixture case  
WHEN parity validation runs  
THEN the difference SHALL be reported as contract drift, not silently normalized.

#### Scenario: visualState decision converges hashes

GIVEN the project decides terminal accepted/readback-verified fixtures use either `changing` or `normal`  
WHEN the decision is recorded  
THEN main fixture JSON, UIUE copied fixture JSON, and manifest sha values SHALL converge to that single value.

### Requirement: Ten-Family Runtime Payload Smoke Covers W50 Display Surface

The system SHALL provide a model-free 10-family Runtime -> Presentation smoke corpus before UIUE visual port claims fixture or simulator readiness.

#### Scenario: 10-family payload fixtures exist

GIVEN W50 defines the display families AC, seat, window, door, ambient light, screen, volume, wiper, sunroof/sunshade, and fragrance  
WHEN main generates or accepts RuntimePresentationPayload fixtures  
THEN the fixture corpus SHALL include at least one accepted payload per family, each with at least one matching `cards[]` entry and one Chinese readback.

#### Scenario: UIUE consumer decodes all W50 fixtures

GIVEN the 10-family fixture corpus exists  
WHEN the UIUE fixture consumer decodes it  
THEN every fixture SHALL decode with the main-owned public schema, proof cap, private-marker deny-list, card key, and readback intact.

#### Scenario: Simulator smoke is case-defined

GIVEN the fixture corpus is decoded successfully  
WHEN simulator/mock smoke runs on the dedicated UIUE simulator  
THEN each family SHALL show a visible card label and visible readback text, and the result SHALL remain simulator/mock proof only.

### Requirement: Proof Class Remains Capped

The system SHALL cap Runtime -> Presentation public fixture proof at local/static/unit fixture contract evidence unless later authority explicitly upgrades proof class.

#### Scenario: Fixture decode does not upgrade proof

GIVEN UIUE decodes all public fixtures  
WHEN docs or UI copy describe the result  
THEN the claim SHALL NOT be runtime-ready, mobile, true-device, live API, UIUE merge, V/S/U-PASS, voice-ready, model-ready, golden-ready, endpoint-ready, or A-2 complete.

## 5. Validation Gates

Run in order; any failure stops the merge branch.

| Gate | Command / check | Proof class | Stop condition |
|---|---|---|---|
| Git freshness | `git fetch --all --prune`; `git status --short --branch` in both trees; run the §2 `changed_in_both_live` snippet. | local | Fresh main is not verified, working tree dirt is unowned, or changed-in-both list differs from the receipt without reclassification. |
| Changed-in-both receipt | Record the 12-file table from §3, including byte-identical files and dispositions. | local_static | Any entry lacks disposition (`port`, `keep-main`, `copy-byte-for-byte`, `historical-reference`, `discard`) before editing. |
| OpenSpec | `openspec validate define-runtime-presentation-bridge --strict` | local/OpenSpec | Missing SHALL coverage for fields, visualState, proof cap, private deny-list, or W50 10-family smoke corpus. |
| Fixture public producer | `swift test --filter RuntimePresentationPayloadPublicFixtureTests` | unit | Public projection/fixture sha/schema proof fails. |
| UIUE consumer | `swift test --filter RuntimePresentationPayloadFixtureConsumerTests` | unit | Unknown-field, private marker, proof cap, visualState, sibling parity, or W50 10-family decode assertion fails. |
| Core suite | `swift test` | unit | Any regression in Core tests. |
| Verify | `make verify` | local | Contract/codegen/reference/consistency gate fails. If Swift-inclusive proof is required, escalate to `make verify-all`. |
| W50 10-family payload smoke | Model-free static/L1 or fixture slow-path frames for AC/seat/window/door/ambient/screen/volume/wiper/sunroof-or-sunshade/fragrance -> C3 -> store -> `RuntimePresentationPayload`; assert card key/title + Chinese readback + proof cap. | local/integration/mock | Any family lacks payload, matching card, readback, or payload/store parity. |
| UIUE 10-family consumer decode | Decode the W50 10 payloads through the UIUE consumer; assert public fields, card key/title, readback, no private markers, and proof cap. | unit/integration/mock | Any W50 family decodes only via UIUE-local field or misses card/readback/proof cap. |
| Compile | `swift build` and/or Xcode build for `MAformacIOS` | local/build | Compile fails after port. |
| Simulator 10-family visual smoke | `MAformacIOS` on dedicated UIUE simulator, preferably `iPhone 17 Pro Max`; fixture-drive all W50 10 payloads; capture visible card label + readback for each family. | simulator/mock | App fails to launch, any family lacks visible card/readback, or route/proof copy implies mobile/true-device. |
| Docs proof cap | Grep docs/OpenSpec for proof-uplift tokens such as `V-PASS`, `S-PASS`, `U-PASS`, `true_device`, `mobile`, `runtime-ready`, `voice-ready`, and `A-2 complete`; review context. | local | Any new overclaim not inside non-claims/forbidden wording. |

## 6. Rollback Lines

Fail closed and do not merge the branch if any of these occur:

- Direct merge or selective-port prep reports a live changed-in-both set that is not fully classified in the receipt.
- `manifest.json` and fixture files do not converge to one schema/sha/visualState contract.
- A UIUE-local payload field appears without OpenSpec requirement and schema/manifest update.
- Tests pass only because sibling-main parity skipped due missing checkout; the merge owner must run parity in a layout where both trees exist before claiming green.
- `docs/CURRENT.md` or `docs/README.md` resurrects stale D24/UIUE route text as current mainline truth.
- W50 10-family payload smoke is missing, covers fewer than 10 families, or lacks card/readback assertions.
- Simulator smoke is generic launch-only or old-fixture-only, or is used to claim mobile, true-device, runtime-ready, voice-ready, model-ready, endpoint-ready, or V/S/U-PASS.
- Formal training/eval is actively consuming memory and UIUE build/simulator work would compete with MLX/eval resources; defer simulator work until the training receipt window is closed.

Rollback action is branch-scoped: keep the failed branch as evidence, write a short receipt with failing gate and sha, and return to the last green fresh-main base. Do not rewrite unrelated main history and do not revert user/other-agent dirty work.

## 7. Timing Relative To Formal Training

W43 order remains valid: **thin bridge -> UIUE/iOS selective port -> voice C7**.

Timing rule:

- During active formal training or active eval: only docs/OpenSpec contract work is allowed if it does not run model, simulator, Xcode, or heavy tests.
- After formal training artifacts are frozen and receipts are written: Phase A can finish and Phase B can start from fresh main.
- If formal training PASSes: UIUE selective port can proceed as simulator/mock/frontend work, but still cannot claim model quality, mobile/true-device, UIUE merge, or V/S/U-PASS without separate gates.
- If formal training FAILs: bridge contract still remains useful because it prevents field drift; UIUE visual port may proceed only if explicitly scoped as consumer/fixture/simulator proof and does not depend on candidate quality.
- Voice C7 remains after bridge/UI state vocabulary stabilizes; real ASR dependency work waits for explicit C7 authorization and resource clearance.

## 8. Execution Checklist

- [ ] Reconfirm live `main`, current execution branch, and UIUE HEAD; record SHAs in the eventual receipt.
- [ ] Re-run live changed-in-both command; classify every entry. Current v2 probe is 12, not W24's historical 5.
- [ ] Land bridge drift OpenSpec wording first; validate strict.
- [ ] Decide `visualState=changing` vs `normal` with a recorded rationale.
- [ ] Align manifest + four legacy runtime fixtures to the chosen value.
- [ ] Add or generate W50 10-family payload fixtures and manifest entries.
- [ ] Port/adapt consumer and tests in one narrow branch, including 10-family decode/card/readback assertions.
- [ ] Run unit/verify/build gates.
- [ ] Port visual/mock-frontstage assets in smaller follow-up commits.
- [ ] Run W50 10-family payload/consumer smoke.
- [ ] Run simulator 10-family visible card/readback smoke on dedicated simulator.
- [ ] Write closeout with proof-class caps and non-claims.

## 9. Source Ledger

- W24 UIUE tree audit: `W24-UIUE-TREE-AUDIT.md:11-21`, `:164-176`, `:214-242`, `:247-274`, `:280-281`.
- W29 thin bridge pre-research: `W29-THIN-BRIDGE-PRERESEARCH.md:15-24`, `:144-190`, `:247-331`, `:333-407`.
- W43 frontend line synthesis: `W43-FRONTEND-LINE-SYNTHESIS.md:8-26`, `:30-93`.
- X4 request-changes review: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/X4-REVIEW-W49.md:11-20`, `:22-53`, `:55-79`, `:188-201`.
- W50 live loop wiring design: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/W50-LIVE-LOOP-WIRING-DESIGN.md:13-23`, `:84-101`, `:122-141`, `:147-153`.
- X3 W50 adversarial review: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/X3-REVIEW-W50.md`（adapter mount / PR38 basis gap feeds W50, not a UIUE merge proof gate yet）.
- v2 live git probe: `git -C /Users/wanglei/workspace/MAformac-uiue merge-base main uiue/phase4-default-scope-presentation` -> `2091dbde3a8d6a59a96a419826f5695ed93f9e22`; changed-in-both `comm -12 ...` -> 12 entries in §3.
- PR38/main evidence worktree: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/code-basis-pr38-worktree/Core/Presentation/RuntimePresentationPayloadFixtureConsumer.swift:14-20`, `:76-123`, `:164-212`.
- UIUE live tree evidence: `/Users/wanglei/workspace/MAformac-uiue/Core/Presentation/RuntimePresentationPayloadFixtureConsumer.swift:14-20`, `:76-123`, `:164-212`.
- Manifest parity evidence: PR38/main and UIUE `Tests/Fixtures/RuntimePresentationPayload/manifest.json:3-11`, `:120-192`; runtime fixture `visualState` at `*runtime_public_payload.v1.json:19`.
- Consumer test evidence: `Tests/MAformacCoreTests/RuntimePresentationPayloadFixtureConsumerTests.swift:24-53`, `:57-112`, `:238-337` in both PR38/main evidence worktree and UIUE live tree.

## 10. Non-Claims

- This plan does not claim UIUE merge is done.
- This plan does not claim runtime-ready, mobile, true-device, live API, voice-ready, model-ready, golden-ready, endpoint-ready, A-2 complete, V-PASS, S-PASS, or U-PASS.
- This plan does not authorize direct merge of stale UIUE branch.
- This plan does not authorize training/eval/simulator concurrency during memory-constrained formal training windows.
