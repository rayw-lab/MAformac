# Brain 2 - Round 01

## Keep
- C01-C04：保留，作为 R0 返修收口和 proof boundary 的硬门。
- C17-C18：保留，作为 closeout 审计与 pathspec 隔离门。
- C20：保留，必须显式列出未修复风险，避免 fake green。
- C21-C24、C26-C30：保留，这组是 R1 交互真值门的核心。
- C32-C44：保留，这组主要是可验证的遮挡、a11y、测试与 proof 纪律。
- C47-C49：保留，避免 readback、proof class 和 formatter 漂移。
- C51-C61：保留，这组直接决定 R2 的 L0-L2 门和 harness 纪律。
- C62-C70：保留，作为 capsule / VPA / L3 closeout 的最终边界。

## Delete
- 暂不建议删除任何项。当前 70 项里没有明显的“无信息增量”条目，更多是应该合并或改写，而不是直接删掉。

## Merge
- C11 + C12：合并为 `ContextCapsule` 资产占位/最终艺术稿分离规则。
- C15 + C16：合并为 phone 顶部布局的单条 frame regression gate。
- C41 + C42：合并为 `verify-uiue-interactions` 的专门门定义。
- C45 + C50：合并为 iceberg teardown 与 interaction debt 挂账规则。
- C56 + C57：合并为 Layout Integrity Gate 及其覆盖面。
- C59 + C60：合并为 L0 capture harness 的字段完整性要求。
- C62 + C63：合并为 capsule proof 的 context 正确性与审美分层。

## Rewrite
- C05：改写为“先把 `cooling + ivory` 作为第一 blocker，再决定是否扩展旧 case”。
- C06：改写为外层摘要联动回归，而不是抽象的“模式切换回归”。
- C07：改写为 `AmbientColorPalette` 与 alias 映射的 contract-derived 复核。
- C19：改写为 prompt / handoff 规范，不要落成实现任务。
- C31：改写为 summary card primary touch 的语义拍板问题。
- C53：改写为“10 族代表矩阵必须先于 L0 截图执行”。
- C68：改写为 placeholder/final-art-deferred 的文档化要求。

## Missing Risks
- 没有单独点出 `accessibilityIdentifier` 重命名后的全局撞名检查。
- 没有单独点出 `ContextCapsuleRoute`、`ValueControlView` 和 UI test 之间的命名同步风险。
- 没有单独点出 evidence package 的命名和目录归属责任人。
- 没有单独点出 R2 失败时“只写发现、不改完成态”的回写纪律在文档层的落点。

## Scores
| Candidate | Importance | Verifiability | Non-duplication | Decision Leverage | Risk Revelation | Total |
|---|---:|---:|---:|---:|---:|---:|
| C01 | 5 | 5 | 4 | 5 | 5 | 24 |
| C02 | 5 | 5 | 4 | 5 | 5 | 24 |
| C03 | 5 | 5 | 5 | 5 | 5 | 25 |
| C04 | 5 | 5 | 5 | 5 | 5 | 25 |
| C05 | 4 | 4 | 4 | 4 | 5 | 21 |
| C06 | 4 | 4 | 4 | 4 | 5 | 21 |
| C07 | 4 | 4 | 4 | 4 | 5 | 21 |
| C08 | 5 | 5 | 5 | 5 | 5 | 25 |
| C09 | 4 | 4 | 4 | 4 | 4 | 20 |
| C10 | 4 | 5 | 4 | 4 | 4 | 21 |
| C11 | 4 | 4 | 2 | 4 | 4 | 18 |
| C12 | 4 | 4 | 2 | 4 | 4 | 18 |
| C13 | 4 | 4 | 4 | 4 | 5 | 21 |
| C14 | 4 | 4 | 4 | 4 | 4 | 20 |
| C15 | 4 | 5 | 4 | 5 | 5 | 23 |
| C16 | 4 | 5 | 4 | 5 | 5 | 23 |
| C17 | 5 | 5 | 5 | 5 | 5 | 25 |
| C18 | 5 | 5 | 5 | 5 | 5 | 25 |
| C19 | 3 | 3 | 4 | 3 | 4 | 17 |
| C20 | 5 | 5 | 5 | 5 | 5 | 25 |
| C21 | 5 | 5 | 4 | 5 | 5 | 24 |
| C22 | 5 | 5 | 4 | 5 | 5 | 24 |
| C23 | 5 | 4 | 4 | 4 | 4 | 21 |
| C24 | 5 | 4 | 4 | 4 | 4 | 21 |
| C25 | 4 | 4 | 3 | 4 | 4 | 19 |
| C26 | 5 | 5 | 5 | 5 | 5 | 25 |
| C27 | 5 | 5 | 5 | 5 | 5 | 25 |
| C28 | 5 | 5 | 5 | 5 | 5 | 25 |
| C29 | 5 | 5 | 5 | 5 | 5 | 25 |
| C30 | 5 | 5 | 5 | 5 | 5 | 25 |
| C31 | 4 | 4 | 4 | 4 | 4 | 20 |
| C32 | 5 | 5 | 4 | 5 | 5 | 24 |
| C33 | 5 | 5 | 5 | 5 | 5 | 25 |
| C34 | 5 | 5 | 5 | 5 | 5 | 25 |
| C35 | 5 | 5 | 5 | 5 | 5 | 25 |
| C36 | 4 | 4 | 4 | 4 | 4 | 20 |
| C37 | 5 | 5 | 5 | 5 | 5 | 25 |
| C38 | 5 | 5 | 5 | 5 | 5 | 25 |
| C39 | 5 | 5 | 5 | 5 | 5 | 25 |
| C40 | 4 | 4 | 4 | 4 | 4 | 20 |
| C41 | 5 | 5 | 4 | 5 | 5 | 24 |
| C42 | 5 | 5 | 4 | 5 | 5 | 24 |
| C43 | 5 | 5 | 5 | 5 | 5 | 25 |
| C44 | 5 | 5 | 4 | 5 | 5 | 24 |
| C45 | 4 | 4 | 3 | 4 | 5 | 20 |
| C46 | 5 | 5 | 4 | 5 | 5 | 24 |
| C47 | 5 | 5 | 5 | 5 | 5 | 25 |
| C48 | 5 | 5 | 5 | 5 | 5 | 25 |
| C49 | 5 | 5 | 4 | 5 | 5 | 24 |
| C50 | 4 | 4 | 3 | 4 | 4 | 19 |
| C51 | 5 | 5 | 5 | 5 | 5 | 25 |
| C52 | 5 | 5 | 4 | 5 | 5 | 24 |
| C53 | 5 | 5 | 4 | 5 | 5 | 24 |
| C54 | 5 | 5 | 4 | 5 | 4 | 23 |
| C55 | 5 | 5 | 4 | 5 | 4 | 23 |
| C56 | 5 | 5 | 4 | 5 | 5 | 24 |
| C57 | 5 | 5 | 4 | 5 | 5 | 24 |
| C58 | 5 | 5 | 5 | 5 | 5 | 25 |
| C59 | 5 | 5 | 5 | 5 | 5 | 25 |
| C60 | 5 | 5 | 5 | 5 | 5 | 25 |
| C61 | 5 | 5 | 4 | 5 | 5 | 24 |
| C62 | 4 | 4 | 4 | 4 | 5 | 21 |
| C63 | 4 | 4 | 4 | 4 | 5 | 21 |
| C64 | 5 | 5 | 4 | 5 | 5 | 24 |
| C65 | 5 | 5 | 4 | 5 | 5 | 24 |
| C66 | 5 | 5 | 4 | 5 | 5 | 24 |
| C67 | 5 | 5 | 4 | 5 | 5 | 24 |
| C68 | 4 | 4 | 4 | 4 | 5 | 21 |
| C69 | 4 | 5 | 4 | 4 | 4 | 21 |
| C70 | 5 | 5 | 4 | 5 | 5 | 24 |

## Candidate Notes
| Candidate | Note |
|---|---|
| C01 | 先用 `git status --short` 和 pathspec 锁 owned path，别把 commander docs 或其它 reviewer 产物混进去。 |
| C02 | 把交互修复、视觉阻断、lessons/baseline 拆成独立 commit，避免 proof class 混写。 |
| C03 | 8.C2 仍保持 open，`tasks.md` 只在 controller 复核后再动。 |
| C04 | 视觉验收 receipt 要写清 project path、scheme、simulator、xcresult，和 `xcodebuild` 结果对齐。 |
| C05 | 先把 `cooling + ivory` 作为第一 blocker，再决定是否扩旧 case。 |
| C06 | 将外层摘要联动补成 regression，落在 `ContentView` / `UIC2VisualAcceptanceUITests` 的读回断言。 |
| C07 | `AmbientColorPalette` 和 alias 映射要按 contract-derived options 复核。 |
| C08 | `ValueControlView` 的 toggle / badge 写回要和 summary readback 同步校验。 |
| C09 | `ContextCapsule.swift` 里 `vehicle.gear` 先保持只读语境，不要暗改成直接触控档位。 |
| C10 | 给 `primaryActionIdentifier` 加唯一性检查，防 UI test 误点元素。 |
| C11 | `ContextCapsule` 资产先按 placeholder 管理，最终艺术稿另走图像 review。 |
| C12 | 继续把 `ContextCapsule.imageset` 当占位图，别把当前裁切当 final art。 |
| C13 | 用 `testOrbPresetStatesExposeDistinctCaptionsAndStayContained` 卡住 orb 光晕高度和容器边界。 |
| C14 | 把 `DemoOrbView` 的四态 caption 映射写进 UI test，避免 speak / think 混文案。 |
| C15 | 把设置/刷新按钮是否压住 capsule 的 frame 断言保留在 `testPhoneTopBandControlsStayOutsideCapsuleAndAlignWithCards`。 |
| C16 | 端状态左右列首行对齐和列间距也继续由同一条 frame regression 覆盖。 |
| C17 | closeout 最小门直接写成 `swift test`、`xcodebuild`、`openspec validate --strict`、`git diff --check`。 |
| C18 | 独立只读审计要重新核 pathspec 和 dirty scope，避免旧 handoff 污染。 |
| C19 | GPT Image 2 和 anchor 图只进 prompt / handoff，不进实现代码。 |
| C20 | final-art、GPU 和 L3 仍写成未完成风险清单，别用测试通过替代。 |
| C21 | `StateCellInteractionPolicy` 应该是 consumer policy，不要长成第三份 SSOT。 |
| C22 | 在 `UIValueTypeMapper` 做 `ui_value_type` 派生，不在 View 里读 unit string。 |
| C23 | 10 族矩阵按 family、cell、gesture、writeback、readback、test 分列。 |
| C24 | 把 family coverage、value type coverage、gesture coverage 拆成三张表。 |
| C25 | 只读/演示态要去按钮语义，测试里验证没有假 affordance。 |
| C26 | 环形控件的 tap、drag、cross-zero、snap 统一走 `CircularControlGestureMapper`。 |
| C27 | stepper 条的左右点按和 scrub 继续挂 `StepperBarGestureLayer`。 |
| C28 | toggle 翻转必须走 contract enum pair，而不是统一 `on/off`。 |
| C29 | badge options 必须来自 contract-derived 列表，别把当前文本当唯一值。 |
| C30 | 颜色 swatch 语义色直接复用 `DesignTokens.ambientGradient(named:)`。 |
| C31 | 先拍板 summary card primary touch 是 expand-only 还是局部调节。 |
| C32 | overlay 遮挡风险继续靠 `ContentView` 的 top band 和展开层 frame 断言。 |
| C33 | `accessibilityIdentifier` 统一后加去重检查，避免坐标级 UI test 找错元素。 |
| C34 | 写回只能走 `DemoVehicleStateStore.applyMockTransition`，别在 View 内做局部状态 hack。 |
| C35 | store、expanded row、summary text、色语义三者同步要在同一条 UI test 链上验。 |
| C36 | 如果有 stagger 或 sequencer，就必须等稳定标记再读 tree。 |
| C37 | tap、long press、drag、adjustable 四类 proof 要分开落 case。 |
| C38 | Reduce Motion / Transparency 路径要在 `ContextCapsule`、orb 和 UI test 里同时落点。 |
| C39 | 44pt touch target 直接变成 frame / hit target 检查，不要只写原则。 |
| C40 | VoiceOver / a11y 替代入口要单独做 review 或 test，不能只靠视觉。 |
| C41 | `make verify-uiue-interactions` 或同等脚本应该落到 `Tools/checks/`。 |
| C42 | 专门门只跑稳定 unit/UI tests，不要混进人工 L3。 |
| C43 | 设备名固定 `iPhone 17 Pro Max`，失败时打印 frame 方便定位。 |
| C44 | 每条 interaction test 都补一个反例或边界断言。 |
| C45 | 小 bug 触发 iceberg teardown 时，把同 value type 和 gesture family 一起扩出去。 |
| C46 | `changing` 过程态规则要写进 `ContentView` 的 visualState 语义。 |
| C47 | 中文 title 和 contract id 的映射继续放进 `runVisualCase` 的 tree assertions。 |
| C48 | proof class 要写进 receipt，禁止把 simulator 结果写成人审。 |
| C49 | 禁止在 View 内再加第二套 formatter，靠 grep gate 或 review gate 卡住。 |
| C50 | interaction debt 只挂最近矩阵项，不单独散开新分支。 |
| C51 | R2 L0 case 先换成 `cooling + ivory`，再保旧 deepSpace 作为回归。 |
| C52 | `heating + ivory`、`safety_refusal + ivory` 等最小边界集要补齐。 |
| C53 | 10 族代表矩阵必须先于 L0 截图执行。 |
| C54 | L1 sentinel 只挡塌陷，不要把 RMSE/WARN 直接当审美结论。 |
| C55 | L2 OCR/contrast 继续保留，但不要替代遮挡、高级感和层级判断。 |
| C56 | Layout Integrity Gate 可以先落到 `Tools/checks/phase2_zone_compare.py` 同类 checker。 |
| C57 | `overlap_pairs`、`min_gaps`、`zone_budget`、`safe_area_violations` 都要出现在 checker 输入输出里。 |
| C58 | Visual Spacing Sentinel 必须输出 PASS/WARN/FAIL 和 crop 元数据。 |
| C59 | L0 capture 只认 on-screen `simctl io screenshot`，不许 Preview 或 ImageRenderer 替代。 |
| C60 | harness JSON 必须包含 launchArg、theme、device、tree、screenshot 和 proof_class。 |
| C61 | L2 summary checker 默认只读，只有 `--write-summary` 才能改包。 |
| C62 | 胶囊 5 个 context 状态先落测试 case，再决定最终艺术稿。 |
| C63 | context 正确性和 diorama 审美要分成两个 proof 层，不互相冒充。 |
| C64 | VPA / orb 四态可直接落到 `testOrbPresetStatesExposeDistinctCaptionsAndStayContained`。 |
| C65 | 米白和深空要分别验，确保米白不靠大辉光抢层级。 |
| C66 | L3 人审模板补上遮挡、留白、层级、手感、玻璃 artifact、状态表达六栏。 |
| C67 | L3 reviewer 先看截图和 crop，再看 UI tree 与 test result，避免自动绿锚定。 |
| C68 | placeholder / final-art-deferred 统一写进 lessons 或 closeout receipt。 |
| C69 | 失败时只回写 findings，不碰 `tasks.md` 完成态。 |
| C70 | R2 通过后先做只读审计，再进 R3 closeout。 |

## Rationale
`ContentView` 已经把舞台、顶栏胶囊、orb、对话、车控区和底部 mic 的边界拆清了，且手机端顶部按钮与胶囊的分离、Mac 分栏、展开层覆盖都已有代码入口，因此这轮更像“收口与防回归”，不是重做布局。见 [App/ContentView.swift](/Users/wanglei/workspace/MAformac-uiue/App/ContentView.swift#L66)、[App/ContentView.swift](/Users/wanglei/workspace/MAformac-uiue/App/ContentView.swift#L191)。

`ContextCapsuleView` 已经有 route gating、reduce motion、glass 壳、夜晚/雨天/行驶态分层和 crossfade 轨迹，所以 C11/C12/C62/C63/C68 更适合做资产边界和 proof 分层，而不是继续扩新视觉系统。见 [App/ContextCapsule.swift](/Users/wanglei/workspace/MAformac-uiue/App/ContextCapsule.swift#L24)、[App/ContextCapsule.swift](/Users/wanglei/workspace/MAformac-uiue/App/ContextCapsule.swift#L76)。

`ValueControlView` 已经实现穷尽 switch、dial/percent/stepper/toggle/badge 五类分支、`StepperBarGestureLayer`、contract-derived badge/mode 选择，以及稳定的 primary identifier，因此 C21-C35 的重点应是 contract 收口和测试入口，而不是发明新的控件层。见 [App/ValueControlView.swift](/Users/wanglei/workspace/MAformac-uiue/App/ValueControlView.swift#L36)、[App/ValueControlView.swift](/Users/wanglei/workspace/MAformac-uiue/App/ValueControlView.swift#L93)、[App/ValueControlView.swift](/Users/wanglei/workspace/MAformac-uiue/App/ValueControlView.swift#L170)。

`UIC2VisualAcceptanceUITests` 已经把 `cooling/deepSpace`、`heating/ivory`、capsule route、10 族展开、primary touch、环形 tap/drag、stepper、mode picker、summary readback 全都落成 case，所以 C41-C43、C59-C60、C64-C67 最适合保留为 verification gates。见 [MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift](/Users/wanglei/workspace/MAformac-uiue/MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift#L32)、[MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift](/Users/wanglei/workspace/MAformac-uiue/MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift#L195)。

`openspec/changes/ui-presentation/spec.md` 和 `tasks.md` 仍把 8.C2、7.A、7.B、8.A、8.C2 的关键项留在 open 状态，所以 C03/C17/C18/C20/C51/C70 必须显式保持在 closeout 和 audit 路径里，不能默认由“测试看起来过了”自动升格。见 [openspec/changes/ui-presentation/specs/ui-presentation/spec.md](/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/specs/ui-presentation/spec.md#L11)、[openspec/changes/ui-presentation/tasks.md](/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/tasks.md#L93)。
