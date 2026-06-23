## summary

调研 lens = **车机/座舱 HMI 多域控制展示范式**(主候选深扒)。结论:真实车机用**四种主流信息架构**展示多域控制——网格式(已淘汰)/卡片式(中国新势力主流,理想代表)/分区式(功能分区建位置记忆,安全导向)/地图为桌面(特斯拉/蔚来/小鹏,功能浮现卡片)。MAformac scheme1 现 6 卡片 2×2 静态网格 = 退化的「网格式」,撑不住 10 族 + 异构值形态。

对 MAformac 最 actionable 的范式:
1. **分区式 + 卡片式混合**(行业最优实践)——分区建稳定空间布局(舒适/车身/娱乐),卡片承载高频功能 + 快捷操作 + 动态信息。
2. **「Zero Layer / 零层级」**(奔驰 MBUX)——重要功能常驻顶层不进子菜单,AI 按场景再浮现 20 个补充卡片。**直接对应 MAformac「语音驱动 + 卡片浮现」的 demo 形态**。
3. **异构值形态 → 异构 widget**(温度=slider/拖拽手势,风量档位=stepper I/II/III,座椅加热=分级 toggle,开关=toggle,RGB=色环/色卡)——解决 MAformac value.type 三分(SPOT/EXP/PERCENT)的展示。
4. **多模态语音反馈三态**(listening/processing/confirming)+ **dual-modality「说+显」**——68% 用户语音后不确定是否被听懂,卡片浮现 = 视觉确认。**这是 MAformac 演示「炸场」的核心机制**。
5. **drive vs park 双态布局** + **多屏联动**(理想:温度变化 surface 到主驾屏)——对应 MAformac 双屏(Mac 主舞台 + iPhone)。
6. **NOMI 是反例**:NIO 故意不用抽象 orb,用拟人化「脸」。MAformac 选 orb 是另一条审美路线(科幻而非萌宠),需自觉这是取舍而非默认。

## findings(逐条带 source)

### F1. 四种主流车机信息架构(MAformac 选型的根本参照)
《智能座舱 HMI 设计》梳理 4 类系统级 IA:
- **网格式**:应用图标平铺、优先级相同,用户自选。代表 = 苹果 CarPlay。**因高频/低频应用使用差异大,已比较少见(淘汰)**。→ scheme1 的 2×2 网格正是这一退化型。
- **卡片式**:延用移动端 App 思路,首屏同时展示 3-4 应用 + 快捷操作。**接触面积大、降低误触、可承载动态信息**。**国内新势力主流,理想代表**。
- **分区式**:界面分导航区/娱乐区/车辆信息区,**各区明确定位、互不干扰,建立信息位置记忆**,减少搜索分心保障安全。
- **地图为桌面**:导航最底层,其他功能以快捷卡片浮现首页固定位。代表 = 特斯拉全系/蔚来 NIO OS/小鹏 Xmart OS。
- **🔴 实践最优 = 混合架构**:以分区建稳定空间布局,以卡片承载高频功能与快捷操作,再以可自定义一级入口满足个性化。
- source: https://siyujia.net/posts/hmidesign (《万字长文》智能座舱 HMI 设计) + https://www.uisdc.com/lixiang-hmi-design (优设网理想再设计) | 2026-06-23 检索

### F2. 理想「L 型」布局 + Dock 栏分区(卡片+分区混合的最佳实证)
理想 L 系列首页四大板块:左上 1/3 固定车辆状态(SR 渲染+多媒体)/ 左下 Dock 栏 = 主页/设置/导航/车控/APP/360 高优先入口 / 右上 2/3 = **快捷卡片(横向滑动切换其它卡片)** / 右下 Dock 栏 = **空调 + 尾门/充电口盖/门锁等高频功能**。空调界面「简单直接」:温度/风量/风向/净化/除雾全用滑动条或虚拟按键排左侧,右侧集成全车座椅通风/加热,**功能键面积普遍很大**。首页 Dock 栏空调可不进全屏弹卡直接快速调温。**多屏联动**:2.0 版滑动调温时温度变化直接出现在主驾信息屏(原需低头看空调屏)。
- 评测者指出卡片「信息利用率偏低」,建议加 mini 卡片轮播展示里程/胎压/水温/车内温度等。
- source: https://zhuanlan.zhihu.com/p/170606625 + https://www.xchuxing.com/article/71334 (呆总聊车机理想座舱再设计) | 2026-06-23 检索

### F3. 奔驰 MBUX「Zero Layer 零层级」+ AI 浮现 20 卡片(MAformac 语音浮现范式直接参照)
MBUX Hyperscreen(56 寸单片玻璃三屏):**「零层级」= 用户不需滚子菜单或语音命令,最重要应用始终在顶层按情境/上下文呈现**。导航/通话/媒体/空调常驻可见,地图始终作背景。**AI 在合适时机额外浮现 20 个功能卡片**——如学习驾驶员座椅加热/按摩习惯,在常激活时段主动建议。无物理按键(12 个 actuator 提供触觉反馈),OLED 非控像素关闭呈深黑。支持 7 套 profile 分区(乘客可见但不可覆盖驾驶员选择)。
- source: https://group.mercedes-benz.com/innovation/digitalisation/connectivity/mbux-hyperscreen.html + https://www.mbusa.com/en/future-vehicles/mbux-hyperscreen | 2026-06-23 检索

### F4. 特斯拉底部栏快捷控制 + 气候卡片(slider/stepper/toggle 混合 widget 实证)
气候控制常驻中控屏底部,默认 Auto。点温度值进主气候屏;Model 3 可三连点气候区调出菜单。**「My Apps」底部栏可自定义**:长按进编辑、从 app tray 拖入快捷;**座椅加热/雨刮除霜/方向盘加热可直接拖到底部栏**(座椅加热特殊,显示在温度旁)。气候卡片含:电源 toggle、座椅加热(3→1 三级,加热红/制冷蓝扭线 icon)、除霜 toggle(30 分自动关)、方向盘加热、出风方向。**Split 分驾乘双温区**时底部栏动态变化。**拖拽手势**:按住温度值左拖减/右拖增(替代弹出 slider);**按住风扇 icon 关 HVAC**。
- source: https://www.tesla.com/ownersmanual/model3/en_gb/GUID-518C51C1...html (官方手册) + https://www.shop4tesla.com/en/pages/tesla-klimaregelung-anleitung-model-y-model-3 | 2026-06-23 检索

### F5. 异构值形态 → 异构控制 widget 映射(MAformac value.type 三分的展示答案)
HMI widget-to-function 标准映射:
- **温度(连续值)** → slider 或 stepper(常叠加拖拽手势)
- **风量/通风档位(离散)** → 离散 stepper(I/II/III/auto/off)
- **座椅加热(分级)** → 分级 stepper/toggle(off→high)
- **HVAC 开关(二元)** → toggle(常用 press-and-hold 风扇 icon 省空间)
- driver distraction 是核心约束 → 拖拽手势降低相比小 slider 的精度要求。
- → **直接对应 MAformac**:温度 18-32℃=slider+offset 动效 / 风量 1-10 档=stepper / 座椅多维(加热×通风×按摩)=分组分级 / 开关=toggle / RGB 氛围灯=色环或预设色卡。
- source: https://axureboutique.com/blogs/ui-ux-design/detailed-explanation-of-automotive-hmi-interaction-design-part-2 + Tesla 官方手册(F4) | 2026-06-23 检索

### F6. 语音命令视觉反馈三态 + dual-modality「说+显」(MAformac 炸场核心机制)
- **68% 用户语音命令后因缺反馈而不确定**(Forrester 引);有效车机 VUI = 语音+视觉(HUD/触屏/仪表)+触觉+音效多模态协同。
- **「说+显」最佳实践**:识别命令后**视觉强化** —— 说「Call Mom」时屏显「Calling Mom」+ 语音确认,dual-modality 增强信心。
- **歧义用视觉卡片消解**:「Navigate to Home」多个 Home 地址列卡片供选。
- **三态指示器**:listening / processing / confirming 用 icon+颜色明确表达;wake 微交互必不可少。
- **动效增「活」感**:voice assistant 动画带来「即时响应」「鲜活」感,提升满意度。
- 高噪环境:push-to-talk + 视觉确认 = 最高可靠。
- → MAformac:**卡片浮现本身 = 语音被听懂的视觉确认**,orb 三态(待命/聆听/思考)+ 卡片 pop = demo 反应快/惊艳的关键。
- source: https://mihup.ai/blog/voice-user-interface-design-best-practices-automotive-applications + https://fuselabcreative.com/voice-user-interface-design-guide-2026/ | 2026-06-23 检索

### F7. 上下文自适应卡片 + drive/park 双态(主视图形态 A/B/C 选型参照)
- **drive 模式**:只显最关键信息、touch target/字体放大、1-2 tap 内触达;**park 模式**:app grid 全展开像平板。
- **NHTSA**:单次视线离路 <2 秒、总任务 <12 秒 → 驱动 glanceability(大字/大 toggle/大按钮)。
- **Adaptive HMI** 持续监控 Driver-Vehicle-Environment,高负荷时只显关键信息降认知负载。
- **Zero UI / 服务找人**:华为智慧助手按场景以卡片推送服务;「不操作也让车主动 curate 环境」。
- → MAformac 主视图候选:**B 纯动态浮现** 最贴合语音驱动 demo(说什么浮什么),但需 **A 全景常驻骨架**作底(否则空屏不惊艳);**C 静态全网格**=scheme1 现状,10 族撑不住,worse。
- source: https://promwad.com/news/adaptive-hmi-driver-context-mood + https://www.aufaitux.com/blog/mi-design-principles-automotive-ux/ + https://www.acsiatech.com/the-ultimate-guide-to-automotive-hmi/ | 2026-06-23 检索

### F8. NOMI = 拟人脸,非抽象 orb(MAformac orb 选择的反例与取舍提醒)
NIO NOMI(2017 首发,2020 Red Dot)= **圆形 AMOLED 拟人「脸+眼」+可转头朝向说话者**的具身机器人,**故意不用抽象 orb**:「要让用户感到 NOMI 是活的,不能只是静态 2D 界面」。2024 NOMI GPT 加情感引擎,2025 Banyan 3.0 生成式 AI 升级。
- 🔴 **对 MAformac 的启示**:NOMI 走「萌宠拟人」路线,MAformac 选「科幻 orb」是**另一条审美路线的主动取舍**(冷峻科技感 vs 情感陪伴),不是默认正解。投屏给企业客户的 demo,科幻 orb 可能比萌脸更「专业惊艳」——但需自觉这是选择。
- source: https://star.global/cases/nio-nomi/ + https://www.red-dot.org/project/nomi-mate-15-46042 | 2026-06-23 检索

### F9. 氛围灯 = HMI 信息通道 + RGB 个性化(灯光氛围族展示参照)
氛围灯已从装饰升为 HMI 核心通道:2025 趋势 = 动态响应(刹车脉冲红/巡航舒缓蓝)、生物识别(按压力/心率调光)、安全告警视觉化(盲区/疲劳,音被噪声盖时灯仍可见)。RGB 静态氛围灯已全段普及。市场 2024 USD 2922M → 2030 USD 5161M(CAGR 10.3%)。
- → MAformac 灯光氛围族:RGB 控制 widget = 色环/预设色卡(mood preset),demo 可演「我有点累」→ 氛围灯转舒缓蓝(语义→颜色,炸场点)。
- source: https://www.valeo.com/en/automotive-interior-lighting-from-static-to-on-surface-projection/ + https://www.digitaljournal.com/pr/news/revupmarketer/ai-powered-ambient-lighting-future-emotionally-1955293462.html | 2026-06-23 检索

### F10. 蔚来 5 区气候 / Polestar 常驻气候带 / 横竖屏布局(分区与常驻栏佐证)
- **NIO ES9 5 区气候**(主/副/二排两区/三排),vent 角度按座位动态调、camera 检测日照热点自动导流。卡片/tab 布局 + 左缘滑出快捷菜单(发现性差,无指示)。
- **Polestar 4**:气候控制带常驻屏幕下缘(评测赞为可用性亮点),但出风口等埋菜单被批步骤多。
- **横竖屏**:横屏操作区/功能区靠左布局;竖屏关键信息放上方(视线少转移),操作区用大面积卡片。
- → MAformac 三屏分层(orb 顶/对话流中/车控卡片下)= 竖屏(iPhone)合理;Mac 横屏可借「常驻气候带 + 卡片区」。
- source: https://evkx.net/models/nio/es9/es9/ + https://www.cars.com/articles/2025-polestar-4-review-not-looking-backwards-517883/ + https://zhuanlan.zhihu.com/p/554543470 | 2026-06-23 检索

### F11. 本机 scout 实况
- 本机屏幕 = 1920×1080 FHD(投屏到客户大屏的基准分辨率;**投屏 banding 风险见 elephant**)。
- ref-repos 无车机专用 UI 实现,但 **itsyhome-macos**(HomeKit 风格 macOS 控制)= 最近的「卡片网格控制智能设备」类比;**Orb**(SwiftUI orb 动效)可直接用于语音 orb;**SwiftUIShaders / open-swiftui-animations** 可用于卡片浮现/breathe 动效。
- GitHub 现成 SwiftUI 车机:**dash_pilot**(glassmorphic 智能仪表,活跃开发中,Swift/iOS)+ relectric-car-team/user-interface(web/Node,含 climate mockup)。**native SwiftUI 不用于真车机**(真车跑 Android Automotive/Qt),demo 用 SwiftUI 反而是 MAformac 取巧合理处。
- source: 本机 `system_profiler` + `ls ref-repos` + https://github.com/mhutshow/dash_pilot | 2026-06-23 检索

## pre-mortem(tiger / paper-tiger / elephant)

### tigers(明确威胁,带验证清单)
- **T1 — 10 族 × 异构值形态用单一卡片样式会信息过载/无法表达**:温度(连续)、档位(离散)、RGB(颜色)、多维座椅(加热×通风×按摩)无法塞进同一个「亮/暗」卡片。验证:列出 10 族每族的 value.type,确认每类有对应 widget(slider/stepper/色环/分组),scheme1 现 7 态二值压绿/灰**已被证实不够**(DemoVisualState 7 态枚举撑不住连续值)。
- **T2 — 纯动态浮现(候选 B)冷启动空屏不惊艳**:语音驱动若主屏初始空白,客户进场第一眼无「科幻感」。验证:对照 MBUX「Zero Layer 常驻 + AI 浮现」=常驻骨架 + 浮现叠加,而非纯空屏;需设计 idle 态全景常驻(A+B 混合)。
- **T3 — 多意图连续两句 → 多卡片同时浮现的视觉混乱**:「放首歌、空调调低」两卡片同时 pop 可能抢戏/时序乱。验证:参照「micro-animation scrolling cards 高亮 previous action」,做**错峰浮现**(150-300ms 间隔)+ 视线引导,而非同帧弹出。

### paper-tigers(看似威胁实际安全,给证据)
- **P1 — 「真车机用 Android Automotive/Qt,SwiftUI 不专业」**:证据 = native SwiftUI 确实不用于量产车机,但 MAformac 是**端侧 demo 非量产**,SwiftUI 取巧合理;dash_pilot 等 SwiftUI 智能仪表 demo 存在。展示效果取决于设计而非框架。**不是威胁**。
- **P2 — 「现场只说 10 族,展示要全 191 device」**:证据 = U13 已拍卡片按 10 族 family_card_id(族级非 191 device 级),MBUX 也是常驻少数 + AI 浮现 20 个,**无车机一次平铺上百控件**。族级卡片 + 下钻是行业共识,**不是威胁**。
- **P3 — 「分区式更安全所以 MAformac 必须分区」**:证据 = 分区式的「位置记忆/降分心」价值是给**驾驶中真车**的(NHTSA 2 秒/12 秒);MAformac 是**销售演示非驾驶**,方案经理主动说话触发,安全约束不适用。分区可借其「视觉秩序」但不必为安全照搬。

### elephants(没人提但该提)
- **E1 — 🔴 投屏到客户大屏的暗底渐变 banding(深空辉光暗底的致命隐患)**:MAformac 视觉语言锁定深空暗底(#0a0b12)+ 辉光渐变,但**暗色渐变在投影仪/大屏 8-bit + HDMI 上极易 banding**(人眼对暗部色阶最敏感,Weber-Fechner;高对比投影放大 100x)。HDMI 2.0 静默降 8-bit、16-235→0-255 range 失配都会产生条带。**修法 = UI 内置 per-pixel 细噪声 dithering(最有效)+ 确保 Full RGB range + 优先 HDMI 2.1/DP**。这是与「全局 aesthetic-first-principles 5 Gate + 飞书白皮书暗底丑教训」**同源的展示层炸雷**——验收必还原客户实际投屏环境,不看自己 Mac 屏。source: https://forums.blurbusters.com/viewtopic.php?t=927 + https://us.ktcplay.com/blogs/technology-hub/monitor-bit-depth-causes-banding
- **E2 — 多屏联动是真车机高赞功能但 MAformac 双屏(Mac+iPhone)未规划联动**:理想「滑动调温→主驾屏同步」被赞;MAformac iPhone「加分屏」若只是镜像而无联动(如 Mac 浮现卡片时 iPhone 同步高亮/补充信息),浪费双屏炸场机会。该把双屏当**协同舞台**(Mac 主控车控卡片,iPhone 显对话流/orb 特写)设计。
- **E3 — 语音 orb 的「三态」未必映射到 demo 真实链路状态**:F6 指 listening/processing/confirming 三态是信任关键,但 MAformac 端侧链路有 ASR→意图→ToolCall→DemoGuard→mock state 多段(C3 五段 trace),orb 若只两态(脉冲/静止)无法表达「正在思考/已确认」。该把 orb 状态机对齐链路阶段(聆听=ASR / 思考=LLM 推理 / 确认=卡片浮现),demo「反应快」的体感正来自三态清晰过渡。

## adopt 候选(repo/skill/组件 + 证据 + 落点)

- **itsyhome-macos**(ref-repos 已 clone,2026-06-22 更新)— HomeKit 风格 macOS 卡片网格控制智能设备,**最近的「多设备卡片控制」类比**,可借其卡片网格 + 设备态展示结构。file: `/Users/wanglei/workspace/raw/05-Projects/MAformac/ref-repos/itsyhome-macos/`
- **Orb**(ref-repos 已 clone,2026-06-22)— SwiftUI orb 动效组件,**直接用于 MAformac 语音 orb**(三态:待命/聆听 pulse/思考)。file: `/Users/wanglei/workspace/raw/05-Projects/MAformac/ref-repos/Orb/README.md`
- **SwiftUIShaders + open-swiftui-animations**(ref-repos 已 clone,2026-06-22)— 卡片 breathe/pop 浮现动效 + 深空辉光 shader;**E1 dithering 噪声可作 shader 实现**(投屏防 banding)。file: `.../ref-repos/SwiftUIShaders/` + `.../ref-repos/open-swiftui-animations/`
- **dash_pilot**(github.com/mhutshow/dash_pilot)— glassmorphic SwiftUI 智能仪表,**活跃开发中**,可参照其 glassmorphic 车控卡片形态(需核 star/pushedAt 新鲜度后再 adopt)。[待核 star/pushedAt]
- **范式 adopt(非 repo)**:① MBUX「Zero Layer 常驻 + AI 浮现」→ 主视图 A+B 混合骨架 ② 理想「L 型 Dock 栏分区 + 横向滑卡」→ Mac 横屏布局 ③ Tesla「拖拽手势 + 底部栏快捷」→ 异构 widget 交互 ④ VUI「说+显 dual-modality + 三态指示」→ orb + 卡片浮现确认机制。
