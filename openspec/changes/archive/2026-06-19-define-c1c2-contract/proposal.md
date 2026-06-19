## Why

2026-06-19 深度内化某车厂 4 张金钥匙语义协议基座后,旧路线(扁平 8 能力 `capabilities.yaml` + 二分路由)被推翻——它错失了语义工程的本质:`value` 四件套(相对/绝对/经验/极值参数规划)、归一化动作编码(几千 intent = device × ~12 原语 × 槽)、二次交互(多轮指代)、场景端态。客户现场会随意说全集 2655+ 甚至超出,只做 8 个窄 mock = 丢脸。

新路线以**契约 SSOT 为根**:先有完整、可校验、从一手源派生的语义契约 + 场景端态协议,后续三层路由 / LoRA / bench / voice(C3–C7)才有正确地基。本 change(C1+C2)立这个根。Q1–Q15 脑暴(CC↔codex,2 轮 oracle 验证)定稿,详见 `docs/c1-q1-q10-claude-oracle-grill-2026-06-19.md` + `docs/adr/0001-generated-full-contract-with-mixed-delivery.md` + `CONTEXT.md`。

## What Changes

一个 change,两个 capability spec delta(spec 层分开防糊账,change 层合一同波 archive 避双向依赖循环):

**C1 `semantic-function-contract`**(语义功能契约 SSOT):
- 生成式全集(甲档):从**冻结源快照** codegen 机械派生(非手写),覆盖 `airControl/carControl/cmd` 源行(source_rows≈3990)
- 主源 `semantic-function-contract.jsonl`(源行级,保 provenance);派生视图 `function-spec-full.yaml`
- `value` 四件套 + device×动作原语×槽三元 + canonical/variant 去重(SCD Type 7 双 key)+ `clarifyTag`
- 二次交互关系边 sidecar `semantic-followup-transitions.jsonl`
- `risk-policy.yaml`(R0–R3 单源,收 ASIL/forbidden 双轨)+ `l1-demo-allowlist.yaml`(L1 reviewed 唯一真源)
- 冻结快照 `manifest`(file_sha256 + content_digest)+ **分流账本**(`unclassified_rows=0`,quarantine≠drop 带 reason)
- `make verify` 本地门(regen+diff / 引用完整性 / 分流账本 / range conflict / coverage)
- **BREAKING**:supersede 旧 `vehicle-capabilities`(扁平 8 能力)

**C2 `scenario-state-protocol`**(场景端态协议):
- demo 自有 mock 场景端态(**非量产端态复刻**),cell 口径 = `L1_device_cells ∪ scenario_required_cells ∪ safety_cells`
- 拥有 `execution_range`(权威);C1 只 `execution_range_ref` 引用,按 exec_tier 分级(L1 concrete / L2–L3 generic|none)
- demo scenarios(初始态 + 触发话术绑定)+ 脱敏参考映射(量产上传清单只作 reference,禁存来源方/车型/责任方)

接口互锁(`execution_range_ref` / `range_ref_kind` / `state_cell_group` / `l1-allowlist`)写 design.md 共享段。

## Capabilities

### New Capabilities
- `semantic-function-contract`: C1 — 源行级语义功能契约 SSOT(JSONL 全集 + value 四件套 + 三元 + clarifyTag + followup sidecar + risk-policy + l1-allowlist + 冻结快照 manifest + 分流账本 + make verify)
- `scenario-state-protocol`: C2 — demo 场景端态协议(state cells + execution_range 权威 + scenarios + 脱敏参考映射)

### Modified Capabilities
- `vehicle-capabilities`: **被 supersede** — 旧扁平 8 能力契约由 C1 源行级全集契约替代(行为契约从「8 个 tool schema」升级为「全集语义 + 分层执行口径 + 场景端态」)

## Non-goals(本 change 不做)
- 不做 runtime 实现(decoder/guard/executor/路由/LoRA/voice → C3–C7)
- 不做全集 674 设备的 runtime 精做(只 L1 ~10 精做,其余 L2 通用 mock 兜底,执行在 C3)
- 不做真车控 / CAN·ECU / 量产端态上传协议复刻(C2 是 demo 原创 mock 场景态)
- 不做 LoRA 训练(C5)/ 三层路由实现(C4)/ bench(C6)
- 源 xlsx / 量产端态清单 / 客户标识 **不进仓**(冻结快照在外部 raw 只读)

## Success Criteria(可验收)
- `make verify` 全绿:① codegen 重跑 `git diff --exit-code` 生成物无漂移 ② JSONL 跨行引用(canonical_id/dedupe_group/followup_refs/execution_range_ref)全解析,unresolved ≤2% ③ 分流账本守恒 `source_rows == valid + quarantined + legacy` 且 `unclassified_rows == 0` ④ range_conflicts 区分 placeholder_open vs material_conflict ⑤ coverage 报告齐全
- C1 JSONL 100% 从冻结快照 codegen 派生(无手写源行);manifest 的 `content_digest` 校验通过
- C2 每个 cell 满足某 l1-allowlist 的 `required_state_cell_group` 需求(allowlist→C2 闭合)
- 脱敏 gate:仓内无客户公司名/车型代号/供应商/人名/禁外传原文
- (非自动化 success signal,单列)L1 炸点设备的 readback / 多轮 / 参数规划在场景里语义完整 —— 磊哥 demo 试演判断

## Impact
- 新增 `contracts/`:`semantic-function-contract.jsonl` / `semantic-followup-transitions.jsonl` / `risk-policy.yaml` / `l1-demo-allowlist.yaml` / `state-cells.yaml` / `demo-scenarios.yaml` / `source-snapshot-manifest.yaml` / `semantic-coverage-report.md` / `function-spec-full.yaml`(派生)
- supersede `openspec/specs/vehicle-capabilities`(旧 8 能力)
- 冻结源快照在 `~/workspace/raw/05-Projects/MAformac/source-snapshots/`(外部只读,不进仓)
- codegen 脚本 `scripts/gen_*.py` + `make verify` + `verify_refs.py`
- 旧 `contracts/capabilities.yaml` / `function-spec-full-v0.yaml`(模板)/ P0 `function-spec-full.yaml`(671 device 聚合稿)降级为参考,不作 C1 主源
