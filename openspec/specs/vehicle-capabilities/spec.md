# vehicle-capabilities Specification

## Purpose
TBD - created by archiving change define-capability-contract. Update Purpose after archive.
## Requirements
### Requirement: 车控能力契约已迁移至 C1/C2(本能力降为指针)

旧扁平 8 能力被全部 REMOVE 后,`vehicle-capabilities` 能力 SHALL 仅作为指向新事实源的指针:其行为契约全部由 `semantic-function-contract`(C1,源行级全集语义 SSOT)与 `scenario-state-protocol`(C2,场景端态)承载。下游消费方(模型/规则/UI/eval/LoRA 数据)MUST 引用 C1/C2,不得再以扁平 `capabilities.yaml` 为事实源。

#### Scenario: 下游查询车控能力的行为契约

- **WHEN** 任意下游产物需要车控能力的行为契约
- **THEN** 解析对象为 `semantic-function-contract`(C1)+ `scenario-state-protocol`(C2)
- **AND** 旧扁平 8 能力 `capabilities.yaml` 不作为事实源(仅历史参考)

