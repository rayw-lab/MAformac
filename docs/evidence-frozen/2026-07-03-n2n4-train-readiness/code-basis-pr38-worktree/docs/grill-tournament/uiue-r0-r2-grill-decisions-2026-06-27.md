---
status: accepted_human_reviewed_formal_amendment
artifact_kind: formal_grill_amendment
date: 2026-06-27
repo: /Users/wanglei/workspace/MAformac-uiue
branch: uiue/phase4-default-scope-presentation
authority: UIUE R0-R2 grill amendment for post-8.C2 roadmap
source_artifacts:
  - docs/loop-competition/2026-06-27-uiue-r0-r2-grill-matrix/final-grill-matrix.md
  - docs/loop-competition/2026-06-27-uiue-r0-r2-grill-matrix/round-01/brain-1.md
  - docs/loop-competition/2026-06-27-uiue-r0-r2-grill-matrix/round-01/brain-2.md
  - docs/loop-competition/2026-06-27-uiue-r0-r2-grill-matrix/round-01/brain-3.md
  - docs/loop-competition/2026-06-27-uiue-r0-r2-grill-matrix/round-02/brain-1.md
  - docs/loop-competition/2026-06-27-uiue-r0-r2-grill-matrix/round-02/brain-2.md
  - docs/loop-competition/2026-06-27-uiue-r0-r2-grill-matrix/round-02/brain-3.md
  - docs/uiue-roadmap-2026-06-27-post-8c2-baseline.md
  - docs/uiue-storyboard-grill-decisions.md
non_claims:
  - no V-PASS
  - no mobile
  - no true_device
  - no runtime-ready
  - no voice-ready
  - no A-2 complete
  - no 8.C2 closure
---

# UIUE R0-R2 Grill Decisions Amendment

## Verdict

70 项 R0/R1/R2/R2b grill 清单已获人审通过，可以正式转写为后续路线图的 grill amendment。这个通过只表示“这些问题、门禁和债务可以进入正式决策账本”，不表示任何实现已经授权、完成或验收。

`docs/loop-competition/2026-06-27-uiue-r0-r2-grill-matrix/final-grill-matrix.md` 和六个 brain detail 文件保留为 loop-competition evidence / audit input；本文件是 R0-R2 后续推进的 formal amendment authority。OpenSpec SHALL、任务勾选、8.C2 closeout、L3/V-PASS 仍必须由各自 authority 单独承接。

## Canonical Groups

| canonical_group_id | source_cxx_ids | classification | authority_level | target_artifact | proof_class | owner | trigger | defer_reason | non_claims | summary |
|---|---|---|---|---|---|---|---|---|---|---|
| G-R0-CLOSEOUT-HYGIENE | C01,C02,C17,C18 | hard_gate | amendment_gate | closeout receipt, commit pathspec audit | local/docs-only | controller | any commit, closeout, or cascade update | none | no 8.C2 closure, no V-PASS | Dirty tree 分区、提交切片、status wording 和 pathspec 审计必须先于任何级联。 |
| G-R0-PROOF-STATUS-BOUNDARY | C03,C04,C20,C48,C69,C70 | decision | status_authority | OpenSpec tasks, evidence README, closeout receipt | local/docs-only | controller + L3 reviewer | any attempt to close 8.C2/A-2 or claim higher proof | L3 not signed | no mobile, no true_device, no A-2 complete | local/unit/simulator 证据不能升级为 L3/V-PASS；8.C2 仍 open。 |
| G-R0-CURRENT-BLOCKERS | C05,C06,C07,C08 | hard_gate | implementation_blocker | R0 repair receipt, evidence README | local/unit/simulator when implemented | implementation owner | current 8.C2 repair window | product/L3 findings still active | no L3 pass | cooling + ivory、模式联动、8 色、badge/toggle/options/readback 必须按 R0 owned proof 收口。 |
| G-R2B-CAPSULE-ANCHOR-ASSET | C11,C12,C19,C62,C63,C68 | decision | design_boundary | SD24/SD25, asset brief, capsule receipt | local/docs-only now; simulator/UI proof later | design + UIUE owner | capsule asset/layout work | final asset may change | no final-art acceptance | GPT Image 2/anchor 只作方向；内容资产不能带预烘焙白壳、图标或 chrome。 |
| G-R2B-VPA-ORB-STATES | C13,C14,C64,C65 | decision | design_boundary | SD16/SD18, VPA/orb receipt | local/docs-only now; simulator/UI proof later | design + UIUE owner | orb state, halo, or status copy work | L3 punchlist pending | no L3 pass | orb 必须回到 idle/listen/think/speak 四态；米白用实色渐变球 + 柔和 shadow，避免大面积外扩辉光。 |
| G-R2B-LAYOUT-SPACING | C15,C16,C56,C57,C58 | hard_gate | checker_spec | Layout Integrity Gate, Visual Spacing Sentinel | local/docs-only now; UI tree + screenshot later | test owner + UIUE owner | any top band/orb/card/mic layout change | checker not implemented yet | no aesthetic pass | 遮挡、留白、右侧按钮外置、胶囊居中、zone budget 和 mic dock 不遮挡必须进入结构门。 |
| G-R1-INTERACTION-SSOT | C21,C22,C24,C49 | decision | implementation_boundary | R1 Interaction Integrity plan | local/docs-only now; unit/UI later | UIUE owner | any new touch/readback policy | implementation shape needs pre-mortem | no implementation authorization | 可点性、writeback、readback、summary 必须消费同一 policy/mapper，不能新增第三份 SSOT。 |
| G-R1-MATRIX-PROOF | C23,C35,C37,C45 | hard_gate | checker_spec | interaction matrix, UI test receipt | local/docs-only now; unit/UI later | test owner | any claim of representative family coverage | matrix scope not finalized | no full matrix claim | 10 族代表控件必须按 value type、writeback、summary readback 和 proof device 建矩阵。 |
| G-R1-READONLY-AFFORDANCE | C25,C31,C46 | premortem | product_boundary | R1 design pre-mortem | local/docs-only | design + UIUE owner | any summary card or process-state control change | needs product decision | no direct control claim | 摘要卡、过程态和只读态不得显示假按钮；是否扩展 summary 直接调节需单独拍。 |
| G-R1-VALUE-CONTROL-SEMANTICS | C26,C27,C28,C29,C30,C32,C34,C47 | hard_gate | checker_spec | ValueControlView contract, UI tests | local/docs-only now; unit/UI later | UIUE owner + test owner | any dial/percent/stepper/toggle/badge change | code not authorized here | no runtime control claim | ring/percent/dial/stepper/toggle/badge 必须有空间语义、合法值域、mock writeback 和外层 readback。 |
| G-R1-A11Y-TESTABILITY | C10,C33,C38,C39,C40,C43,C44 | debt | merge_only_debt | accessibility/testability debt ledger | local/docs-only | accessibility/test owner | R1 hardening scope expansion | not P0 for current docs task | no a11y complete claim | 稳定 identifiers、VoiceOver adjustable、44pt touch、Reduce Motion 等需要按 R1 补强，不偷关 8.C2。 |
| G-R1-STABILITY-DEBT | C36,C50 | debt | merge_only_debt | debt ledger | local/docs-only | controller | post-R1 cleanup | lower priority than P0 blockers | no complete claim | flake、等待、债务 owner/proof/defer/trigger 要入账但不混入当前 closeout。 |
| G-R1-UIUE-VERIFY-GATE | C41,C42 | premortem | gate_candidate | future make verify-uiue-interactions decision | local/docs-only | controller + test owner | before adding a make target or precommit gate | needs grill decision | no global verify-all claim | 只能先作为 UIUE 专门门候选；不能直接塞进全局 `make verify-all`。 |
| G-R1-GEAR-DIRECT-TOUCH | C09 | premortem | product_boundary | R1 interaction pre-mortem | local/docs-only | product + UIUE owner | any direct gear touch proposal | gear is still context/instrument in current proof | no gear control claim | `vehicle.gear` 是否从只读 context 变成可直接触摸控制，必须单独 grill。 |
| G-R2-CASE-MATRIX | C51,C52,C53 | hard_gate | evidence_plan | R2 rerun plan | local/docs-only | evidence owner | before rerunning 8.C2 L0-L3 | case matrix not signed | no rerun authorization | cooling/ivory、模式切换、8 色、座椅、toggle/option、golden path 等 case 需先定 scope。 |
| G-R2-EVIDENCE-GATES | C54,C55,C59,C60,C61 | hard_gate | evidence_gate | L0/L1/L2 checker receipts | local/docs-only now; simulator/checker later | evidence owner | any L0/L1/L2 proof claim | evidence package not rerun | no L3 pass | on-screen simctl、UI tree fields、OCR/contrast、SSIM evidence、device/xcresult 必须完整。 |
| G-R2-L3-PUNCHLIST | C66,C67 | hard_gate | human_review_gate | L3 punchlist template | local/docs-only | L3 reviewer + controller | after L0/L1/L2 before asking final verdict | template not cascaded | no V-PASS | L3 前先过 punchlist：遮挡、留白、层级、手感、玻璃 artifact、状态表达。 |

## Formal Decisions

| decision_id | canonical_group_id | decision | target_artifact | non_claims |
|---|---|---|---|---|
| D-R0-001 | G-R0-PROOF-STATUS-BOUNDARY | `8.C2` 在磊哥 L3 复签前保持 open；local/unit/simulator proof 不得升级成 `V-PASS`。 | `openspec/changes/ui-presentation/tasks.md`, evidence README | no 8.C2 closure, no A-2 complete |
| D-R0-002 | G-R0-CLOSEOUT-HYGIENE | 当前 dirty tree 下，任何提交/级联前必须列 owned/unowned/no-touch，并用精确 pathspec。 | closeout receipt | no mixed commit |
| D-R1-001 | G-R1-INTERACTION-SSOT | Interaction Integrity 的真值必须来自 consumer policy / mapper 单源，不允许 view 内新增第二套 range、options 或 readback 规则。 | R1 plan, future implementation | no code authorization |
| D-R1-002 | G-R1-READONLY-AFFORDANCE | 只读/过程态不显示假 affordance；摘要卡默认仍是状态摘要，除非后续 pre-mortem 拍成可控。 | R1 plan, storyboard amend | no summary direct-control claim |
| D-R1-003 | G-R1-UIUE-VERIFY-GATE | `C41/C42` 只能先作为 UIUE 专门门候选；进入 `make verify-all` 前必须另做 grill 决策。 | future gate decision | no global gate claim |
| D-R2B-001 | G-R2B-CAPSULE-ANCHOR-ASSET | GPT Image 2/anchor 是方向和审美 bar，不是工程结构权威；最终 capsule chrome/mask/glass 由 SwiftUI 负责。 | SD24/SD25, asset brief | no final-art pass |
| D-R2B-002 | G-R2B-VPA-ORB-STATES | VPA/orb 必须表达 idle/listen/think/speak 四态；米白主题禁止用大面积外扩光晕抢层级。 | SD16/SD18 | no L3 pass |
| D-R2B-003 | G-R2B-LAYOUT-SPACING | Layout Integrity 和 Visual Spacing 是结构门，只挡遮挡/留白/zone budget/安全区，不替代审美判断。 | future checker spec | no aesthetic pass |

## Hard Gate / Checker Specs

| gate_id | canonical_group_id | trigger | minimum_inputs | pass_condition | fail_condition | proof_class | target_artifact |
|---|---|---|---|---|---|---|---|
| HG-R0-SCOPE | G-R0-CLOSEOUT-HYGIENE | commit, cascade, closeout | `git status --short --branch`, owned/unowned/no-touch table | owned paths only, no mixed code/docs/evidence scope | ambiguous dirty ownership or broad staging | local | closeout receipt |
| HG-R0-PROOF | G-R0-PROOF-STATUS-BOUNDARY | any completion claim | evidence layer, command output, L3 verdict file | claim matches proof class and L3 status | local/sim proof written as V-PASS/mobile/true_device | local/docs | README, tasks, receipt |
| HG-R1-MATRIX | G-R1-MATRIX-PROOF | R1 implementation claim | value type x family x action x writeback x readback table | every claimed representative has target id, writeback, summary readback | fake affordance, missing target, illegal value, stale summary | unit + simulator UI when implemented | R1 receipt |
| HG-R1-RANGE | G-R1-VALUE-CONTROL-SEMANTICS | value control change | mapper contract, UI action path, readback assertion | view maps gesture to progress only; mapper snaps/clamps | view defines second range/options contract | unit + simulator UI when implemented | ValueControl receipt |
| HG-R1-GATE-CANDIDATE | G-R1-UIUE-VERIFY-GATE | new make/precommit gate proposal | gate name, scope, runtime cost, owner, false-positive plan | UIUE-only gate approved by grill | added to global `make verify-all` without decision | local/docs | gate decision doc |
| HG-R2-L0 | G-R2-EVIDENCE-GATES | visual rerun | device, scheme, launchArg, theme, UI tree, screenshot path, proof class | on-screen `simctl io screenshot` and matching UI tree | Preview/ImageRenderer/static snapshot used as L0 | simulator L0 when rerun | evidence README |
| HG-R2-L1L2 | G-R2-EVIDENCE-GATES | machine visual proof | L1 PASS/WARN/FAIL, OCR, contrast, SSIM evidence | OCR/contrast hard gates pass; L1 FAIL blocks | RMSE/SSIM treated as aesthetic signoff | local checker when rerun | evidence README |
| HG-R2B-LAYOUT | G-R2B-LAYOUT-SPACING | top band/orb/card/mic/capsule change | UI tree frames, screenshot metadata, safe-area data | no overlap, min gaps met, zone budget respected | settings/refresh overlap capsule, white edge leak, mic covers card row | simulator UI + screenshot when implemented | Layout Integrity receipt |
| HG-R2-L3 | G-R2-L3-PUNCHLIST | before asking L3 verdict | punchlist template, L0/L1/L2 package, known non-claims | human reviews punchlist before final verdict | asking for binary pass while known punchlist is open | human L3 | `l3/human-5gate-verdict.md` |

## Pre-Mortem Questions

| premortem_id | canonical_group_id | question | recommended_default | required_before |
|---|---|---|---|---|
| PM-R1-001 | G-R1-INTERACTION-SSOT | `StateCellInteractionPolicy` 是新 policy、mapper projection，还是现有 mapper 的 read-only view？ | 先用 consumer-side projection，避免第三份 SSOT。 | R1 implementation plan |
| PM-R1-002 | G-R1-GEAR-DIRECT-TOUCH | `vehicle.gear` 是否应从 context/instrument 升级成直接触摸控制？ | 默认保持只读 context，除非另拍 gear demo 需求。 | any gear UI control |
| PM-R1-003 | G-R1-READONLY-AFFORDANCE | summary card 是否允许直接调节，还是必须先展开？ | 默认摘要只读，展开态控件可写回。 | summary direct-control work |
| PM-R1-004 | G-R1-UIUE-VERIFY-GATE | `make verify-uiue-interactions` 的范围、时长和失败归属是什么？ | UIUE 专门门，先不进 `make verify-all`。 | adding make target |
| PM-R2-001 | G-R2-CASE-MATRIX | R2 重跑 case 是最小 7 个，还是扩到 10 族 x 米白/深空 x a11y？ | 先定分层：L0 必跑集、UI test 回归集、unit 补充集。 | R2 rerun |
| PM-R2B-001 | G-R2B-CAPSULE-ANCHOR-ASSET | 新 capsule asset 是最终图、placeholder，还是 route spike 输入？ | 当前按目标 px 占位；最终 asset 单独 brief。 | replacing capsule asset |
| PM-R2B-002 | G-R2B-VPA-ORB-STATES | orb 四态由 mock state、gesture state 还是 voice event 驱动？ | 当前只做 presentation mock / status expression，不接 voice runtime。 | VPA/orb implementation |
| PM-R2B-003 | G-R2B-LAYOUT-SPACING | Layout Integrity checker 判定结构 bug 的阈值如何避免变成审美裁判？ | 输出 PASS/WARN/FAIL + evidence，禁止输出 V-PASS。 | checker spec |

## Merge-Only / Deferred Debt Ledger

| debt_id | source_cxx_ids | canonical_group_id | owner | defer_reason | merge_condition | non_claims |
|---|---|---|---|---|---|---|
| DEBT-R0-001 | C02,C18 | G-R0-CLOSEOUT-HYGIENE | controller | current worktree has unrelated docs/code/evidence dirty | pathspec audit before commit/cascade | no mixed commit |
| DEBT-R1-001 | C10,C33 | G-R1-A11Y-TESTABILITY | test owner | stable identifiers can be added with R1 matrix | every control row has deterministic id | no full testability claim |
| DEBT-R1-002 | C38,C39,C40 | G-R1-A11Y-TESTABILITY | accessibility owner | a11y proof is outside current docs task | adjustable action + touch target + Reduce Motion receipt | no a11y complete |
| DEBT-R1-003 | C36,C50 | G-R1-STABILITY-DEBT | controller | lower priority than P0 proof/status blockers | owner/proof/defer/trigger recorded in closeout | no debt-free claim |
| DEBT-R2B-001 | C62,C68 | G-R2B-CAPSULE-ANCHOR-ASSET | design owner | final art may change; current image can be placeholder | asset brief says content-only, no baked shell/chrome | no final-art pass |

## P0 Blocker Map

### status blocker

These block closing `8.C2` / `A-2` or upgrading status:

- R0 cannot close: C03, C04, C05, C06, C08, C13, C14, C15, C17, C20.
- R3 cannot cascade status upward: C69, C70.
- Extra closeout hygiene: C01, C18 are strong P1/P0 boundaries in the current dirty worktree.

### implementation blocker

These block starting or claiming a specific implementation without another grill / pre-mortem:

- R1 cannot claim completion: C22, C24, C25, C26, C27, C28, C30, C32, C34, C35, C37, C39, C42, C45, C48, C49.
- `C41/C42` specifically block direct promotion to global `make verify-all`; they require a UIUE-specific gate decision first.
- `C09` blocks direct gear touch claims until the product/control boundary is decided.

### evidence blocker

These block rerunning, signing, or accepting proof:

- R2/R2b cannot rerun or close: C51, C53, C54, C56, C57, C58, C59, C60, C63, C64, C65, C66, C67, C69, C70.
- Machine/local/simulator evidence cannot sign L3 or V-PASS.
- L3 punchlist must run after L0/L1/L2 and before final human verdict.

### cascade blocker

These block router/README/OpenSpec/state escalation:

- Do not update router documents to point at an authority that does not exist.
- Do not change OpenSpec SHALL/tasks until the relevant behavior/gate is actually accepted as a spec-level contract.
- Do not tick `8.C2` in `openspec/changes/ui-presentation/tasks.md` from this amendment.
- Do not write final matrix output directly into `docs/uiue-storyboard-grill-decisions.md`; this file is the formal authority.

## Doc Cascade Plan

| order | artifact | role | write | do_not_write | status_after_this_amendment |
|---|---|---|---|---|---|
| 1 | `docs/grill-tournament/uiue-r0-r2-grill-decisions-2026-06-27.md` | formal amendment authority | canonical groups, decisions, gates, blocker map, cascade plan | implementation diffs, completion claims | created |
| 2 | `docs/uiue-storyboard-grill-decisions.md` | narrative/design SSOT | light SD16/SD18/SD24/SD25 boundary notes and cross-link | raw 70-item checker matrix | amend only |
| 3 | `docs/uiue-roadmap-2026-06-27-post-8c2-baseline.md` | roadmap baseline | classify `SHOULD_GRILL` into decided/deferred/rejected/needs-premortem | OpenSpec SHALL, task completion | amend only |
| 4 | `openspec/changes/ui-presentation/specs/ui-presentation/spec.md` and `tasks.md` | behavior contract/task tracker | only later accepted SHALL/gates; `8.C2` remains unchecked | 70-item raw matrix, L3/V-PASS claim | future cascade, not this doc task |
| 5 | `docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/README.md` and `LESSONS.md` | evidence/lessons | later record findings, proof class, non-claims, rerun requirements | closing 8.C2 or replacing L3 | future cascade |
| 6 | `docs/CURRENT.md` and `docs/README.md` | router/map | after authorities exist, point to this amendment and updated roadmap | authority before artifact exists, status upgrade | future cascade |

## Machine-Readable Checklist

```yaml
amendment_id: uiue-r0-r2-grill-decisions-2026-06-27
status: accepted_human_reviewed_formal_amendment
implementation_authorized: false
close_8c2_allowed: false
claims_forbidden:
  - V-PASS
  - mobile
  - true_device
  - runtime-ready
  - voice-ready
  - A-2 complete
required_before_8c2_close:
  - R0 blockers resolved with owned proof
  - R1 interaction integrity scope decided or explicitly deferred
  - R2 L0/L1/L2 rerun package complete
  - R2 L3 punchlist reviewed
  - 磊哥 L3 verdict signed
gate_candidates:
  - make verify-uiue-interactions
  - Layout Integrity Gate
  - Visual Spacing Sentinel
```
