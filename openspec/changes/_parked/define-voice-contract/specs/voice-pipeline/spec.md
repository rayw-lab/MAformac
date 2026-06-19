## ADDED Requirements

### Requirement: ASR 只产文本与置信
语音识别 SHALL 只输出文本 + 置信度,SHALL NOT 判断意图 / 槽位 / 热词归属。

#### Scenario: ASR 不越界
- **WHEN** 一段语音被识别
- **THEN** 输出文本 + 置信度,不含意图 / 槽位判断

### Requirement: push-to-talk 松手即端点
系统 SHALL 以 push-to-talk 交互(按住录音、松手结束),松手即端点,不依赖自动语音端点检测;**最终文本 SHALL 为松手后对整段录音的识别结果**(录音期预览不作最终)。

#### Scenario: 松手出整段最终文本
- **GIVEN** 用户按住说完一句
- **WHEN** 松手
- **THEN** 系统对整段录音识别出最终文本,录音期预览不进入意图理解

### Requirement: 文本归一化为独立层
系统 SHALL 在 ASR 与意图理解之间设独立归一化层,输出原文 / 归一化文本 / 改写轨迹 / 置信修正;意图理解 SHALL 只吃归一化文本,原始口语只留痕。

#### Scenario: 归一化产出可追溯
- **WHEN** ASR 出文本
- **THEN** 归一化层输出原文 + 归一化文本 + 改写轨迹,意图理解只用归一化文本

### Requirement: 幻觉与近静音拒识
系统 SHALL 拒识近静音 / 超短录音触发的幻觉文本(如训练语料字幕类短语);命中幻觉特征 SHALL 转拒识或澄清,SHALL NOT 当正常指令执行。

#### Scenario: 短指令幻觉被拒
- **WHEN** 近静音或超短录音产出训练语料字幕类短语
- **THEN** 系统拒识,不执行

### Requirement: 置信拦截区分识别置信与意图模糊
系统 SHALL 区分「ASR 识别低置信」(转澄清、不交 LLM)与「ASR 高置信但意图模糊」(交 LLM 推理);低识别置信 SHALL NOT 交 LLM 合理化错字。

#### Scenario: 低识别置信不交 LLM
- **WHEN** ASR 识别置信低
- **THEN** 系统转澄清,不交 LLM

#### Scenario: 高置信模糊意图走 LLM
- **WHEN** ASR 高置信但意图模糊
- **THEN** 系统交 LLM 推理,不被「仅明确指令才继续」挡住

### Requirement: TTS 只播报且可中断
语音合成 SHALL 只播报(操作对象 + readback 结果),可被中断;SHALL NOT 参与车控判断或读车控状态。

#### Scenario: TTS 可被打断
- **GIVEN** TTS 正在播报
- **WHEN** 用户触发打断
- **THEN** TTS 立即停止,回到录音

### Requirement: 录音与播报会话互斥
系统 SHALL 串行处理录音与播报(不并发同一音频会话),避免会话冲突。

#### Scenario: 录播不并发
- **WHEN** 系统在录音
- **THEN** 不同时播报(反之亦然)

### Requirement: 语音链路离线可用
语音链路 SHALL 全程在无网络下工作。

#### Scenario: 断网识别播报
- **GIVEN** 飞行模式
- **WHEN** 用户发出语音指令
- **THEN** ASR + 归一化 + TTS 全程无网络依赖
