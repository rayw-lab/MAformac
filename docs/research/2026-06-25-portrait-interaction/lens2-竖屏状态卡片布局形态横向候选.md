# 竖屏状态卡片布局形态横向候选

> 一手 finder full_markdown（ultracode 三层一手性）

（finder full_markdown 为空/失败，下方为结构化 findings/candidates）

{
  "summary": "7 种竖屏卡片布局横扫。最优=外层固定三 zone(候选七 D6)+下层固定全景 idle+活跃族 bento spatial-weight 原地放大(候选三)。详见 findings。",
  "findings": [
    {
      "point": "固定布局 favors spatial memory，reorder 破坏但 sub-300ms slide 缓解，支撑 D1 全景常驻加活跃置顶（决策最关键）",
      "detail": "稳定 placement 建 mental map 降认知负荷，reorder 须小于 300ms slide，working memory 仅 3-5 项需 spatial weight 分主次。",
      "source": "smashingmagazine.com 2025-09 加 ixdf.org 2026",
      "heat": "Smashing 2025-09"
    },
    {
      "point": "Home Assistant 2026.1 mobile summary-cards-to-top 是活跃置顶 prior-art（候选二活跃置顶 demo4 须 sub-300ms slide 建议放大替置顶）",
      "detail": "HA 2026.1 mobile summary cards 置顶替代旧 tab 加 drag-drop reorder mobile 置顶 vs desktop 侧栏。",
      "source": "home-assistant.io blog 2026-01-07 加 2025-12-03",
      "heat": "HA 2026-01"
    },
    {
      "point": "特斯拉固定区分 zone，小鹏 AIOS6.0 卡片灵境桌面，蔚来竖屏对视频不友好（候选七固定三 zone D6 demo5 容器骨架）",
      "detail": "Tesla 顶状态中地图底气候持久条不滚走 Euro NCAP 2026。候选七 759pt orb120 content440 mic80 车控受挤 10 族 2 列须约 440pt 内同屏或可控滚动。",
      "source": "tesla.com model3 2026.14 加 Euro NCAP 2026 加 ithome.com 914 652",
      "heat": "Tesla 2026.14"
    },
    {
      "point": "Apple Home tile resize spatial-weight 加 group 折叠默认固定（候选三固定全景 idle 加活跃族 bento 放大 demo5 主推）",
      "detail": "Home tile 默认固定可 resize spatial-weight 雏形加 Group 折叠。候选三 idle 守 spatial memory 活跃族放大成 hero 不移位零破坏优于候选二物理置顶加守 D5，cons 放大态 Grid 重排需 spike。",
      "source": "macrumors.com reorganize-home-view 加 orbix.studio bento-grid 2026",
      "heat": "Apple 加 Orbix 2026 引 NN g"
    },
    {
      "point": "sheet 加 detents 适 4b 下钻不适主骨架(demo1.5)；横滑分页对 10 族反模式藏 9 加双 UIScrollView 坑(demo0.5排除)；折叠 demo3 已内化",
      "detail": "sheet 遮挡 10 族全景不能主视图 4b 详情可用。TabView page 藏 9 毁 glanceability 加双 UIScrollView 坑排除。10 族已族级折叠 191 到 10 内化 UI 保持全展。",
      "source": "developer.apple.com presentationdetents 加 onmyway133.com paging-tabview",
      "heat": "Apple doc 加 HackingWithSwift"
    },
    {
      "point": "4a 纯均匀固定全景网格 iPhone 2 列 ScrollView 仅激活态 breathe = 候选一 demo4.5 骨架，GAP 五点",
      "detail": "ContentView.swift 117-265 固定列 Grid 守 D5。GAP 无 active-to-top vs D1/非固定三 zone vs D6/无 spatial-weight 炸场/候选二三活跃态布局 vs D5 离散稳定需 magnet 确认口径/候选四 sheet vs D2 in-place 4b 选型。",
      "source": "App ContentView.swift 117-265 本机坐实",
      "heat": "n/a 本机代码"
    }
  ],
  "candidates": [
    {
      "option": "见 findings",
      "pros": "t",
      "cons": "t",
      "fit_for_portrait_demo": "t"
    }
  ],
  "gaps": [
    "见 findings6"
  ]
}
