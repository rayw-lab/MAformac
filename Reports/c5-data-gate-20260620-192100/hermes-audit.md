# P1-A C5 数据门全维度审计报告

## 审计范围
- OpenSpec 契约一致性
- 数据污染防护（C6 must_pass 泄漏）
- raw/PII 泄漏检查
- receipt 可复跑性
- 验收门充分性
- 状态诚实性

---

## 审计发现

### P0: 关键问题
**无**

### P1: 重要问题
**无**

### Important: 需要关注的问题
| 发现 | 文件位置 | 描述 |
|------|----------|------|
| masking 覆盖未包含三形态 | `Reports/c5-data-gate-20260620-192100/c5-data-gate-receipt.json:11-19` | receipt 中的 masking_coverage 全部为 false，未体现 Hammer 三形态（function_name、argument_name、argument_value）。当前 C5 数据门只作为验证器不生成数据，此状态为预期，但需在 closeout 中明确说明 masking 是 P1-C LoRA 数据生成阶段的责任。 |

### Nit: 小问题
| 发现 | 文件位置 | 描述 |
|------|----------|------|
| tasks.md 未完成 | `openspec/changes/define-lora-data-gate/tasks.md:23-27` | 4.2-4.5 未完成，包括 Hermes 审计、修复问题、重新验收、写 closeout。这是当前任务，预期行为。 |

---

## 验收检查

### ✅ OpenSpec 契约一致性
- `openspec validate define-lora-data-gate --strict`: 通过
- `openspec validate --all --strict`: 通过

### ✅ 数据污染防护
- `must_not_train_violations: 0`
- `train_parent_semantic_overlap: 0`
- C6 must_pass 集被正确标记为 `must_not_train` 且未进入 train split

### ✅ raw/PII 泄漏检查
- raw 目录只读访问
- receipt 只包含哈希和计数，无原始数据
- redaction_status: pass，敏感词检查通过

### ✅ receipt 可复跑性
- 包含完整的 receipt_version、format_contract_version、source_snapshot_digest
- 无 `auto_apply: true` 标记
- 所有字段完整

### ✅ 验收门充分性
- status: `data_gate_ready`（**未声称 `train_ready`**）
- 硬门全部通过：must_not_train_violations=0，train_parent_semantic_overlap=0，tool_call_format_failures=0，redaction_status=pass
- split_whitelist 正确包含 c6_base

### ✅ 状态诚实性
- bucket_counts: train=2320，heldout=1200，must_pass=30，quarantine=120
- row_count=3670，符合预期（2320+1200+30+120=3670）
- source_authorization_status: `authorized_existing_raw_closeout`，明确说明来源

---

## 硬约束检查（CLAUDE.md & 项目宪法）

✅ **只做 C5 数据门，不做 LoRA 训练**  
✅ **未声称 `train_ready`，只说 `data_gate_ready`**  
✅ **raw 目录只读**  
✅ **C6 must_pass 集未进入 train split**  
✅ **proposed_fix.auto_apply=false**  

---

## 结论

**审计状态：PASS**

C5 数据门实现完全符合 OpenSpec 契约，数据污染防护有效，无 raw/PII 泄漏，receipt 可复跑，验收门充分，状态诚实。唯一的 masking 覆盖问题是预期的，因为当前 C5 只是验证器，masking 是 P1-C LoRA 数据生成阶段的责任。
