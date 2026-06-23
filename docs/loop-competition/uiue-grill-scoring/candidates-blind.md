# UIUE 30 设计决策 — 独立评估提案集（盲评 input，假装从未评估过）

> 这是 MAformac demo 的 30 个前端 UI 设计决策提案，**请当作从零独立评估**（不预设它们对或错）。逐个判断质量、可行性、是否有更好方案、是否有漏洞，给 5 维打分。
> 🔴 **必须本地核 + 联网核，不准纸面打分**：
> - 本地核：grep/Read 仓内 `App/ContentView.swift` / `Core/State/DemoVehicleStateStore.swift` / `contracts/state-cells.yaml` / `docs/design/{tokens.md,hig-liquid-glass-rules.md}` / `prototypes/scheme1-deep-space-interactive.html` / `docs/research/2026-06-23-uiue-10family-presentation/lens*.md`
> - 联网核：WebSearch 事实（SwiftUI API 版本可用性 / 车机 HMI 范式 / 组件 star+活跃度 / iOS/macOS 行为坑 等）

## 项目背景（评估上下文）
- MAformac = 纯端侧 macOS+iOS、完全离线、Qwen3-1.7B+LoRA 大脑、mock 车控的「方案演示助手」，给方案经理客户现场 5min 销售演示语音控车。北极星=听懂中文/反应快/不崩/看着惊艳/断网也能跑。
- 视觉语言已锁：深空辉光暗底科幻车机风（base #0a0b12 + cyan #00e5ff + violet #7b5cff），三屏分层（语音 orb / 对话流 / 车控卡片），纯 SwiftUI iOS17+/macOS14+ 部署、iOS26/macOS26 SDK，零依赖离线。
- 10 族=空调/座椅/车窗/车门/灯光氛围/屏幕/音量/雨刮/天窗遮阳/香氛；每族多 device（全集 191）+ 异构值（温度连续 18-32 / 档位 1-10 / RGB / 开度 0-100% / 座椅多维加热×通风×按摩 / 开关）。
- 语音驱动（方案经理说话触发，非手指浏览）；Mac 主舞台 + iPhone。

## 评估打分（每候选 5 维，1-5 分）
- **Importance** 命中实质决策/风险/失败路径吗
- **Verifiability** 能物理证实/证伪吗（本地 file / 联网事实）
- **Non-duplication** 与其他候选区别度
- **Decision Leverage** 逼出有用承诺/优先级吗
- **Risk Revelation** 暴露隐藏/高成本/易漏风险吗
- 另给：**反对意见 / 更好方案 / 漏洞**（独立判断，发现问题直说）

---

## 候选清单（C1-C30）

### 主视图形态
- **C1** 开场第一帧 = orb 呼吸 1-2s → 全 10 族网格 reveal 扫一遍 → idle dim 待命
- **C2** 多意图聚焦 = 序列化高亮联动（非同时闪），多卡只高亮不展开，单意图才展开细控
- **C3** 未触发的 dim 族 = 保持极弱呼吸微光（非死灰）+ 语音"全部展示"彩蛋
- **C4** 双屏架构 = Mac + iPhone 两个独立纯端侧 demo 实例（各自跑模型+ASR+10族），iPhone 脱机能独立全功能演示，双屏 LAN 联动为可选加分
- **C5** 主视图形态 = 全景常驻（10 族 dim 网格证明能力广度）+ 触发聚焦（语音触发族卡放大）

### 族内下钻
- **C6** 展开触发 = 语音为主（"空调26度"展开+设值一步）+ tap 为辅，两路走同一入口
- **C7** 展开布局 = 原地放大成中卡 + 全景 blur 背景（非全屏 modal）
- **C8** 子 device 展示 = 每族展开显 3-4 高频子 device（按线上优先级），超过用二级分区
- **C9** 展开并发 = 同时只展开 1 族，全景其他族 blur+dim
- **C10** 折叠 vs 平铺 = 族卡折叠（191 device 不平铺）+ 族卡角标显子能力数 + 语音可直达任意 device

### 异构值可视化
- **C11** 值分发 = value.type 统一 enum+switch（连续/离散档/RGB/开关/多维 5 类），从 state-cells 数据派生
- **C12** 控件缺口 = 座椅多维 + RGB 色环自建，其余用原生（温度/开度→Gauge 环 / 档位→分段 / 开关→toggle）
- **C13** shader 性能 = 氛围灯色带+水波 shader 仅氛围层非常驻 + GPU 协调器与模型推理错峰互斥
- **C14** 卡片骨架 = 骨架统一（标题/数值/状态同位同字号），只值可视化区按 value.type 变
- **C15** 分发实现 = enum+switch（编译穷尽），非每族完全自定义 view、非 AnyView

### 双屏细节
- **C16** iPhone 内容 = 独立全功能（自己的 orb+10族+对话+语音），竖屏适配，非镜像 Mac
- **C17** 跨屏方式 = iPhone 独立不依赖 Mac + 双屏走 Bonjour/Network framework LAN 可选联动（不用共享文件镜像）
- **C18** iPhone 竖屏布局 = 759pt 三屏分层（orb 120 / 内容 440 / mic 80）+ iPhone 接语音独立 ASR
- **C19** 断连降级 = iPhone 独立无断连概念（自包含）+ 双实例各自能独立炸场
- **C20** 双屏定位 = iPhone 不极简，是独立全功能端侧 demo（脱机可演）

### 聚焦过渡技术
- **C21** 过渡 API = 状态切换 matchedGeometryEffect（@Namespace+isExpanded），不用跨栈 navigationTransition.zoom
- **C22** 网格容器 = 10 族固定集合用 Grid（非 LazyVGrid），规避 matchedGeometry 懒渲染 source 未挂载冲突
- **C23** 兜底动画 = matchedGeometry 不可用时用 opacityScale+边框辉光+内容淡入+一次性 ripple 兜底
- **C24** 过渡时长 = 聚焦展开 320ms，多意图 stagger 220ms（两个独立参数防竞态）
- **C25** 升级门 = 默认 opacityScale + matchedGeometry 经编译验证（macOS 可用+无抖闪+ReduceMotion fallback）后才升级

### 炸场高潮
- **C26** shader 选型 = orb MeshGradient + ripple 水波 + 氛围灯 Sinebow，每个 shader 必有低版本 fallback
- **C27** wow 编排 = 4 段序列化（氛围灯开场→单点聚焦→多意图联动→断网高潮 morph），走 sequencer + 合同回放
- **C28** TTS 时序 = 端侧 AVSpeechSynthesizer + 视觉动效先于/同步 TTS（不等 TTS 完）+ immediate ack 掩盖首音延迟
- **C29** 断网高潮 = 顶栏在线 cyan→离线琥珀 morph + "100%端侧·0网络"徽章 + 全族卡断网保持响应
- **C30** 炸场 vs 稳 = 稳定优先于炸场（特效与模型推理错峰 + ReduceMotion/低电量双通道 + thermal watchdog）
