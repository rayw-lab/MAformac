# WS2 bug-skill-dev 10族 bug 挖掘

结论：bug-skill-dev 这批数据对 10 族有价值，但“12000+ bug”不能按独立 bug 数理解。本轮 live probe 看到的是：dump 3531 条 bug 记录、`~/.bug-skill/data.db` 里 4053 个有 analysis 的 distinct bug、1811 个有 comment event 的 distinct bug，以及 12446 条 `ki_evidence_links` / 13791 条 comment event 这类事件级/证据级行。按保守关键词+语义候选去重，4053 个 distinct bug 中有 1730 个命中 10 族相关信号。

## 边界与一手依据

- 10 族权威定义：空调/座椅/车窗/车门/灯光氛围/屏幕/音量/雨刮 + 天窗遮阳帘 + 香氛；香氛只支持开关/强度，不支持选味道；10 族外走 unsupported 兜底。证据：`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:80-82`、`:216`。
- 训练口径：10 族 intent=562、行=2159、device=191；旧 534/2086 口径作废。证据：`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:224-230`。
- 价值优先级参考：demo 多轮优先空调/车窗/雨刮/香氛；LoRA 信号重心偏座椅、灯光氛围、音量、车窗、雨刮。证据：`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:243-257`、`:283-296`。
- 红线：真实座舱/bug 语料只抽象语义，不复制原文；密钥/PII/真实人名绝不入仓。证据：`CLAUDE.md:105-108`。bug-skill-dev 也要求分清生产 DB 与文档/临时 DB，生产 DB 以 `~/.bug-skill/data.db` sqlite 实际写入为准。证据：`/Users/wanglei/workspace/bug-skill-dev/AGENTS.md:32-41`。

## DB 结构与量级核验

| 来源 | live probe 结果 | 判断 |
|---|---:|---|
| `/Users/wanglei/workspace/bug-skill-dev/data.db` | 0B；`.tables` 空 | 仓内壳文件，不能当 bug 库 |
| `/Users/wanglei/workspace/bug-skill-dev/db.db` | 0B；`.tables` 空 | 仓内壳文件，不能当 bug 库 |
| `/Users/wanglei/workspace/bug-skill-dev/dist/seeds/initial-e0v-e0yfl.sqlite` | 7 tables；`analyses=3626`、`ki_evidence_links=11692`、`kis=309` | seed/知识层，可辅助但不是完整 raw bug 库 |
| `/Users/wanglei/workspace/raw/05-Projects/bug-skill-dev-unified-fix/bug-skill-home/.bug-skill/dumps/e0v-all-bugs-*.jsonl` | `3531` JSONL rows；字段含 `bug_id/title/description/resolution_notes/history_actions/comment_count` 等 | 真实 bug 记录主入口之一 |
| `/Users/wanglei/workspace/raw/05-Projects/bug-skill-dev-unified-fix/bug-skill-home/.bug-skill/data.db` | `analyses=3902`、`ki_evidence_links` 不在此 copy、`bugs=0` | raw copy 可辅助；`bugs` 表为空 |
| `/Users/wanglei/.bug-skill/data.db` | `analyses=5324`；distinct analysis bug_id=`4053`；`e3_comments_events=13791` rows / distinct bug_id=`1811`；`ki_evidence_links=12446` | 本机生产 DB 入口；解释“12000+”应按 evidence/comment row 级，不是独立 bug 数 |

方法说明：本轮只读 sqlite/JSONL，不写 DB，不生成训练样本。分类把每个 `bug_id` 的 dump 文本、analysis summary、comment event 文本在内存中合并后做关键词+语义候选匹配；输出只保留统计、关键词族和脱敏派生例子，不输出原始标题/评论/人名。

## 10族候选命中数

主口径：`~/.bug-skill/data.db` + dump/raw/seed 去重后的 `4053` distinct bug_id；同一 bug 可命中多个族，所以逐族求和会大于 1730。

| 10族 | distinct bug 命中 | 主要触发词/语义 | 数据价值 |
|---|---:|---|---|
| 音量 | 1099 | 播报、声音、音频、音量、静音、媒体音、导航音 | 最大候选池；适合 failure/refusal、播报/音频执行失败、音量槽位缺失样本 |
| 屏幕 | 344 | 中控屏、屏幕、亮度、黑屏、显示异常、仪表屏 | 适合 no-call/unsupported 边界，尤其黑屏/系统故障不应被误学成车控执行 |
| 空调 | 327 | 空调、温度、通风、风量、风速、出风、除雾、制冷 | 适合自然中文体感词和 clarify；注意我已移除裸 `ac` 假阳性 |
| 车窗 | 174 | 车窗、窗户、升窗/降窗/关窗、防夹、主副驾窗 | 适合多轮/读回/安全防夹边界 |
| 座椅 | 162 | 座椅、按摩、座椅加热/通风、主驾/副驾、靠背 | 适合 EXP/SPOT value-form 和多槽位 clarify |
| 灯光氛围 | 112 | 氛围灯、灯光、大灯、阅读灯、转向灯 | 适合颜色/亮度模糊表达与 rule/free 分流 |
| 车门 | 82 | 解锁、车门、儿童锁、上锁、尾门、开门/关门 | 高安全边界；多为 refusal/safety 而非训练 positive |
| 香氛 | 65 | 香氛、味道、香氛浓度、气味、香薰 | 高价值小池；“选味道”应进 unsupported/refusal |
| 天窗遮阳帘 | 34 | 天窗、遮阳帘、遮阳、sunroof | 小池但多轮价值高，适合 scope/percent clarify |
| 雨刮 | 12 | 雨刮、雨刷、wiper | 命中少但 demo 多轮价值高；需要后续扩关键词或补外部样本 |

按来源交叉看，live home DB analysis 命中与 JSONL 命中方向一致：音量 1099/1010、屏幕 344/328、空调 327/284、车窗 174/154、座椅 162/140、灯光 112/94、车门 82/70、香氛 65/55、天窗 34/27、雨刮 12/12。说明候选不是单一来源偶然，但仍是弱监督 shortlist，不是可直接训练标签。

## 失败模式与样本价值

在 1730 个 10族候选 bug 中，派生失败模式命中如下：

| 失败模式 | distinct bug 命中 | 可转化价值 | 注意 |
|---|---:|---|---|
| 执行失败/读回失败 | 809 | failure receipt、readback mismatch、no-op output 样本 | 不要把系统 bug 原文当用户命令训练；只抽象失败类型 |
| 多意图/联动 | 415 | 多工具/拆步/部分拒识样本 | 需要和 C6 multi-action scorer 对齐 |
| unsupported/越界 | 380 | no-call/refusal 样本 | 尤其导航/音乐/HUD/驾驶模式/香氛选味道 |
| 槽位缺失/需澄清 | 234 | clarify 样本 | “调一下/开一下/大一点/小一点”类应补问目标/档位/对象 |
| 口语模糊/体感词 | 97 | 自然中文 positive/clarify 样本 | “太冷/闷/刺眼/太暗/难闻/下雨了”类要映射 value-form |
| 安全/拒识候选 | 58 | safety refusal 样本 | 车门/车窗儿童锁、防夹、行驶中动作要单独判 risk |

逐族看，音量和屏幕贡献了最多失败/越界样本；空调、车窗、香氛更适合自然中文和 clarify；车门、车窗更适合 safety/refusal；雨刮样本少但口语/场景触发价值高。

## 脱敏派生例子

以下不是原始 bug 文本，只是从命中模式抽象出的训练/评测候选形态：

- 空调 positive/clarify：用户用体感说“车里太热/太闷/起雾”，没有给温度或风量；应映射到空调/除雾候选并在槽位不足时 clarify。
- 座椅 value-form：用户说“主驾坐着不舒服/想更暖一点/按摩强一点”，涉及座椅加热、通风、按摩、靠背等多槽位；适合 EXP/SPOT 规整。
- 车窗 safety/refusal：用户表达关窗/升窗时夹到人、儿童相关、行驶中误触；应优先走 safety/refusal 或 guarded clarify。
- 车门 safety/refusal：用户围绕解锁、儿童锁、尾门打不开等表达问题；训练上应避免把故障处理话术误变成直接开锁/关门 positive。
- 灯光氛围 positive/clarify：用户说“太暗/刺眼/想换个颜色/氛围更柔和”，需要映射亮度/颜色/模式，必要时补问目标区域或档位。
- 屏幕 failure/no-call：用户说中控屏黑屏、显示异常、投屏/系统故障；大多是 failure/no-call，不应训练成“调屏幕亮度” positive。
- 音量 failure/clarify：用户说播报太吵、导航音/媒体音太大或没声音；应区分音量 positive、音频故障、导航/音乐越界。
- 雨刮 scene trigger：用户说下雨、看不清、雨刮不动；可派生成雨刮 positive/clarify/failure 三类，不直接复制原始故障描述。
- 天窗遮阳帘 scope：用户说太阳晒、遮阳帘开合比例、天窗相关异响；遮阳帘开合可 positive，异响/维修类应 no-call。
- 香氛 boundary：用户说气味太重/想淡一点可作为强度/开关；指定香型/换味道必须 unsupported/refusal。

## 推荐后续用法

1. 先把本报告作为 data scoping shortlist，不要直接生成训练集，符合 R7 design-only。
2. 后续若进入数据生成，建议抽样标注：每族 20-50 个候选人工复核，先确认 precision，再决定是否扩大。
3. 训练样本只允许使用派生改写后的自然中文，不使用原始 bug 标题、评论、处理人、车型、客户或 bug id。
4. C6 eval 侧优先把这些样本投向 negative/no-call/refusal/failure receipt，而不是盲目扩 positive。

## 残留风险

- 这是关键词+语义 shortlist，不是 gold labels；“播报/声音”会把一部分非车控音频问题带进音量候选，屏幕/黑屏也会混入系统故障。
- `bugs` 表在 raw copy 与 live DB 都是 0 行，真实 bug 正文主要来自 JSONL dump 和 comment events；如果后续有新的 E3 export，需要重新核 row count。
- 12000+ 量级在本轮证据里对应 `ki_evidence_links=12446` 或 `e3_comments_events=13791` 这类事件/证据行；不能对外声称 12000+ 独立 bug。
