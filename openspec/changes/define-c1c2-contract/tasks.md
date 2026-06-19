# Tasks — define-c1c2-contract(C1+C2,甲-混:C1/C2 先做对 → 纵切验全栈 → 横铺)

> 分工:**CC 设计为主**(契约/schema/allowlist/risk-policy/接口);codegen 脚本可派 codex(CC 审);**magnet reviewed** 项见标注。叠加 Superpowers(TDD codegen / verification)。大前提:方案助手 demo,不往真车靠。

## 1. 冻结源快照 + manifest(provenance 地基)
- [x] 1.1 [CC定/codex脚本] `freeze` 脚本:4 张金钥匙 xlsx + C2 端态源 → 拷到 `raw/05-Projects/MAformac/source-snapshots/c1-<date>-<hash8>/`,算 `file_sha256` + `content_digest`(解析行集规范化 hash)。**产出** snapshot + `source-snapshot-manifest.yaml`。**验收** 双 hash + sheets_expected + source_rows;源料不进仓。Stage A:已冻结 4 张 C1 金钥匙表;C2 端态源仍按 open question 留空,待阶段 B。
- [x] 1.2 [codex/TDD] codegen 三道硬 gate:`reset_dimensions()` / 合并单元格 forward-fill / schema validation。**验收** WPS dimension 不可靠时仍正确计行;脏行不静默丢

## 2. C1 codegen:源行级 JSONL 主源
- [x] 2.1 [codex/CC审] 解析快照 → `semantic-function-contract.jsonl`(每源行一记录 + provenance + `value` 四件套 + device×primitive×slot)。**验收** source_rows≈3990,每行带 source_sheet/row_no/hash
- [x] 2.2 [codex/CC审] 去重:`canonical_semantic_id` + `dedupe_role`(primary 按 survivorship 选非任选,记 rule)。**验收** canonical≈3917
- [x] 2.3 [CC定/codex] 分流账本:脏行→quarantine 带 reason,`unclassified=0`,守恒。**验收** `source_rows==valid+quarantined+legacy`
- [x] 2.4 [CC定/codex] clarifyTag + `semantic-followup-transitions.jsonl`(两端引用校验)。**验收** unresolved≤2%

## 3. C1 治理产物(magnet reviewed)
- [ ] 3.1 [CC定] `risk-policy.yaml`:`Rn→{asil_origin,demo_action,confirm_timeout_s,source}`,收 ASIL/forbidden 双轨,**注明 demo 豁免 ISO26262、二次确认=炸场效果**。**验收** 每 risk 有 mapping
- [ ] 3.2 [**magnet reviewed**] `l1-demo-allowlist.yaml`:磊哥拍 ~10 炸点,粒度 `device+primitive+required_state_cell_groups+required_followup_transitions`。**验收** review_status=reviewed;C1 的 L1 从它派生(非手写)
- [ ] 3.3 [CC定/codex] exec_tier/risk 挂源行,L1 派生自 allowlist。**验收** C1 的 L1 行集 ≡ allowlist 展开集(双向)

## 4. C2 场景端态协议
- [ ] 4.1 [CC定/codex] `state-cells.yaml`:三源并集(L1_device ∪ scenario_required ∪ safety),`execution_range` 权威,四态(空≠默认≠未知≠关闭)。**验收** 每 cell 满足某 allowlist 需求或场景/安全需求
- [ ] 4.2 [**magnet reviewed**] `demo-scenarios.yaml`:初始态 + 触发话术绑定(磊哥定场景)。**验收** 覆盖 5 幕 + L1 readback/多轮/参数规划
- [ ] 4.3 [CC定] 脱敏参考映射(可选):「字段语义→cell」,禁来源方/车型/责任方/上传频率。**验收** 无客户标识
- [ ] 4.4 [CC定] 接口:C1 `execution_range_ref` 按 exec_tier 分级(L1 concrete / L2-L3 generic|none)落 C2 cell。**验收** L1 必 concrete,L2/L3 不悬空

## 5. 派生视图 + 本地校验门
- [x] 5.1 [codex/CC审] `function-spec-full.yaml` 从 JSONL 派生(非手写;P0 671-device 旧稿仅作核对参考)。**验收** device 聚合视图 + `risk_max` 派生
- [x] 5.2 [CC定/codex] `make verify` + `verify_refs.py`:regen+diff / 引用完整性 / 分流账本 / range conflict 分类(placeholder_open vs material_conflict)/ coverage。**验收** 5 项全绿
- [x] 5.3 [CC定] 脱敏 gate:grep 客户公司名/车型代号/供应商/人名 = 0。**验收** 仓内 0 命中,源 xlsx 不在版本控制

## 6. supersede + 基建文档级联
- [ ] 6.1 [CC] `vehicle-capabilities` 标 superseded(delta 已写,archive 时合并)
- [ ] 6.2 [CC] 基建文档级联:CLAUDE.md(§2 路线/§4 架构/§5 决策 D16/D30/D35/D37/范围纠错 18-32·1-10)、decisions、docs/README、lessons-learned §E/§F、collaboration §7、MEMORY.md/memory。**验收** 无文档仍指旧 8 能力/二分路由/旧范围

## 7. 验证(纵切先行,甲-混 + Superpowers verification)
- [ ] 7.1 [CC] 纵切 `空调温度`+`车窗` 贯穿全栈(value 四件套 + 经验步长 + position fan-out + 读回)验接口。**验收** 两设备 C1→C2 闭环、make verify 绿
- [ ] 7.2 [CC] Superpowers verification-before-completion:make verify 全绿 + 纵切闭环 + 脱敏 0 命中 + 覆盖率守恒,才算 C1/C2 可 apply 完成
