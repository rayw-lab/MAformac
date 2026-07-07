# W20A Grill R1 综合定稿（草案，待 R2 红队 + 磊哥拍板项）

status: R1_SYNTHESIS_DRAFT
inputs: grill-topics(16+RT-6) / answers-A(%12) / answers-B(%14) / persona(%16) / cross-review(%15, 14C/3D, cite 抽核 9/9 TRUE) / w9-review(%12, CONDITIONAL) / superaudit-absorption(19F/1P/0D)
non_claims: 非实装授权（W20A 写码仍待磊哥 run-auth）；非 V-PASS/candidate signoff；磊哥拍板项未决前不落 decisions.md。

## 一、CONSENSUS 直接落定（14 题，R2 红队可攻但需新证据才翻）

| # | 落定 |
|---|---|
| 1 | 旧 `decode:306` 禁回流：W20A 任务单标 D-111 stale wording + target test `legacy_decode_forbidden_for_ddomain_tool_call` |
| 2 | ir_map ⭐C 编译常量 `DDomainIRMap.generated.swift` 进 Core，codegen 挂 make verify，**generator 必须定 canonical serialization（sorted keys）防 fingerprint 假 drift** |
| 3 | P4 硬绑 iOS Simulator destination + `runtime_target=ios_sim`；Mac-only 只算 local/mac proof；跳 iOS 实测须磊哥 waiver |
| 4 | 单一 chokepoint 在具体 `LLMBackend.generateToolPlan`；router 薄适配取首帧；**显式声明 streamText 不参与 W20A 接线** |
| 5 | `FrameDecoder` 升 async throws；不做同步等待 adapter；**注意勿把模型工作卡 @MainActor（实装加 elapsed 观测）** |
| 8 | slot 投影：direct-value 温度 drop direction/mode（白名单保留制）；`ac.power=on` 合法副作用；trace 必有 `slot_projected` |
| 9 | malformed 兜底：typed failure taxonomy（parse_failed/name_rejected/ir_unclassified/bridge_failed）→ unsupported payload + TTS 短句；文案磊哥拍 |
| 10 | claim-envelope 门只扫新收尾 claim artifacts；positive+negative fixture 自测必跑；历史 evidence 不 gate |
| 11 | receipt 必由 readback XCTest 产出，绑 HEAD/adapter/catalog/iOS target；手写不过门 |
| 13 | P3 技术 ledger + demo phrase allow/avoid + out-of-claim banner；具体话术磊哥拍 |
| 14 | axis-D 聚合数必标 not-health-anchor；子类表述（direct-value 增益/EXP 系统坏/新 regression 三栏） |
| 15 | readback basis 固定 C6 direct-value 案 + receipt 绑五 sha/ref；full-suite gap 单列 residual |
| 16 | 结构化 trace reason（finite set）+ redacted raw hash + readback artifact；30 秒 operator recovery 目标 |
| 17 | RT-6 升为 P4 closeout human-review gate（不阻塞实装起步）；无真异源时磊哥/人审签 accepted residual |

## 二、Commander 技术拍（4 项，本稿落定）

1. **#6 capabilityID**：`agentID="vehicle-control"` 常量 + `capabilityID="cabin.<device>"` device 派生——与现有 `decodeContentFallback` 构造 pattern 一致（ToolCallFrame.swift 现行 `capabilityID: "cabin.\(device)"`），不造新映射。若日后进 UI/客户话术再由磊哥拍命名。`candidateSource=.modelRouter` 固定。
2. **#7 mounted catalog**：采 B 卷强化——catalog 从 `irMapCompiled.keys` 全集派生 + runtime exclusion list（by_exp×2 + lock_ac）**不手写第二份全集**（derivation-layer 铁律：第二 SSOT 必契约测试约束）；canonical sha = sorted keys + LF 的确定性序列化后 sha256，门/receipt/ledger 共用一个计算函数。
3. **#11 runtime_target 承载**：**扩 `RuntimeAdapterMountReceipt` schema 加必填 `runtime_target` 字段**（非 sidecar）——impl-plan P4-2④(v) 原文即要求「receipt 带 runtime_target: ios_sim 字段」，sidecar 会造成 receipt 与 evidence 分离的第二真相源。schema 演进属 W20A 实装面。
4. **#12 W18/W19B stage0**（吸收 W13 CONDITIONAL）：
   - W18/W19B 已收基线（commit ed69a935/72fd2ac0，message 明记已知 P1 不声称 clean foundation）= P2-N4 满足。
   - **P1 的 moot 是条件性的**：W20A 实装必须加 target test 断言「具体 backend 禁调 `decodeNonStreamingCompletion`」+ 该 helper 加代码注释标记 P1 风险；P1 本体修复（给 helper 加 allowlist 参数）不阻塞 W20A，登记 DEFER ledger（W18 P1 行已在 impl-plan P3 表）。
   - 节奏（先修 P1 再 W20A vs 接受 conditional-moot 进 W20A）仍留磊哥拍——⭐建议后者（demo 主路不经旧 helper，条件已被 target test 机械化）。

## 三、双盲缺维吸收（4 条，进 W20A 实装 checklist）

1. grill-topics frontmatter `topic_count:16` 与实际 17 题 drift——本稿即修正口径：17 题。
2. `runtime_target` schema 缺口——已由技术拍 #3 落定（扩 schema）。
3. async 化后主 actor 卡顿风险——实装 checklist 加「backend 调用不在 @MainActor + readback test 记录 elapsed_ms」。
4. catalog sha 与 ir_map fingerprint 的 canonicalization——已由技术拍 #2 落定（共用确定性序列化函数）。

## 四、磊哥拍板项（6 项，呈报清单）

| # | 问题 | 选项 + ⭐ |
|---|---|---|
| G1 | iOS destination 若现场只演 Mac，跳 iOS 实测要 waiver 吗 | A ⭐不跳，iOS 门保留（防 Mac 侥幸假绿，impl-plan RR-a）/ B 给 waiver 本轮 Mac-only |
| G2 | malformed 兜底 TTS/UI 文案 | ⭐「这个我先记下来，稍后帮您处理」类中性短句（persona 卷草案）/ 磊哥自定 |
| G3 | W18 P1 节奏 | A ⭐接受 conditional-moot 进 W20A（target test 机械化条件）/ B 先修 P1 再进 |
| G4 | demo 现场话术 allow/avoid 清单（persona 卷已产草案：allow=direct-value 数值句式；avoid=有点冷/能不能/主驾/闷） | ⭐采纳 persona 草案进 operator runbook / 磊哥改 |
| G5 | 对外表达是否展示 axis-D 聚合数 | ⭐不展示聚合数，只说「演示这条 direct-value 链路」/ 展示但标注 |
| G6 | RT-6 无真异源时接受磊哥/人审替代并签 accepted residual | ⭐接受（Hermes 不可用现状）/ 等真异源 |

## 五、R2 红队边界

R2 攻击面：本稿一/二/三节的落定与吸收（新证据才翻，禁凭偏好重开）；LOCKED（D-111/superaudit 2P1/裁决#1-#5）不attack。
