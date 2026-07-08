export const meta = {
  name: 'macos-uiue-methodology-research',
  description: '联网调研 macOS App 前端 UI/UE 开发方法论：多角度扫描 + 引用核验 + 中文综合报告',
  phases: [
    { title: '扫描', detail: '6 路联网角度 + 1 路本地基线并行搜证', model: 'opus' },
    { title: '核验', detail: '抽查各路引用来源真实性(WebFetch 实访)', model: 'opus' },
    { title: '综合', detail: '合并去重,产出中文方法论综合报告', model: 'opus' },
  ],
}

const FINDINGS_SCHEMA = {
  type: 'object',
  required: ['angle', 'summary', 'findings'],
  properties: {
    angle: { type: 'string' },
    summary: { type: 'string', description: '本角度 5-10 句中文摘要' },
    findings: {
      type: 'array',
      items: {
        type: 'object',
        required: ['claim', 'source_url', 'source_title'],
        properties: {
          claim: { type: 'string', description: '一条具体方法论/实践断言,中文' },
          source_url: { type: 'string' },
          source_title: { type: 'string' },
          fetched: { type: 'boolean', description: '是否已用 WebFetch 实际打开过该 URL' },
          notes: { type: 'string' },
        },
      },
    },
  },
}

const VERIFY_SCHEMA = {
  type: 'object',
  required: ['angle', 'checked', 'dead_or_fabricated', 'verdict'],
  properties: {
    angle: { type: 'string' },
    checked: { type: 'array', items: { type: 'object', required: ['url', 'ok'], properties: { url: { type: 'string' }, ok: { type: 'boolean' }, note: { type: 'string' } } } },
    dead_or_fabricated: { type: 'array', items: { type: 'string' } },
    verdict: { type: 'string', enum: ['CLEAN', 'MINOR_ISSUES', 'UNRELIABLE'] },
  },
}

const COMMON = `你是调研 finder。任务背景:MAformac 项目(纯端侧 macOS SwiftUI 演示助手,主演示面已定为 macOS,后续要做 UIUE 前置化)。
要求:
- 先用 ToolSearch 加载 WebSearch 和 WebFetch,然后联网搜索。
- 每条 findings 的 claim 必须来自你真实打开(WebFetch)或搜索摘要确认过的来源;禁止凭记忆编造 URL、数字、版本号。能 WebFetch 的关键来源尽量实访,并把 fetched 标 true。
- 优先 2024-2026 的新资料(Liquid Glass / macOS 26 时代),老经典(HIG 长期原则、Nielsen 启发式)也可收但注明。
- 输出全部用中文(URL/API 名/专有名词保留英文)。
- 8-15 条高质量 findings,宁缺毋滥。
调研角度:`

phase('扫描')

const ANGLES = [
  { key: 'apple-official', prompt: COMMON + 'Apple 官方视角——macOS Human Interface Guidelines 最新结构与核心原则、Liquid Glass 设计语言(适用范围/迁移建议)、Apple Design Resources(Figma/Sketch 模板)、近两年 WWDC 中与 macOS App 设计/SwiftUI UI 开发相关的关键 session 要点。' },
  { key: 'swiftui-arch', prompt: COMMON + 'SwiftUI macOS 工程方法——UI 层架构选型(纯 MV / MVVM / TCA 等)在 macOS App 中的实践与争论、Xcode Previews 预览驱动开发工作流、组件化与 design tokens 在 SwiftUI 的落地方式、多窗口/菜单栏/Settings scene 等 macOS 特有 UI 结构的开发方法。' },
  { key: 'design-process', prompt: COMMON + '设计流程方法论——design system 从零构建流程、Figma(或其他工具)→ SwiftUI 的 handoff 工作流、低保真→高保真原型迭代方法、design sprint/双钻模型等通用方法论在桌面端 App 的裁剪应用、solo 开发者/小团队的轻量设计流程。' },
  { key: 'usability-review', prompt: COMMON + '可用性与 UIUE 评审——Nielsen 启发式评估及桌面端应用、macOS 特有交互质量维度(键盘快捷键、菜单栏、拖拽、多窗口、指针悬停)、可访问性(VoiceOver/键盘导航/Dynamic Type/对比度)验收方法、UI 走查(design review/UI audit)的 checklist 化方法、demo 场景下"惊艳感"的评估维度。' },
  { key: 'benchmark-apps', prompt: COMMON + '业界标杆拆解——公认设计优秀的 macOS App(如 Things、Craft、Raycast、Sketch、Linear/Arc 桌面端等)的设计拆解文章、这些团队公开分享的设计/前端方法论(博客/访谈/talk)、从中可提炼的 macOS 原生感(platform-native feel)要素清单。' },
  { key: 'ai-assisted', prompt: COMMON + 'AI 辅助 UI 开发工作流——用 LLM/agent 生成与迭代 SwiftUI 界面的方法(截图驱动迭代、snapshot 对比、agent 自动评审 UI)、AI 时代的 design-to-code 工具链现状、这类工作流的已知坑(幻觉 API、风格漂移)与对策。' },
]

const localBaseline = agent(
  `读取本仓库 macOS 构建/设计相关的本地基线资料,不联网:
1) Tools/agent-platform-plugin-refs/ 下 build-macos-apps 相关的 SKILL.md 与 references(先 ls 看结构再挑重点读);
2) docs/ 下与 UIUE 相关的既有决策(可 grep "UIUE" docs/ 快速定位,重点看 roadmap-2026-07-07-macos-closure-baseline.md 中 UIUE 相关段落)。
输出中文:本地已有哪些 macOS UI 开发方法论资产、已锁的 UIUE 相关决策/约束、外部调研应该补什么缺口。findings 的 source_url 用本地文件路径(file:line)。`,
  { label: 'local-baseline', phase: '扫描', schema: FINDINGS_SCHEMA, model: 'opus', effort: 'medium' }
)

const sweepResults = await pipeline(
  ANGLES,
  (a) => agent(a.prompt, { label: `finder:${a.key}`, phase: '扫描', schema: FINDINGS_SCHEMA, model: 'opus', effort: 'medium' }),
  (found, a) => {
    if (!found || !found.findings || !found.findings.length) return { found, verify: null }
    const top = found.findings.slice(0, 4).map(f => `- ${f.source_title}: ${f.source_url}\n  声称: ${f.claim}`).join('\n')
    return agent(
      `你是引用核验员。用 ToolSearch 加载 WebFetch(必要时 WebSearch),逐条实访下列 URL,判断:URL 是否可达、页面内容是否真的支持对应声称(标题/主题对得上即可,不苛求逐字)。对打不开或内容对不上的,记入 dead_or_fabricated。输出中文。\n\n角度: ${a.key}\n${top}`,
      { label: `verify:${a.key}`, phase: '核验', schema: VERIFY_SCHEMA, model: 'opus', effort: 'medium' }
    ).then(v => ({ found, verify: v }))
  }
)

const local = await localBaseline
const valid = sweepResults.filter(Boolean)
log(`扫描完成: ${valid.length}/6 路联网角度返回, 本地基线 ${local ? '已到' : '缺失'}`)

phase('综合')

const corpus = JSON.stringify({
  local_baseline: local,
  web_angles: valid.map(r => ({ findings: r.found, verification: r.verify })),
})

const report = await agent(
  `你是综合官。下面是 7 路调研的结构化结果(6 路联网角度各带一份引用核验 verdict,1 路本地基线)。请写一份中文综合报告《macOS App 前端 UIUE 开发方法论调研》,markdown 格式,要求:
1. 结构建议:TL;DR(≤10行) / 方法论全景(按"设计原则→设计流程→工程实现→评审验收→AI辅助"组织,而非按 finder 分路堆砌) / 对 MAformac 的适配建议(结合本地基线:纯端侧 SwiftUI demo、solo 轻治理、北极星=现场5分钟惊艳不崩) / 关键来源清单。
2. 只引用核验 verdict 非 UNRELIABLE 的来源;被标 dead_or_fabricated 的 URL 一律不得出现。每条关键断言后附来源链接。
3. 交叉去重,冲突观点并列注明。
4. 全文中文,专有名词/API/URL 保留英文。直接返回 markdown 全文,不要寒暄。

调研原料(JSON):
${corpus}`,
  { label: 'synthesize', phase: '综合', model: 'opus', effort: 'medium' }
)

return { report, stats: { angles_returned: valid.length, local_baseline: !!local } }