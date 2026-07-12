# V5B ABI proof operator guide（TEST_RUNNER bridge）

## status

`READY_AFTER_HARNESS_FIX_WAIT_OPERATOR_WINDOW`

该命令只在 commander 协调的磊哥可见授权窗执行一次。本 guide 不授权无人值守重试。

Xcode 26.6 本机一手依据：`/Applications/Xcode.app/Contents/Developer/usr/share/man/man1/xcodebuild.1:918-930` 定义 `TEST_RUNNER_<VAR>`；`xcodebuild` 会把变量传给 test runner，并将 `TEST_RUNNER_` **prefix stripped**。因此 shell 侧必须设置 `TEST_RUNNER_C1_*`，runner 内才会看到 formal `C1_*` 五键。不得再依赖普通 shell env 穿透，也不得在 sandboxed runner 内执行 `git rev-parse`。

Xcode 生成的 macOS UI test runner 即使 target build setting 为 `ENABLE_APP_SANDBOX=NO`，实际签名仍带 `com.apple.security.app-sandbox=true`，且对绝对路径只有 read-only exception；app 本体无 sandbox。故 runner 只读取 latest receipt，并把两轮 JSON 保存为 `.keepAlways` xcresult attachment；`xcodebuild` 返回后，由非沙箱侧 `Tools/checks/finalize_frontstage_route_ui_abi.py` 导出、双跑 owner checker，再原子发布 `owner/copies`。

## operator step

1. 系统设置 → Privacy & Security → Developer Tools，确认 Xcode 已勾选。
2. 确认无挂起的系统认证弹窗。
3. commander 派 worker 执行下列命令；出现 Automation Mode 的 Touch ID / 登录密码弹窗时，磊哥确认一次。
4. 若失败，保存 xcresult 并停止；不得盲重试。

## formal command

```bash
set -euo pipefail
cd /Users/wanglei/workspace/MAformac-int-v5b-contain

abi_run_id="c1-v5b-abi-operator-$(date -u +%Y%m%dT%H%M%SZ)-$$"
abi_root="$PWD/.build/int-v5b/abi-two-turn/$abi_run_id"
abi_run_dir="$abi_root/owner"
derived_data="$PWD/.build/int-v5b/DerivedData/abi-two-turn-$abi_run_id"
xcresult="$abi_root/mandatory-release.xcresult"
abi_nonce="$(openssl rand -hex 16)"
abi_head="$(git rev-parse HEAD)"
mkdir -p "$abi_run_dir"

TEST_RUNNER_C1_FRONTSTAGE_RECEIPT_EMIT=1 \
TEST_RUNNER_C1_FRONTSTAGE_RUN_ID="$abi_run_id" \
TEST_RUNNER_C1_FRONTSTAGE_RUN_NONCE="$abi_nonce" \
TEST_RUNNER_C1_RUN_DIR="$abi_run_dir" \
TEST_RUNNER_C1_FRONTSTAGE_SOURCE_HEAD_SHA="$abi_head" \
xcodebuild \
  -project MAformac.xcodeproj \
  -scheme MAformacMac \
  -configuration Release \
  -destination 'platform=macOS' \
  -derivedDataPath "$derived_data" \
  -resultBundlePath "$xcresult" \
  -only-testing:MAformacMacUITests/FrontstageRouteUITests/testReleaseCustomerTwoTurnRunIdentityContract \
  test

.venv/bin/python Tools/checks/finalize_frontstage_route_ui_abi.py \
  --xcresult "$xcresult" \
  --owner-dir "$abi_run_dir" \
  --checker Tools/checks/check_frontstage_route_receipt.py \
  --schema contracts/schemas/frontstage-route-receipt.schema.json \
  --matrix contracts/demo-capability-matrix.json \
  --runtime-bundle-manifest generated/demo-runtime-contract-bundle.manifest.json \
  --app-executable "$derived_data/Build/Products/Release/MAformacMac.app/Contents/MacOS/MAformacMac" \
  --expected-head "$abi_head" \
  --expected-run-id "$abi_run_id" \
  --expected-run-nonce "$abi_nonce"
```

test runner 在 app launch 前 fail-closed 校验五键。缺键报 `FRONTSTAGE_UI_HARNESS_MISSING_KEY:<KEY>`；值非法报 `FRONTSTAGE_UI_HARNESS_INVALID_KEY:<KEY>`。formal method 不含 run-id/nonce fallback，也不执行 git subprocess。

成功仍以 `TEST SUCCEEDED`、finalizer `status=PASS`、两份 immutable copies、latest receipt 与两次 owner checker rc=0 共同判定。任一失败都保留 xcresult 并停止，不能把 UI test 单绿升格成完整 ABI proof。
