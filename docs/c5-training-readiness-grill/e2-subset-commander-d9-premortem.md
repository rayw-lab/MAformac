---
authority: e2_subset_grill_commander_d9
artifact_kind: grill_premortem_failure_modes
dimension: D9 subset 特有失败模式（贯穿纵切）
id_range: SF-01~SF-14
round: e2-subset-grill（2026-07-02）
status: proposed（待磊哥 lock）
author: claude-commander
core_frame: subset 不能制造新的 surface drift（磊哥定）
---

# D9 — subset 特有失败模式 premortem（commander 纵切）

> 三分类：🐯 tiger（真威胁+验证清单）/ 🐅 paper-tiger（看似威胁给证据）/ 🐘 elephant（没人提但该提）。每条给防线归属（哪个维度/gate 接）。cite 惨败源：`docs/c5-training-readiness-grill/worker-commander-failure-defense-decisions.md:15`（0/34 九失守 + θ-α）。

| ID | 失败模式 | 分类 | 机理 | 防线归属 | 验证清单 |
|---|---|---|---|---|---|
| SF-01 | **runtime 动态裁剪造 drift** | 🐯 | 超预算时 runtime 现场丢工具 → 训练面≠运行面，θ-α surface mismatch 重演 | D3-3b ⭐静态 build 门 | manifest build 逐 group 预算断言 fail-closed；runtime 断言「零裁剪」 |
| SF-02 | **grammar 无 NO_TOOL 出口 = 强制幻觉** | 🐯 | grammar 只含工具分支，模型想拒拒不了 → 必然误吸；F-005 empty=hit（`docs/c5-training-readiness-grill/worker-commander-failure-defense-decisions.md:23`）的对偶 | D5-5d | grammar fixture 单测：无关请求在 grammar 约束下可产 NO_TOOL；C6 unsupported 层在 grammar-on 配置复测 |
| SF-03 | **分组 manifest 手写 = 第二 SSOT** | 🐯 | 手写 scene/group 映射与 catalog 漂移 = 0/34 惨败失守③ surface 双分叉重演（`docs/c5-training-readiness-grill/worker-commander-failure-defense-decisions.md:15`） | D1-1b | manifest 必 codegen + 契约存在性测试（每 group 成员 ∈ catalog）+ make verify 挂门 |
| SF-04 | **漏挂（目标不在面上）静默退化** | 🐯 | 预路由错族/错组 → 模型只能拒或幻觉；错因难与模型短板区分 | D2-2d + D8-8a | receipt 记 `target_in_prompt` per case；C6 分账「漏挂失败」独立于「模型失败」 |
| SF-05 | **digest 校验只在 preflight，runtime 不 assert** | 🐯 | 构建时同源、端侧加载旧 grammar cache → 运行态 drift；「校验过了」= 声称层 | D5-5a/5c | 端侧启动 assert mounted_digest==grammar_digest；失配硬拒不降级 |
| SF-06 | **KV cache 抖动拖爆 3s 闭环** | 🐯 | 换 group=前缀变=KV 冷启动；demo 连续多指令频繁换组 → 每次冷 prefill | D3-3d | demo 剧本序列实测换组频率×prefill 耗时；宏内稳定性设计（4c） |
| SF-07 | **多轮 group 切换丢 DialogueState 语境** | 🐯 | 上一轮在 ac group 说「调高一点」，本轮换 seat group → 指代对象面上消失 | D6-6c + D4 | 多轮 fixture：跨轮指代 + 换组场景；sequencer per-step digest 日志 |
| SF-08 | top-2 组合爆预算 | 🐅（若 D3 静态门立） | 最坏 seat+light 58k——但 build 时组合预算矩阵可静态排除，非运行时惊喜 | D2-2b | 组合矩阵全枚举实算进 manifest 门 |
| SF-09 | grammar 编译延迟 | 🐅（待 W3 搜证） | XGrammar per-group 静态预编译可缓存；README 实测简单 grammar <3% | D5-5b | 预编译产物进 manifest build；启动加载耗时实测 |
| SF-10 | 宏外说法被硬拒伤 demo 体验 | 🐅（demo 约定缓解） | 「现场只说 10 族」产品约定 + R2 拒识话术已决——宏外≠事故，是设计内拒识 | D4-4d + D8-8c | 拒识话术分层 fixture；方案经理剧本含宏外彩排 |
| SF-11 | 🐘 **subset 让 C6 历史锚失效** | 🐘 | base 10/23 锚（F-093，`docs/c5-training-readiness-grill/worker-commander-dim10-gate-r-l17-deepen.md:48`）是全量/旧面测的；subset 语境下 base 重测数字会变 → candidate 对比锚要不要重定（这没人提，但 R-L17 candidate comparison 直接受影响） | D8 + 裁决门 | E-2 落地后 base 锚在同 subset 配置重测一次（R7-gated，进 run-auth 清单） |
| SF-12 | 🐘 **训练/评测/端侧三方 tokenizer 不同源** | 🐘 | 预算按 HF tokenizer 算，端侧 mlx-swift tokenizer 若分词差异 → 预算/offset 双漂移（gate2 残留 P1 的同族问题） | D7 + gate2 P1 | real-model batch dump（已在 R7-gated 清单）扩展：同文本三方 token 数对账 |
| SF-13 | 🐘 **manifest 版本漂移跨 run**：数据 wave-1 用 v1 分组、重训 wave-2 换 v2 → 新旧样本混训 = 面内分布断层 | 🐘 | — | D7-7a + gate5 | 样本记 `subset_policy_digest`；数据门拒混 digest 训练集（或显式 allowlist） |
| SF-14 | 🐘 **「subset 已同源」的声称层复发**：manifest/receipt 字段齐全但消费方（渲染器/grammar 生成器）各自硬编码——字段一致 dead field 重演（gate2 P0 同构） | 🐘 | — | 全局 | 消费层测试：改 manifest 一个工具 → 断言 prompt 渲染与 grammar 同步变（行为测试非字段比对） |

## 与 W1/W2/W3 的会聚点（消减预告）
- SF-01/SF-08 → W2 D3 静态门是解，验证清单并入其决策。
- SF-02/SF-05/SF-09 → W3 D5 机制设计直接吸收。
- SF-04/SF-07 → W1 D2/D6 的 receipt/fixture 要求。
- SF-11/SF-12/SF-13/SF-14 = commander 独有增量（elephant 组），消减时单列上抛磊哥。
