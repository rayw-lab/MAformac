#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT_DIR="${1:-$ROOT/.pf1-motion-perf/matrix}"
SAMPLE="$ROOT/Tools/checks/motion-perf-sample.sh"
mkdir -p "$OUT_DIR"

receipts=()
for budget in fullShowcase balancedDemo trainSafeStatic; do
  receipt="$($SAMPLE --mode headless --budget "$budget" --out "$OUT_DIR")"
  receipts+=("$receipt")
done

python3 - "$OUT_DIR/motion-budget-matrix.json" "${receipts[@]}" <<'PY'
import json
import sys
from pathlib import Path

matrix_path = Path(sys.argv[1])
receipts = [json.loads(Path(path).read_text()) for path in sys.argv[2:]]
matrix = {
    "schema": "maformac.motion_perf_budget_matrix.v1",
    "status": "headless_matrix_ready_gui_traces_pending_idle_window",
    "proof_class": "local",
    "rounds": [
        {
            "level": item["budget"]["level"],
            "fps_target": item["budget"]["fps_target"],
            "orb_particle_count": item["budget"]["orb_particle_count"],
            "stage_particle_count": item["budget"]["stage_particle_count"],
            "burst_particle_count": item["budget"]["burst_particle_count"],
            "context_capsule_mode": item["budget"]["context_capsule_mode"],
            "receipt": sys.argv[index + 2],
            "pending_idle_window_count": item["pending_idle_window_count"],
        }
        for index, item in enumerate(receipts)
    ],
    "non_claims": [
        "not_perf_pass",
        "not_operator_visual_pass",
        "not_gui_trace_captured_by_headless_manifest"
    ],
}
matrix_path.write_text(json.dumps(matrix, indent=2, sort_keys=True) + "\n")
print(matrix_path)
PY
