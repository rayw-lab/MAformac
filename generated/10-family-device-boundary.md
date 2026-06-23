# G4: 10 族 device 边界精确梳理

> **as-of**: 2026-06-22
> **数据源**: `contracts/semantic-function-contract.jsonl`（3990 行 / 671 device / 1538 intent）
> **目的**: 解 CC 422 vs GLM 397 不一致——根因是子串匹配 vs 精确匹配 + disputed device 归属差异
> **配套**: `generated/10-family-device-map.json`（device→family 映射，223 device）

## 总览

| 统计 | Definite only | Definite + Disputed |
|---|---|---|
| device 数 | 161 | 223 |
| 行数 | 2065 (51.8%) | 2449 (61.4%) |
| 不同 intent | 507 (33.0%) | 680 (44.2%) |

> **422/397 不一致根因**：CC 用子串宽匹配（"ac" 误匹配 "acoustics"）→ 422；GLM 用精确 device 值匹配 → 397。两者都没区分 definite/disputed。本表精确到每个 device 值，definite/disputed 分开标注。

## 10 族明细

### 空调（14 definite + 9 disputed = 23 device）

| 状态 | device | 行数 | intent 数 |
|---|---|---|---|
| definite | ac_temperature | 44 | 10 |
| definite | ac_windspeed | 44 | 10 |
| definite | ac | 8 | 4 |
| definite | ac_cooling_mode | 8 | 2 |
| definite | ac_heating_mode | 8 | 2 |
| definite | defog_mode | 8 | 2 |
| definite | defrost_mode | 8 | 2 |
| definite | ac_wind_direction | 6 | 3 |
| definite | ac_set_interface | 4 | 2 |
| definite | airoutlet | 4 | 2 |
| definite | airoutlet_direction | 4 | 2 |
| definite | dehumidification_mode | 4 | 2 |
| definite | zone_synchronization_mode | 4 | 2 |
| definite | ac_mode | 2 | 1 |
| **disputed→空调** | interior_heat | 40 | 10 |
| **disputed→空调** | windshield_heating | 4 | 2 |
| **disputed→空调** | air_clean | 4 | 2 |
| **disputed→空调** | cabin_disinfect | 4 | 2 |
| **disputed→空调** | humidifier | 4 | 2 |
| **disputed→空调** | blower_delay_shutdown | 2 | 2 |
| **disputed→空调** | ventilation_system | 2 | 2 |
| **disputed→空调** | timed_ventilation | 2 | 2 |
| **disputed→空调** | timed_ventilation_interval | 4 | 1 |

**小计**: definite 156 行/46 intent + disputed 66 行/25 intent = 222 行/71 intent

### 座椅（30 definite + 4 disputed = 34 device）

| 状态 | device | 行数 | intent 数 |
|---|---|---|---|
| definite | seat_heat_temperature | 88 | 8 |
| definite | seat_ventilation_windspeed | 88 | 8 |
| definite | seat_mode | 52 | 5 |
| definite | seat_massage_time | 44 | 7 |
| definite | seat_massage_force | 40 | 8 |
| definite | seat_leg_support | 32 | 6 |
| definite | seat_rhythm_mode | 32 | 8 |
| definite | seat_position | 28 | 4 |
| definite | seat_backrest/feet/shoulder/lumbar/cushion | 各24 | 各4 |
| definite | seat_belt_heat_temperature | 16 | 8 |
| definite | 其余 seat_* | 142 | — |
| **disputed→座椅** | headrest_ear_slice_direction | 24 | 3 |
| **disputed→座椅** | headrest_direction | 16 | 3 |
| **disputed→座椅** | headrest_direction_adjust | 4 | 1 |
| **disputed→座椅** | headrest_direction_ear_slice_adjust | 4 | 1 |

**小计**: definite 640 行/114 intent + disputed 48 行/8 intent = 688 行/122 intent
> ⚠️ 磊哥说"跳过头枕"——headrest 4 个 device 归属待拍。若跳过则座椅 = 640 行/114 intent

### 车窗（10 definite + 0 disputed = 10 device）

| device | 行数 | intent 数 |
|---|---|---|
| window | 38 | 8 |
| window_ventilation_mode | 8 | 2 |
| automatic_window_opening | 8 | 2 |
| window_slide/lock/breathe_mode/curtain | 各4 | 各2 |
| automatic_window_closing | 4 | 2 |
| remote_control_window | 2 | 2 |
| back_window | 2 | 2 |

**小计**: 78 行 / 25 intent（无争议）

### 车门（6 definite + 5 disputed = 11 device）

| 状态 | device | 行数 | intent 数 |
|---|---|---|---|
| definite | door | 40 | 7 |
| definite | car_door | 16 | 3 |
| definite | door_speed | 8 | 2 |
| definite | vehicle_refrigerator_door | 8 | 2 |
| definite | door_height | 4 | 1 |
| definite | maximum_of_door_opening | 4 | 1 |
| **disputed→车门** | lock_mode | 8 | 2 |
| **disputed→车门** | unlock_mode | 4 | 2 |
| **disputed→车门** | child_lock | 4 | 2 |
| **disputed→车门** | central_lock | 2 | 2 |
| **disputed→车门** | doors_windows_locks_set_interface | 2 | 2 |

**小计**: definite 80 行/16 intent + disputed 20 行/10 intent = 100 行/26 intent

### 灯光氛围（26 definite + 11 disputed = 37 device）

| 状态 | device | 行数 | intent 数 |
|---|---|---|---|
| definite | atmosphere_lamp_brightness | 80 | 9 |
| definite | designative_in_car_lamp_time | 52 | 7 |
| definite | designative_in_car_lamp_brightness | 40 | 8 |
| definite | designative_in_car_lamp_color_temperature | 40 | 8 |
| definite | backlight_brightness | 39 | 8 |
| definite | button_brightness | 28 | 9 |
| definite | designative_out_car_lamp_time | 26 | 7 |
| definite | atmosphere_lamp_change_speed | 24 | 5 |
| definite | atmosphere_lamp/color | 各20 | — |
| definite | designative_in/out_car_lamp | 各20/12 | — |
| definite | 其余 light_*/backlight | 73 | — |
| **disputed→灯光** | dimming_glass_top_brightness | 22 | 8 |
| **disputed→灯光** | dimming_glass_top_transparency | 22 | 8 |
| **disputed→灯光** | stream_rearview_mirror_brightness | 22 | 8 |
| **disputed→灯光** | headliner | 7 | 6 |
| **disputed→灯光** | dimming_glass_top/mode/color | 各4-6 | — |
| **disputed→灯光** | illuminated/luminous_luggage_rack | 各2 | — |
| **disputed→灯光** | turnsignal_frequency | 1 | 1 |

**小计**: definite 493 行/109 intent + disputed 96 行/44 intent = 589 行/153 intent

### 屏幕（30 definite + 23 disputed = 53 device）

| 状态 | device | 行数 | intent 数 |
|---|---|---|---|
| definite | split_screen | 18 | 3 |
| definite | screen_brightness | 26 | 8 |
| definite | screen_saver | 14 | 4 |
| definite | exchange/copy_same/cross_screen | 各5-10 | — |
| definite | screen/display_mode/direction/color_mode | 各6-10 | — |
| definite | 其余 screen_*/hud_display_content | 76 | — |
| **disputed→屏幕** | hud_brightness/height | 各11 | 各8 |
| **disputed→屏幕** | hud_inclination | 8 | 5 |
| **disputed→屏幕** | speak_speed → 实归音量 | 13 | 8 |
| **disputed→屏幕** | 其余 hud_*/theme/wallpaper/desktop | 各2-7 | — |

**小计**: definite 205 行/64 intent + disputed 105 行/62 intent = 310 行/126 intent

### 音量（22 definite + 8 disputed = 30 device）

| 状态 | device | 行数 | intent 数 |
|---|---|---|---|
| definite | volume | 78 | 8 |
| definite | eq | 18 | 9 |
| definite | volume_mode | 12 | 3 |
| definite | noise_volume_compensation | 12 | 9 |
| definite | volume_external_playback/gradually/banlance | 各8 | — |
| definite | current_volume/mute/unmute | 各6 | — |
| definite | 其余 driving_sound/auto_volume/wind_reduction | 各2-4 | — |
| **disputed→音量** | acoustics_mode | 10 | 3 |
| **disputed→音量** | speak_speed | 13 | 8 |
| **disputed→音量** | anc | 2 | 2 |
| **disputed→音量** | headrest_audio_system*3 | 各4 | — |
| **disputed→音量** | speaker/speaker_property | 1+5 | — |

**小计**: definite 203 行/64 intent + disputed 43 行/21 intent = 246 行/85 intent

### 雨刮（8 definite + 2 disputed = 10 device）

| 状态 | device | 行数 | intent 数 |
|---|---|---|---|
| definite | wiper_speed | 40 | 8 |
| definite | wiper_sensitivity | 16 | 8 |
| definite | wiper | 8 | 2 |
| definite | wiper_maintenance/wash/mode/set_interface/the_rain_sensor | 各2-4 | — |
| **disputed→雨刮** | nozzle_heat | 4 | 2 |
| **disputed→雨刮** | nozzle_heat_mode | 2 | 1 |

**小计**: definite 80 行/27 intent + disputed 6 行/3 intent = 86 行/30 intent

### 天窗遮阳帘（8 definite + 0 disputed = 8 device）

| device | 行数 | intent 数 |
|---|---|---|
| sunroof | 38 | 8 |
| sunshade | 36 | 8 |
| sunroof_ventilation/heat/breathe_mode/tilt/slide | 各4 | — |
| sunshade_slide | 4 | 1 |

**小计**: 98 行 / 26 intent（无争议）

### 香氛（7 definite + 0 disputed = 7 device）

| device | 行数 | intent 数 |
|---|---|---|
| fragrance_intensity | 16 | 8 |
| fragrance_mode | 5 | 1 |
| fragrance | 4 | 2 |
| fragrance_time | 3 | 1 |
| fragrance_set_interface | 2 | 2 |
| mode_of_fragrance/amount_of_fragrance | 各1 | — |

**小计**: 32 行 / 16 intent（无争议）
> 香氛边界：只支持强度/开关（intensity/mode），不支持选味道（raw「香氛味道不承接」）

## 争议 device 分组（63 个，待磊哥拍）

### 组1：空调子系统扩展（9 device, 66 行）
airoutlet 已归 definite。disputed: interior_heat(40行最大), windshield_heating, air_clean, cabin_disinfect, humidifier, blower_delay_shutdown, ventilation_system, timed_ventilation×2
> 建议：全归空调（都是空调子系统功能）

### 组2：头枕（7 device, 60 行）
headrest_direction*4 → 座椅 | headrest_audio*3 → 音量
> ⚠️ 磊哥说"跳过头枕"——若跳过则这 60 行不计入 10 族

### 组3：车门锁（5 device, 20 行）
lock_mode, unlock_mode, child_lock, central_lock, doors_windows_locks_set_interface
> 建议：归车门（锁是车门子系统）

### 组4：调光玻璃顶（5 device, 58 行）
dimming_glass_top + brightness/transparency/mode/color
> 建议：归灯光氛围（调光=灯光控制）or 天窗遮阳帘（物理位置在顶部）—— 倾向灯光

### 组5：HUD/UI（23 device, 105 行）
hud*10 + theme/wallpaper/desktop_mode/blue_ray_filtering/system_font_size/touch*/gesture/dropdown/folder/back_to_homepage
> 建议：HUD 归屏幕；UI 设置（theme/wallpaper/font）可能超出 demo 范围（不是车控而是系统设置）

### 组6：音量扩展（5 device, 27 行）
acoustics_mode, speak_speed(语速=TTS非车控), anc(主动降噪), speaker/speaker_property
> 建议：acoustics_mode/anc 归音量；speak_speed 排除（TTS 参数非车控）；speaker 归音量

### 组7：雨刮扩展（2 device, 6 行）
nozzle_heat/nozzle_heat_mode
> 建议：归雨刮（喷嘴除冰）

### 组8：灯光边缘（6 device, 59 行）
stream_rearview_mirror_brightness(22), headliner(7), illuminated/luminous_luggage_rack(6), turnsignal_frequency(1)
> 建议：流媒体后视镜归屏幕 or 灯光；行李架归灯光；转向灯归灯光

## 与之前数字的对账

| 来源 | 10族 intent 数 | 口径 |
|---|---|---|
| CC 宽子串匹配 | 422 | "ac" 误匹配 acoustics/face_recognition 等 |
| GLM 精确匹配（definite only） | 397 | 只算 definite device |
| **本表 definite only** | **507** | 161 device 精确匹配 |
| **本表 definite + disputed** | **680** | 223 device 精确匹配 |

> GLM 之前的 397 偏低——是因为手动列举 device 值时遗漏了部分 definite device（如 seat_belt_*, comfortable_entry_exit, instrument_show_content 等）。本表从 671 个 device 全量扫描，definite 161 个 = 507 intent。
