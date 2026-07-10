PYTHON_BOOTSTRAP ?= python3
PYTHON := .venv/bin/python
PIP := .venv/bin/pip
PYTHON_TOKENIZER ?= python3.13
GENERATED_CONTRACTS := \
	contracts/semantic-function-contract.jsonl \
	contracts/semantic-followup-transitions.jsonl \
	contracts/semantic-quarantine.jsonl \
	contracts/function-spec-full.yaml \
	contracts/semantic-coverage-report.md

# generated/ domain 产物(A2 S0+S1): family allowlist + flat device-map + D-domain 具名工具目录(两层 scope)
# + 旧 surface(B_frame/D_domain.tools 守现状 S2 删) + strangler map; 全显式纳入 diff gate(补 generated/ 裸奔漏点).
GENERATED_DOMAIN := \
	generated/family-device-allowlist.json \
	generated/10-family-device-map.json \
	generated/B_frame.frame_schema.json \
	generated/D_domain.tools.json \
	generated/D_domain.tools.demo.json \
	generated/D_domain.tools.full.json \
	generated/d_domain_ir_map.json \
	generated/strangler_map.json \
	generated/rendered_tools_text \
	generated/subset-policy-manifest.json \
	generated/subset-grammar-artifacts.json

GENERATED_SWIFT := \
	Core/Contracts/DDomainIRMap.generated.swift

.PHONY: verify verify-all verify-ci verify-ci-receipt verify-c1-matrix verify-c1-fallback verify-c1-probes verify-c1-action-probes verify-c1-s10 verify-mounted-catalog-no-delta swift-test check-tts-preflight verify-generated regen regen-tool-contract verify-subset-budget verify-source verify-refs verify-cross-section verify-surface verify-c6-shape verify-default-scope verify-register verify-c5-phase1-gates diff test clean-venv

.venv/.deps.stamp: scripts/requirements.txt
	$(PYTHON_BOOTSTRAP) -m venv .venv
	$(PIP) install --upgrade pip
	$(PIP) install -r scripts/requirements.txt
	touch .venv/.deps.stamp

verify: .venv/.deps.stamp verify-source regen verify-refs verify-cross-section verify-surface verify-c6-shape verify-default-scope verify-register verify-c1-matrix verify-c1-fallback verify-c1-probes verify-c1-s10 verify-mounted-catalog-no-delta diff test verify-contentview-wiring

# Codex 审计 P2: make verify 只跑 python/source/regen/surface/diff/test, 不含 swift test → 靠人工双跑。
# verify-all 聚合 swift test + make verify 一条命令, 作为完整本地验收门(D1 决策=本地 make verify 替 CI 轻治理)。
verify-all: verify swift-test

# GitHub runner 没有本机 raw/source-snapshots,不能诚实执行 verify-source/regen(gen_c1 读 source snapshot)。
# verify-ci 只跑 source-free 的 committed-contract 引用/表面/default-scope/diff/python/swift 门;完整 head-bound 证明仍由本地 receipt 跑 verify-all。
verify-ci: .venv/.deps.stamp verify-refs verify-cross-section verify-surface verify-c6-shape verify-default-scope verify-register verify-c1-matrix verify-c1-fallback verify-c1-probes verify-c1-s10 verify-mounted-catalog-no-delta verify-ci-receipt diff test swift-test verify-contentview-wiring

verify-c1-matrix: verify-c1-probes verify-c1-action-probes
	mkdir -p .build/c1-run/receipts/c1
	$(PYTHON_BOOTSTRAP) -m unittest scripts/test_check_capability_matrix.py
	$(PYTHON_BOOTSTRAP) Tools/checks/check_capability_matrix.py check \
		--action-probe-receipt .build/c1-run/receipts/c1/runtime-action-readback-probes.json \
		--matrix contracts/demo-capability-matrix.json \
		--receipt .build/c1-run/receipts/c1/capability-matrix.json

verify-c1-fallback:
	@if [ ! -f Tools/checks/check_fallback_scripts.py ]; then \
		echo "SKIP_PENDING_SLICE verify-c1-fallback"; \
	else \
		mkdir -p /tmp/maformac-c1-checks; \
		$(PYTHON_BOOTSTRAP) Tools/checks/check_fallback_scripts.py \
			--source contracts/fallback-scripts.yaml \
			--schema contracts/schemas/fallback-scripts.schema.json \
			--generated-json generated/demo-fallback-scripts.catalog.json \
			--receipt /tmp/maformac-c1-checks/fallback-scripts.json; \
	fi

verify-c1-probes: .venv/.deps.stamp
	$(PYTHON_BOOTSTRAP) -m unittest scripts/test_check_runtime_no_mutation_receipts.py
	C1_RUN_DIR="$(CURDIR)/.build/c1-run" swift test --filter RuntimeNoMutationProbeTests
	$(PYTHON_BOOTSTRAP) Tools/checks/check_runtime_no_mutation_receipts.py check \
		--receipt .build/c1-run/receipts/c1/runtime-no-mutation-40-probes.json \
		--output .build/c1-run/receipts/c1/runtime-no-mutation-check.json

# Action/readback honesty gate is intentionally separate from CG-044 fallback probes.
# A failed action probe is a truthful observation and keeps canDemo=false; it must
# never be replaced by a no-mutation fallback receipt.
verify-c1-action-probes:
	C1_RUN_DIR="$(CURDIR)/.build/c1-run" swift test --filter RuntimeActionReadbackProbeTests
	test -f .build/c1-run/receipts/c1/runtime-action-readback-probes.json

verify-c1-s10:
	@if [ ! -f scripts/check_s10_receipt.py ]; then \
		echo "SKIP_PENDING_SLICE verify-c1-s10"; \
	else \
		$(PYTHON_BOOTSTRAP) scripts/test_check_s10_receipt.py; \
	fi

verify-ci-receipt:
	$(PYTHON_BOOTSTRAP) scripts/test_write_verify_ci_receipt.py

swift-test:
	swift test

check-tts-preflight:
	@swift scripts/check_tts_preflight.swift

# UIUE 接线 enforce 进 CI（gptpro 跨厂商审 P0-2：原只在 .githooks/pre-commit 本地，CI 不跑）。
# bash 调用避免 executable bit 漏洞；防 ContentView 接线丢失（前任 proof 图丢根因）。
verify-contentview-wiring:
	bash Tools/checks/check-contentview-uses-display-catalog.sh

# pG1 §35 文档级联 cross-section（基线文档组段间一致性, 纯 stdlib 不需 venv/raw）
verify-cross-section:
	$(PYTHON_BOOTSTRAP) scripts/cross_section_check.py

# S5: D-domain surface drift 硬门(0/34 根因=C6 expected 工具名漂移出 catalog 无硬门捕获)。
# surface_consistency: C6 expected 工具名 ⊆ 562 D-domain catalog; verify_gold: 57 case 工具名(含 alt)全在 surface。
verify-surface: .venv/.deps.stamp
	$(PYTHON) scripts/surface_consistency.py contracts/c6-bench-cases.jsonl generated/D_domain.tools.demo.json
	$(PYTHON) scripts/verify_gold.py contracts/c6-bench-cases.jsonl generated/D_domain.tools.demo.json

verify-c6-shape: .venv/.deps.stamp
	$(PYTHON) scripts/check_c6_case_shape.py contracts/c6-bench-cases.jsonl generated/D_domain.tools.demo.json

verify-default-scope: .venv/.deps.stamp
	$(PYTHON) scripts/check_default_scope_ssot.py
	$(PYTHON) scripts/check_c5_c2_scope_parity.py
	$(PYTHON) scripts/check_scope_origin_single_source.py

verify-register:
	PYTHONPATH=scripts python3 scripts/test_register_classifier_lib.py
	PYTHONPATH=scripts python3 scripts/test_register_classifier_golden.py

verify-mounted-catalog-no-delta: .venv/.deps.stamp
	$(PYTHON) -m unittest scripts/test_check_mounted_catalog_no_delta.py
	$(PYTHON) scripts/check_mounted_catalog_no_delta.py

verify-c5-phase1-gates: .venv/.deps.stamp
	$(PYTHON) scripts/test_query_zero_tolerance.py
	$(PYTHON) scripts/test_eval_mount_validity.py
	$(PYTHON) scripts/test_label_authority_conflicts.py

# source-free: 只校验已提交产物(JSONL/YAML/coverage/state-cells/manifest)自洽与引用,
# 不依赖 raw xlsx 快照(别人 clone 仓无 snapshot 也能验契约). verify-refs 只读 manifest+committed, 不读源表.
verify-generated: .venv/.deps.stamp verify-refs test

# 合成脏行 fixture: 坐实 quarantine 逻辑生效(source-free, 不需 raw 快照)
test: .venv/.deps.stamp
	$(PYTHON) scripts/test_quarantine.py
	$(PYTHON) scripts/test_fc_flags.py
	$(PYTHON) scripts/test_tool_name_sanitize.py
	$(PYTHON) scripts/test_check_c6_case_shape.py
	$(PYTHON) scripts/test_query_zero_tolerance.py
	$(PYTHON) scripts/test_eval_mount_validity.py
	$(PYTHON) scripts/test_label_authority_conflicts.py
	$(PYTHON) scripts/test_c6_bench_cli.py
	$(PYTHON) scripts/test_subset_manifest.py
	$(PYTHON) scripts/test_train_eval_exposure.py

verify-source: .venv/.deps.stamp
	$(PYTHON) scripts/freeze_snapshot.py --check

regen: .venv/.deps.stamp
	$(PYTHON) scripts/gen_c1.py
	$(PYTHON) scripts/gen_tool_contract.py --contract contracts/semantic-function-contract.jsonl --output-dir generated
	$(PYTHON) scripts/gen_family_allowlist.py --emit --output-dir generated
	HF_HUB_OFFLINE=1 $(PYTHON_TOKENIZER) scripts/gen_subset_manifest.py --emit --verify-budget --budget-cap 7200 --tokenizer-mode qwen --output-dir generated

regen-tool-contract: .venv/.deps.stamp
	$(PYTHON) scripts/gen_tool_contract.py --contract contracts/semantic-function-contract.jsonl --output-dir generated

verify-subset-budget:
	HF_HUB_OFFLINE=1 $(PYTHON_TOKENIZER) scripts/gen_subset_manifest.py --check --verify-budget --budget-cap 7200 --tokenizer-mode qwen

verify-refs: .venv/.deps.stamp
	$(PYTHON) scripts/verify_refs.py

# 手写契约(非生成), 纳入 diff 防未提交漂移; 不进 regen。risk-policy/demo-scenarios 2026-06-20 补入(审计:别让 reviewed 候选伪装闭合)
HANDWRITTEN_CONTRACTS := contracts/state-cells.yaml contracts/l1-demo-allowlist.yaml contracts/risk-policy.yaml contracts/demo-scenarios.yaml contracts/subset-grouping.yaml

diff:
	git diff --exit-code -- contracts/source-snapshot-manifest.yaml $(GENERATED_CONTRACTS) $(GENERATED_DOMAIN) $(GENERATED_SWIFT) $(HANDWRITTEN_CONTRACTS) scripts Makefile

clean-venv:
	rm -rf .venv
