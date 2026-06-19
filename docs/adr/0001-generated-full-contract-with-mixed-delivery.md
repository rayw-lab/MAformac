# 生成式全集语义契约与甲-混节奏

status: proposed

我们在 C1 采用 **生成式全集（甲档）**：从一手源表派生完整 `airControl / carControl / cmd` 语义契约，而不是人工手写能力。前两问结论是：Q1 采用生成式全量语义覆盖，不采用 L1-only 或设备骨架口径；Q2 采用 **甲-混节奏**，先立 C1/C2，再用一到两个 L1 纵切验证全栈，然后横向扩展。

Q3 结论是：C1 新建 `semantic-function-contract` capability spec，并在 delta 中声明它替代旧 `vehicle-capabilities`。旧 spec 仍是 8 个 MVP 能力、mock/readback/guard 口径；直接大改会把旧能力模型和生成式全集契约混在一起。

Q4 结论是：C1 使用 `contracts/semantic-function-contract.jsonl` 作为主源，`contracts/function-spec-full.yaml` 作为派生聚合视图，`contracts/semantic-coverage-report.md` 作为本地覆盖报告。JSONL 行至少保留 `contract_row_id / source_domain / source_sheet / source_row_no / source_row_hash / service / intent / ds_protocol / value / action_code / range / fc_flags / second_turn_refs / redaction_state`；YAML 只保留 `device_id / state_cell / primitives / range / exec_tier / risk` 等聚合字段。

Q5 结论修正为：JSONL 主源按源行级建模，而不是按去重四级功能建模；但 coverage 不追求 `dropped_rows=0`，而是建立分流账本。核心三域源行口径为 `source_rows=3990`，去重语义口径为 `canonical_semantics=3917`；JSONL 行增加 `canonical_semantic_id / dedupe_group_id / dedupe_role: primary|variant|alias|legacy_mapping`。覆盖报告写 `source_rows = valid_contract_rows + quarantined_rows + legacy_mapping_rows`，硬门是 `unclassified_rows=0`；quarantine 必须带 `reason` 枚举，不能静默丢弃或洗白为契约。

Q6 结论是：源表原始中文说法不进仓，C1 只存 `example_utterance_hash / example_utterance_kind / example_utterance_redaction / external_evidence_ref / evidence_ref_kind`。`evidence_ref_kind` 取值为 `downloads|raw_digest|manual_review`，防止未来把外部证据引用误当可公开文本来源；LoRA 训练脚本从本机只读源表取数，训练输出默认落外部 raw，进仓前另走脱敏候选门。

Q7 结论是：二次交互做 C1 的关系契约 sidecar，由 C4 消费。`contracts/semantic-function-contract.jsonl` 存 3990 条语义节点，`contracts/semantic-followup-transitions.jsonl` 存二轮关系边，coverage report 分开写 `source_rows` 和 `followup_transition_rows`。关系边字段包含 `transition_id / first_canonical_semantic_id / second_canonical_semantic_id / inherited_slots / rewrite_policy / source_sheet / source_row_no / source_row_hash / unresolved_ref`；本地生成检查必须校验两端引用存在，或显式标 `unresolved_ref`。

Q8 结论是：C1 保留 `semantic_range` 与分级的 `execution_range_ref`，C2 的 `state-cells.yaml` 拥有 `execution_range`，C3/DemoGuard 执行时只按 C2 做 range guard。覆盖报告增加 `range_conflicts`，当语义范围与执行范围不一致时必须显式记录。`execution_range_ref` 校验按 `exec_tier` 分级：L1 必须 `range_ref_kind=concrete` 并落到具体 C2 state cell；L2/L3 允许 `range_ref_kind=generic|none`，不进入 DemoGuard range guard，避免全集兜底行制造大规模悬空引用。

Q9 结论是：`exec_tier` 与 `risk` 挂在 JSONL `contract_row` 粒度，device 聚合视图只能派生 `risk_max`，不作权威。新增 `contracts/risk-policy.yaml` 收口 R0-R3、ASIL/QM、forbidden、restraint 到 `{asil_origin, demo_action, confirm_timeout_s, source}`，并写明 demo 二次确认是演示效果，不是真 ISO 功能安全责任。`exec_tier=L1` 必须 `classification_confidence=reviewed`，由 `contracts/l1-demo-allowlist.yaml` 授权；生成器默认 L2，不允许把“高优先级”自动提升为 L1。

Q10 结论是：生成权威不是 live `~/Downloads/*.xlsx`，也不是 raw digest，而是由 hash 和 manifest 锁定的冻结源快照。源 xlsx 本体继续按红线留在外部只读位置，仓内只保存 `contracts/source-snapshot-manifest.yaml`、源行级 JSONL 镜像和 coverage report；live Downloads 只作人工编辑入口，raw digest 只作审阅缓存。`MAformac-p0/contracts/function-spec-full.yaml` 是一次误跑出的设备参考清单，只能作为输入证据，不作 C1 主源或起点。

Q11 结论是：冻结源快照放在仓外 raw 区，仓内 manifest 必须比文件路径更强。`contracts/source-snapshot-manifest.yaml` 分 `c1_semantic_sources`、`c2_state_reference_sources` 与 `authority_notes` 三段：C1 至少覆盖四张金钥匙表（公版语义四级协议编辑版、多语种展开 V1、车控功能打点表、上下文二次交互功能清单）；C2 的量产端态材料只作为参考输入，`authority_kind` 标为 `reference_only`，不作为 demo 端态权威。C2 权威应是 MAformac 自己的场景端态协议，用于 mock state、参数规划和 readback。每个源文件记录 `file_sha256` 与 `content_digest`：前者防文件被替换，后者由解析后的规范化行集生成，作为 `verify-source` 判断语义漂移的主依据。`snapshot_id` 采用 `c1-<date>-<content_digest8>` 这类内容寻址命名；manifest 同时写 `source_reachable`，源不可达时仓内 JSONL 镜像只是 fallback 权威，可验仓内自洽、引用和 coverage，不能声称从一手源重新生成。

Q12 结论是：C2 采用场景端态权威，量产端状态上传信息清单只作为参考池。C2 的 cell 覆盖口径不是纯场景脚本反推，而是三源并集：`L1_device_cells`（每个 L1 精做设备完整 mock 态，保证卡片和 readback 不残）、`scenario_required_cells`（场景触发与感知状态，如定位、车头方向、乘员/环境）、`safety_cells`（L4 安全门需要读取的状态）。`state-reference-map.yaml` 如进仓，只允许存脱敏后的“字段语义 -> demo cell”映射，禁止保存供应商名、车型代号、责任方、人名、上传频率等源表敏感列；`工作簿1.xlsx` 这类量产上传协议材料继续留在 raw/Downloads 只读，不进入仓内契约原文。

Q13 结论是：`contracts/l1-demo-allowlist.yaml` 是 L1 精做范围的唯一 reviewed 来源，粒度到 `device + primitive + state_cell_group + followup_transition`。allowlist 条目必须声明 `required_followup_transitions`，引用 Q7 的 `semantic-followup-transitions.jsonl`，本地验证校验 transition 存在且两端 canonical id 落在 C1。allowlist 到 C2 的方向是需求声明而不是反向引用：`required_state_cell_groups` 定义 C2 必须提供的 cell group，C2 生成后再由本地验证校验闭合。C1 行上的 `exec_tier=L1` 不允许手写，只能从 allowlist 展开集派生；本地验证双向校验 C1 的 L1 行集与 allowlist 展开集一致。

跨题结论是：C1 必须有本地验证门，例如 `make verify` 或等价命令，覆盖重新生成、`git diff --exit-code`、引用完整性、分流账本、range conflict 和 coverage report。这个 gate 不等于 pre-commit、CI 或 PR 流程；仓库没有这些机制时仍要有本地命令，否则单一事实源只是纸面声明。

这个取舍是有意的：纯横切会太晚暴露问题，纯纵切又违背“全集契约先行”。甲-混保留完整契约，同时用早期纵切暴露 schema、端态、路由、LoRA、bench 和 voice 集成错误。
