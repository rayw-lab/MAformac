---
status: pre_ui_preparation
artifact_kind: layout_spacing_checker_spec
date: 2026-06-27
repo: /Users/wanglei/workspace/MAformac-uiue
branch: uiue/phase4-default-scope-presentation
parent_authority: docs/grill-tournament/uiue-r0-r2-grill-decisions-2026-06-27.md
proof_class: local/docs-only
non_claims:
  - no 8.C2 closure
  - no V-PASS
  - no mobile
  - no true_device
  - no runtime-ready
  - no voice-ready
  - no A-2 complete
---

# UIUE R2b Layout Integrity / Visual Spacing Checker Spec

## Verdict

本文件定义 UI 改动前的 R2b 结构门准备口径。Layout Integrity / Visual Spacing 只能挡结构 bug：遮挡、留白/白边、zone budget、安全区、右侧按钮外置/对齐、胶囊居中、mic dock 遮挡、orb spacing / halo budget。它不能签审美，不能替代 L3，也不能关闭 `8.C2`。

本轮不新增 checker 脚本、不改 Swift / assets / UI tests。原因：OpenSpec 已有 gate/proof boundary；当前需要先冻结 checker 输入/输出 schema 和 proof split，避免 UI 改动时用截图主观描述替代结构 receipt。后续如实现脚本，建议先做 UIUE-scoped checker，不直接进入全局 `make verify-all`。

## Evidence Status Boundary

This document intentionally separates committed-baseline evidence from current worktree dirty candidates.

- `committed_baseline`: present at commit `e296ba5` and safe for this docs-only commit to cite as durable code evidence.
- `live_dirty_candidate`: observed in the current worktree while this file was authored, but not included in this docs-only pathspec. These lines are useful pre-UI input, not committed implementation proof.
- `future_checker`: desired receipt behavior; no script or test is added by this document.

Do not treat `live_dirty_candidate` entries as shipped behavior until the relevant Swift / asset / UI test changes are committed and validated in their own scope.

## Live Source Map

| concern | evidence_status | source_file_line | live fact |
|---|---|---|---|
| root layout stack | committed_baseline | `App/ContentView.swift:66` | top-level `GeometryReader` + `ZStack` drives background, stage body, and Mac controls. |
| baseline top capsule | committed_baseline | `App/ContentView.swift:189` | committed baseline has `topContextBand(size:)` with `ContextCapsuleView`, spacer, and `context-band` identifier. |
| mic safe area target | committed_baseline | `App/ContentView.swift:199` | bottom mic dock carries `mic-dock-safe-area` identifier and bottom offset. |
| baseline settings/refresh controls | committed_baseline | `App/ContentView.swift:727` | committed baseline has horizontal `SettingsRefreshControls`; it does not expose per-button `refresh-control` / `settings-control` identifiers. |
| baseline orb captions | committed_baseline | `App/ContentView.swift:1154` | committed baseline has four-state enum but idle/listen both render `我在听...`; this is a known R2b/VPA gap, not a pass. |
| phone top capsule + right controls | live_dirty_candidate | `App/ContentView.swift:192` | current no-touch dirty worktree places centered capsule and vertical settings/refresh controls; do not cite as committed proof. |
| dirty capsule accessibility target | live_dirty_candidate | `App/ContentView.swift:234` | current no-touch dirty worktree wraps `context-band` in a clipped capsule hit target. |
| dirty refresh/settings identifiers | live_dirty_candidate | `App/ContentView.swift:776` | current no-touch dirty worktree exposes `refresh-control` / `settings-control`. |
| dirty orb halo reduction and captions | live_dirty_candidate | `App/ContentView.swift:1095`, `App/ContentView.swift:1221` | current no-touch dirty worktree reduces halo and restores distinct idle/listen/think/speak captions. |
| capsule content/chrome split | live_dirty_candidate | `App/ContextCapsule.swift:38`, `App/ContextCapsule.swift:65`, `App/ContextCapsule.swift:76` | current no-touch dirty worktree separates content, chrome, and base image/video layers. |
| capsule asset overscan | live_dirty_candidate | `App/ContextCapsule.swift:121` | current no-touch dirty worktree scales image `x: 1.03, y: 1.08`; white-edge leakage still needs screenshot/crop proof. |
| layout UI test candidate | live_dirty_candidate | `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift:195` | current no-touch dirty worktree adds layout assertions for controls/capsule/cards; not committed with this docs artifact. |
| committed visual/UI coverage | committed_baseline | `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift:195`, `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift:217`, `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift:239`, `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift:263` | committed baseline covers ambient color, ambient brightness, percent ring tap, and percent ring drag; no reusable layout receipt. |
| formal gate boundary | committed_baseline | `openspec/changes/ui-presentation/specs/ui-presentation/spec.md:309` | structural gates must report structural evidence and not replace L3. |

## Checker Input Contract

The future checker should consume only observable structural evidence:

| input | required fields | source |
|---|---|---|
| `source_ui_tree` | path, captured_at, simulator/device name, theme, case_id, raw frames for identifiers | XCUITest `debugDescription` or exported UI tree. |
| `source_screenshot_metadata` | path, captured_at, pixel_size, scale, viewport, launch args, crop coordinate basis | on-screen simulator screenshot metadata. |
| `identifier_frames` | `context-band`, `refresh-control`, `settings-control`, `demo-orb`, `vehicle-card-family.*`, `dialogue-bubble-user`, `mic-dock-safe-area` | UI tree frames. |
| `safe_area` | viewport bounds, top/bottom safe inset if available, dock/capsule exclusion zones | simulator metadata or app-emitted geometry receipt if later added. |
| `crop_paths` | top capsule crop, right-controls crop, orb crop, vehicle-grid crop, mic dock crop | deterministic crop artifacts for audit, not aesthetic pass. |

The checker must not consume GPT Image 2 / anchor images as geometry truth. Anchors are allowed only as direction, composition intent, and aesthetic bar for human review.

## Output Schema

```json
{
  "status": "PASS|WARN|FAIL",
  "proof_class": "local|simulator",
  "source_ui_tree": {
    "path": "docs/research/.../case-ui-tree.txt",
    "captured_at": "2026-06-27T00:00:00+08:00",
    "case_id": "main_cooling_ivory",
    "simulator": "iPhone 17 Pro Max"
  },
  "source_screenshot_metadata": {
    "path": "docs/research/.../case.png",
    "pixel_size": {"width": 1290, "height": 2796},
    "scale": 3,
    "viewport_points": {"width": 430, "height": 932}
  },
  "overlap_pairs": [
    {
      "a": "refresh-control",
      "b": "context-band",
      "intersection_area": 0,
      "status": "PASS"
    }
  ],
  "min_gaps": [
    {
      "a": "settings-control",
      "b": "context-band",
      "axis": "x",
      "gap_points": 8,
      "threshold_points": 8,
      "status": "PASS"
    }
  ],
  "zone_budget": {
    "top_band_height_points": 108,
    "orb_height_points": 172,
    "vehicle_grid_available_points": 0,
    "mic_dock_exclusion_points": 96,
    "status": "WARN"
  },
  "safe_area_violations": [],
  "crop_paths": {
    "top_band": "docs/research/.../crops/top-band.png",
    "orb": "docs/research/.../crops/orb.png",
    "mic_dock": "docs/research/.../crops/mic-dock.png"
  },
  "warnings": [
    "white-edge leakage requires pixel crop threshold before PASS"
  ],
  "non_claims": [
    "no L3 aesthetic pass",
    "no V-PASS",
    "no 8.C2 closure",
    "no mobile",
    "no true_device"
  ]
}
```

## Structural Gates

| gate_id | checks | pass condition | fail condition | current source | current gap |
|---|---|---|---|---|---|
| R2B-OVERLAP | `overlap_pairs` among `context-band`, `refresh-control`, `settings-control`, `demo-orb`, vehicle cards, `mic-dock-safe-area` | no positive intersection for forbidden pairs | controls cover capsule, mic covers card, orb covers cards/dialogue incoherently | candidate UI test frame checks in dirty worktree at `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift:195` | no committed reusable receipt; only candidate test assertions. |
| R2B-BLANK-WHITE-EDGE | capsule crop edge pixel scan for white/blank leakage | no visible asset white shell or blank edge after clip/overscan | capsule asset leaks white border, baked shell, or transparent gap | dirty worktree content/chrome split at `App/ContextCapsule.swift:76` and overscan at `App/ContextCapsule.swift:121` | no pixel checker; current asset may change. |
| R2B-ZONE-BUDGET | top band, orb, dialogue, cards, mic dock vertical budget | min visible card area and no incoherent compression | top band/orb/mic consume middle space, card rows disappear or overlap | committed baseline has layout helpers; dirty worktree changes sizing, e.g. `App/ContentView.swift:711`, `App/ContentView.swift:718`, `App/ContentView.swift:726`, `App/ContentView.swift:746` | no formal budget thresholds yet. |
| R2B-SAFE-AREA | safe-area and viewport bounds | all interactive controls stay inside viewport and outside unsafe inset | right controls clipped, mic dock too low/high, capsule under sensor area | committed baseline root/mic at `App/ContentView.swift:66`, `App/ContentView.swift:199`; dirty worktree button identifiers at `App/ContentView.swift:776` | safe-area insets not emitted in receipt. |
| R2B-RIGHT-CONTROLS | settings/refresh outside capsule, right edges aligned, order stable | controls are independent column; refresh aligns to settings, may sit below settings on phone | refresh drifts over capsule or away from settings | dirty candidate UI test asserts at `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift:215`-`MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift:240` | no committed screenshot crop attached to assertion. |
| R2B-CAPSULE-CENTER | capsule top band center within threshold | `context-band.midX` near viewport midX when phone layout | capsule forced left by buttons or blank side dominates | dirty candidate UI test asserts at `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift:241` | threshold may need device matrix. |
| R2B-MIC-DOCK | `mic-dock-safe-area` does not cover final visible card row | bottom dock exclusion respected | dock occludes cards or creates dead tap zone | identifier exists in committed baseline at `App/ContentView.swift:199`; visual cases wait for it | no overlap pair receipt with cards. |
| R2B-ORB-SPACING | `demo-orb` frame and halo budget stay within allocated zone | four states remain distinct and contained; halo does not swallow card/dialogue zone | halo too large, state copy overlaps, only one visible state | dirty worktree has distinct captions at `App/ContentView.swift:1221`; committed baseline has duplicate idle/listen caption at `App/ContentView.swift:1154` | no halo pixel radius or particle spill receipt. |

## Capsule / VPA Proof Split

| proof_stream | proves | source | cannot prove |
|---|---|---|---|
| context/data proof | capsule state responds to `DemoContext` vehicle speed, gear, weather, time period; orb state responds to `PresentationOrbState` | `Core/Presentation/PresentationSnapshot.swift:21`, `Core/Presentation/PresentationSnapshot.swift:35`; `App/ContextCapsule.swift:18`; committed caption mapping at `App/ContentView.swift:1154`, with distinct idle/listen copy still a dirty candidate | visual polish, L3 aesthetics, real runtime readiness. |
| layout proof | frames, gaps, safe-area, overlap, crop edges, zone budget | UI tree + screenshot metadata + checker receipt | premium look, emotional feel, anchor match. |
| diorama aesthetic / L3 proof | whether capsule/VPA feels like intended cockpit diorama and assistant presence | human L3 punchlist and anchor comparison | machine structural PASS, runtime/voice readiness, V-PASS by itself. |

## GPT Image 2 / Anchor Governance

- GPT Image 2 / anchor images are direction, composition intent, and aesthetic bar only.
- Generated images must not reverse-define engineering structure. The SwiftUI implementation owns chrome, mask, glass, hit testing, layout bounds, and accessibility identifiers.
- Content asset and code chrome must stay separate: final or placeholder image should be content-only, with no pre-baked white shell, control icons, fake shadow, or glass edge that competes with SwiftUI `Capsule()` / `.glassEffect`.
- White-edge bugs should be handled by normal production methods: crop unsafe borders in the asset, provide overscan margin, clip/mask in code, and verify edge pixels on the rendered screenshot. Do not blindly stretch an anchor without checking focal distortion and edge leakage.
- If the asset will be replaced later, current work should use target pixel size / aspect ratio placeholder plus checker receipt, not pretend final art is signed.

## Minimal Future Checker Scope

If a checker is added before UI implementation, keep it scoped:

- candidate path: `Tools/checks/check-uiue-layout-spacing.py`
- inputs: UI tree text + screenshot metadata + optional crop directory
- outputs: one JSON receipt matching the schema above
- owner: UIUE test owner
- proof class: `local` for parser-only; `simulator` only when fed fresh simulator screenshot/UI tree
- non-goal: no aesthetic score, no L3 verdict, no global `make verify-all` integration without separate grill decision

## Pre-UI Checklist

- Top band changes must produce overlap/gap checks for `context-band`, `settings-control`, `refresh-control`, and `dialogue-bubble-user`.
- Capsule image changes must produce edge crop evidence for blank/white-edge leakage.
- Orb changes must prove four captions/states remain distinct and contained, with halo/particle budget recorded.
- Vehicle card layout changes must prove first-row alignment and column gap, then mic dock non-occlusion.
- Structural PASS is not enough for `8.C2`; L0-L3 evidence and L3 human 5-gate remain required.
