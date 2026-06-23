PYTHON_BOOTSTRAP ?= python3
PYTHON := .venv/bin/python
PIP := .venv/bin/pip
GENERATED_CONTRACTS := \
	contracts/semantic-function-contract.jsonl \
	contracts/semantic-followup-transitions.jsonl \
	contracts/semantic-quarantine.jsonl \
	contracts/function-spec-full.yaml \
	contracts/semantic-coverage-report.md

# generated/ domain 产物(A2 S0+): family allowlist + flat device-map; 显式纳入 diff gate(补 generated/ 裸奔漏点).
# S1 D-domain 具名工具目录产物后续追加此变量.
GENERATED_DOMAIN := \
	generated/family-device-allowlist.json \
	generated/10-family-device-map.json

.PHONY: verify verify-generated regen regen-tool-contract verify-source verify-refs verify-cross-section diff test clean-venv

.venv/.deps.stamp: scripts/requirements.txt
	$(PYTHON_BOOTSTRAP) -m venv .venv
	$(PIP) install --upgrade pip
	$(PIP) install -r scripts/requirements.txt
	touch .venv/.deps.stamp

verify: .venv/.deps.stamp verify-source regen verify-refs verify-cross-section diff test

# pG1 §35 文档级联 cross-section（基线文档组段间一致性, 纯 stdlib 不需 venv/raw）
verify-cross-section:
	$(PYTHON_BOOTSTRAP) scripts/cross_section_check.py

# source-free: 只校验已提交产物(JSONL/YAML/coverage/state-cells/manifest)自洽与引用,
# 不依赖 raw xlsx 快照(别人 clone 仓无 snapshot 也能验契约). verify-refs 只读 manifest+committed, 不读源表.
verify-generated: .venv/.deps.stamp verify-refs test

# 合成脏行 fixture: 坐实 quarantine 逻辑生效(source-free, 不需 raw 快照)
test: .venv/.deps.stamp
	$(PYTHON) scripts/test_quarantine.py
	$(PYTHON) scripts/test_fc_flags.py

verify-source: .venv/.deps.stamp
	$(PYTHON) scripts/freeze_snapshot.py --check

regen: .venv/.deps.stamp
	$(PYTHON) scripts/gen_c1.py
	$(PYTHON) scripts/gen_tool_contract.py --contract contracts/semantic-function-contract.jsonl --output-dir generated
	$(PYTHON) scripts/gen_family_allowlist.py --emit --output-dir generated

regen-tool-contract: .venv/.deps.stamp
	$(PYTHON) scripts/gen_tool_contract.py --contract contracts/semantic-function-contract.jsonl --output-dir generated

verify-refs: .venv/.deps.stamp
	$(PYTHON) scripts/verify_refs.py

# 手写契约(非生成), 纳入 diff 防未提交漂移; 不进 regen。risk-policy/demo-scenarios 2026-06-20 补入(审计:别让 reviewed 候选伪装闭合)
HANDWRITTEN_CONTRACTS := contracts/state-cells.yaml contracts/l1-demo-allowlist.yaml contracts/risk-policy.yaml contracts/demo-scenarios.yaml

diff:
	git diff --exit-code -- contracts/source-snapshot-manifest.yaml $(GENERATED_CONTRACTS) $(GENERATED_DOMAIN) $(HANDWRITTEN_CONTRACTS) scripts Makefile

clean-venv:
	rm -rf .venv
