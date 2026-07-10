#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
python_bin="${PYTHON_BIN:-$root/.venv/bin/python}"
test -x "$python_bin"
"$python_bin" -c 'import jsonschema'

if [ -z "${C1_FRONTSTAGE_RECEIPT_EMIT+x}" ]; then
  C1_FRONTSTAGE_RECEIPT_EMIT=1
  C1_FRONTSTAGE_RUN_ID="c1-frontstage-local-$$"
  C1_FRONTSTAGE_RUN_NONCE="$(openssl rand -hex 16)"
  C1_RUN_DIR="$root/.build/c1-run/$C1_FRONTSTAGE_RUN_ID"
  C1_FRONTSTAGE_SOURCE_HEAD_SHA="$(git rev-parse HEAD)"
fi
export C1_FRONTSTAGE_RECEIPT_EMIT C1_FRONTSTAGE_RUN_ID C1_FRONTSTAGE_RUN_NONCE C1_RUN_DIR C1_FRONTSTAGE_SOURCE_HEAD_SHA

swift build --product FrontstageRouteGateCLI >/dev/null
app_executable="$root/.build/debug/FrontstageRouteGateCLI"
"$app_executable" >/dev/null
receipt="$C1_RUN_DIR/receipts/c1/frontstage-route-receipt.v1.json"
"$python_bin" Tools/checks/check_frontstage_route_receipt.py \
  --receipt "$receipt" \
  --schema contracts/schemas/frontstage-route-receipt.schema.json \
  --matrix contracts/demo-capability-matrix.json \
  --runtime-bundle-manifest generated/demo-runtime-contract-bundle.manifest.json \
  --app-executable "$app_executable" \
  --expected-head "$C1_FRONTSTAGE_SOURCE_HEAD_SHA" \
  --expected-run-id "$C1_FRONTSTAGE_RUN_ID" \
  --expected-run-nonce "$C1_FRONTSTAGE_RUN_NONCE"
