## REMOVED Requirements

### Requirement: 能力定义有唯一权威源

**Reason**: 2026-06-19 基座深度内化后,扁平 8 能力模型(power/level 平铺)被推翻——错失 value 四件套、device×动作原语×槽三元、二次交互、场景端态等语义工程本质,无法支撑「客户随意说全集 2655+ + 不丢脸分层兜底」。

**Migration**: 唯一权威源迁移到 `semantic-function-contract`(C1,源行级全集 JSONL SSOT,`make verify` 守护)。

### Requirement: 每条车控能力声明口语别名

**Reason**: 同上,口语别名在扁平模型下无 clarifyTag 路由分型,无法表达感受词/模糊说→FC 泛化。

**Migration**: 迁移到 C1 的示例说法 + `clarifyTag` 路由标记;旧 8 能力作为 L1 候选子集纳入 `l1-demo-allowlist`,不丢失。

### Requirement: 每条能力声明 mock 执行与 readback

**Reason**: 同上,扁平 cell(8 个)不足以表达 L1 设备完整读回与场景端态。

**Migration**: 迁移到 `scenario-state-protocol`(C2,场景端态 mock 读回,cell = 精做设备端态 ∪ 场景所需 ∪ 安全门所需)。

### Requirement: 危险或带范围能力声明 demo_guard

**Reason**: 同上,扁平范围(如温度 16-30/风量 0-5,实为拍错)无 execution_range 权威与风险单源。

**Migration**: 范围权威迁移到 C2 的 `execution_range`;风险分级迁移到 C1 的 `risk-policy`(R0–R3 单源,收 ASIL/forbidden 双轨,demo 豁免 ISO26262)。

### Requirement: MVP 车控能力集覆盖 5 幕演示

**Reason**: 同上,5 幕 must-pass 应建在全集语义 + reviewed L1 名单上,而非 8 个扁平能力。

**Migration**: 迁移到 C2 的 demo scenarios + C1 的 `l1-demo-allowlist`;顶层 demo 体验契约(`demo-experience`:离线可演 / 车控为 mock / 错误不冒充成功 / 5 幕 must-pass / 安全门为代码)**不变**,C1/C2 是其细化实现层。
