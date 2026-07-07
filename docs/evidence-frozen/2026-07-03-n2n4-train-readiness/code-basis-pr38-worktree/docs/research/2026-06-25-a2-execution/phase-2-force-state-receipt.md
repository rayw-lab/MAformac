# Phase 2 Force-State Screenshot Receipt

status: PARTIAL
proof_class: runtime_simulator + local
captured_at: 2026-06-26 02:08 Asia/Shanghai

## Scope

This receipt covers the Phase 2 force-state screenshot gate only:

- `-forceVisualState <state>` full-screen DEBUG screen.
- `-forceTheme ivory|deepSpace` theme selection.
- 7 `DemoVisualState` cases x 2 themes = 14 simulator screenshots.

It does not prove the full Phase 2 continuous-stage visual gate. The main iPhone stage still requires user visual acceptance and the broader Phase 2 anchor audit.

## Evidence

Screenshots:

- `docs/research/2026-06-25-a2-execution/shots/phase2-force-states-v1/phase2-force-ivory-normal.png`
- `docs/research/2026-06-25-a2-execution/shots/phase2-force-states-v1/phase2-force-ivory-satisfied.png`
- `docs/research/2026-06-25-a2-execution/shots/phase2-force-states-v1/phase2-force-ivory-changing.png`
- `docs/research/2026-06-25-a2-execution/shots/phase2-force-states-v1/phase2-force-ivory-blocked_with_alternative.png`
- `docs/research/2026-06-25-a2-execution/shots/phase2-force-states-v1/phase2-force-ivory-blocked_hard.png`
- `docs/research/2026-06-25-a2-execution/shots/phase2-force-states-v1/phase2-force-ivory-unsafe.png`
- `docs/research/2026-06-25-a2-execution/shots/phase2-force-states-v1/phase2-force-ivory-unknown.png`
- `docs/research/2026-06-25-a2-execution/shots/phase2-force-states-v1/phase2-force-deepSpace-normal.png`
- `docs/research/2026-06-25-a2-execution/shots/phase2-force-states-v1/phase2-force-deepSpace-satisfied.png`
- `docs/research/2026-06-25-a2-execution/shots/phase2-force-states-v1/phase2-force-deepSpace-changing.png`
- `docs/research/2026-06-25-a2-execution/shots/phase2-force-states-v1/phase2-force-deepSpace-blocked_with_alternative.png`
- `docs/research/2026-06-25-a2-execution/shots/phase2-force-states-v1/phase2-force-deepSpace-blocked_hard.png`
- `docs/research/2026-06-25-a2-execution/shots/phase2-force-states-v1/phase2-force-deepSpace-unsafe.png`
- `docs/research/2026-06-25-a2-execution/shots/phase2-force-states-v1/phase2-force-deepSpace-unknown.png`

Contact sheets:

- `docs/research/2026-06-25-a2-execution/shots/phase2-force-states-v1/contact-ivory.png`
- `docs/research/2026-06-25-a2-execution/shots/phase2-force-states-v1/contact-deepSpace.png`

All 14 screenshots are `1320x2868` from `iPhone 17 Pro Max` simulator `9E9EC0D0-E4EF-4D29-AAE5-911EB3F02D6D`.

## Verification

Commands run:

```bash
bash Tools/checks/check-no-binary-visualstate.sh
bash Tools/checks/check-contentview-uses-display-catalog.sh
bash Tools/checks/check-platform-vs-version-guard.sh
xcodebuild -project MAformac.xcodeproj -scheme MAformacIOS -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -derivedDataPath .build/dd build
xcodebuild -project MAformac.xcodeproj -scheme MAformacMac -destination 'platform=macOS' -derivedDataPath .build/dd-mac build
swift test
```

Results:

- `check-no-binary-visualstate`: pass
- `check-contentview-uses-display-catalog`: pass
- `check-platform-vs-version-guard`: pass
- iOS build: `BUILD SUCCEEDED`
- macOS build: `BUILD SUCCEEDED`
- `swift test`: 237 tests, 3 skipped, 0 failures

## Limits

- Force-state screenshots validate the 7-state visual grammar, theme rendering, and 10-family card skeleton.
- They do not validate the current iPhone continuous stage against the anchor image.
- They do not validate Mac runtime screenshot privacy-safely; Mac proof here is build + source path only.
- Coverage index remains unchecked for Phase 2 until the full Phase 2 gate is complete.
