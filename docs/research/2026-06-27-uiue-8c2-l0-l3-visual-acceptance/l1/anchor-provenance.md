# 8.C2 L1 Anchor Provenance

proof_class：local L1 sentinel；仅挡明显塌陷，不签审美，不替代 L3。

| case | anchor copied into package | source | provenance note |
| --- | --- | --- | --- |
| `main_cooling_deep_space` | `l1/anchors/main_cooling_deep_space-anchor.png` | `docs/research/2026-06-25-a2-execution/shots/phase2-main-stage-v1/phase2-main-deepSpace-cooling.png` | 独立旧 Phase 2 main-stage deepSpace cooling anchor。 |
| `main_heating_ivory` | `l1/anchors/main_heating_ivory-anchor.png` | `docs/research/2026-06-25-a2-execution/shots/phase2-main-stage-v1/phase2-main-ivory-heating.png` | 独立旧 Phase 2 main-stage ivory heating anchor。 |
| `safety_refusal_ivory` | `l1/anchors/safety_refusal_ivory-anchor.png` | `docs/research/2026-06-25-a2-execution/shots/phase2-main-stage-v1/phase2-main-ivory-safetyRefusal.png` | 独立旧 Phase 2 main-stage ivory safety refusal anchor。 |
| `capsule_video_loop_deep_space` | `l1/anchors/capsule_video_loop_deep_space-anchor.png` | `docs/research/2026-06-25-a2-execution/shots/phase2-main-stage-v1/phase2-main-deepSpace-cooling.png` | fallback：未找到独立 deepSpace + `videoLoop` route-specific anchor；此 anchor 只证明同 theme/preset 主舞台未塌陷，不能证明 videoLoop 细节。videoLoop 细节由 L0 launchArg + screenshot 进入 L3 人审。 |
| `u17_golden_path_deep_space` | `l1/anchors/u17_golden_path_deep_space-anchor.png` | `docs/research/2026-06-27-uiue-8g9b-u17-l0/u17-golden-path-simctl.png` | 独立 U17 committed L0 smoke 截图，验证黄金路径主舞台未塌陷。 |
