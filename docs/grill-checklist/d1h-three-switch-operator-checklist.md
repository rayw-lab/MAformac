# D1H Three-Switch Operator Checklist

Scope: manual demo-preflight check only. This checklist records the OS-level Reduce Transparency / Increase Contrast / Reduce Motion walkthrough intent without letting automated tests mutate global machine state.

Proof class: operator manual step. Not CI, not headless snapshot proof, not true-device acceptance.

## Preconditions

- Use an idle demo window. Do not run during training, calls, screen sharing, or user work.
- Keep a note of the original OS accessibility settings before toggling anything.
- Run automated deterministic coverage first:
  - `Tools/checks/d1h-three-switch-walkthrough.sh`
  - `swift test --filter U17HeadlessSnapshotSSIMTests`
  - `swift test --filter D1HLiquidGlassSwitchContrastTests`

## Manual OS Walkthrough

For each OS setting below, enable only the named switch, relaunch or refresh the demo surface, and verify that core state remains readable by text, number, icon, and card state without relying on glass or animation alone.

- Reduce Transparency
- Increase Contrast
- Reduce Motion
- Reduce Transparency + Reduce Motion

## Pass Criteria

- Vehicle cards remain legible.
- The mic dock and context band remain discoverable.
- Active AC state and readback remain visible after the mock voice trigger.
- No essential state is communicated only through motion, translucency, glow, or blur.

## Restore

- Restore the original OS accessibility settings immediately after the manual walkthrough.
- Record the operator, timestamp, OS version, app build/commit, and any visual anomaly in the run receipt.

## Non-Claims

- This checklist does not claim automated OS-level switch mutation.
- This checklist does not replace the D1H process-injected headless render and contrast gates.
- This checklist does not claim mobile, true-device, live API, or product V-PASS.
