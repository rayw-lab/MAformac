# UIUE R0/R1/R2 Grill Matrix Loop Competition Contract

日期：2026-06-27
scope：`docs/uiue-roadmap-2026-06-27-post-8c2-baseline.md` 中 R0 / R1 / R2 / R2b
mode：fixed blind candidate set + persona reviewers
rounds：2
reviewers_per_round：3
candidate_count：70
output_dir：`docs/loop-competition/2026-06-27-uiue-r0-r2-grill-matrix/`
proof_boundary：local / unit / simulator；不声明 L3 / V-PASS / mobile / true_device / A-2 complete

## Source Pool

Reviewer 必读源：

- `docs/uiue-roadmap-2026-06-27-post-8c2-baseline.md`
- `docs/research/2026-06-27-uiue-8c2-interaction-grill-retrospective.md`
- `docs/research/2026-06-27-uiue-8g9b-u17-l0/README.md`
- `docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/README.md`
- `docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/LESSONS.md`
- `docs/uiue-storyboard-grill-decisions.md` 的 SD16 / SD18 / SD24 / SD25 段落
- `openspec/changes/ui-presentation/tasks.md`
- `openspec/changes/ui-presentation/specs/ui-presentation/spec.md`

可选核查源：

- `App/ContentView.swift`
- `App/ContextCapsule.swift`
- `App/ValueControlView.swift`
- `App/ExpandedFamilyCard.swift`
- `Core/Presentation/ValueRangeMapper.swift`
- `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift`
- `Tools/checks/`

## Review Rules

- 每个 reviewer 只读 `contract.md`、`candidates-blind.md` 和 source pool；不得读其它 `brain-*.md`、`judge.md` 或 `ledger.md`。
- 每个 reviewer 必须覆盖全部 70 个候选，至少在 `## Scores` 中给出 70 行。
- 每个 reviewer 可以建议 merge/rewrite/delete/missing risks，但不能改候选文件。
- reviewer 只给建议；controller/judge 才能最终采纳、合并、排序。
- 所有建议必须守 proof class：local/unit/simulator 不升级成 L3 / V-PASS / mobile / true_device。
- 任何 `【SHOULD_GRILL】` 推进建议都必须要求后续单独 grill / pre-mortem / 决策存档。

## Personas

Round 01:

- `brain-1.md`：RED failure auditor。专盯 tiger / paper-tiger / elephant、假绿、proof class 误升格。
- `brain-2.md`：GREEN implementation coordinator。专盯可落地性、文件边界、测试入口、commit 切分。
- `brain-3.md`：BLUE UX/HMI designer。专盯手指路径、遮挡、留白、视觉层级、座舱直觉。

Round 02:

- `brain-1.md`：PURPLE systems architect。专盯 SSOT、OpenSpec 边界、R0/R1/R2 路线耦合。
- `brain-2.md`：ORANGE test engineer。专盯 UI test / checker / evidence package / failure diagnostics。
- `brain-3.md`：BLACK skeptical product judge。专盯 L3 人审、演示现场、客户可感知问题。

## Scoring Rubric

每项 1-5 分：

- Importance：是否命中 R0/R1/R2 的重大决策、风险或失败路径。
- Verifiability：后续 agent 是否能用文件、命令、测试、截图、receipt 或人工签核证明。
- Non-duplication：是否和其它候选区分清楚。
- Decision leverage：是否迫使明确拍板或优先级取舍。
- Risk revelation：是否揭出隐藏、昂贵、易漏的风险。

Total = 五项相加，满分 25。

## Reviewer Output Schema

```markdown
# Brain N - Round XX

## Keep
| Candidate | Score | Reason |

## Delete
| Candidate | Reason |

## Merge
| Candidates | Proposed canonical wording | Reason |

## Rewrite
| Candidate | Proposed wording | Reason |

## Missing Risks
- ...

## Scores
| Candidate | Importance | Verifiability | Non-duplication | Decision Leverage | Risk Revelation | Total |

## Candidate Notes
| Candidate | Note |

## Rationale
...
```

## Judge Output

Controller 输出：

- `round-01/judge.md`
- `round-02/judge.md`
- `ledger.md`
- `final-grill-matrix.md`

最终矩阵必须至少 50 项；本轮目标为保留全部 70 项并给出 priority / route / recommendation / six-reviewer signal。
