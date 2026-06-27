#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

OUT_DIR="${1:-docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance}"
DEVICE_NAME="${UIUE_8C2_DEVICE_NAME:-iPhone 17 Pro Max}"
FALLBACK_DEVICE_NAME="${UIUE_8C2_FALLBACK_DEVICE_NAME:-iPhone 17 Pro}"
BUNDLE_ID="lab.rayw.MAformac.ios"
DERIVED_DATA="${OUT_DIR}/DerivedData"
LOG_DIR="${OUT_DIR}/_logs"
L0_DIR="${OUT_DIR}/l0"
MANIFEST="${OUT_DIR}/package-manifest.json"

CASES=(
  "main_cooling_deep_space"
  "main_heating_ivory"
  "safety_refusal_ivory"
  "capsule_video_loop_deep_space"
  "u17_golden_path_deep_space"
)

mkdir -p "$OUT_DIR" "$LOG_DIR" "$L0_DIR"
rm -rf "$DERIVED_DATA"
rm -f "$MANIFEST" "$L0_DIR"/*.json "$L0_DIR"/*.png "$L0_DIR"/*.txt
rm -rf "$LOG_DIR"/*

resolve_udid() {
  local name="$1"
  local devices_json
  devices_json="$(mktemp "${TMPDIR:-/tmp}/uiue-8c2-sim-devices.XXXXXX.json")"
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

launch_args_for_case() {
  case "$1" in
    main_cooling_deep_space)
      printf '%s\n' "-mockSnapshot" "cooling" "-mockTheme" "deepSpace"
      ;;
    main_heating_ivory)
      printf '%s\n' "-mockSnapshot" "heating" "-mockTheme" "ivory"
      ;;
    safety_refusal_ivory)
      printf '%s\n' "-mockSnapshot" "safetyRefusal" "-mockTheme" "ivory"
      ;;
    capsule_video_loop_deep_space)
      printf '%s\n' "-mockSnapshot" "cooling" "-mockTheme" "deepSpace" "-contextCapsuleRoute" "videoLoop"
      ;;
    u17_golden_path_deep_space)
      printf '%s\n' "-goldenPathID" "uiue_g9b_ac_success_deep_space"
      ;;
    *)
      echo "error: unknown 8.C2 case: $1" >&2
      return 2
      ;;
  esac
}

theme_for_case() {
  case "$1" in
    main_heating_ivory|safety_refusal_ivory)
      printf 'ivory\n'
      ;;
    *)
      printf 'deepSpace\n'
      ;;
  esac
}

test_method_for_case() {
  case "$1" in
    main_cooling_deep_space)
      printf 'testMainCoolingDeepSpaceCapturesUITree\n'
      ;;
    main_heating_ivory)
      printf 'testMainHeatingIvoryCapturesUITree\n'
      ;;
    safety_refusal_ivory)
      printf 'testSafetyRefusalIvoryCapturesUITree\n'
      ;;
    capsule_video_loop_deep_space)
      printf 'testCapsuleVideoLoopDeepSpaceCapturesUITree\n'
      ;;
    u17_golden_path_deep_space)
      printf 'testU17GoldenPathDeepSpaceCapturesUITree\n'
      ;;
    *)
      echo "error: unknown 8.C2 case: $1" >&2
      return 2
      ;;
  esac
}

assert_single_booted_simulator() {
  local booted_lines
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
}

extract_ui_tree() {
  local case_id="$1"
  local log_path="$2"
  local tree_path="$3"
  python3 - "$case_id" "$log_path" "$tree_path" <<'PY'
import sys
from pathlib import Path

case_id = sys.argv[1]
log_path = Path(sys.argv[2])
tree_path = Path(sys.argv[3])
text = log_path.read_text(encoding="utf-8", errors="replace")
start_marker = f"UIUE_8C2_CASE_BEGIN {case_id}"
end_marker = f"UIUE_8C2_CASE_END {case_id}"
start = text.rfind(start_marker)
end = text.rfind(end_marker)

if start == -1 or end == -1 or end <= start:
    print(f"error: failed to extract UIUE 8.C2 UI tree markers for {case_id}", file=sys.stderr)
    raise SystemExit(6)

tree = text[start + len(start_marker):end].strip()
tree_path.write_text(tree + "\n", encoding="utf-8")
PY
}

write_l0_json() {
  local case_id="$1"
  local launch_arg_text="$2"
  local theme="$3"
  local ui_tree="$4"
  local screenshot="$5"
  local output_json="$6"
  python3 - "$OUT_DIR" "$case_id" "$DEVICE_NAME" "$UDID" "$launch_arg_text" "$theme" "$ui_tree" "$screenshot" "$output_json" <<'PY'
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

out_dir = Path(sys.argv[1])
case_id = sys.argv[2]
device_name = sys.argv[3]
device_udid = sys.argv[4]
launch_arg_text = sys.argv[5]
theme = sys.argv[6]
ui_tree = Path(sys.argv[7])
screenshot = Path(sys.argv[8])
output_json = Path(sys.argv[9])

def rel(path: Path) -> str:
    return str(path.relative_to(out_dir))

payload = {
    "case_id": case_id,
    "captured_at": datetime.now(timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z"),
    "device": {
        "name": device_name,
        "udid": device_udid,
        "runtime": "iOS Simulator"
    },
    "launchArg": launch_arg_text,
    "theme": theme,
    "ui_tree_evidence": rel(ui_tree),
    "screenshot_path": rel(screenshot),
    "proof_class": "simulator_l0_runtime_truth",
    "screenshot_source": "on_screen_simctl_io_booted_screenshot",
    "capture_command": "xcrun simctl io booted screenshot",
    "ui_tree_source": "XCUITest stdout debugDescription markers",
    "forbidden_sources_not_used": [
        "ImageRenderer",
        "SwiftUI preview",
        "Preview",
        "static snapshot",
        "XCTAttachment",
        "xcuitest_attachment"
    ],
    "claims_not_made": [
        "mobile",
        "true_device",
        "L3",
        "V-PASS",
        "A-2 complete"
    ]
}
output_json.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
PY
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

for case_id in "${CASES[@]}"; do
  result_bundle="${LOG_DIR}/${case_id}.xcresult"
  xcodebuild_log="${LOG_DIR}/${case_id}-xcodebuild.log"
  ui_tree="${L0_DIR}/${case_id}-ui-tree.txt"
  screenshot="${L0_DIR}/${case_id}-simctl.png"
  l0_json="${L0_DIR}/${case_id}.json"
  rm -rf "$result_bundle"
  test_method="$(test_method_for_case "$case_id")"

  set +e
  xcodebuild test \
    -project MAformac.xcodeproj \
    -scheme MAformacIOS \
    -destination "platform=iOS Simulator,name=${DEVICE_NAME}" \
    -derivedDataPath "$DERIVED_DATA" \
    -resultBundlePath "$result_bundle" \
    "-only-testing:MAformacIOSUITests/UIC2VisualAcceptanceUITests/${test_method}" \
    2>&1 | tee "$xcodebuild_log"
  xcodebuild_status="${PIPESTATUS[0]}"
  set -e

  if [[ "$xcodebuild_status" != "0" ]]; then
    echo "error: 8.C2 XCUITest failed for ${case_id}; see ${xcodebuild_log}" >&2
    exit "$xcodebuild_status"
  fi

  extract_ui_tree "$case_id" "$xcodebuild_log" "$ui_tree"

  APP_PATH="${DERIVED_DATA}/Build/Products/Debug-iphonesimulator/MAformacIOS.app"
  if [[ ! -d "$APP_PATH" ]]; then
    echo "error: expected built app at $APP_PATH" >&2
    exit 3
  fi

  xcrun simctl install "$UDID" "$APP_PATH"
  xcrun simctl terminate "$UDID" "$BUNDLE_ID" >/dev/null 2>&1 || true
  launch_args=()
  while IFS= read -r launch_arg; do
    launch_args+=("$launch_arg")
  done < <(launch_args_for_case "$case_id")
  xcrun simctl launch "$UDID" "$BUNDLE_ID" "${launch_args[@]}"
  sleep 3

  assert_single_booted_simulator
  xcrun simctl io booted screenshot "$screenshot"

  launch_arg_text="${launch_args[*]}"
  write_l0_json "$case_id" "$launch_arg_text" "$(theme_for_case "$case_id")" "$ui_tree" "$screenshot" "$l0_json"
done

python3 - "$OUT_DIR" "$MANIFEST" "${CASES[@]}" <<'PY'
import json
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

out_dir = Path(sys.argv[1])
manifest_path = Path(sys.argv[2])
cases = sys.argv[3:]
repo_head = subprocess.check_output(["git", "rev-parse", "--short", "HEAD"], text=True).strip()
payload = {
    "package_id": "uiue-8c2-l0-l3-visual-acceptance",
    "created_at": datetime.now(timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z"),
    "repo_head": repo_head,
    "proof_class": "simulator_l0_runtime_truth_plus_local_l1_l2_pending_l3",
    "cases": cases,
    "l0": [f"l0/{case_id}.json" for case_id in cases],
    "l1": {
        "summary": "l1/l1-summary.tsv",
        "boundary": "L1 sentinel blocks collapse only; it does not sign aesthetics or replace L3."
    },
    "l2": {
        "summary": "l2/l2-summary.json",
        "ocr_engine": "VNRecognizeTextRequest",
        "contrast_gate": "hard_gate",
        "ssim": "regression_evidence_only"
    },
    "l3": {
        "template": "l3/human-5gate-verdict.md",
        "verdict": "PENDING",
        "v_pass_authority": "磊哥 only"
    },
    "readme": "README.md",
    "claims_not_made": [
        "mobile",
        "true_device",
        "L3",
        "V-PASS",
        "A-2 complete"
    ]
}
manifest_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
PY

python3 Tools/checks/check-8c2-l0-evidence.py "$OUT_DIR"
rm -rf "$DERIVED_DATA" "$LOG_DIR"
