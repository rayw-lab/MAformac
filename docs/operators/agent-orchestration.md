# Agent orchestration operator entry

本页只保存稳定的 operator 分流原则，不记录具体模型、provider、pane、PID、主机路径或当次运行状态。

- 默认由一个 controller 负责读 live truth、拆依赖、分配不重叠写集、整合与终判。
- controller 优先编排；极小、低风险、可逆且不会造成 ownership 冲突的修复可直接完成。
- 是否启用多 agent、跨厂商、tmux 或持久 worker，由任务依赖、写集、恢复需求和 fan-in 成本决定，不按可用席位凑并发。
- 具体模型/provider/命令只写入本机 profile 或单次任务合同；项目文档不固定这些动态值。
- 收稿以文件、diff、命令输出和 readback 为准。共享写面保持单 owner；最终 verdict 由 controller 基于 fresh evidence 给出。

需要恢复某次 operator session 时，只读该次 run-dir/receipt/handoff 的显式链，并重新探测 live process/runtime；不得复用本页推断动态状态。
