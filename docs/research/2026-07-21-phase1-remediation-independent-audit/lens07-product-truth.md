# Lens 07 — Product Truth

- 日期：2026-07-21
- 席位：glm-worker
- transcript：`history://ProductTruthAudit`
- 结构化输出：`agent://ProductTruthAudit`

## 有效 Finding

1. 当前 app 产品路径是 FastPath literal，不经过 LLM；DDomain backend 存在但未接 app 路由。
2. ASR 为 `.stubDisabledGuidance`；多意图 fail-closed；车窗/座椅/灯光等零准入。
3. 空调 surface 实际为 1 条 exact + 6 个温度前缀，共 7 类；handoff 少列“能把空调调到N度”。
4. “能调到26度吗”当前会执行 power-on + temp，而 WBS WP2-4c 要求只回答不执行。
5. COR-1 的安全门代码真实并有行为测试。

## 复判修正

原席位静态读取后把 COR-4 判为已修。主线程随后发现 frozen WBS 要求空 content，而活跃测试把 `The answer is 42.` 判为合法；parser 还绕过 size，runner 把 `[]` 映为 unsupported。故 COR-4 最终裁决改为 FAIL。

## Runtime Ceiling

可演能力只能表述为 Core literal route 的窄域空调行为；iOS 客户前台入口在直接 XCUITest 中失败，不能从 core test 推导产品可演。
