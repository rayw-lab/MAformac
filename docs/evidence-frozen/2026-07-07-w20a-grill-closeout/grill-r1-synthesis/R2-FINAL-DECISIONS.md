# W20A Grill 定稿（R1 综合 + R2 双红队修订吸收）

status: GRILL_FINAL_PENDING_LEIGE_ITEMS
lineage: grill-topics(17) → 双卷对抗(A/B) + persona → cross-review(14C/3D, cite 9/9 TRUE) → R1-DECISIONS-DRAFT → R2 红队双路（甲 P0=0/P1=3、乙 P0=0/P1=3，两队独立共振 catalog 混淆）→ 本定稿
non_claims: 非实装授权（写码待磊哥 run-auth）；G1-G6 磊哥拍板项未决；非 V-PASS/candidate signoff。

## R2 红队修订（3 处技术拍更正，均双队共振或有新证据）

### 修订一（原技术拍 #7）：mounted catalog 与 562 全集彻底分离，本轮最小挂载
- ❌ R1 原拍「catalog 从 irMapCompiled.keys 562 全集派生 - 3 排除」**作废**。红队一手复算：562 名中仅 **136 个** device 在 `deviceCellMap`（24 executable device，`ToolContractCompiler.swift:455-489`），426 个挂进去 = name guard 通过但 C3 `no_execution_cell` 炸（`C3ExecutionPipeline.swift:490-527`）——现场表现从「未挂拒识」恶化成「模型选中但 runtime unsupported」；且 559 全集挂载扩大 honest-frozen-closeout 的 claim surface。
- ✅ 定稿：**双 artifact 分离**——`ir_map_fingerprint`（562 识别全集，bench/normalizer 用）与 `mounted_demo_catalog_sha`（W20A claimed runtime surface）。mounted catalog 从 **W20A claimed demo surface 派生（direct-value AC 温度数值类为核，最小挂载）**，不从全集减法派生。
- 硬门三件：① `mounted_catalog_all_names_resolve_to_execution_cell`（逐 name normalize 后断言 deviceCellMap 命中）② avoid-list 交叉校验（persona avoid 面的 tool name 不得 mounted）③ receipt 同时写两个 sha，名称语义分离。

### 修订二（原技术拍 #11）：receipt schema 扩字段必 bump v2
- R1 原拍「扩 schema 加 runtime_target」保留，但**必须 bump `runtime_adapter_mount_receipt.v2`**（乙队新证据：validate 现只查 schemaVersion 非空不查值，`RuntimeAdapterMountReceipt.swift:152-164`；v1 已随 ed69a935 收基线，同名 v1 双语义会污染历史 evidence）。
- 定稿：v2 + validate 精确校验 schemaVersion 常量；`runtime_target` **由 readback XCTest helper 从实际运行 destination 探测生成**（非调用方传串）；negative test：Mac helper 产出的 receipt 写 ios_sim 必 fail；P4 门同时收 xcodebuild iOS destination stdout artifact 与 receipt 字段，不一致 BLOCK。v1 只 decode 历史 evidence，不可作 W20A closeout receipt。

### 修订三（原技术拍 #12）：升级为「直接修 helper」最强修法，消灭而非绕过 P1
- ❌ R1 原拍「禁调 + 注释 + 静态测试」不充分（双队共振：黑盒测试证不了「没在某分支调用」；注释非机械门；复制 helper 逻辑不调函数名可绕过静态门）。
- ✅ 定稿（乙队最强修法）：**W20A P1-S2 scope 内直接修 `decodeNonStreamingCompletion`**——加 `allowedToolNames` 参数复用 `decode(_:)` 的 guard 语义（`ToolCallFrame.swift:306-319`），P1 被消灭而非条件化。叠加：① 静态 guard（production source 中该 helper 调用只允许出现在 tests）② 行为负例 target test 三类必覆盖：未挂 catalog 名 / by_exp / lock_ac → reject before normalize & before C3。
- 效应：G3（磊哥拍板项「W18 P1 节奏」）**收窄**——修 helper 已并入 W20A scope，不再是「先修 vs 接受 conditional-moot」二选一。G3 从拍板清单撤销。

## 维持项
- R1 的 14 条 CONSENSUS 落定、技术拍 #6（capabilityID=cabin.<device>，红队双队均判 paper-tiger：不撞 C3 执行；吸收甲队建议——W20A 文档标注它是 internal IR-derived trace id ≠ contracts/capabilities.yaml 的 capability contract）、缺维吸收 4 条全维持。
- 红队 elephant（甲队）：demo 现场「模型选中但 unsupported」的兜底话术需与 G2 文案一起拍——已并入 G2。

## 磊哥拍板项（G3 撤销后剩 5 项）
| # | 问题 | ⭐建议 |
|---|---|---|
| G1 | iOS 实测门是否保留（现场若只演 Mac） | ⭐保留 iOS 门不 waiver |
| G2 | malformed/unsupported 兜底 TTS 文案 | ⭐「这个我先记下来，稍后帮您处理」类中性短句 |
| G4 | demo 话术 allow/avoid 清单进 operator runbook | ⭐采纳 persona 草案（runbook 草稿已备）|
| G5 | 对外是否展示 axis-D 聚合数 | ⭐不展示，只说「演示 direct-value 链路」 |
| G6 | RT-6 无真异源时磊哥/人审替代并签 accepted residual | ⭐接受 |
