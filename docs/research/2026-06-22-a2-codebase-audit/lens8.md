# Lens 8: codegen/大重构坑点 oracle (外部联网 pre-mortem)

# A2 重型重构坑点 Pre-Mortem 全表（codegen + 大重构）

> finder: codegen/大重构坑点 oracle（外部联网,12 处搜证,3 处 issue 已亲核标题/日期防编造）
> 服务对象: MAformac A2 重型重构(立项至今大部分代码改 + 从硬编码迁到 SSOT codegen + generic frame→D-domain 具名工具 surface)
> 日期: 2026-06-22

## 本机现状坐实(grounding,不凭猜)

- MAformac codegen = **Python 脚本**(`scripts/gen_c1.py` + `scripts/gen_tool_contract.py`)→ `generated/` + `contracts/*.jsonl`,**不是 Swift build plugin**（不踩 SPM plugin 那一类坑）。来源:本机 `Makefile:37-39`。
- 生成产物**提交进仓**(非 gitignore):`git ls-files` 确认 `generated/B_frame.frame_schema.json`、`generated/D_domain.tools.json`、`contracts/semantic-function-contract.jsonl` 等均 tracked。
- **漂移门已存在**:`make verify` → `regen`(重生成)→ `git diff --exit-code`(`Makefile:19,51`),即「重生成后若与提交版不一致就炸红」。这是 SSOT 提交派的标准安全配置。
- 体量:`semantic-function-contract.jsonl` 7.4M、`function-spec-full.yaml` 808K → **重生成 diff 体量巨大**(影响下面 elephant #1)。

---

## Tiger（明确威胁,带验证清单）

### T1 — 大爆炸式重构（A2 最大单点风险）
从头重写/一次改大部分代码是「软件公司能犯的最严重战略错误」。Netscape 4.0→6.0 从头重写致 3 年无发布、份额被吞;Borland(dBase/Quattro)、微软(Pyramid)同坑。根因:① 停产期间对手前进 ② 低估工作量(2 周→4 周→2 月→砍) ③ **丢失旧代码隐性知识**(每根毛发=一个修过的真实 bug) ④ 没理由相信第二次写得更好。微软 Pyramid 因没停旧线,只是财务灾难非战略灾难。
- **修法**: incremental 一个子系统一次,旧系统保持可跑可发(strangler fig)。
- **验证清单**: A2 是否被切成可独立验收/可回滚的小刀? 每刀后链路是否仍可跑可演? **有没有一刀就把「大部分代码」同时改掉的步骤 → 若有 = 大爆炸 red flag,停下让磊哥拍。**
- 源: [Spolsky 2000-04-06](https://www.joelonsoftware.com/2000/04/06/things-you-should-never-do-part-i/) + [Frontend at Scale](https://frontendatscale.com/issues/19/)（访问 2026-06-22）

### T2 — codegen 模板单点 bug 复制到所有产物 + reviewer 盲区
模板是单一真值,模板里一个 bug 被复制进每个生成产物(非孤立一处)。**ANTLR4 #2207『C++ codegen template incomplete: generation fails for $start, $stop』(开 2018-01-23, 4.7.1, 已亲核)** 即模板缺陷致所有引用该属性的语法全部生成失败。叠加:生成代码「格式工整、带注释」disarm 评审本能;**2026 研究实证 AI 生成 PR 含近 2x 代码冗余却收到更少负面反馈**(surface plausibility 降低批判性审查)。
- **修法**: ① 重点 review **模板/生成器本身**(它才是真 SSOT),不逐个 review 生成产物 ② 生成器/验证器用**结构性独立的第二来源**(异源 LLM 或人,别同 frame 自验——与 MAformac §claim-vs-reality 铁律1 循环失守同源)。
- **验证清单**: `gen_tool_contract.py`/`gen_c1.py` 的模板逻辑有没有被独立异源审过? 生成产物的**语义正确性**谁核验(非只核 git diff 干净)?
- 源: [ANTLR #2207](https://github.com/antlr/antlr4/issues/2207)（亲核） + [ShiftAsia QA blind spot](https://shiftasia.com/column/testing-ai-generated-code-the-qa-engineers-new-blind-spot/) + [AugmentedSWE(引 2026 study)](https://www.augmentedswe.com/p/ai-code-review-security)（访问 2026-06-22）

### T3 — codegen 工具/消费方版本漂移 → 编译炸
**swift-protobuf #1830(已亲核)**:protoc-gen-swift 1.29 生成的 `.pb.swift` 在 1.30 runtime 下编译失败(`_NameMap` API 变,『argument passed to call that takes no arguments』)——生成代码与 runtime 是两个独立组件,只升一边就 out-of-sync。
- **修法**: 生成器版本 pin 到与消费方严格匹配;升消费方必同步重新生成全部产物;或 build-time 生成(同次 resolve)。
- **验证清单**: MAformac codegen 是 Python,跨机的 python/依赖版本(`scripts/requirements.txt`)是否锁死? 生成产物 schema 与 Swift 消费侧(`ToolContractCompiler.swift`)的解析契约有没有版本/hash 对账,避免脚本改了 Swift 侧没跟?
- 源: [swift-protobuf #1830](https://github.com/apple/swift-protobuf/issues/1830)（亲核） + [Sourcery 版本 pin](https://swiftpackageregistry.com/krzysztofzablocki/Sourcery)（访问 2026-06-22）

### T4 — 重构 scope creep『while we are at it』
重构时顺手改无关部分,把 behavior-preserving 重构混入 behavior-changing 编辑,使 review/regression 验证极难。**Xerox 工业研究:70.8% 开发者最担心引入回归**,reviewer 主焦点就是验证重构后行为不变;mixed-scope 让这验证崩。A2 已是「大部分代码改」高危基线,任何额外 scope 都放大风险。
- **修法**: 定清晰目标 + 严守 scope + time-box;「顺手改」推迟到重构完成后。
- **验证清单**: A2 派单/PR 是否明确「只做 surface 迁移、不夹带功能变更/优化/重命名」? 生成物变更与手写变更是否分 PR?
- 源: [andreigridnev scope creep](https://andreigridnev.com/blog/2019-01-20-four-tips-to-avoid-scope-creep-during-refactoring/) + [arXiv Xerox case 70.8%](https://arxiv.org/pdf/2102.05201)（访问 2026-06-22）

### T5 — 防回归核心手段 = golden master / parity gate（必做,否则 A2 盲飞）
改前先把「当前行为」全量录成基线(把现状当真值,不重新推导 should-be),每刀重构后 replay 比对,任何差异=回归信号。**关键纪律:gate 先于 incremental 迁移建立(Establish CI gates first);old/new 双路并行跑 parity。**
- **A2 应用**: A2 改的正是 contract surface(generic frame→D-domain 具名工具),**C6 vehicle-tool-bench 正好可当 parity harness**——迁移前后跑同一 C6 集,要求 hard_pass 不退化;每刀对比 base/lora **分轴**数,禁止整体聚合掩盖子轴退化(MAformac §claim-vs-reality 铁律3)。
- 源: [SitePoint golden master](https://www.sitepoint.com/golden-master-testing-refactor-complicated-views/) + [Qonto AI-driven migration(parity gate first)](https://medium.com/qonto-way/ai-driven-refactoring-in-large-scale-migrations-strategies-and-techniques-fcdb9b5116c6)（访问 2026-06-22）

---

## Paper-Tiger（看似险实可控,带证据）

### P1 — 「过早抽象/过度泛化」（MAformac 部分豁免,但仍守一条）
wrong abstraction 比 no abstraction 更糟;为假想未来泛化 = future-proof 反而更难改;spike 应 throwaway。**但**:MAformac 是 solo demo 轻治理 + 已有 4 金钥匙一手契约定型(非纯探索),抽象边界(device×action×value 三元 + clarifyTag)是从真实座舱料归纳的**已稳定 domain pattern**,不算过早抽象。
- **仍需守**: A2 引入的新抽象(D-domain 具名工具层)是否**只服务已确认的 10 族 MVP**? 有没有为「全集泛化/多语种/二期 MCP」预埋未用抽象 → 若有 = 过早泛化,砍。
- 源: [arendjr premature abstraction](https://arendjr.nl/blog/2024/07/post-architecture-premature-abstraction-is-the-root-of-all-evil/) + [transcendsoftware(wrong>no abstraction)](https://www.transcendsoftware.se/posts/the-perils-of-premature-abstraction/) + [learningloop(spike=throwaway)](https://learningloop.io/plays/technical-spike)（访问 2026-06-22）

### P2 — 「生成代码提交进仓 vs gitignore+build-plugin」（MAformac 已选安全派,不必纠结）
业界两派真分歧,但 **MAformac 已选更安全的一派**:提交进仓 + `make verify` 的 `git diff --exit-code` 漂移门(本机 `Makefile:4-19,51` + `git ls-files` 实测 tracked)。提交派优点(fresh checkout 即有 IDE 支持/可 diff/不依赖每机装工具/clean build 快),缺点(merge 冲突/仓膨胀/SSOT 漂移)被 regen+diff 门精确堵住。Paramount/Sourcery 是用 gitignore 躲冲突,MAformac 用 diff 门躲漂移,殊途同归——且不踩 gitignore 派的坑(fresh checkout 无 IDE 补全 / SPM sandbox 写权限 / 环境变量触发全量重跑 SwiftGen #560)。
- **对 A2 的唯一要求**: 新增生成产物**也纳入 `GENERATED_CONTRACTS` 漂移门**,别漏。
- 源: [Paramount XcodeGen/Sourcery(gitignore 派)](https://paramount.tech/blog/2023/11/28/xcodegen-sourcery-case-study.html) + 本机 `Makefile` + `git ls-files`

---

## Elephant（没人提但该提）

### E1 — 生成物变更与手写代码变更混进同一巨 PR → review 失效 + rollback 灾难
A2 是「大部分代码改」,若把 codegen 产物 diff(7.4M jsonl + 808K yaml 重生成 = 上千行机械变更)和手写逻辑变更塞同 commit/PR,reviewer 无法区分「机械迁移噪声」vs「真实逻辑改动」,出问题也无法只回滚手写部分。
- **修法**: 生成物变更单独 commit(`chore(codegen): regen`),手写逻辑变更单独 commit;PR 描述显式分「surface 迁移行 / 逻辑变更行」。
- 源: [bitband scope creep in git](https://www.bitband.com/blog/expanding-refactoring-in-git-projects-a-sign-of-scope-creep/) + 本机重生成 diff 体量

### E2 — generated Swift 大文件触发类型检查器指数级爆炸
Swift constraint solver 是 n 维笛卡尔积(`expression too complex`;实测 Swift 6 在 12 行上花 42 秒)。**更阴险:类型错藏大表达式里会伪装成 timeout 而非清晰诊断**(solver 放弃前没报真 mismatch)。codegen 生成大字面量集合/深链式/无显式类型标注初始化极易踩。A2 把全集级 contract 编译进 Swift 消费侧时高危。
- **修法**: 生成器 emit 时**显式类型标注** + 拆大字面量为命名小块 + 避免深嵌套;用 `-warn-long-expression-type-checking` 扫最慢表达式。
- 源: [cocoawithlove 指数复杂度](https://www.cocoawithlove.com/blog/2016/07/12/type-checker-issues.html) + [danielchasehooper(42秒/12行)](https://danielchasehooper.com/posts/why-swift-is-slow/)（访问 2026-06-22）

### E3 — parity baseline 自身的 pre-existing 失败会 block 正确的 A2 变更
**Google 大规模 LLM 迁移实证**:回归套件若有与本次变更无关的既有失败,validation 在 test 步就挂,正确变更也推不进(得先修旧失败);golden 还常需手动更新。MAformac 直接对应:**C6 base Qwen3-1.7B 本就 hard_fail(IrrelAcc 0.789<0.9)、C5 candidate 0/34**——A2 若用 C6 当 parity gate,要先厘清「A2 之前就存在的基线噪声 vs A2 引入的回归」,否则 A2 被既有红挡住或反之被掩盖。
- **修法**: A2 前先 freeze 一份「A2-before」基线快照(每轴 base 数),parity 比**相对 before 不退化**而非**绝对全绿**。
- 源: [arXiv 2504.09691(Google migration)](https://arxiv.org/html/2504.09691v1) + 本机 `CLAUDE.md §9`

### E4 — SSOT 全量重生成的「调试复杂度」代价（成熟度前提 MAformac 已满足,但 A2 扩 surface 要警惕）
spec-as-source 近零 drift,但代价是高组织摩擦 + **高调试复杂度(生成代码难追溯)**,且前提是先有 CI 门 + contract test(否则 spec 沦为理想文档)。MAformac 已有 make verify 漂移门(满足前提),但 A2 大幅扩 SSOT surface 时,生成的 Swift 出 bug 要能快速定位是「模板 bug / 源数据 bug / 消费侧 bug」。
- **修法**: 生成产物保留**来源行号/source 锚点**(回溯到 contract jsonl 哪行),与 MAformac §28 一手源行号锚点同源。
- 源: [arXiv 2602.00180(Spec-Driven Dev)](https://arxiv.org/html/2602.00180) + 本机 make verify 门

---

## 喂回主线程的 grill 弹药（每条带 ⭐ 默认）

1. **A2 切刀粒度**: A2 是否切成「每刀可独立跑 C6 + 可回滚」的 N 小刀? ⭐默认: 是,且任何「一刀改大部分」的步骤必拆。(对应 T1)
2. **parity gate**: A2-before 是否先 freeze 每轴 base 快照,parity 比「相对不退化」? ⭐默认: 是(E3+T5),否则 C6 既有红会误判。
3. **生成物 vs 手写分 PR**: 是否强制 `chore(codegen): regen` 与逻辑变更分 commit? ⭐默认: 是(E1)。
4. **模板异源审**: gen_*.py 模板逻辑是否过异源(GLM/hermes)审 + 生成产物语义核(非只 git diff)? ⭐默认: 是(T2,与铁律1 循环失守同源)。
5. **新生成产物入漂移门**: A2 新增的 generated 文件是否都加进 `GENERATED_CONTRACTS`? ⭐默认: 是(P2 唯一行动项)。

## pre-mortem 三分类汇总
- **tiger ×5**: T1 大爆炸重构 / T2 模板单点 bug+reviewer 盲区 / T3 工具版本漂移 / T4 scope creep / T5 缺 parity gate
- **paper_tiger ×2**: P1 过早抽象(MAformac 部分豁免) / P2 提交 vs gitignore(已选安全派)
- **elephant ×4**: E1 混 PR review/rollback 灾难 / E2 Swift 类型检查器爆炸 / E3 baseline 既有失败 block 正确变更 / E4 SSOT 调试复杂度

## 真实性自查（防 finder 编造违纪）
- 三处 GitHub issue 标题/日期**已用 WebFetch 亲核**: ANTLR #2207(2018-01-23)、swift-protobuf #1830、SwiftGen #560(2018-11-23)——非凭印象。
- 「42 秒/12 行」「70.8% 开发者担心回归」「AI PR 近 2x 冗余收更少负评」「Swift 6」均带具体来源 URL,非编造数字。
- 本机事实(Makefile 行号、git ls-files tracked 状态、文件体量)均 Bash 实测,非推断。
