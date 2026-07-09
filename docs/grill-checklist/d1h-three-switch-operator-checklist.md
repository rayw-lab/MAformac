# D1H Three-Switch Operator Checklist

Scope: manual demo-preflight check for OS-level accessibility switches. This is an operator runbook for Reduce Transparency, Increase Contrast, and Reduce Motion. It must not mutate OS settings from automation.

Proof class: `operator_manual_checklist` only. This is not CI, not headless snapshot proof, not macOS XCUITest proof, not mobile / true-device / live API proof, and not product V-PASS.

## What This Closes

- Manual confirmation that the demo surface stays readable when the three OS accessibility switches are toggled by a human.
- Roadmap v5 Liquid Glass smoke coverage for the three navigation-layer glass surfaces:
  - MicDock
  - ContextCapsule / top context band
  - DemoControlPanel
- Manual confirmation that vehicle cards remain solid/readable and critical state is carried by text, number, icon, or card state, not only by glass, motion, glow, or blur.

## What This Does Not Close

- It does not replace D1H process-injected headless SSIM / contrast gates.
- It does not close the full Liquid Glass gate by itself; it is the manual three-switch supplement.
- It does not prove VoiceOver, `performAccessibilityAudit`, or full operator-pass.

## Before You Start

1. Confirm the developer-side deterministic receipt exists and is green. The operator does not need to run these commands:
   - `Tools/checks/d1h-three-switch-walkthrough.sh`
   - `swift test --filter U17HeadlessSnapshotSSIMTests`
   - `swift test --filter D1HLiquidGlassSwitchContrastTests`
2. Use an idle demo window. Do not run this during training, calls, screen sharing, or unrelated user work.
3. Record:
   - operator name
   - timestamp
   - app build or commit
   - macOS version and build
   - display mode: built-in only / external display / projection
   - whether the demo is using Clear or Regular appearance. If external display or projection contrast is poor, use Regular and do not use Clear.
4. Open the demo to the idle main surface before changing any OS setting.
5. Take or record a baseline screenshot with all three settings at their original values.

## Find The OS Switches

Use System Settings search first. If the named switch is not found, record `BLOCKED_SETTING_NOT_FOUND` with the macOS version and do not guess.

- Reduce Transparency: System Settings -> Accessibility -> Display, or search `Reduce Transparency`.
- Increase Contrast: System Settings -> Accessibility -> Display, or search `Increase Contrast`.
- Reduce Motion: System Settings -> Accessibility -> Display or Accessibility -> Motion, or search `Reduce Motion`.

Before toggling anything, record the original value of each switch:

| Switch | Original value |
| --- | --- |
| Reduce Transparency | on / off |
| Increase Contrast | on / off |
| Reduce Motion | on / off |

## Test Cases

For each case below:

1. Set only the switches listed in the case. Return unlisted switches to their original values.
2. Quit and relaunch the app, or use the demo refresh/reset control if the run owner confirms it refreshes the full surface.
3. Trigger the mock voice path once from the MicDock.
4. Use the scripted utterance/preset that produces the visible readback: `打开空调把温度调到24度`.
5. Verify the expected visible result:
   - AC card shows `空调 24℃` or equivalent active AC temperature state.
   - readback text is visible on screen, not only spoken by TTS.
   - AC state is communicated through at least two channels among text, number, icon, and card state.
   - MicDock remains discoverable.
   - ContextCapsule / top context band remains readable.
   - DemoControlPanel remains readable if opened.
   - vehicle cards remain solid/readable; content cards must not depend on Liquid Glass translucency.

| Case ID | Switches to enable | Required checks |
| --- | --- | --- |
| baseline | original values | baseline readability and screenshot/record |
| rt | Reduce Transparency | glass fallback does not hide MicDock / ContextCapsule / DemoControlPanel; cards remain readable |
| ic | Increase Contrast | text, numbers, icons, and card boundaries remain readable |
| rm | Reduce Motion | state is still clear without animation or energy-line motion |
| rt_rm | Reduce Transparency + Reduce Motion | combined fallback remains readable without glass or motion as the only signal |

Manual scope note: D1H process-injected automated gates cover the broader switch matrix. This manual checklist must single-test the three switches and the `rt_rm` risk pair; it does not claim complete manual 8-combination coverage unless a separate all-combinations receipt is produced.

## Hard Fail Conditions

Mark the case `FAIL` if any item below occurs:

- Any critical text or number cannot be read.
- AC active state is not visible after the mock voice trigger.
- AC state is communicated through only one channel, or only through motion, glow, blur, or translucency.
- Reduce Motion removes the only visible state-change cue.
- Reduce Transparency or Increase Contrast makes MicDock, ContextCapsule, DemoControlPanel, or vehicle cards unreadable.
- Content vehicle cards become glass-dependent instead of solid/readable.
- The demo uses Clear appearance on a low-contrast external display or projection when Regular is available.
- The original OS settings cannot be restored.

## Receipt Table

Fill one row per case:

| case_id | switches_enabled | screenshot_or_record_path | MicDock | ContextCapsule | DemoControlPanel | vehicle_cards | AC_readback | dual_channel | pass_fail | notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| baseline |  |  | pass/fail | pass/fail | pass/fail/not opened | pass/fail | pass/fail | pass/fail |  |  |
| rt | Reduce Transparency |  | pass/fail | pass/fail | pass/fail/not opened | pass/fail | pass/fail | pass/fail |  |  |
| ic | Increase Contrast |  | pass/fail | pass/fail | pass/fail/not opened | pass/fail | pass/fail | pass/fail |  |  |
| rm | Reduce Motion |  | pass/fail | pass/fail | pass/fail/not opened | pass/fail | pass/fail | pass/fail |  |  |
| rt_rm | Reduce Transparency + Reduce Motion |  | pass/fail | pass/fail | pass/fail/not opened | pass/fail | pass/fail | pass/fail |  |  |

## Restore Gate

1. Restore Reduce Transparency, Increase Contrast, and Reduce Motion to the original values recorded above.
2. Reopen System Settings and verify the restored values.
3. Record `restored=true` only after the values match the original values.
4. If any setting cannot be restored, mark `BLOCKED_RESTORE_FAILED` and notify the run owner immediately.

## Final Receipt Fields

Record these fields in the run receipt:

- operator
- timestamp
- app build or commit
- macOS version/build
- display mode
- original switch values
- per-case receipt table
- restored: true / false
- anomalies
- non-claims: no CI proof, no headless proof, no XCUITest proof, no mobile / true-device / live API proof, no V-PASS
