#!/usr/bin/env bash
# V9 product-operator TTS hard-gate preflight (AD-7 / S5).
# Real local AVSpeech voice lookup via scripts/check_tts_preflight.swift.
# Proof class: runtime_local_preflight only — NOT operator / mobile / true-device.
# Emits a single machine-readable JSON receipt on stdout. Nonzero exit when no zh voice.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"

check_script="${root}/scripts/check_tts_preflight.swift"
if [[ ! -f "${check_script}" ]]; then
  printf '%s\n' "{\"proof_class\":\"runtime_local_preflight\",\"verdict\":\"FAIL\",\"reason\":\"missing_check_tts_preflight_swift\",\"preferred_zh_CN\":false,\"fallback_zh\":false,\"premium_zh_CN\":false,\"voice_count\":0,\"warnings\":[\"missing_check_script\"]}"
  exit 2
fi

# Real local voice lookup (AVSpeech). Capture stdout; tolerate nonzero from checker.
set +e
raw_json="$(/usr/bin/env swift "${check_script}" 2>/dev/null)"
checker_rc=$?
set -e

if [[ -z "${raw_json}" ]]; then
  printf '%s\n' "{\"proof_class\":\"runtime_local_preflight\",\"verdict\":\"FAIL\",\"reason\":\"empty_checker_output\",\"preferred_zh_CN\":false,\"fallback_zh\":false,\"premium_zh_CN\":false,\"voice_count\":0,\"warnings\":[\"empty_checker_output\"],\"checker_exit_code\":${checker_rc}}"
  exit 3
fi

# Single machine-readable receipt with explicit PASS/FAIL and proof class.
# Prefer python for JSON reshape; fall back to a minimal pure-shell path.
# Checker JSON is piped on stdin (no repo artifact write).
if command -v python3 >/dev/null 2>&1; then
  receipt="$(
    CHECKER_RC="${checker_rc}" python3 -c '
import json, os, sys
raw = sys.stdin.read()
try:
    data = json.loads(raw)
except Exception as exc:
    print(json.dumps({
        "proof_class": "runtime_local_preflight",
        "verdict": "FAIL",
        "reason": "checker_json_parse_error",
        "preferred_zh_CN": False,
        "fallback_zh": False,
        "premium_zh_CN": False,
        "voice_count": 0,
        "warnings": ["parse_error:%s" % exc],
        "checker_exit_code": int(os.environ.get("CHECKER_RC", "1")),
        "non_claims": ["operator-pass", "mobile", "true-device", "customer_path_DONE", "actionDemoProven"],
    }, ensure_ascii=False, sort_keys=True))
    sys.exit(0)

disposition = str(data.get("disposition", "")).lower()
fallback_zh = bool(data.get("fallback_zh", False))
preferred = bool(data.get("preferred_zh_CN", False))
premium = bool(data.get("premium_zh_CN", False))
voice_count = int(data.get("voice_count", 0) or 0)
warnings = list(data.get("warnings") or [])

# Hard gate: no zh* voice → FAIL. warning (missing preferred/premium) still PASS
# when fallback_zh is true — local preflight only, not operator/true-device.
if disposition == "fail" or not fallback_zh:
    verdict = "FAIL"
    reason = "no_chinese_voice"
elif disposition in ("pass", "warning"):
    verdict = "PASS"
    reason = "chinese_voice_available" if disposition == "pass" else "chinese_voice_available_with_warnings"
else:
    verdict = "FAIL"
    reason = "unknown_disposition:%s" % (disposition or "empty")

print(json.dumps({
    "proof_class": "runtime_local_preflight",
    "verdict": verdict,
    "reason": reason,
    "preferred_zh_CN": preferred,
    "fallback_zh": fallback_zh,
    "premium_zh_CN": premium,
    "voice_count": voice_count,
    "warnings": warnings,
    "checker_disposition": disposition,
    "checker_exit_code": int(os.environ.get("CHECKER_RC", "0")),
    "non_claims": [
        "operator-pass",
        "mobile",
        "true-device",
        "customer_path_DONE",
        "actionDemoProven",
    ],
}, ensure_ascii=False, sort_keys=True))
' <<<"${raw_json}"
  )"
  # Note: <<< is safe here because checker JSON is single-line compact-ish pretty JSON without NULs.
else
  # Minimal fallback without python: surface raw checker fields + hard verdict.
  if printf '%s' "${raw_json}" | grep -q '"disposition"[[:space:]]*:[[:space:]]*"fail"'; then
    verdict="FAIL"
    reason="no_chinese_voice"
  elif printf '%s' "${raw_json}" | grep -q '"fallback_zh"[[:space:]]*:[[:space:]]*false'; then
    verdict="FAIL"
    reason="no_chinese_voice"
  else
    verdict="PASS"
    reason="chinese_voice_available"
  fi
  receipt="{\"proof_class\":\"runtime_local_preflight\",\"verdict\":\"${verdict}\",\"reason\":\"${reason}\",\"checker_exit_code\":${checker_rc},\"non_claims\":[\"operator-pass\",\"mobile\",\"true-device\"],\"checker_receipt\":${raw_json}}"
fi

printf '%s\n' "${receipt}"

# Nonzero when no zh voice / FAIL.
if printf '%s' "${receipt}" | grep -q '"verdict"[[:space:]]*:[[:space:]]*"FAIL"'; then
  exit 66
fi
exit 0
