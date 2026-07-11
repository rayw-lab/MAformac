# V5B ABI proof operator guide（TEST_RUNNER bridge）

## status

`READY_AFTER_HARNESS_FIX_WAIT_OPERATOR_WINDOW`

该命令只在 commander 协调的磊哥可见授权窗执行一次。本 guide 不授权无人值守重试。

Xcode 26.6 本机一手依据：`/Applications/Xcode.app/Contents/Developer/usr/share/man/man1/xcodebuild.1:918-930` 定义 `TEST_RUNNER_<VAR>`；`xcodebuild` 会把变量传给 test runner，并将 `TEST_RUNNER_` **prefix stripped**。因此 shell 侧必须设置 `TEST_RUNNER_C1_*`，runner 内才会看到 formal `C1_*` 五键。不得再依赖普通 shell env 穿透，也不得在 sandboxed runner 内执行 `git rev-parse`。

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
  -derivedDataPath "$PWD/.build/int-v5b/DerivedData/abi-two-turn-$abi_run_id" \
  -resultBundlePath "$abi_root/mandatory-release.xcresult" \
  -only-testing:MAformacMacUITests/FrontstageRouteUITests/testReleaseCustomerTwoTurnRunIdentityContract \
  test
```

test runner 在 app launch 前 fail-closed 校验五键。缺键报 `FRONTSTAGE_UI_HARNESS_MISSING_KEY:<KEY>`；值非法报 `FRONTSTAGE_UI_HARNESS_INVALID_KEY:<KEY>`。formal method 不含 run-id/nonce fallback，也不执行 git subprocess。

成功仍以 `TEST SUCCEEDED`、两份 immutable copies、latest receipt 与两次 owner checker rc=0 四项共同判定。
