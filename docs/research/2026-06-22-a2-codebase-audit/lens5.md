# Lens 5: 业内代码质量管控 + SSOT-driven codegen + 防 spike 硬编码固化（external 调研 finder）

# 业内代码质量管控 + SSOT-driven codegen + 防 spike 硬编码固化（external finder 一手档）

> 调研日期 2026-06-22 | finder lens: 外部联网（github-first，12 次 WebSearch + 9 repo gh 核实 star/pushedAt）| 任务：业内怎么管控代码质量 + 避免硬编码 + SSOT codegen，尤其防 spike scaffolding 硬编码固化进主链路（MAformac：6 工具硬编码本是 spike，范式翻案后成债）

## Summary（核心结论）

业内 2026 共识 = **Schema/Spec-Driven Development（SDD）已是主流**，三件套：
1. **单一 schema/spec 作权威源派生一切**（类型/枚举/校验/工具定义/文档/测试），不每处手写。
2. **生成物 ≠ 手写第二套**——手写第二套必漂移，TypeORM/OpenAPI-Generator/Prisma 真实 bug 是铁证。
3. **CI drift gate = `regenerate + git diff --exit-code`** 兜底，committed 生成物与重生成不一致就断红。

**MAformac 已经走在正路上**（本机核实）：`Makefile` 有 `gen_tool_contract.py`（派生）+ `verify_refs.py` + `verify-cross-section`（§35 文档级联一致）+ `git diff --exit-code`（Makefile:51 漂移门）；`ToolContractCompiler.swift` 把 `frameToolSchema`（legacy generic-frame）和 `dDomainToolSchemas` 都从同一 `SemanticContractRow`/`C5SemanticSeed` 派生——**这正是业内推荐形态**。

**"6 工具硬编码债"的实质**：是 legacy `tool_call_frame` generic-frame surface，**新 D-domain surface 已是 compiler-derived（非裸硬编码）**。真风险不是"硬编码没派生"，而是 **elephant：该删的 frame surface 仍在被 compiler 派生 → drift gate 不报警、"看着合规"**（claim-vs-reality 铁律1 变体：compiler 派生 ≠ 该派生）。

---

## 逐 finding（每条带 source + 日期 + pre-mortem 类）

### F1 — 主流范式 = Schema-Driven Development（na）
单一 schema 作 SSOT，派生 API/校验/文档/类型/测试。Godspeed/noclocks 2026 文章一致：'用一个 schema 决定/生成所有依赖它的东西'（生成多协议 CRUD、producer/consumer 校验、API 文档、mock server、基础测试）。**= MAformac `semantic-function-contract.jsonl → gen_tool_contract.py` 派生工具枚举的形态。**
- source: https://godspeed.systems/blog/schema-driven-development-and-single-source-of-truth (2026) + https://blog.noclocks.dev/schema-driven-development-and-single-source-of-truth-essential-practices-for-modern-developers

### F2 — 硬编码 = '伪装成简洁的技术债'（na）
可变值（路径/枚举/常量/magic number）嵌进业务逻辑，模糊 behavior↔config 边界，违反 SRP + 12-Factor 'store config in environment'。**MAformac 6 工具硬编码本是 spike，范式翻案后正中此坑（behavior 固化进主链路）。**
- source: https://www.in-com.com/blog/breaking-free-from-hardcoded-values-smarter-strategies-for-modern-software/ + https://medium.com/the-pythonworld/stop-hardcoding-everything-how-to-write-and-use-configuration-files-in-python-like-a-pro-cf9f2df0200c (Apr 2026)

### F3 — '手写第二套 schema 必漂移'是实证 bug 模式（tiger）
非理论：**TypeORM #11735**（两列复用 enum 生成重复 CREATE TYPE，第二条炸）、**OpenAPITools/openapi-generator #5024**（重复生成 enum 而非引用单源）、**Prisma #3010**（duplicate mapped enum 生成失败）。**印证 claim-vs-reality 铁律1：单一 SSOT compiler 派生，不手写第二套。**
- source: https://github.com/typeorm/typeorm/issues/11735 + https://github.com/OpenAPITools/openapi-generator/issues/5024 + https://github.com/prisma/prisma/issues/3010

### F4 — CI drift gate 标准配方（na）
`run generator + git diff --exit-code`（committed 生成物 vs 重生成不一致则 build fail）。GraphQL Code Generator 社区原始实现；jOOQ 用参数化单测对比临时目录与源树。**MAformac Makefile:51 已实装 `git diff --exit-code -- ... $(GENERATED_CONTRACTS) ...`，与业内一致。**
- source: https://the-guild.dev/graphql/codegen/docs/getting-started/development-workflow + https://www.jooq.org/doc/latest/manual/code-generation/codegen-version-control/ + 本机 Makefile:51

### F5 — Buf 是 protobuf 契约治理工业标杆（na）
**bufbuild/buf 11211★, pushed 2026-06-21**（本机 gh 核实）：`buf lint` + `buf breaking`（FILE/PACKAGE/WIRE_JSON/WIRE 多层兼容分类）+ BSR 服务端策略拒绝 breaking change。'one contract drives whole workflow: compile/lint/compat/codegen/validate/publish'。**可作 MAformac 契约门成熟参照（lint+breaking 进 CI）。**
- source: https://github.com/bufbuild/buf + https://buf.build/docs/breaking/

### F6 — Swift 端 SSOT codegen 工具链成熟（na）
- **Sourcery 8010★, pushed 2026-06-11**（SwiftSyntax 基底，40000+ 项目，Airbnb/NYT 在用）读 Swift AST 生成。
- **SwiftGen 9545★, pushed 2026-04-16** 读资源/数据 schema（JSON/plist/asset）生成 type-safe 枚举常量，build-time 跑保持同步。

**MAformac 若把契约派生从 Python 脚本进一步 Swift 原生化，这两是首选。**
- source: https://github.com/krzysztofzablocki/Sourcery + https://github.com/SwiftGen/SwiftGen（本机 gh repo view 核实）

### F7 — spike 代码业内定性 = 隔离、用完丢弃（na）
spike = time-boxed 知识发现，deliverable 是 knowledge 不是 shippable code，'Spike code should always be isolated from production'。**预防 > 事后清理。MAformac 教训：spike scaffolding 当时未隔离，范式翻案后成债。**
- source: https://learningloop.io/plays/technical-spike + https://www.xploreagile.com/agile-spikes-and-technical-debt-the-juggling-act-in-agile-development/

### F8 — 硬编码 scaffolding 清理配方（na）
①refactor 是 prototype→production 的桥 ②Replace Magic Number With Constant 是实证最高频清理（arxiv 1412.6359）③隔离进独立 small cleanup PR（防被 feature work 卷入/回滚）④小步 tested 增量 ⑤80/20 优先最常改路径 ⑥小批次 release 不大爆破。**对 MAformac = legacy frame 工具拆除走专门 PR，别混进 C5 训练改动。**
- source: https://arxiv.org/pdf/1412.6359 + https://www.panaya.com/blog/modern-alm/technical-debt-agile-way/ + https://handlewithcare.dev/blog/tech_debt_as_product_strategy/

### F9 — Periphery 是 Swift dead-code 标准工具（na）
**peripheryapp/periphery 6148★, pushed 2026-05-15**（本机 gh 核实）：直接覆盖 unused enum cases/types/properties——**正是删 legacy frame surface 后定位 orphaned 枚举/工具的机制**。配 `.periphery.yml` + CI step 防 scaffolding 再积累。SwiftLint（19627★ pushed 2026-06-21）只管 style 不可靠抓 dead enum，两者互补。
- source: https://github.com/peripheryapp/periphery + https://github.com/realm/SwiftLint

### F10 — 生成物入仓 vs gitignore 的 2026 共识 = hybrid（na）
commit 生成物（text 可 review diff 演进，如 openapi.json 追踪 breaking）+ CI regenerate+diff 兜底（保证不 stale）。spec-driven 进阶：spec 上 main 走 full review，生成实现当 build artifact。**MAformac 选了 commit 生成物 + Makefile drift gate = 正解 hybrid。**
- source: https://ashishb.net/all/when-to-commit-generated-code-to-version-control/ + https://github.com/dotansimha/graphql-code-generator/discussions/4253 + https://kentcdodds.com/blog/why-i-dont-commit-generated-files-to-master

### F11 — protovalidate：连校验逻辑也不重复（na）
**bufbuild/protovalidate 1519★, pushed 2026-06-22**：约束写在 protobuf schema 旁跨语言派生，避免'后端校验逻辑被前端手抄'。**对 MAformac = value 四件套/range 约束也应进契约 SSOT 派生校验，别在 Swift runtime 手写第二套 range check。**
- source: https://github.com/bufbuild/protovalidate + https://kmcd.dev/posts/protovalidate/

---

## Pre-mortem：adopt 到 Swift/MAformac 的坑（三分类）

### TIGER（明确威胁，带验证清单）
- **坑1 — SwiftPM build plugin sandbox**：Sourcery plugin 在 sandbox 跑，需 `swift package --allow-writing-to-package-directory sourcery-command` 才能写文件，且 `.sourcery.yml` 放 target sources 目录非 package root，Xcode 14+ 才有。**验证清单**：先在 spike target 跑通 plugin 再上主链路。source: https://github.com/krzysztofzablocki/Sourcery
- **坑2 — Periphery 依赖 build index，会误报 unused**：只看编译进 build 的源文件——只被'未编译 target / 未走的 #if 分支 / Obj-C runtime 可达'引用的声明会误报。**删 legacy frame 前必须 build 全部相关 target/config**，否则按误报删会 regression。**验证**：用 `--retain-public`（framework 无 app 消费时）/ `--retain-objc-accessible`，人工 review diff 后**手动 commit 删除，不让 CI 自动删**。source: https://github.com/peripheryapp/periphery + https://nowham.dev/posts/swift-periphery-cleanup/
- **坑3（F3）— 手写第二套必漂移**（见上，tiger）

### PAPER-TIGER（看似威胁实际安全，给证据）
- **'codegen-in-CI 会无谓断红'**：jOOQ 承认 schema 临时不可用时 build break；contract-test 作者警告 false-positive。**但 MAformac 契约源是仓内 jsonl（不依赖外部 DB/网络），verify-refs 只读 manifest+committed 不读源表（Makefile:26 注释已写明'别人 clone 仓无 snapshot 也能验'）——此坑对 MAformac 不成立，已规避。** source: https://www.jooq.org/doc/latest/manual/code-generation/codegen-version-control/ + 本机 Makefile:26

### ELEPHANT（没人提但该提）
- **双 surface 长期并存掩盖在 SSOT 派生之下**：MAformac SSOT 已对，真风险是 `frameToolSchema`（generic frame, legacy spike）与 `dDomainToolSchemas` **都从同一 compiler 派生且都进 `renderedToolsText`**（ToolContractCompiler.swift:22-58）。范式翻案后 generic frame 是债，**但因为它也是 compiler-derived（非裸硬编码），drift gate 不会报警、反而'看着合规'**。需要的是【产品决策门】：在 ToolContractCompiler 里显式标记/移除 frame surface。**这是 claim-vs-reality 铁律1 变体：compiler 派生 ≠ 该派生**——SSOT 机制正确，但派生了不该派生的东西，机械门抓不到（铁律2：合规 ≠ 语义正确）。source: 本机 ToolContractCompiler.swift:22-58

---

## adopt 建议（落 MAformac，按 ROI 排）

1. **【最高，elephant 对应】给 frame surface 加显式退役门**：在 `ToolContractCompiler` 把 `frameToolSchema` 标 `@available(*, deprecated)` 或加 `legacyFrameEnabled: Bool` 开关，让 `renderedToolsText` 默认只渲 `dDomainToolSchemas`；删之前用 Periphery 扫 orphaned 引用。**理由**：现状 drift gate 抓不到"该删的还在派生"，需人为决策门。
2. **【高】Periphery 进 CI（6148★ 活跃）**：`.periphery.yml` + PR step，专抓 legacy frame 拆除后残留的 dead enum/types。坑2 的验证清单照搬（build 全 target + retain flags + 人工 review）。
3. **【中】校验逻辑也进 SSOT 派生（protovalidate 思想）**：value 四件套 range/约束从契约派生 Swift 校验，别 runtime 手写第二套（防 F3 类漂移）。
4. **【中】保持 hybrid（已对，别改）**：commit 生成物 + Makefile `git diff --exit-code` 漂移门 = 业内正解，继续守住。
5. **【低/可选】Sourcery/SwiftGen 原生化**：若想把 Python `gen_tool_contract.py` 进一步 Swift 原生派生再考虑，注意坑1 sandbox。当前 Python 脚本 + Makefile 门已够 demo 轻治理，不必为此 over-engineer。

## vs baseline 对比
- **MAformac 现状 vs 业内最佳实践**：**better than typical**——已有 compiler 派生 + drift gate + cross-section 一致门，多数团队连 drift gate 都没有。唯一缺口 = **legacy spike surface 的退役决策门**（elephant），这不是 SSOT 机制问题，是"派生了不该派生的"产品决策问题。
- 证据：本机 Makefile 11-51 行 + ToolContractCompiler.swift；业内 drift gate 仍属'middle ground 推荐'非普及（jOOQ/GraphQL Codegen 文档语气）。