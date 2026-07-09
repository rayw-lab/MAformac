#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MANIFEST="$ROOT/Tools/checks/motion-perf-sampling-points.json"
OUT_DIR="$ROOT/.pf1-motion-perf"
BUDGET="balancedDemo"
MODE="headless"
DURATION_SECONDS="${PF1_XCTRACE_DURATION_SECONDS:-20}"
TEMPLATE="${PF1_XCTRACE_TEMPLATE:-Animation Hitches}"
APP_PATH="${PF1_APP_PATH:-}"

usage() {
  cat <<'USAGE'
Usage: Tools/checks/motion-perf-sample.sh [--budget fullShowcase|balancedDemo|trainSafeStatic] [--mode headless|xctrace] [--out DIR]

headless:
  Validates the PF1 sampling manifest and writes a JSON receipt. GUI-only points
  are marked pending_idle_window for the T6R idle-window package.

xctrace:
  Requires PF1_RUN_XCTRACE=1 and PF1_APP_PATH=/path/to/MAformac.app. Records an
  xctrace run with the selected template, then writes a receipt beside the trace.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --budget)
      BUDGET="${2:?missing budget}"
      shift 2
      ;;
    --mode)
      MODE="${2:?missing mode}"
      shift 2
      ;;
    --out)
      OUT_DIR="${2:?missing output directory}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "unknown argument: $1" >&2
      usage >&2
      exit 64
      ;;
  esac
done

mkdir -p "$OUT_DIR"

case "$BUDGET" in
  fullShowcase|balancedDemo|trainSafeStatic) ;;
  *)
    echo "unsupported budget: $BUDGET" >&2
    exit 64
    ;;
esac

case "$MODE" in
  headless|xctrace) ;;
  *)
    echo "unsupported mode: $MODE" >&2
    exit 64
    ;;
esac

RECEIPT="$OUT_DIR/pf1-${BUDGET}-${MODE}-receipt.json"
TRACE_PATH="$OUT_DIR/pf1-${BUDGET}.trace"
TRACE_STATUS="not_requested"

if [[ "$MODE" == "xctrace" ]]; then
  if [[ "${PF1_RUN_XCTRACE:-0}" != "1" ]]; then
    TRACE_STATUS="pending_idle_window"
  elif [[ -z "$APP_PATH" || ! -d "$APP_PATH" ]]; then
    echo "PF1_APP_PATH must point to a built .app when PF1_RUN_XCTRACE=1" >&2
    exit 65
  else
    rm -rf "$TRACE_PATH"
    xcrun xctrace record \
      --template "$TEMPLATE" \
      --time-limit "${DURATION_SECONDS}s" \
      --output "$TRACE_PATH" \
      --launch "$APP_PATH"
    TRACE_STATUS="captured"
  fi
fi

python3 - "$MANIFEST" "$RECEIPT" "$BUDGET" "$MODE" "$TRACE_STATUS" "$TRACE_PATH" <<'PY'
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

manifest_path, receipt_path, budget_name, mode, trace_status, trace_path = sys.argv[1:7]
manifest = json.loads(Path(manifest_path).read_text())

budgets = {item["level"]: item for item in manifest["budgets"]}
if budget_name not in budgets:
    raise SystemExit(f"budget missing from manifest: {budget_name}")

points = manifest["sampling_points"]
pending = [item["id"] for item in points if item.get("capture") == "pending_idle_window"]
headless_ready = {
    "status": "headless_manifest_ready" if mode == "headless" else trace_status,
    "proof_class": "local" if mode == "headless" else "runtime_pending_or_runtime",
    "captured_at": datetime.now(timezone.utc).isoformat(),
    "budget": budgets[budget_name],
    "sampled_points": [item["id"] for item in points],
    "sampled_point_count": len(points),
    "pending_idle_window_points": pending,
    "pending_idle_window_count": len(pending),
    "trace_status": trace_status,
    "trace_path": trace_path if trace_status == "captured" else None,
    "manifest": manifest_path,
    "non_claims": manifest["non_claims"],
}
Path(receipt_path).write_text(json.dumps(headless_ready, indent=2, sort_keys=True) + "\n")
print(receipt_path)
PY
