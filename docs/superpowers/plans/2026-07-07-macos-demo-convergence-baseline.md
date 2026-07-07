# macOS Demo Convergence Baseline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把当前已有 SwiftUI 双端 presentation lane 收敛成可复核的 macOS 端侧 mock demo 路线 baseline，同时保持 proof class 诚实，不新增 C 系列决策。

**Architecture:** 先固定 Mac demo 的最小可演示 shell 和证据链，再把 `ui-presentation`、`define-runtime-presentation-bridge`、`define-demo-default-scope` 的现有边界 reconcile 成一个 operator-scoped package。Mac demo 只消费现有 App/Core/Presentation/mock 路径，不引入真 ASR/TTS/LLM/LoRA，不把 local/mock/simulator 证据升级成 `V-PASS`。

**Tech Stack:** SwiftUI, Xcode project `MAformac.xcodeproj`, schemes `MAformacMac` / `MAformacIOS`, Swift Package tests, OpenSpec, Python/shell evidence checkers, local docs receipts.

## Global Constraints

- 本计划是 `implementation_plan_not_ssot`；权威仍是 `CLAUDE.md`、OpenSpec、当前 receipt、live repo truth。
- 本轮目标是 macOS mock demo 收敛；不得混入真 ASR/TTS/LLM/LoRA、C5/C6 acceptance、demo-golden-run、voice-ready、runtime-ready、mobile、true_device、live_api。
- `ui-presentation` 的 `8.C2` 当前保持 open；L0/L1/L2 自动化证据不能替代 L3 人审或 `V-PASS`。
- `verify-uiue-interactions` 当前只能作为 UIUE-scoped gate candidate；不得直接塞入全局 `make verify-all`。
- `define-demo-default-scope` 已作为 dedicated carrier；下游只消费，不重新定义 omitted/default/fan-out scope。
- `define-runtime-presentation-bridge` 是 bridge/payload/proof-cap authority；UIUE 或 Mac package 不得自造 shared field 或 proof vocabulary。
- 涉及 Swift symbol 编辑前，执行者须按当前 repo GitNexus 纪律做 impact/navigation；本 baseline 不替代该步骤。
- 每个 PR/commit 只绑定一个 proof domain：Mac shell、bridge/proof cap、OpenSpec/docs reconcile、demo package 分开。

---

## Current Baseline Truth

- Repo: `/Users/wanglei/workspace/MAformac`
- Branch at plan creation: `codex/rebuild-c6-doc-absorption-20260624`
- HEAD at plan creation: `f2ec2497dbf2b6f751fa6f377105b6646371954c` (`creation_snapshot`; stale unless Task 1 reprobes live HEAD)
- Dirty at plan creation: `M docs/CURRENT.md`
- Existing Mac app target: `MAformacMac` in `MAformac.xcodeproj/project.pbxproj`
- Existing Mac layout contract: `Tests/MAformacCoreTests/U14MacLayoutContractTests.swift`
- Current gap: Mac target/layout exists, but Mac-specific shared scheme/evidence package/acceptance receipt is not yet a first-class proof chain.

## File Structure

| Path | Responsibility |
|---|---|
| `MAformac.xcodeproj/xcshareddata/xcschemes/MAformacMac.xcscheme` | If the shared file is missing, make Mac build/run entry reproducible through a repo-owned shared scheme even when Xcode can infer a local/generated scheme. |
| `Tools/checks/capture-macos-demo-evidence.sh` | Capture Mac demo build/run/screenshot metadata without claiming runtime/mobile proof. |
| `Tools/checks/check-macos-demo-evidence.py` | Validate the Mac evidence package fields and proof caps fail-closed. |
| `docs/research/2026-07-07-macos-demo-convergence/README.md` | Human-readable evidence index and non-claim ledger for the first Mac package. |
| `docs/research/2026-07-07-macos-demo-convergence/evidence.json` | Machine-readable evidence summary for Mac shell proof. |
| `openspec/changes/ui-presentation/tasks.md` | Reconcile checklist comments only if the Mac package materially changes `8.C2` precursor status; do not close `8.C2`. |
| `openspec/changes/define-runtime-presentation-bridge/tasks.md` | Reconcile Gate4 UIUE route/burndown only after bridge payload/proof-cap is still green. |
| `docs/superpowers/plans/2026-07-07-macos-demo-convergence-baseline.md` | This baseline plan; planning artifact only. |

## Phase Baseline

| Phase | Scope | Expected State |
|---|---|---|
| P0 | Re-probe truth and branch hygiene | Exact repo/head/dirty/scheme truth recorded. |
| P1 | Minimal Mac demo shell | Mac build/run smoke and evidence package exist; proof class `local/mac_runtime_smoke` or weaker. |
| P2 | OpenSpec reconciliation | Existing carriers point to the Mac package without changing product-level claims. |
| P3 | Deliverable demo package | Launch checklist, evidence index, non-claim ledger, and rollback notes exist. |
| P4 | Independent audit | Read-only subagent audit verifies no fake green and no scope drift. |

### Task 1: Truth Freeze And Mac Entry Probe

**Files:**
- Read: `CLAUDE.md`
- Read: `docs/CURRENT.md`
- Read: `docs/README.md`
- Read: `MAformac.xcodeproj/project.pbxproj`
- Read: `MAformac.xcodeproj/xcshareddata/xcschemes/`
- Read: `App/ContentView.swift`
- Read: `Tests/MAformacCoreTests/U14MacLayoutContractTests.swift`

**Interfaces:**
- Consumes: live git status, current xcode project target list, existing Mac split contract.
- Produces: a commander-approved go/no-go for Task 2; no file changes.

- [ ] **Step 1.1: Record repo truth**

Run:

```bash
pwd
git status --short --branch
git rev-parse HEAD
git branch --show-current
```

Expected: cwd is `/Users/wanglei/workspace/MAformac`; branch is known; dirty files are explicitly listed. If dirty files other than this plan and known user-owned docs exist, stop and partition owned/unowned before edits.

- [ ] **Step 1.2: Confirm Mac target and scheme truth**

Run:

```bash
rg -n "MAformacMac|MAformacIOS" MAformac.xcodeproj/project.pbxproj
ls -la MAformac.xcodeproj/xcshareddata/xcschemes
xcodebuild -list -project MAformac.xcodeproj
```

Expected: `MAformacMac` target exists. `xcodebuild -list` is recorded as scheme truth only; Task 2.0 decides whether to create a shared scheme from repo-owned file existence at `MAformac.xcodeproj/xcshareddata/xcschemes/MAformacMac.xcscheme`, not from generated scheme visibility.

- [ ] **Step 1.3: Confirm Mac layout contract truth**

Run:

```bash
swift test --filter U14MacLayoutContractTests
```

Expected: PASS. If it fails, stop and route to a focused Mac layout regression fix before any package work.

- [ ] **Step 1.4: Commit boundary**

Do not commit in this task. Record the truth probe output in the Task 2 receipt or package notes.

### Task 2: Minimal macOS Demo Shell Evidence

**Files:**
- Create: `Tools/checks/capture-macos-demo-evidence.sh`
- Create: `Tools/checks/check-macos-demo-evidence.py`
- Create: `docs/research/2026-07-07-macos-demo-convergence/evidence.json`
- Create: `docs/research/2026-07-07-macos-demo-convergence/README.md`
- Modify only if missing and commander-approved: `MAformac.xcodeproj/xcshareddata/xcschemes/MAformacMac.xcscheme`

**Interfaces:**
- Consumes: `MAformacMac` target, `ContentView.usesMacSplit(size:)`, existing launch args in `App/MAformacApp.swift`.
- Produces: a reproducible Mac shell proof package capped at `local/mac_runtime_smoke`.

- [ ] **Step 2.0: Create Mac shared scheme if the repo-owned shared file is missing**

If `MAformac.xcodeproj/xcshareddata/xcschemes/MAformacMac.xcscheme` does not exist, create it. Do this even if `xcodebuild -list -project MAformac.xcodeproj` already lists an inferred `MAformacMac` scheme, because the baseline needs a repo-owned shared launch entry.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "2650"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES"
      buildArchitectures = "Automatic">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "A50000000000000000000001"
               BuildableName = "MAformacMac.app"
               BlueprintName = "MAformacMac"
               ReferencedContainer = "container:MAformac.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "NO"
            buildForProfiling = "NO"
            buildForArchiving = "NO"
            buildForAnalyzing = "NO">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "D50000000000000000000001"
               BuildableName = "MAformacCoreTests.xctest"
               BlueprintName = "MAformacCoreTests"
               ReferencedContainer = "container:MAformac.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES"
      shouldAutocreateTestPlan = "YES">
      <Testables>
         <TestableReference
            skipped = "NO">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "D50000000000000000000001"
               BuildableName = "MAformacCoreTests.xctest"
               BlueprintName = "MAformacCoreTests"
               ReferencedContainer = "container:MAformac.xcodeproj">
            </BuildableReference>
         </TestableReference>
      </Testables>
      <MacroExpansion>
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "A50000000000000000000001"
            BuildableName = "MAformacMac.app"
            BlueprintName = "MAformacMac"
            ReferencedContainer = "container:MAformac.xcodeproj">
         </BuildableReference>
      </MacroExpansion>
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "A50000000000000000000001"
            BuildableName = "MAformacMac.app"
            BlueprintName = "MAformacMac"
            ReferencedContainer = "container:MAformac.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "A50000000000000000000001"
            BuildableName = "MAformacMac.app"
            BlueprintName = "MAformacMac"
            ReferencedContainer = "container:MAformac.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
```

Run:

```bash
xcodebuild -list -project MAformac.xcodeproj | rg "MAformacMac"
```

Expected: `MAformacMac` appears in scheme output. If it does not, stop and inspect the Xcode project before writing capture scripts.

- [ ] **Step 2.1: Create failing evidence validator**

Create `Tools/checks/check-macos-demo-evidence.py`:

```python
#!/usr/bin/env python3
import json
import sys
from pathlib import Path

REQUIRED = {
    "repo_head",
    "branch",
    "scheme",
    "platform",
    "proof_class",
    "build_result",
    "run_result",
    "window_check",
    "screenshot_result",
    "screenshot_path",
    "non_claims",
}

FORBIDDEN_CLAIMS = {
    "mobile",
    "true_device",
    "live_api",
    "V-PASS",
    "runtime-ready",
    "voice-ready",
    "model-ready",
    "golden-ready",
    "A-2 complete",
}

REQUIRED_NON_CLAIMS = {
    "no V-PASS",
    "no mobile",
    "no true_device",
    "no live_api",
    "no runtime-ready",
    "no voice-ready",
    "no model-ready",
    "no golden-ready",
    "no A-2 complete",
}

def iter_strings(value, path="$"):
    if isinstance(value, str):
        yield path, value
    elif isinstance(value, list):
        for index, item in enumerate(value):
            yield from iter_strings(item, f"{path}[{index}]")
    elif isinstance(value, dict):
        for key, item in value.items():
            yield from iter_strings(item, f"{path}.{key}")

def main() -> int:
    if len(sys.argv) != 2:
        print("usage: check-macos-demo-evidence.py <evidence.json>", file=sys.stderr)
        return 2
    path = Path(sys.argv[1])
    data = json.loads(path.read_text(encoding="utf-8"))
    missing = sorted(REQUIRED - data.keys())
    if missing:
        print(f"missing required fields: {missing}", file=sys.stderr)
        return 1
    proof_class = str(data["proof_class"])
    if proof_class != "local/mac_runtime_smoke":
        print(f"unexpected proof_class: {proof_class}", file=sys.stderr)
        return 1
    if data["build_result"] != "PASS":
        print(f"unexpected build_result: {data['build_result']}", file=sys.stderr)
        return 1
    if data["run_result"] != "LAUNCHED_WITH_VISIBLE_WINDOW":
        print(f"unexpected run_result: {data['run_result']}", file=sys.stderr)
        return 1
    if data["screenshot_result"] != "FILE_CREATED_NONEMPTY":
        print(f"unexpected screenshot_result: {data['screenshot_result']}", file=sys.stderr)
        return 1
    window_check = data["window_check"]
    if not isinstance(window_check, dict):
        print("window_check must be an object", file=sys.stderr)
        return 1
    try:
        window_count = int(window_check.get("window_count", 0))
    except (TypeError, ValueError):
        print(f"invalid window_count: {window_check.get('window_count')}", file=sys.stderr)
        return 1
    if window_count <= 0:
        print(f"window_count must be positive: {window_count}", file=sys.stderr)
        return 1
    if not isinstance(data["non_claims"], list):
        print("non_claims must be a list", file=sys.stderr)
        return 1
    if not all(isinstance(item, str) for item in data["non_claims"]):
        print("non_claims entries must be strings", file=sys.stderr)
        return 1
    non_claims = set(data["non_claims"])
    if len(non_claims) != len(data["non_claims"]):
        print("non_claims must not contain duplicates", file=sys.stderr)
        return 1
    missing_non_claims = sorted(REQUIRED_NON_CLAIMS - non_claims)
    if missing_non_claims:
        print(f"missing non_claims: {missing_non_claims}", file=sys.stderr)
        return 1
    extra_non_claims = sorted(non_claims - REQUIRED_NON_CLAIMS)
    if extra_non_claims:
        print(f"unexpected non_claims: {extra_non_claims}", file=sys.stderr)
        return 1
    if not Path(data["screenshot_path"]).exists():
        print(f"screenshot missing: {data['screenshot_path']}", file=sys.stderr)
        return 1
    if Path(data["screenshot_path"]).stat().st_size <= 0:
        print(f"screenshot empty: {data['screenshot_path']}", file=sys.stderr)
        return 1
    leaked = []
    for value_path, value in iter_strings(data):
        if value_path.startswith("$.non_claims["):
            continue
        leaked.extend(f"{value_path}:{token}" for token in FORBIDDEN_CLAIMS if token in value)
    if leaked:
        print(f"forbidden claim token outside non_claims: {sorted(leaked)}", file=sys.stderr)
        return 1
    print("macos demo evidence: PASS")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
```

- [ ] **Step 2.2: Run validator before evidence exists**

Run:

```bash
python3 Tools/checks/check-macos-demo-evidence.py docs/research/2026-07-07-macos-demo-convergence/evidence.json
```

Expected: FAIL because the evidence file does not exist or required fields are missing.

- [ ] **Step 2.3: Create capture script**

Create `Tools/checks/capture-macos-demo-evidence.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT="$ROOT/docs/research/2026-07-07-macos-demo-convergence"
mkdir -p "$OUT"

HEAD_SHA="$(git -C "$ROOT" rev-parse HEAD)"
BRANCH="$(git -C "$ROOT" branch --show-current)"
SCHEME="MAformacMac"
SCREENSHOT="$OUT/macos-demo-smoke.png"

xcodebuild -project "$ROOT/MAformac.xcodeproj" \
  -scheme "$SCHEME" \
  -destination 'platform=macOS' \
  -derivedDataPath "$ROOT/.build/dd-macos-demo" \
  build

APP_PATH="$(find "$ROOT/.build/dd-macos-demo/Build/Products" -path "*/MAformacMac.app" -type d | head -n 1)"
if [[ -z "$APP_PATH" ]]; then
  echo "MAformacMac.app not found" >&2
  exit 1
fi

open -n "$APP_PATH" --args -mockSnapshot cooling -mockTheme deepSpace
sleep 4
WINDOW_COUNT="$(osascript <<'OSA'
tell application "System Events"
  if not (exists process "MAformacMac") then
    return "PROCESS_MISSING"
  end if
  tell process "MAformacMac"
    set frontmost to true
    return (count of windows) as text
  end tell
end tell
OSA
)"
if [[ ! "$WINDOW_COUNT" =~ ^[1-9][0-9]*$ ]]; then
  echo "MAformacMac visible window check failed: $WINDOW_COUNT" >&2
  osascript -e 'tell application "MAformacMac" to quit' >/dev/null 2>&1 || true
  exit 1
fi
screencapture -x "$SCREENSHOT"
if [[ ! -s "$SCREENSHOT" ]]; then
  echo "screenshot not created or empty: $SCREENSHOT" >&2
  osascript -e 'tell application "MAformacMac" to quit' >/dev/null 2>&1 || true
  exit 1
fi
osascript -e 'tell application "MAformacMac" to quit' >/dev/null 2>&1 || true

cat > "$OUT/evidence.json" <<JSON
{
  "repo_head": "$HEAD_SHA",
  "branch": "$BRANCH",
  "scheme": "$SCHEME",
  "platform": "macOS",
  "proof_class": "local/mac_runtime_smoke",
  "build_result": "PASS",
  "run_result": "LAUNCHED_WITH_VISIBLE_WINDOW",
  "window_check": {
    "method": "System Events",
    "window_count": $WINDOW_COUNT
  },
  "screenshot_result": "FILE_CREATED_NONEMPTY",
  "launch_args": ["-mockSnapshot", "cooling", "-mockTheme", "deepSpace"],
  "screenshot_path": "$SCREENSHOT",
  "non_claims": [
    "no V-PASS",
    "no mobile",
    "no true_device",
    "no live_api",
    "no runtime-ready",
    "no voice-ready",
    "no model-ready",
    "no golden-ready",
    "no A-2 complete"
  ]
}
JSON

python3 "$ROOT/Tools/checks/check-macos-demo-evidence.py" "$OUT/evidence.json"
```

- [ ] **Step 2.4: Run capture script**

Run:

```bash
chmod +x Tools/checks/capture-macos-demo-evidence.sh Tools/checks/check-macos-demo-evidence.py
Tools/checks/capture-macos-demo-evidence.sh
```

Expected: `xcodebuild` succeeds, `System Events` observes at least one `MAformacMac` window, the screenshot file is non-empty, and validator prints `macos demo evidence: PASS`. If `System Events` or Accessibility permission blocks the window check, record `NEEDS_EVIDENCE` and do not rewrite this into a softer pass.

- [ ] **Step 2.5: Write evidence README**

Create `docs/research/2026-07-07-macos-demo-convergence/README.md`:

```markdown
# macOS Demo Convergence Evidence

status: `LOCAL_MAC_RUNTIME_SMOKE_PASS`
proof_class: `local/mac_runtime_smoke`

## What This Proves

- `MAformacMac` builds on local macOS.
- The app launches with deterministic mock presentation args.
- `System Events` observed at least one `MAformacMac` window before screenshot capture.
- A non-empty local macOS screenshot was captured.
- The evidence package is machine-checked for proof caps and non-claims.

## What This Does Not Prove

- no `V-PASS`
- no `mobile`
- no `true_device`
- no `live_api`
- no `runtime-ready`
- no `voice-ready`
- no `model-ready`
- no `golden-ready`
- no `A-2 complete`

## Re-run

```bash
Tools/checks/capture-macos-demo-evidence.sh
python3 Tools/checks/check-macos-demo-evidence.py docs/research/2026-07-07-macos-demo-convergence/evidence.json
```
```

- [ ] **Step 2.6: Validate Task 2**

Run:

```bash
python3 Tools/checks/check-macos-demo-evidence.py docs/research/2026-07-07-macos-demo-convergence/evidence.json
git diff --check
```

Expected: validator PASS; `git diff --check` emits no whitespace errors.

- [ ] **Step 2.7: Commit Task 2**

Run exact pathspec staging only:

```bash
git add Tools/checks/capture-macos-demo-evidence.sh \
  Tools/checks/check-macos-demo-evidence.py \
  docs/research/2026-07-07-macos-demo-convergence/README.md \
  docs/research/2026-07-07-macos-demo-convergence/evidence.json \
  docs/research/2026-07-07-macos-demo-convergence/macos-demo-smoke.png
git diff --cached --check
git commit -m "test(mac): add macOS demo smoke evidence"
```

Expected: commit succeeds. If `MAformacMac.xcscheme` had to be created, add it in the same commit only after reviewing the scheme diff.

### Task 3: OpenSpec Reconciliation Without Claim Upgrade

**Files:**
- Modify: `openspec/changes/ui-presentation/tasks.md`
- Modify: `openspec/changes/define-runtime-presentation-bridge/tasks.md`
- Read: `openspec/changes/define-demo-default-scope/tasks.md`
- Read: `openspec/changes/define-demo-golden-run-and-voice/tasks.md`

**Interfaces:**
- Consumes: Task 2 evidence package path and proof class.
- Produces: checklist comments that point to Mac local smoke while preserving open gates.

- [ ] **Step 3.1: Add ui-presentation note without closing 8.C2**

In `openspec/changes/ui-presentation/tasks.md`, add a dated note under `8.C2`:

```markdown
> 2026-07-07 macOS demo convergence note: `docs/research/2026-07-07-macos-demo-convergence/` provides `local/mac_runtime_smoke` evidence for `MAformacMac` build/launch/screenshot only. This does not close `8.C2`, does not replace L3 human 5-gate, and does not claim `V-PASS`, mobile, true_device, runtime-ready, voice-ready, model-ready, golden-ready, or `A-2 complete`.
```

- [ ] **Step 3.2: Add bridge Gate4 reconciliation note**

In `openspec/changes/define-runtime-presentation-bridge/tasks.md`, under Gate4 open items, add a dated note:

```markdown
> 2026-07-07 macOS demo convergence note: Mac package consumers may use only public presentation-safe payload/readback/proof-cap vocabulary already defined by this carrier. The Mac smoke package is local/operator evidence and must not consume private adapter fields, raw runtime store, raw model output, training receipt, durable ledger internals, or UIUE-invented shared fields.
```

- [ ] **Step 3.3: Validate OpenSpec**

Run:

```bash
openspec validate ui-presentation --strict
openspec validate define-runtime-presentation-bridge --strict
openspec validate --all --strict
git diff --check
```

Expected: all validations PASS. If validation fails because notes are in invalid locations, move notes into valid markdown sections without changing task checkboxes.

- [ ] **Step 3.4: Commit Task 3**

Run exact pathspec staging only:

```bash
git add openspec/changes/ui-presentation/tasks.md \
  openspec/changes/define-runtime-presentation-bridge/tasks.md
git diff --cached --check
git commit -m "docs(openspec): cap macOS demo convergence proof"
```

Expected: commit succeeds; `8.C2` remains unchecked.

### Task 4: Deliverable Demo Package Baseline

**Files:**
- Create: `docs/research/2026-07-07-macos-demo-convergence/launch-checklist.md`
- Create: `docs/research/2026-07-07-macos-demo-convergence/non-claim-ledger.md`
- Create: `docs/research/2026-07-07-macos-demo-convergence/operator-closeout-template.md`

**Interfaces:**
- Consumes: Task 2 evidence package and Task 3 OpenSpec notes.
- Produces: package-level operator handoff for future execution or review.

- [ ] **Step 4.1: Create launch checklist**

Create `launch-checklist.md`:

```markdown
# macOS Demo Launch Checklist

- [ ] Confirm repo path is `/Users/wanglei/workspace/MAformac`.
- [ ] Confirm branch and HEAD with `git status --short --branch` and `git rev-parse HEAD`.
- [ ] Confirm dirty tree ownership; do not mix unrelated `docs/CURRENT.md` edits with demo package work.
- [ ] Run `swift test --filter U14MacLayoutContractTests`.
- [ ] Run `Tools/checks/capture-macos-demo-evidence.sh`.
- [ ] Run `python3 Tools/checks/check-macos-demo-evidence.py docs/research/2026-07-07-macos-demo-convergence/evidence.json`.
- [ ] Record proof class as `local/mac_runtime_smoke`.
- [ ] Preserve non-claims exactly as listed in `non-claim-ledger.md`.
```

- [ ] **Step 4.2: Create non-claim ledger**

Create `non-claim-ledger.md`:

```markdown
# macOS Demo Non-Claim Ledger

The macOS demo package may claim only `local/mac_runtime_smoke` unless a later accepted plan adds stronger proof.

It must not claim:

- `V-PASS`
- `A-2 complete`
- `runtime-ready`
- `voice-ready`
- `model-ready`
- `golden-ready`
- `mobile`
- `true_device`
- `live_api`
- `C5 acceptance`
- `C6 acceptance`
- `UIUE merge-ready`
- `ASR/TTS/LLM/LoRA ready`
```

- [ ] **Step 4.3: Create closeout template**

Create `operator-closeout-template.md`:

```markdown
# macOS Demo Operator Closeout Template

## Conclusion

`LOCAL_MAC_RUNTIME_SMOKE_PASS` or `PARTIAL` or `BLOCKED`.

## Changed Files

List exact paths.

## Validation

```bash
swift test --filter U14MacLayoutContractTests
Tools/checks/capture-macos-demo-evidence.sh
python3 Tools/checks/check-macos-demo-evidence.py docs/research/2026-07-07-macos-demo-convergence/evidence.json
openspec validate ui-presentation --strict
openspec validate define-runtime-presentation-bridge --strict
git diff --check
```

## Proof Class

`local/mac_runtime_smoke`

## Non-Claims

Copy `non-claim-ledger.md` exactly.

## Residual Risks

- `8.C2` remains open until L3 human 5-gate.
- Mac smoke is not mobile or true-device proof.
- UIUE consumer merge remains separate.
```

- [ ] **Step 4.4: Validate package docs**

Run:

```bash
rg -n "V-PASS|runtime-ready|mobile|true_device|live_api|A-2 complete" docs/research/2026-07-07-macos-demo-convergence
git diff --check
```

Expected: all strong terms appear only in non-claim context.

- [ ] **Step 4.5: Commit Task 4**

Run:

```bash
git add docs/research/2026-07-07-macos-demo-convergence/launch-checklist.md \
  docs/research/2026-07-07-macos-demo-convergence/non-claim-ledger.md \
  docs/research/2026-07-07-macos-demo-convergence/operator-closeout-template.md
git diff --cached --check
git commit -m "docs(mac): add macOS demo package baseline"
```

Expected: commit succeeds.

### Task 5: Independent Read-Only Audit Gate

**Files:**
- Read: all files changed by Tasks 2-4.
- Create only if commander requests landing audit artifact: `docs/research/2026-07-07-macos-demo-convergence/read-only-audit.md`

**Interfaces:**
- Consumes: final diff and validation output.
- Produces: independent verdict: `PASS_WITH_NOTES`, `PARTIAL`, or `BLOCKED`.

- [ ] **Step 5.1: Dispatch read-only audit**

Prompt the subagent with:

```text
你是 MAformac macOS demo convergence baseline 的只读审计 worker。cwd=/Users/wanglei/workspace/MAformac。不要改任何文件，不跑会写入的命令。

审计范围：
- Tools/checks/capture-macos-demo-evidence.sh
- Tools/checks/check-macos-demo-evidence.py
- docs/research/2026-07-07-macos-demo-convergence/
- openspec/changes/ui-presentation/tasks.md
- openspec/changes/define-runtime-presentation-bridge/tasks.md

请回答：
1. 是否存在把 local/mac_runtime_smoke 冒充 V-PASS/runtime-ready/mobile/true_device/live_api 的 wording。
2. 是否误关闭或暗示关闭 8.C2。
3. 是否误把 voice/golden/LoRA/ASR/TTS 混入本轮。
4. evidence validator 是否 fail-closed，字段是否足够。
5. 是否需要新增 C 系列决策，还是 amend/reconcile 现有 OpenSpec 即可。

输出中文，包含 status、findings table、file:line evidence、proof class、residual risk、NEEDS_EVIDENCE。只读。
```

- [ ] **Step 5.2: Commander review**

Commander reads the audit and classifies:

```text
PASS_WITH_NOTES: wording/proof caps are acceptable; notes can be follow-up.
PARTIAL: package usable only internally; missing validation or ambiguous wording remains.
BLOCKED: fake-green wording or proof-class upgrade risk exists.
```

- [ ] **Step 5.3: Closeout**

If audit is `PASS_WITH_NOTES`, close as `LOCAL_MAC_RUNTIME_SMOKE_PASS`. If audit is `PARTIAL`, close as `PARTIAL` and list exact missing evidence. If audit is `BLOCKED`, do not ship the package and fix the cited wording/checker issue first.

## Self-Review

- Spec coverage: covers Mac target/shell, proof package, OpenSpec reconciliation, non-claim ledger, and independent audit. It intentionally excludes voice/golden/LoRA/C5/C6/mobile/true-device.
- Placeholder scan: no unresolved placeholder marker or unowned future implementation placeholder is required for execution; all created files have concrete content.
- Type/path consistency: proof class is consistently `local/mac_runtime_smoke`; evidence path is consistently `docs/research/2026-07-07-macos-demo-convergence/`; `8.C2` remains open throughout.

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-07-07-macos-demo-convergence-baseline.md`.

Two execution options:

1. Subagent-Driven (recommended) - dispatch a fresh subagent per task, review between tasks, fast iteration.
2. Inline Execution - execute tasks in this session using executing-plans, batch execution with checkpoints.

Default recommendation: do not execute yet; first run the requested read-only subagent audit on this baseline plan.
