#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

OUT_DIR="${1:-docs/research/2026-06-27-uiue-8g9b-u17-l0}"
DEVICE_NAME="${U17_DEVICE_NAME:-iPhone 17 Pro Max}"
FALLBACK_DEVICE_NAME="${U17_FALLBACK_DEVICE_NAME:-iPhone 17 Pro}"
GOLDEN_PATH_ID="uiue_g9b_ac_success_deep_space"
BUNDLE_ID="lab.rayw.MAformac.ios"
DERIVED_DATA="${OUT_DIR}/DerivedData"
RESULT_BUNDLE="${OUT_DIR}/u17-xcuitest.xcresult"
XCODEBUILD_LOG="${OUT_DIR}/u17-xcodebuild.log"
UI_TREE="${OUT_DIR}/u17-ui-tree.txt"
SCREENSHOT="${OUT_DIR}/u17-golden-path-simctl.png"
EVIDENCE_JSON="${OUT_DIR}/l0-evidence.json"

mkdir -p "$OUT_DIR"
rm -rf "$RESULT_BUNDLE" "$DERIVED_DATA"
rm -f "$XCODEBUILD_LOG" "$UI_TREE" "$SCREENSHOT" "$EVIDENCE_JSON"

resolve_udid() {
  local name="$1"
  local devices_json
  devices_json="$(mktemp "${TMPDIR:-/tmp}/u17-sim-devices.XXXXXX.json")"
  xcrun simctl list devices available --json > "$devices_json"
  python3 - "$name" "$devices_json" <<'PY'
import json
import sys

target = sys.argv[1]
with open(sys.argv[2], encoding="utf-8") as handle:
    payload = json.load(handle)
for devices in payload.get("devices", {}).values():
    for device in devices:
        if device.get("name") == target and device.get("isAvailable", False):
            print(device["udid"])
            raise SystemExit(0)
raise SystemExit(1)
PY
  rm -f "$devices_json"
}

UDID="$(resolve_udid "$DEVICE_NAME" || true)"
if [[ -z "$UDID" ]]; then
  DEVICE_NAME="$FALLBACK_DEVICE_NAME"
  UDID="$(resolve_udid "$DEVICE_NAME" || true)"
fi

if [[ -z "$UDID" ]]; then
  echo "error: no available simulator named iPhone 17 Pro Max or iPhone 17 Pro" >&2
  exit 2
fi

xcrun simctl boot "$UDID" >/dev/null 2>&1 || true
xcrun simctl bootstatus "$UDID" -b
open -a Simulator --args -CurrentDeviceUDID "$UDID" >/dev/null 2>&1 || true

set +e
U17_L0_EVIDENCE_DIR="$OUT_DIR" \
xcodebuild test \
  -project MAformac.xcodeproj \
  -scheme MAformacIOS \
  -destination "platform=iOS Simulator,name=${DEVICE_NAME}" \
  -derivedDataPath "$DERIVED_DATA" \
  -resultBundlePath "$RESULT_BUNDLE" \
  -only-testing:MAformacIOSUITests/U17GoldenPathUITests/testGoldenPathLaunchesAndCapturesCoreUI \
  2>&1 | tee "$XCODEBUILD_LOG"
xcodebuild_status="${PIPESTATUS[0]}"
set -e

if [[ "$xcodebuild_status" != "0" ]]; then
  echo "error: U17 XCUITest failed; see $XCODEBUILD_LOG" >&2
  exit "$xcodebuild_status"
fi

python3 - "$XCODEBUILD_LOG" "$UI_TREE" <<'PY'
import sys
from pathlib import Path

log_path = Path(sys.argv[1])
tree_path = Path(sys.argv[2])
text = log_path.read_text(encoding="utf-8", errors="replace")
start_marker = "U17_UI_TREE_BEGIN"
end_marker = "U17_UI_TREE_END"
start = text.rfind(start_marker)
end = text.rfind(end_marker)
if start == -1 or end == -1 or end <= start:
    print("error: failed to extract U17 UI tree markers from xcodebuild log", file=sys.stderr)
    raise SystemExit(6)

tree = text[start + len(start_marker):end].strip()
tree_path.write_text(tree + "\n", encoding="utf-8")
PY

APP_PATH="${DERIVED_DATA}/Build/Products/Debug-iphonesimulator/MAformacIOS.app"
if [[ ! -d "$APP_PATH" ]]; then
  echo "error: expected built app at $APP_PATH" >&2
  exit 3
fi

xcrun simctl install "$UDID" "$APP_PATH"
xcrun simctl terminate "$UDID" "$BUNDLE_ID" >/dev/null 2>&1 || true
xcrun simctl launch "$UDID" "$BUNDLE_ID" -goldenPathID "$GOLDEN_PATH_ID"
sleep 3

booted_lines="$(xcrun simctl list devices available | grep "(Booted)" || true)"
if [[ "$(printf "%s\n" "$booted_lines" | sed '/^$/d' | wc -l | tr -d ' ')" != "1" ]]; then
  echo "error: expected exactly one booted simulator before L0 screenshot" >&2
  printf "%s\n" "$booted_lines" >&2
  exit 4
fi

if ! printf "%s\n" "$booted_lines" | grep -q "$UDID"; then
  echo "error: booted simulator is not target device $DEVICE_NAME ($UDID)" >&2
  printf "%s\n" "$booted_lines" >&2
  exit 5
fi

xcrun simctl io booted screenshot "$SCREENSHOT"

python3 - "$EVIDENCE_JSON" "$DEVICE_NAME" "$UDID" "$UI_TREE" "$SCREENSHOT" "$RESULT_BUNDLE" <<'PY'
import json
import sys
from pathlib import Path

evidence_path = Path(sys.argv[1])
device_name = sys.argv[2]
device_udid = sys.argv[3]
ui_tree = Path(sys.argv[4])
screenshot = Path(sys.argv[5])
result_bundle = Path(sys.argv[6])
out_dir = evidence_path.parent

def rel(path: Path) -> str:
    return str(path.relative_to(out_dir))

payload = {
    "device": {
        "name": device_name,
        "udid": device_udid,
        "runtime": "iOS Simulator"
    },
    "launchArg": "-goldenPathID uiue_g9b_ac_success_deep_space",
    "theme": "deepSpace",
    "ui_tree_evidence": rel(ui_tree),
    "screenshot_path": rel(screenshot),
    "proof_class": "simulator_l0_runtime_truth",
    "screenshot_source": "on_screen_simctl_io_booted_screenshot",
    "capture_command": "xcrun simctl io booted screenshot u17-golden-path-simctl.png",
    "ui_tree_source": "XCUITest stdout debugDescription markers",
    "claims_not_made": [
        "mobile",
        "true_device",
        "L3",
        "V-PASS",
        "A-2 complete"
    ]
}
evidence_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
PY

python3 Tools/checks/check-u17-l0-evidence.py "$OUT_DIR"
rm -rf "$DERIVED_DATA" "$RESULT_BUNDLE"
rm -f "$XCODEBUILD_LOG"
