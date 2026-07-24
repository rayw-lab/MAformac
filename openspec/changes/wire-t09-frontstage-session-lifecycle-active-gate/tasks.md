# Tasks: wire-t09-frontstage-session-lifecycle-active-gate (K3)

```text
change_id: wire-t09-frontstage-session-lifecycle-active-gate
authority: W8-K3-HUMAN-AGREE-RISK-ACK-BINDING
basis_head_expected: f5c963fcb5d48a5d7c0ace67a423ac1a39517313
packet_sha: 38d974643318d0bc2dad103016de536bc1b60c49eacf9339a82d8871d06ad9ea
claim_markers_sha: ab862712430f9da4f1e87cebef325b8696bae5c766d68e4e2d311da11a97076e
status: K3_CLOSEOUT_DONE_LOCAL_PRODUCTION_SHAPED
self_signed_review_clear: false
proof_ceiling_now: DONE_LOCAL_PRODUCTION_SHAPED
proof_ceiling_conditional: DONE_LOCAL_PRODUCTION_SHAPED
coding_writer: Grok released
independent_reviewer: Codex controller released
```

> 格式：numbered `##`；本 closeout 将 0.1–11.1 真实完成项勾 `[x]`。
> **严格 RED→GREEN** 已落地；independent review CLEAR 由 Codex controller 裁决。
> proposal / design / spec **未改**。

## 0. Authority / binding / review / rehash

- [x] 0.1 Cite-verify HUMAN_AGREE binding sidecar 与 packet / CLAIM / HEAD。
  - Output: 对照
    - binding: `.../W8-K3-HUMAN-AGREE-RISK-ACK-BINDING.md` sha `5b4fda7888435f85d1dd4960a2cabf564e368122f6c58e232793c7ad5c534782`
    - packet SHA `38d974643318d0bc2dad103016de536bc1b60c49eacf9339a82d8871d06ad9ea`
    - CLAIM markers SHA `ab862712430f9da4f1e87cebef325b8696bae5c766d68e4e2d311da11a97076e`
    - `git rev-parse HEAD` == `f5c963fcb5d48a5d7c0ace67a423ac1a39517313`
  - Acceptance: 全一致；分歧 → **HOLD** re-agree。
  - Superpowers: `[verification]`

- [x] 0.2 Confirm CRITICAL risk-ack + W5c narrow override still bound.
  - Output: class CRITICAL 225/223；method LOW 3/1/process1 非替代；override = property + routeDemoSlice guard only。
  - Acceptance: 无扩大 override 计划。
  - Superpowers: `[verification]`

- [x] 0.3 Independent controller review of this OpenSpec four-piece（producer ≠ auditor）.
  - Output: OpenSpec agree receipt sha `7107741b3170fc66bd567a8da96494bc0fb04f98333904ce9485405c03e1fc3b`；controller final review v2 P0/P1/P2/P3=0；CLEAR_FOR_DONE_LOCAL_PRODUCTION_SHAPED。
  - Acceptance: status 仅由 controller 记录前进；**禁止** producer self-CLEAR（held）。
  - Superpowers: `[verification]`

- [x] 0.4 Fresh rehash / basis check before any code edit.
  - Output: HEAD、status、worktree path 与 binding 对照；code 三 SHA exact 保持。
  - Acceptance: basis 未漂。
  - Superpowers: `[verification]`

## 1. Targeted RED tests first

- [x] 1.1 CREATE only `Tests/MAformacCoreTests/SessionLifecycleCompositionGateTests.swift` with **failing** tests first.
  - Coverage required:
    - first activation → active；revision 行为符合 design
    - repeat ensureActive idempotent；revision 不增
    - cross-session → zero mutation + typed fail
    - non-active / identity mismatch fail-closed
    - **source-contract**：读 `App/FrontstageRuntimeComposition.swift` 证明 ensureActive-before-route 顺序与 gate property（实现前应 RED）
  - Acceptance: 测试编译可跑且 **RED**（实现前）— evidence sha `da0579cf6ccda183cfe78ad46aaf8166a0bb1b7c5d93ab19f0b7c32031658917`；rc1；missing gate/error type。
  - Superpowers: `[TDD]`

## 2. Gate GREEN

- [x] 2.1 CREATE `Core/Lifecycle/SessionLifecycleCompositionGate.swift` minimal GREEN.
  - API: public `@MainActor final class`；private owner + coordinator；bound SessionID + gen 0；`ensureActive(expectedSessionID:)` throws + returns immutable snapshot；optional read-only snapshot；**no** terminal API。
  - Acceptance: unit 侧 first/idempotent/cross-session/non-active 变 GREEN；gate sha `ae0de5012366771922f128091afd07f3704715ae843c3cffde7bd9ba7fe0e14f`。
  - Superpowers: `[TDD]`

## 3. App composition minimal MODIFY

- [x] 3.1 MODIFY only `App/FrontstageRuntimeComposition.swift`.
  - Add lazy optional private gate property default nil（init 保持现有赋值）。
  - `routeDemoSlice`: current-turn precondition → lazy create gate(session.sessionID, gen0) → ensureActive(turn.sessionID) → guard snapshot ID + active → then existing DemoSliceRoute。
  - Acceptance: 无其它文件 coding diff；ContentView/runner/pipeline/DemoSliceRoute 零改；App sha `bf01786bf4e54c36466119ba44d7631be2ca666e4585ba11e50e57a256332ae5`。
  - Superpowers: `[TDD]`

## 4. Targeted tests GREEN

- [x] 4.1 Re-run `SessionLifecycleCompositionGateTests` until **all targeted GREEN**.
  - Acceptance: unit + source-contract 全绿 — **rc0 · 6/0**。
  - Superpowers: `[TDD]` `[verification]`

## 5. Full swift test

- [x] 5.1 Run full package test suite (`swift test` 或项目等价入口).
  - Acceptance: 全绿 — **rc0 · 843 executed / 6 skipped / 0 failures**；无 NOT_TOUCH 面失败被“改测放过”。
  - Superpowers: `[verification]`

## 6. OpenSpec strict

- [x] 6.1 `openspec validate wire-t09-frontstage-session-lifecycle-active-gate --strict` rc0.
- [x] 6.2 Project-required `openspec validate --all --strict`（或等价）rc0.
  - Acceptance: 双绿；**32/32**；失败不改 base spec 蒙混。
  - Superpowers: `[verification]`

## 7. Local App builds

- [x] 7.1 iOS Simulator generic build:

```bash
xcodebuild -project MAformac.xcodeproj -scheme MAformacIOS -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

- [x] 7.2 macOS build:

```bash
xcodebuild -project MAformac.xcodeproj -scheme MAformacMac -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO build
```

  - Acceptance: 双 build 成功（exact `CODE_SIGNING_ALLOWED=NO`；Mac rc0；iOS generic simulator rc0）。
  - Superpowers: `[verification]`

## 8. Deliberate-red

- [x] 8.1 Temporarily break ensureActive-before-route order **or** cross-session/state guard；证明 tests **must** go RED.
- [x] 8.2 Restore exact implementation；re-GREEN.
  - Acceptance: red 有牙 + restore exact；deliberate-red report sha `9b4d33948ea2f2c36e7dc5a098c02d13402f2948f5a679c783243a6b599dea3e`；临时把 DemoSliceRoute 构造移到 ensureActive 前 → 同 targeted rc1 · 6 tests/1 failure（唯一 ordering source-contract）；恢复后三 SHA exact · 同 targeted 6/0。
  - Superpowers: `[verification]`

## 9. GitNexus + detect_changes

- [x] 9.1 **Before edit**（若尚未在 0.x 做过 live）：fresh GitNexus impact on live basis；class CRITICAL 225/223 already acked — 重跑确认未静默漂移。
- [x] 9.2 **After edit**：`detect_changes`（或项目等价）证明变更集 ⊆ CREATE×2 + MODIFY×1；无 NOT_TOUCH 泄漏。
  - Acceptance: pre-edit class CRITICAL 225/223 + routeDemoSlice LOW 3/1/process1；after-edit changed_symbols=3 (routeDemoSlice, class, init) · changed_files=1 tracked · affected=0 · risk=low；untracked CREATEs 由 `git status` exact-set 补齐，**不能**写成 GitNexus 看见它们。
  - Superpowers: `[verification]`

## 10. Independent Codex controller verifier + closeout

- [x] 10.1 Non-producer Codex controller verifier：P0/P1 = 0（最终 P0=0 · P1=0 · P2=0 · P3=0）。
- [x] 10.2 Closeout reports only after gates；claim ≤ `DONE_LOCAL_PRODUCTION_SHAPED`；否则保持 HOLD。
  - Acceptance: producer **不** self-agreed；verifier ≠ writer；verdict `CLEAR_FOR_DONE_LOCAL_PRODUCTION_SHAPED`；implementation/review/state/active/closeout v2 落盘。
  - Superpowers: `[verification]`

## 11. No commit / push

- [x] 11.1 Explicit no-op gate: **no** commit / merge / push / PR unless 另键授权。
  - Acceptance: git log 无本波次擅自 commit；status 可脏但无 push。
  - Superpowers: `[verification]`

---

## Closeout footer

- status: `K3_CLOSEOUT_DONE_LOCAL_PRODUCTION_SHAPED`
- proof_ceiling_now: `DONE_LOCAL_PRODUCTION_SHAPED`
- coding_writer: **Grok released**
- independent_reviewer: **Codex controller released**
- active WIP: **0**
- nonclaims: no runtime / no operator / no mobile-true_device-live_api / no V-PASS / no global runner gating / no K2-K4-K5-K6 completion / no commit-merge-push-PR
- OpenSpec proposal/design/spec = **frozen unchanged** this secretary wave
