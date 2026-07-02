---
authority: wave1_owner_decision_package
status: pending_leige_wakeup（5 项拍完即可起 wave-1 live 生成）
created: 2026-07-03 凌晨
source: %45 wave1-pregen-survey.md（250 行，file:line 证据表）+ commander 提炼
---

# wave-1 真生成 · 磊哥 5 拍点（醒来即拍包）

> 通宵已推进到「万事俱备只差凭证」：G7 管道 mock 端到端/labeler slots 桥接/数据门实跑 由 %45 通宵补齐（RECEIPT-P5W）。live 云生成路径代码有意 fail-closed（`Gate7GeneratorPipeline.swift:81-95`）等下面 5 拍。

| # | 拍点 | 选项+⭐default | 说明 |
|---|---|---|---|
| 1 | 执行基座冻结 | ⭐P12 交叉审 APPROVE 后 merge 进 main，wave-1 pin 该 commit | dirty worktree 不可复跑；A+ 契约 647 行 diff 必须先落 main |
| 2 | 云凭证/模型 ID | 无 default——磊哥提供 Anthropic generator + OpenAI judge 的 env var/key/具体模型 ID/速率限额 | repo 只锁了「跨厂商 vendor enum」决策，具体接线配置不在仓 |
| 3 | 首波配额 | ⭐4.5k positives（562 工具×8，prepare 默认对齐）；不跑 18,260 全 subset 对 | manifest 全集是空间不是首波配额 |
| 4 | 旧 3,804/4,500 文本 salvage | ⭐参与，但全量重过 vendor-enum judge + C5DataGate（旧 same-vendor judge verdict 作废） | 承接既有 salvage 决策，省生成成本 |
| 5 | 人工精度门 staffing | ⭐磊哥本人按代码算的 sample size 抽检（`Gate7GeneratorPipeline.swift:657-670`，family<0.8 停）；或拍「首波跳过人工门、数据门+judge 双机械门先行」 | 无人认领 label = 门空转 |

拍完 → commander 派 worker 接线跑 wave-1 live + C5DataGate 全量 → 数据 receipt 上抛。
