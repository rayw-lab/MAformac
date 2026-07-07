# Phase 2 Main Stage Receipt

Date: 2026-06-26
Status: PARTIAL, not V-PASS
Proof class: local + mock + runtime/simulator

## Scope

This receipt covers the current Phase 2 continuous-stage iPhone pass through the retained v59 AC hero typography pass, plus rejected v60-v65 diagnostics. It does not claim full Phase 2 completion, true-device acceptance, mobile V-PASS, OpenSpec 8.A completion, or coverage-index burn-down.

## Current Implementation Evidence

- `App/ContentView.swift` consumes `PresentationSnapshot` through `VehicleCardDisplay.familyDisplays(from:activeCells:reasons:)`.
- iPhone stage remains split into context capsule, orb, dialogue stream, vehicle controls, and bottom `safeAreaInset` mic dock.
- macOS branch remains an `AnyLayout(HStackLayout)` split: left orb/dialogue, right control panorama. It does not use `SplitView`.
- AC hero card uses `SemanticColorMapper.acThermalTint(siblingCells:)` through display sibling cells, so cooling/heating color is mode-driven instead of hard-coded blue.
- Range bar progress maps the contract range `18...32` via `(value - 18) / 14`.
- v39 fixes the cold-start force state path so it uses the populated Phase 2 idle baseline instead of the empty Core provider snapshot.
- v40/v41 fixes the featured-card hard-code: iPhone hero now follows `activeFamily` with `.ac` as fallback. This keeps cooling on the AC hero while letting safety refusal promote the refused family.
- v41 consumes `PresentationSnapshot.refusedCell` + `resultKind` as card reason text, so safety refusal presents the active refused family with a visible safety reason instead of leaving the refusal buried in a compact card.
- v42 tightens the iPhone featured controls zone: the featured-grid side inset moves from `8pt` to `16pt`, and the AC hero number uses default SF heavy instead of the wider rounded figure style. This is a measured alignment fix, not a contract change.
- v44 adds a phone-only `6pt` top offset to the vehicle controls grid. This moves the AC-card title band from normalized screenshot y=`1488` in v42 to y=`1506`, close to the anchor y=`1508`, while leaving the macOS split layout untouched.
- v45 softens the ivory vehicle-card material and shadow, and adjusts the phone featured layout from `gap=20 / left=0.51` to `gap=18 / left=0.515`. This keeps the 10-family display contract intact while nudging the controls zone toward the anchor's lighter glass weight.
- Rejected v46-v49 experiments are preserved as evidence, not retained in code: v46 moved the phone capsule up visually and regressed cooling context badly; v47 reduced the AC hero typography and regressed cooling controls; v48 widened compact-card icon/text spacing and regressed cooling controls; v49 raised the mic dock and regressed controls. Current code stays at the v45 visual patch.
- v55 keeps the v45 material/ratio settings and only adjusts the iPhone featured column gap from `18pt` to `22pt`. This is retained because it slightly improves the primary cooling controls zone and materially improves the safety-refusal controls zone; v50-v54 are rejected/diagnostic trials.
- v56 fixes the AC hero Celsius split bug: `VehicleCardDisplay.valueText` emits the single-character `℃`, while `acTemperatureParts` previously only split the two-character `°C`. Current code now splits both forms, rendering the number and unit at separate visual weights instead of making `26℃` one 58pt text run.
- v59 raises only the AC hero main number from `58pt` to `62pt`. This is retained because it improves the primary cooling controls-zone metric after the v56 unit split while leaving the Celsius unit and range mapping contract unchanged.
- v60-v65 are rejected diagnostics, not retained. Current code keeps the v59 visual state: `unit spacing=6pt`, phone controls top padding `6pt`, featured left ratio `0.515`, hero border opacity `0.26`, rim line `1.05`, range thumb `13pt` with `6.5pt` offset, and AC mode label `12pt`.
- `Tools/checks/phase2_zone_compare.py` now contains the repeatable four-zone RMSE gate used by this receipt, including optional `--mask-rect` and `--mask-preset phase2-capsule-diorama` support for dynamic capsule regions.

## Runtime Screenshots

Runtime target: iPhone 17 Pro Max simulator (`9E9EC0D0-E4EF-4D29-AAE5-911EB3F02D6D`)

Full v39 snapshot set:

```text
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v39-ivory-coldStart.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v39-ivory-cooling.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v39-ivory-heating.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v39-ivory-safetyRefusal.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v39-deepSpace-coldStart.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v39-deepSpace-cooling.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v39-deepSpace-heating.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v39-deepSpace-safetyRefusal.png
```

Focused v40/v41 regression checks:

```text
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v40-ivory-cooling.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v40-ivory-safetyRefusal.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v41-ivory-safetyRefusal.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v42-ivory-cooling.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v42-ivory-safetyRefusal.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v44-ivory-cooling.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v44-ivory-safetyRefusal.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v45-ivory-cooling.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v45-ivory-safetyRefusal.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v46-ivory-cooling.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v46-ivory-safetyRefusal.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v47-ivory-cooling.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v47-ivory-safetyRefusal.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v48-ivory-cooling.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v48-ivory-safetyRefusal.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v49-ivory-cooling.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v49-ivory-safetyRefusal.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v50-glass-cooling.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v50-glass-safetyRefusal.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v51-glass-cooling.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v51-glass-safetyRefusal.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v52-inset24-cooling.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v52-inset24-safetyRefusal.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v53-inset12-cooling.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v53-inset12-safetyRefusal.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v54-gap14-cooling.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v55-gap22-cooling.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v55-gap22-safetyRefusal.png
```

Readout:

- `v40-ivory-cooling` confirms the fallback path still keeps AC as the featured hero for cooling.
- `v41-ivory-safetyRefusal` confirms the active refused family becomes the hero and shows the safety reason.
- `v42-ivory-cooling` confirms the AC hero is still used for cooling after the featured-grid side inset and number-font adjustment.
- `v42-ivory-safetyRefusal` was captured with the correct main-stage launch flag `-mockSnapshot safetyRefusal`; the older `-forceSnapshot` flag does not drive `ContentView`.
- `v44-ivory-cooling` confirms the controls zone moved down without changing the featured AC contract mapping.
- `v44-ivory-safetyRefusal` confirms the safety-refusal hero remains promoted after the controls-zone vertical adjustment.
- `v45-ivory-cooling` confirms the softer card material and column-ratio patch keeps the cooling hero and improves the focused cooling RMSE in all four zones.
- `v45-ivory-safetyRefusal` confirms the same patch keeps safety refusal promoted; the safety controls-zone RMSE slightly regresses, so this is recorded as a tradeoff, not a completed gate.
- `v46-*` through `v49-*` are rejected trial screenshots. They are retained only so future passes do not repeat those moves.
- `v50-*` and `v51-*` are rejected Liquid Glass trials: native card `.glassEffect` compiled and rendered, but it regressed the primary cooling controls zone.
- `v52-*` and `v53-*` are rejected side-inset trials: changing the outer inset helped safety controls but hurt the primary cooling controls zone.
- `v54-gap14-cooling` is a rejected gap trial. `v55-gap22-*` is retained as the current narrow geometry improvement.
- These are simulator screenshots only; they are not true-device or human visual V-PASS.

## Anchor Zone Compare

Zone definition on normalized iPhone screenshots:

```text
context: 0...530
orb:     530...1080
dialogue:1080...1450
controls:1450...2868
```

Full v39 output directory:

```text
docs/research/2026-06-25-a2-execution/zone-compare-v39/
```

Full v39 RMSE table:

```tsv
case	anchor	context	orb	dialogue	controls
ivory-coldStart	anchor-01-idle-baseline.png	0.24292	0.0923768	0.239938	0.158816
ivory-cooling	anchor-00-diorama-5-fullscreen-insitu.png	0.211692	0.090687	0.212843	0.181868
ivory-heating	anchor-02-heat-red-hero.png	0.269298	0.115028	0.224876	0.172627
ivory-safetyRefusal	anchor-05-r2-refuse.png	0.261659	0.132868	0.214736	0.154878
deepSpace-coldStart	anchor-07-night-deepspace.png	0.365179	0.177957	0.269828	0.177172
deepSpace-cooling	anchor-07-night-deepspace.png	0.365751	0.21088	0.25264	0.18828
deepSpace-heating	anchor-02-heat-red-hero.png	0.632472	0.770221	0.760788	0.769109
deepSpace-safetyRefusal	anchor-05-r2-refuse.png	0.65095	0.77006	0.766418	0.794772
```

Focused v41 output directory:

```text
docs/research/2026-06-25-a2-execution/zone-compare-v41/
```

Focused v41 RMSE table:

```tsv
case	anchor	context	orb	dialogue	controls
ivory-cooling	anchor-00-diorama-5-fullscreen-insitu.png	0.220333	0.092477	0.114303	0.222439
ivory-safetyRefusal	anchor-05-r2-refuse.png	0.232897	0.146476	0.168148	0.168647
```

Focused v42 output directory:

```text
docs/research/2026-06-25-a2-execution/zone-compare-v42/
```

Focused v42 RMSE table:

```tsv
case	anchor	context	orb	dialogue	controls
ivory-cooling	anchor-00-diorama-5-fullscreen-insitu.png	0.217540	0.088217	0.106522	0.206127
ivory-safetyRefusal	anchor-05-r2-refuse.png	0.231435	0.144416	0.167536	0.167437
```

Focused v44 output directory:

```text
docs/research/2026-06-25-a2-execution/zone-compare-v44/
```

Focused v44 RMSE table:

```tsv
case	anchor	context	orb	dialogue	controls
ivory-cooling	anchor-00-diorama-5-fullscreen-insitu.png	0.217209	0.088409	0.106485	0.194572
ivory-safetyRefusal	anchor-05-r2-refuse.png	0.231581	0.142969	0.167486	0.166804
```

Focused v45 output directory:

```text
docs/research/2026-06-25-a2-execution/zone-compare-v45/
docs/research/2026-06-25-a2-execution/zone-compare-v45-scripted/
```

Focused v45 RMSE table:

```tsv
case	anchor	context	orb	dialogue	controls
ivory-cooling	anchor-00-diorama-5-fullscreen-insitu.png	0.216134	0.087823	0.105839	0.193612
ivory-safetyRefusal	anchor-05-r2-refuse.png	0.230656	0.145432	0.164178	0.168293
```

The scripted rerun uses:

```bash
Tools/checks/phase2_zone_compare.py --case ivory-cooling --anchor docs/design/anchors/anchor-00-diorama-5-fullscreen-insitu.png --current docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v45-ivory-cooling.png --output docs/research/2026-06-25-a2-execution/zone-compare-v45-scripted/cooling.tsv
Tools/checks/phase2_zone_compare.py --case ivory-safetyRefusal --anchor docs/design/anchors/anchor-05-r2-refuse.png --current docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v45-ivory-safetyRefusal.png --output docs/research/2026-06-25-a2-execution/zone-compare-v45-scripted/safety.tsv
Tools/checks/phase2_zone_compare.py --case ivory-cooling-masked --anchor docs/design/anchors/anchor-00-diorama-5-fullscreen-insitu.png --current docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v45-ivory-cooling.png --mask-preset phase2-capsule-diorama --output docs/research/2026-06-25-a2-execution/zone-compare-v45-scripted/cooling-masked.tsv
Tools/checks/phase2_zone_compare.py --case ivory-safetyRefusal-masked --anchor docs/design/anchors/anchor-05-r2-refuse.png --current docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v45-ivory-safetyRefusal.png --mask-preset phase2-capsule-diorama --output docs/research/2026-06-25-a2-execution/zone-compare-v45-scripted/safety-masked.tsv
```

Scripted v45 masked RMSE table (`phase2-capsule-diorama` masks only the animated capsule interior; raw metrics remain the acceptance baseline):

```tsv
case	anchor	context	orb	dialogue	controls
ivory-cooling-masked	anchor-00-diorama-5-fullscreen-insitu.png	0.174189	0.086917	0.105839	0.193612
ivory-safetyRefusal-masked	anchor-05-r2-refuse.png	0.138033	0.143578	0.164178	0.168293
```

Rejected v46-v49 RMSE tables:

```tsv
case	anchor	context	orb	dialogue	controls
v46-ivory-cooling	anchor-00-diorama-5-fullscreen-insitu.png	0.255447	0.087948	0.105848	0.204642
v46-ivory-safetyRefusal	anchor-05-r2-refuse.png	0.231018	0.146184	0.164186	0.168278
v47-ivory-cooling	anchor-00-diorama-5-fullscreen-insitu.png	0.216885	0.087838	0.105842	0.196363
v47-ivory-safetyRefusal	anchor-05-r2-refuse.png	0.230706	0.146294	0.164183	0.168295
v48-ivory-cooling	anchor-00-diorama-5-fullscreen-insitu.png	0.245384	0.087781	0.105845	0.203699
v48-ivory-safetyRefusal	anchor-05-r2-refuse.png	0.230580	0.144542	0.164178	0.167325
v49-ivory-cooling	anchor-00-diorama-5-fullscreen-insitu.png	0.244898	0.088161	0.105848	0.203779
v49-ivory-safetyRefusal	anchor-05-r2-refuse.png	0.230652	0.144986	0.164186	0.168458
```

v50-v55 RMSE tables:

```tsv
case	anchor	context	orb	dialogue	controls
v50-glass-ivory-cooling	anchor-00-diorama-5-fullscreen-insitu.png	0.213640	0.088152	0.105998	0.197920
v50-glass-ivory-safetyRefusal	anchor-05-r2-refuse.png	0.229534	0.145298	0.164291	0.167267
v51-glass-ivory-cooling	anchor-00-diorama-5-fullscreen-insitu.png	0.213444	0.087898	0.105992	0.197595
v51-glass-ivory-safetyRefusal	anchor-05-r2-refuse.png	0.229636	0.143769	0.164288	0.167250
v52-inset24-ivory-cooling	anchor-00-diorama-5-fullscreen-insitu.png	0.214337	0.088002	0.105849	0.201312
v52-inset24-ivory-safetyRefusal	anchor-05-r2-refuse.png	0.229548	0.143847	0.164190	0.165010
v53-inset12-ivory-cooling	anchor-00-diorama-5-fullscreen-insitu.png	0.213329	0.088090	0.105841	0.196070
v53-inset12-ivory-safetyRefusal	anchor-05-r2-refuse.png	0.229545	0.146092	0.164179	0.166284
v54-gap14-ivory-cooling	anchor-00-diorama-5-fullscreen-insitu.png	0.214038	0.088111	0.105844	0.196863
v55-gap22-ivory-cooling	anchor-00-diorama-5-fullscreen-insitu.png	0.213526	0.087921	0.105845	0.193508
v55-gap22-ivory-safetyRefusal	anchor-05-r2-refuse.png	0.229552	0.146344	0.164188	0.165553
v56-celsius-split-ivory-cooling	anchor-00-diorama-5-fullscreen-insitu.png	0.213672	0.087977	0.105842	0.186891
v56-celsius-split-ivory-safetyRefusal	anchor-05-r2-refuse.png	0.229645	0.145218	0.164179	0.165553
v58-inset8-ivory-cooling	anchor-00-diorama-5-fullscreen-insitu.png	0.213353	0.087860	0.105841	0.190837
v58-inset8-ivory-safetyRefusal	anchor-05-r2-refuse.png	0.229573	0.144210	0.164184	0.165782
v59-acnum62-ivory-cooling	anchor-00-diorama-5-fullscreen-insitu.png	0.213393	0.088164	0.105847	0.183279
v59-acnum62-ivory-safetyRefusal	anchor-05-r2-refuse.png	0.229654	0.146340	0.164180	0.165551
v60-unitspacing-ivory-cooling	anchor-00-diorama-5-fullscreen-insitu.png	0.213387	0.088148	0.105848	0.186605
v60-unitspacing-ivory-safetyRefusal	anchor-05-r2-refuse.png	0.229516	0.146323	0.164181	0.165551
v61-controlsTop0-ivory-cooling	anchor-00-diorama-5-fullscreen-insitu.png	0.213615	0.087868	0.105849	0.191176
v61-controlsTop0-ivory-safetyRefusal	anchor-05-r2-refuse.png	0.229705	0.146181	0.164182	0.168834
v62-left54-ivory-cooling	anchor-00-diorama-5-fullscreen-insitu.png	0.213653	0.087924	0.105850	0.186092
v62-left54-ivory-safetyRefusal	anchor-05-r2-refuse.png	0.229582	0.145415	0.164183	0.164837
v63-hero-softedge-ivory-cooling	anchor-00-diorama-5-fullscreen-insitu.png	0.213649	0.087947	0.105849	0.186568
v63-hero-softedge-ivory-safetyRefusal	anchor-05-r2-refuse.png	0.229615	0.146211	0.164182	0.165716
v64-range-thumb11-ivory-cooling	anchor-00-diorama-5-fullscreen-insitu.png	0.213390	0.088152	0.105848	0.186026
v64-range-thumb11-ivory-safetyRefusal	anchor-05-r2-refuse.png	0.229653	0.146335	0.164181	0.165553
v65-modelabel13-ivory-cooling	anchor-00-diorama-5-fullscreen-insitu.png	0.213557	0.087856	0.105848	0.186482
v65-modelabel13-ivory-safetyRefusal	anchor-05-r2-refuse.png	0.229584	0.145556	0.164183	0.165546
```

Same-script safety-refusal delta after the active-hero fix:

```tsv
case	context	orb	dialogue	controls
v39-safety	0.232998	0.145821	0.168146	0.194389
v41-safety	0.232897	0.146476	0.168148	0.168647
delta_v41_minus_v39	-0.000101	+0.000655	+0.000002	-0.025741
```

Same-script delta after the v42 controls-zone alignment pass:

```tsv
case	context	orb	dialogue	controls
ivory-cooling	-0.002793	-0.004260	-0.007781	-0.016312
ivory-safetyRefusal	-0.001462	-0.002060	-0.000612	-0.001210
```

Same-script delta after the v44 controls-zone vertical alignment pass:

```tsv
case	context	orb	dialogue	controls
ivory-cooling	-0.000331	+0.000192	-0.000037	-0.011555
ivory-safetyRefusal	+0.000146	-0.001447	-0.000050	-0.000633
```

Same-script delta after the v45 card-material / column-ratio pass:

```tsv
case	context	orb	dialogue	controls
ivory-cooling	-0.001075	-0.000586	-0.000646	-0.000960
ivory-safetyRefusal	-0.000925	+0.002463	-0.003308	+0.001489
```

Same-script delta after the retained v55 gap pass versus v45:

```tsv
case	context	orb	dialogue	controls
ivory-cooling	-0.002608	+0.000098	+0.000006	-0.000104
ivory-safetyRefusal	-0.001104	+0.000912	+0.000010	-0.002740
```

Same-script delta after the retained v56 Celsius split versus v55:

```tsv
case	context	orb	dialogue	controls
ivory-cooling	+0.000146	+0.000056	-0.000003	-0.006617
ivory-safetyRefusal	+0.000093	-0.001126	-0.000009	+0.000000
```

Same-script delta after the retained v59 AC number pass versus v56:

```tsv
case	context	orb	dialogue	controls
ivory-cooling	-0.000279	+0.000187	+0.000005	-0.003612
ivory-safetyRefusal	+0.000009	+0.001122	+0.000001	-0.000002
```

Readout:

- The focused v41 script is for same-script safety/cooling regression checks; do not compare it directly against the full v39 table.
- Safety-refusal controls-zone RMSE improves by `-0.025741` under the same v39/v41 script because the refused family is now promoted into the hero zone with reason text.
- v42 improves both focused cases across all four zones compared with v41. The biggest local gain is `ivory-cooling` controls-zone `-0.016312`, matching the targeted AC-card placement/font correction.
- v44 improves the target controls zone again for both focused cases, with the largest local gain in `ivory-cooling` controls-zone `-0.011555`. The context/orb/dialogue changes are near-zero, so the patch is scoped to vertical card alignment rather than a broad re-layout.
- A rejected v43 capsule-size experiment is intentionally not retained: it improved controls similarly but worsened the context zone (`ivory-cooling` context `+0.013085`), so the v44 patch keeps the v42 capsule geometry.
- v45 is retained as a narrow positive tradeoff: cooling improves in all four zones, and safety refusal improves in context/dialogue while safety controls regresses by `+0.001489`. The remaining mismatch is still visual density/material quality, not data wiring.
- `ios-simulator-skill` visual_diff artifacts for v45 are in `docs/research/2026-06-25-a2-execution/visual-diff-v45/`; same-size zone comparison reports context `35.96%`, orb `17.63%`, dialogue `14.44%`, controls `20.02%` changed pixels versus anchor. These are diagnostic artifacts, not acceptance gates.
- v46/v47/v48/v49 are rejected: v46 capsule-only offset regressed `ivory-cooling` context from `0.216134` to `0.255447`; v47 typography-only adjustment regressed `ivory-cooling` controls from `0.193612` to `0.196363`; v48 compact-card spacing regressed cooling controls to `0.203699`; v49 mic-dock offset regressed cooling controls to `0.203779`.
- v50/v51 are rejected despite using native Liquid Glass guidance: they improved context diagnostics but regressed the primary cooling controls zone to `0.197920`/`0.197595`.
- v52/v53 are rejected side-inset trials: safety controls improved, but cooling controls regressed to `0.201312`/`0.196070`.
- v54 gap `14pt` is rejected because cooling controls regressed to `0.196863`.
- v55 gap `22pt` is retained: cooling controls narrowly improves from `0.193612` to `0.193508`, and safety controls improves from `0.168293` to `0.165553`. This is still a small geometry improvement, not a Phase 2 visual acceptance.
- v56 Celsius split is retained: it fixes a real formatting bug and improves cooling controls from `0.193508` to `0.186891` without regressing safety controls (`0.165553`). It intentionally keeps range-bar progress mapped to the real contract range `18...32` instead of faking the anchor knob position.
- v57 `semantic.cool.deep` range-bar color experiment is rejected: cooling controls regressed from v56 `0.186891` to `0.187518`, so the code keeps the token-faithful `semanticCool` range bar.
- v58 side-inset `16pt → 8pt` is rejected: it moved the featured grid closer to the visual left edge but regressed cooling controls to `0.190837` and safety controls to `0.165782`.
- v59 AC number `58pt → 62pt` is retained: cooling controls improves from `0.186891` to `0.183279`; safety controls stays effectively flat (`0.165553 → 0.165551`). The small safety orb delta is treated as animation-frame noise because the safety-refusal hero is not the AC card.
- v60 unit-spacing `6pt → 3pt` is rejected: it improves the visual gap hypothesis but regresses cooling controls from v59 `0.183279` to `0.186605`.
- v61 controls top padding `6pt → 0pt` is rejected: cooling controls regressed to `0.191176`, and safety controls regressed to `0.168834`.
- v62 featured left ratio `0.515 → 0.54` is rejected for the retained baseline: safety controls improved to `0.164837`, but the primary cooling controls zone regressed to `0.186092`. Phase 2's current AC/cooling anchor work keeps cooling as the tie-breaker until a broader layout pass can improve both.
- v63 hero soft-edge trial is rejected: lowering hero border/rim visual weight regressed cooling controls to `0.186568` and safety controls to `0.165716`.
- v64 range thumb `13pt → 11pt` is rejected: it regressed cooling controls to `0.186026` while leaving safety effectively flat (`0.165553`).
- v65 AC mode label `12pt → 13pt` is rejected and reverted in code: cooling controls regressed to `0.186482`, so the current label size is again `12pt`.
- The v48/v49 context regressions also show the current unmasked context metric is sensitive to capsule animation frame drift; future pixel gates must follow the plan's dynamic-region masking rule instead of treating whole-zone context RMSE as a stable single number.
- The masked v45 rerun confirms context-zone RMSE is materially affected by capsule diorama frame/content: cooling `0.216134 → 0.174189`, safety-refusal `0.230656 → 0.138033`. This separates dynamic-capsule judgment from lower-zone controls judgment; it does not lower the raw visual bar.
- This is real improvement, but not enough to burn down Phase 2: typography, exact zone density, DeepSpace composition, and human visual acceptance remain open.
- The implementation still preserves the 10-family mock contract instead of copying non-contract anchor cards or labels.

## Validation

Commands run from `/Users/wanglei/workspace/MAformac-uiue` after the v45 code patch:

```bash
bash Tools/checks/check-no-binary-visualstate.sh
bash Tools/checks/check-contentview-uses-display-catalog.sh
bash Tools/checks/check-platform-vs-version-guard.sh
Tools/checks/phase2_zone_compare.py --case ivory-cooling --anchor docs/design/anchors/anchor-00-diorama-5-fullscreen-insitu.png --current docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v45-ivory-cooling.png --output docs/research/2026-06-25-a2-execution/zone-compare-v45-scripted/cooling.tsv
Tools/checks/phase2_zone_compare.py --case ivory-safetyRefusal --anchor docs/design/anchors/anchor-05-r2-refuse.png --current docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v45-ivory-safetyRefusal.png --output docs/research/2026-06-25-a2-execution/zone-compare-v45-scripted/safety.tsv
Tools/checks/phase2_zone_compare.py --case ivory-cooling-masked --anchor docs/design/anchors/anchor-00-diorama-5-fullscreen-insitu.png --current docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v45-ivory-cooling.png --mask-preset phase2-capsule-diorama --output docs/research/2026-06-25-a2-execution/zone-compare-v45-scripted/cooling-masked.tsv
Tools/checks/phase2_zone_compare.py --case ivory-safetyRefusal-masked --anchor docs/design/anchors/anchor-05-r2-refuse.png --current docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v45-ivory-safetyRefusal.png --mask-preset phase2-capsule-diorama --output docs/research/2026-06-25-a2-execution/zone-compare-v45-scripted/safety-masked.tsv
xcodebuild -project MAformac.xcodeproj -scheme MAformacIOS -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -derivedDataPath .build/dd-ios build
xcrun simctl install booted .build/dd-ios/Build/Products/Debug-iphonesimulator/MAformacIOS.app
xcrun simctl terminate booted lab.rayw.MAformac.ios
xcrun simctl launch booted lab.rayw.MAformac.ios -forceTheme ivory -mockSnapshot cooling
xcrun simctl terminate booted lab.rayw.MAformac.ios
xcrun simctl launch booted lab.rayw.MAformac.ios -forceTheme ivory -mockSnapshot safetyRefusal
xcodebuild -project MAformac.xcodeproj -scheme MAformacMac -destination 'platform=macOS' -derivedDataPath .build/dd-mac build
swift test
git diff --check
```

Results:

- `check-no-binary-visualstate`: pass.
- `check-contentview-uses-display-catalog`: pass.
- `check-platform-vs-version-guard`: pass.
- `phase2_zone_compare.py`: reproduces the v45 focused RMSE values for cooling and safety-refusal, and produces the masked diagnostic rerun with `phase2-capsule-diorama`.
- iOS simulator build: `** BUILD SUCCEEDED **`.
- macOS build: `** BUILD SUCCEEDED **`.
- `swift test`: 245 tests executed, 3 skipped, 0 failures.
- `git diff --check`: pass.

Additional commands run after the retained v55 gap patch:

```bash
xcodebuild -project MAformac.xcodeproj -scheme MAformacIOS -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -derivedDataPath .build/dd-ios build
xcrun simctl install booted .build/dd-ios/Build/Products/Debug-iphonesimulator/MAformacIOS.app
xcrun simctl launch booted lab.rayw.MAformac.ios -forceTheme ivory -mockSnapshot cooling
xcrun simctl launch booted lab.rayw.MAformac.ios -forceTheme ivory -mockSnapshot safetyRefusal
Tools/checks/phase2_zone_compare.py --case v55-gap22-ivory-cooling --anchor docs/design/anchors/anchor-00-diorama-5-fullscreen-insitu.png --current docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v55-gap22-cooling.png --output docs/research/2026-06-25-a2-execution/zone-compare-v55-gap22/cooling.tsv
Tools/checks/phase2_zone_compare.py --case v55-gap22-ivory-safetyRefusal --anchor docs/design/anchors/anchor-05-r2-refuse.png --current docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v55-gap22-safetyRefusal.png --output docs/research/2026-06-25-a2-execution/zone-compare-v55-gap22/safety.tsv
Tools/checks/phase2_zone_compare.py --case v55-gap22-ivory-cooling-masked --anchor docs/design/anchors/anchor-00-diorama-5-fullscreen-insitu.png --current docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v55-gap22-cooling.png --mask-preset phase2-capsule-diorama --output docs/research/2026-06-25-a2-execution/zone-compare-v55-gap22/cooling-masked.tsv
Tools/checks/phase2_zone_compare.py --case v55-gap22-ivory-safetyRefusal-masked --anchor docs/design/anchors/anchor-05-r2-refuse.png --current docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v55-gap22-safetyRefusal.png --mask-preset phase2-capsule-diorama --output docs/research/2026-06-25-a2-execution/zone-compare-v55-gap22/safety-masked.tsv
bash Tools/checks/check-no-binary-visualstate.sh
bash Tools/checks/check-contentview-uses-display-catalog.sh
bash Tools/checks/check-platform-vs-version-guard.sh
xcodebuild -project MAformac.xcodeproj -scheme MAformacMac -destination 'platform=macOS' -derivedDataPath .build/dd-mac build
swift test
git diff --check
```

Additional v55 results:

- iOS simulator build: `** BUILD SUCCEEDED **`.
- macOS build: `** BUILD SUCCEEDED **`.
- `swift test`: 245 tests executed, 3 skipped, 0 failures.
- `check-no-binary-visualstate`: pass.
- `check-contentview-uses-display-catalog`: pass.
- `check-platform-vs-version-guard`: pass.
- `git diff --check`: pass.

Additional commands run after the retained v56 Celsius split patch:

```bash
xcodebuild -project MAformac.xcodeproj -scheme MAformacIOS -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -derivedDataPath .build/dd-ios build
xcrun simctl install booted .build/dd-ios/Build/Products/Debug-iphonesimulator/MAformacIOS.app
xcrun simctl launch booted lab.rayw.MAformac.ios -forceTheme ivory -mockSnapshot cooling
xcrun simctl launch booted lab.rayw.MAformac.ios -forceTheme ivory -mockSnapshot safetyRefusal
Tools/checks/phase2_zone_compare.py --case v56-celsius-split-ivory-cooling --anchor docs/design/anchors/anchor-00-diorama-5-fullscreen-insitu.png --current docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v56-celsius-split-cooling.png --output docs/research/2026-06-25-a2-execution/zone-compare-v56-celsius-split/cooling.tsv
Tools/checks/phase2_zone_compare.py --case v56-celsius-split-ivory-safetyRefusal --anchor docs/design/anchors/anchor-05-r2-refuse.png --current docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v56-celsius-split-safetyRefusal.png --output docs/research/2026-06-25-a2-execution/zone-compare-v56-celsius-split/safety.tsv
Tools/checks/phase2_zone_compare.py --case v56-celsius-split-ivory-cooling-masked --anchor docs/design/anchors/anchor-00-diorama-5-fullscreen-insitu.png --current docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v56-celsius-split-cooling.png --mask-preset phase2-capsule-diorama --output docs/research/2026-06-25-a2-execution/zone-compare-v56-celsius-split/cooling-masked.tsv
Tools/checks/phase2_zone_compare.py --case v56-celsius-split-ivory-safetyRefusal-masked --anchor docs/design/anchors/anchor-05-r2-refuse.png --current docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v56-celsius-split-safetyRefusal.png --mask-preset phase2-capsule-diorama --output docs/research/2026-06-25-a2-execution/zone-compare-v56-celsius-split/safety-masked.tsv
bash Tools/checks/check-no-binary-visualstate.sh
bash Tools/checks/check-contentview-uses-display-catalog.sh
bash Tools/checks/check-platform-vs-version-guard.sh
xcodebuild -project MAformac.xcodeproj -scheme MAformacMac -destination 'platform=macOS' -derivedDataPath .build/dd-mac build
swift test
git diff --check
```

Additional v56 results:

- iOS simulator build: `** BUILD SUCCEEDED **`.
- macOS build: `** BUILD SUCCEEDED **`.
- `swift test`: 245 tests executed, 3 skipped, 0 failures.
- `check-no-binary-visualstate`: pass.
- `check-contentview-uses-display-catalog`: pass.
- `check-platform-vs-version-guard`: pass.
- `git diff --check`: pass.

Additional commands run after the retained v59 AC hero typography patch:

```bash
xcodebuild -project MAformac.xcodeproj -scheme MAformacIOS -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -derivedDataPath .build/dd-ios build
xcrun simctl install booted .build/dd-ios/Build/Products/Debug-iphonesimulator/MAformacIOS.app
xcrun simctl launch booted lab.rayw.MAformac.ios -forceTheme ivory -mockSnapshot cooling
xcrun simctl launch booted lab.rayw.MAformac.ios -forceTheme ivory -mockSnapshot safetyRefusal
Tools/checks/phase2_zone_compare.py --case v59-acnum62-ivory-cooling --anchor docs/design/anchors/anchor-00-diorama-5-fullscreen-insitu.png --current docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v59-acnum62-cooling.png --output docs/research/2026-06-25-a2-execution/zone-compare-v59-acnum62/cooling.tsv
Tools/checks/phase2_zone_compare.py --case v59-acnum62-ivory-safetyRefusal --anchor docs/design/anchors/anchor-05-r2-refuse.png --current docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v59-acnum62-safetyRefusal.png --output docs/research/2026-06-25-a2-execution/zone-compare-v59-acnum62/safety.tsv
Tools/checks/phase2_zone_compare.py --case v59-acnum62-ivory-cooling-masked --anchor docs/design/anchors/anchor-00-diorama-5-fullscreen-insitu.png --current docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v59-acnum62-cooling.png --mask-preset phase2-capsule-diorama --output docs/research/2026-06-25-a2-execution/zone-compare-v59-acnum62/cooling-masked.tsv
Tools/checks/phase2_zone_compare.py --case v59-acnum62-ivory-safetyRefusal-masked --anchor docs/design/anchors/anchor-05-r2-refuse.png --current docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v59-acnum62-safetyRefusal.png --mask-preset phase2-capsule-diorama --output docs/research/2026-06-25-a2-execution/zone-compare-v59-acnum62/safety-masked.tsv
bash Tools/checks/check-no-binary-visualstate.sh
bash Tools/checks/check-contentview-uses-display-catalog.sh
bash Tools/checks/check-platform-vs-version-guard.sh
xcodebuild -project MAformac.xcodeproj -scheme MAformacIOS -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -derivedDataPath .build/dd-ios build
xcodebuild -project MAformac.xcodeproj -scheme MAformacMac -destination 'platform=macOS' -derivedDataPath .build/dd-mac build
swift test
git diff --check
```

Additional v59 current-state results:

- masked v59 cooling: context `0.170728`, orb `0.086894`, dialogue `0.105847`, controls `0.183279`.
- masked v59 safety-refusal: context `0.136179`, orb `0.144586`, dialogue `0.164180`, controls `0.165551`.
- iOS simulator build: `** BUILD SUCCEEDED **`.
- macOS build: `** BUILD SUCCEEDED **`.
- `swift test`: 245 tests executed, 3 skipped, 0 failures.
- `check-no-binary-visualstate`: pass.
- `check-contentview-uses-display-catalog`: pass.
- `check-platform-vs-version-guard`: pass.
- `git diff --check`: pass.

Additional current verification after rejecting and reverting the v65 AC mode-label experiment:

```bash
bash Tools/checks/check-no-binary-visualstate.sh
bash Tools/checks/check-contentview-uses-display-catalog.sh
bash Tools/checks/check-platform-vs-version-guard.sh
git diff --check
xcodebuild -project MAformac.xcodeproj -scheme MAformacIOS -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -derivedDataPath .build/dd-ios build
xcodebuild -project MAformac.xcodeproj -scheme MAformacMac -destination 'platform=macOS' -derivedDataPath .build/dd-mac build
swift test
```

Current verification results:

- `check-no-binary-visualstate`: pass.
- `check-contentview-uses-display-catalog`: pass.
- `check-platform-vs-version-guard`: pass.
- `git diff --check`: pass.
- iOS simulator build: `** BUILD SUCCEEDED **`.
- macOS build: `** BUILD SUCCEEDED **`.
- `swift test`: 245 tests executed, 3 skipped, 0 failures.

Rejected diagnostic commands also generated v58/v60 screenshots and zone reports under:

```text
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v58-inset8-*.png
docs/research/2026-06-25-a2-execution/zone-compare-v58-inset8/
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v60-unitspacing-*.png
docs/research/2026-06-25-a2-execution/zone-compare-v60-unitspacing/
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v61-controlsTop0-*.png
docs/research/2026-06-25-a2-execution/zone-compare-v61-controlsTop0/
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v62-left54-*.png
docs/research/2026-06-25-a2-execution/zone-compare-v62-left54/
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v63-hero-softedge-*.png
docs/research/2026-06-25-a2-execution/zone-compare-v63-hero-softedge/
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v64-range-thumb11-*.png
docs/research/2026-06-25-a2-execution/zone-compare-v64-range-thumb11/
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v65-modelabel13-*.png
docs/research/2026-06-25-a2-execution/zone-compare-v65-modelabel13/
```

## Additional v72 Atmosphere + AC Scrub Pass

This pass responds to the latest iPhone visual review. It is still **PARTIAL**, not a Phase 2 sign-off.

Implementation deltas:

- Added `StageAtmosphereLayer` behind the stage: lightweight SwiftUI `Canvas` sparkle/dust field + edge sheen, borrowing the local Vortex/Orb pattern category without importing/copying extra repo code or using heavy shader/layerEffect paths.
- Upgraded `DemoOrbView` with layered halo, angular highlight, specular spot, softer rim, and `Reduce Motion` aware timeline behavior.
- Added `cardSpecularLayer` to vehicle cards so the AC hero and compact cards read less like flat white rectangles.
- Reduced AC hero non-temperature value weight: `待命` now renders as a 23pt medium in the AC hero instead of occupying the 62pt temperature slot.
- Replaced the transparent nested `Slider` experiment with a `ThermalRangeBar` `DragGesture` that maps drag position to the contract range `18...32` and calls `applyMockTransition(family:key:desiredValue:)`.
- `applyMockTransition` seeds a missing AC temperature cell before applying the mock transition, so safety-refusal snapshots can still scrub the AC bar even when their initial store cells contain only the refused door cell.

Screenshots:

```text
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v72-atmosphere-cooling.png
docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v72-atmosphere-safetyRefusal.png
```

Zone compare:

```tsv
case	anchor	context	orb	dialogue	controls
v72-atmosphere-ivory-cooling	anchor-00-diorama-5-fullscreen-insitu.png	0.213043	0.096557	0.105962	0.173887
v72-atmosphere-ivory-safetyRefusal	anchor-05-r2-refuse.png	0.229354	0.149086	0.164233	0.157762
v72-atmosphere-ivory-cooling-masked	anchor-00-diorama-5-fullscreen-insitu.png	0.170691	0.094879	0.105962	0.173887
v72-atmosphere-ivory-safetyRefusal-masked	anchor-05-r2-refuse.png	0.136212	0.147088	0.164233	0.157762
```

Readout:

- Controls-zone RMSE improved versus the retained v59 baseline (`cooling 0.183279 -> 0.173887`, `safety 0.165551 -> 0.157762`), matching the user's callout that the lower control zone needed more anchor-grade material and density.
- Orb-zone RMSE regressed versus v59 after adding atmosphere, then improved in v72 compared with v71 after reducing halo saturation. This confirms the visual algorithm needs both zone metrics and human aesthetic review: pure RMSE penalizes intentional particles/atmosphere, but over-bright halo was a real mismatch.
- Runtime UI snapshot confirms the AC card remains a tap target and keeps the scrub value exposed: `e15|tap|button|空调 待命 待命|25℃|vehicle-card-family.ac`.
- Automated drag is not claimed as passed: XcodeBuildMCP drag failed with `FBSimulatorHIDEvent does not support touch move events`; `idb` is not installed in this environment. Code-level gesture wiring and runtime accessibility are verified, but touch-drag proof remains `PARTIAL` until idb/manual/true-device evidence is added.

Additional v72 verification:

```bash
bash Tools/checks/check-no-binary-visualstate.sh
bash Tools/checks/check-contentview-uses-display-catalog.sh
bash Tools/checks/check-platform-vs-version-guard.sh
git diff --check
xcodebuild -project MAformac.xcodeproj -scheme MAformacIOS -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build
xcodebuild -project MAformac.xcodeproj -scheme MAformacMac -destination 'platform=macOS' -derivedDataPath .build/dd-mac build
swift test
```

Results:

- iOS simulator build via XcodeBuildMCP: succeeded.
- macOS build: `** BUILD SUCCEEDED **`.
- `swift test`: 245 tests executed, 3 skipped, 0 failures.
- `check-no-binary-visualstate`: pass.
- `check-contentview-uses-display-catalog`: pass.
- `check-platform-vs-version-guard`: pass.
- `git diff --check`: pass.

## Coverage Index

`docs/grill-checklist/uiue-a2-grill-coverage-index.md` was not ticked in this pass.

Reason: Phase 2 still needs final visual acceptance and hard-gate closure before the grouped P2 rows can honestly move from `- [ ]` to `- [x]`.

## Residual Risk

- iPhone visual quality is improved but not signed off as 100-point / V-PASS.
- v59 specifically improves the AC Celsius-unit typography and hero-number weight; it does not close the broader 1:1 anchor density/material/range-bar visual gaps.
- DeepSpace heating/refusal comparisons are retained as regression sentinels, not same-composition acceptance evidence.
- Phase 3+ touch/control-panel/ambient-burst/capsule work remains open.

## P0 Commit Anchor: Phase 2 proof slice

Commit subject: `docs(uiue): anchor phase2 main-stage proof slice`

This commit anchors the Phase 2 proof slice after the shared scaffold commit: repeatable `Tools/checks/phase2_zone_compare.py`, the Phase 2 main-stage receipt, the Phase 2 force-state receipt text, v72 current screenshots, v72 TSV compare outputs, v59 retained baseline TSV outputs, and the small v59 side-by-side inspection images.

Not anchored here: the shared SwiftUI implementation already lives in `98f7c57`; historical v1-v72 screenshot/zone-compare iteration directories remain generated working-tree artifacts; the 25MB force-state full screenshot set is not committed in this proof slice.

Claim boundary: Phase 2 remains `PARTIAL`. This commit proves there is a recoverable Phase 2 evidence slice in the isolated UIUE worktree, not anchor-level human acceptance, not 8.C2, not coverage burn-down, and not mainline proof.

Next: reconcile Phase 2 `tasks.md`/coverage only after visual-acceptance 5-gate and anchor-level review pass.
