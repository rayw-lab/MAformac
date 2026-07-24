# Lens 03 — CI / Fake Green

- 日期：2026-07-21
- 席位：auditor / Grok
- transcript：`history://CIFakeGreenAudit`
- 结构化输出：`agent://CIFakeGreenAudit`

## 最终有效 Finding

1. `make verify-anti-placebo` 当前实跑失败；脚本只查 `verify.yml` 是否含字面 `verify-e2e`，不能证明 Make 依赖或真实执行。来源：`scripts/verify_anti_placebo.py:88-118`。
2. `verify-ui-e2e` 用 `xcodebuild | tail` 丢失前环退出码，只检查 testsCount，不检查 failedTests。来源：`Makefile:73-91`。
3. `IOS26_UDID` 在一条 Make recipe shell 赋值，下一条 recipe 读取为空。来源：`Makefile:65-77`。
4. `ui-e2e.yml` 未提交到 GitHub、未注册、未 required；当前 uncommitted 整改未经过远端 CI。
5. `verify-e2e` 自身命令退出传播正确，且已在 `verify-ci` 依赖链中。

## 纠错记录

初始输出曾断言 `FrontstageCustomerIngressUITests` 不存在，原因是查错目录。真实文件在仓库根 `MAformacIOSUITests/FrontstageCustomerIngressUITests.swift`，该断言撤销。初始“verify-e2e 未进 verify-ci”也撤销；`Makefile:145` 已包含。

## 动态复现

主线程直接运行 P1 XCUITest 得到 1 test / 7 failures，进一步证明当前 Make 判分器会掩盖真实测试失败。
