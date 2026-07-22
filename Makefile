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

.PHONY: verify verify-all verify-ci verify-ci-receipt verify-governance-hygiene verify-anti-placebo verify-a4-target-exclusions verify-c1-checker-files verify-c1-ownership verify-c1-finite-reason-authority verify-c1-matrix verify-c1-matrix-canonical verify-c1-fallback verify-c1-probes verify-c1-action-probes verify-c1-s10 verify-mounted-catalog-no-delta verify-action-demo-proven-rename verify-runtime-bundle verify-frontstage-route verify-closure-work-packages verify-closure-work-packages-static verify-closure-work-packages-local-fast verify-c6-authority-eval-live swift-test check-tts-preflight verify-generated regen regen-tool-contract verify-subset-budget verify-source verify-refs verify-cross-section verify-surface verify-c6-shape verify-default-scope verify-register verify-c5-phase1-gates diff test clean-venv demo-progress verify-e2e verify-ui-e2e
.PHONY: verify-e2e-product-behavior verify-e2e-wp21-window verify-e2e-wp21-ambient verify-e2e-wp21-seat
.PHONY: verify-e2e-row167 verify-e2e-query verify-e2e-risk verify-e2e-replay verify-e2e-cancel verify-e2e-receipt

.venv/.deps.stamp: scripts/requirements.txt
	$(PYTHON_BOOTSTRAP) -m venv .venv
	$(PIP) install --upgrade pip
	$(PIP) install -r scripts/requirements.txt
	touch .venv/.deps.stamp

verify: verify-governance-hygiene verify-c1-checker-files .venv/.deps.stamp verify-source regen verify-refs verify-cross-section verify-surface verify-c6-shape verify-default-scope verify-register verify-a4-target-exclusions verify-c1-ownership verify-c1-finite-reason-authority verify-c1-matrix verify-c1-fallback verify-c1-probes verify-c1-s10 verify-mounted-catalog-no-delta verify-action-demo-proven-rename verify-closure-work-packages verify-c6-authority-eval-live diff test verify-contentview-wiring verify-anti-placebo

verify-governance-hygiene:
	$(PYTHON_BOOTSTRAP) -m unittest -v scripts/test_check_governance_hygiene.py
	$(PYTHON_BOOTSTRAP) scripts/check_governance_hygiene.py


verify-anti-placebo:
	$(PYTHON_BOOTSTRAP) -m unittest -v scripts/test_verify_anti_placebo.py scripts/test_run_ui_e2e.py
	$(PYTHON_BOOTSTRAP) scripts/verify_anti_placebo.py
# FA-1 + G7 contract: full product-behavior class (AC golden incl. test07/test03a)
# + WP21 + G7 batch filters. Each filter goes through run_swift_test_exact.py
# --min-count 1 so 0-match cannot exit 0 (anti-placebo executed>0 gate).
# G7 risk couples to legacy testG3_window (NOT testG7_risk_) — keep Makefile
# filter, G7_TARGETS lock table, and docs in sync if renaming.
verify-e2e: verify-e2e-product-behavior verify-e2e-wp21-window verify-e2e-wp21-ambient verify-e2e-wp21-seat verify-e2e-row167 verify-e2e-query verify-e2e-risk verify-e2e-replay verify-e2e-cancel verify-e2e-receipt
	$(PYTHON_BOOTSTRAP) scripts/verify_anti_placebo.py

verify-e2e-product-behavior:
	$(PYTHON_BOOTSTRAP) Tools/checks/run_swift_test_exact.py \
		--filter DemoSliceProductBehaviorGateTests --min-count 1

verify-e2e-wp21-window:
	$(PYTHON_BOOTSTRAP) Tools/checks/run_swift_test_exact.py \
		--filter DemoSliceProductBehaviorGateTests/testWP21BatchA_ --min-count 1

verify-e2e-wp21-ambient:
	$(PYTHON_BOOTSTRAP) Tools/checks/run_swift_test_exact.py \
		--filter DemoSliceProductBehaviorGateTests/testWP21BatchB_ --min-count 1

verify-e2e-wp21-seat:
	$(PYTHON_BOOTSTRAP) Tools/checks/run_swift_test_exact.py \
		--filter DemoSliceProductBehaviorGateTests/testWP21BatchC_ --min-count 1

verify-e2e-row167:
	$(PYTHON_BOOTSTRAP) Tools/checks/run_swift_test_exact.py \
		--filter DemoSliceProductBehaviorGateTests/testG3_row167_ --min-count 1

verify-e2e-query:
	$(PYTHON_BOOTSTRAP) Tools/checks/run_swift_test_exact.py \
		--filter DemoSliceProductBehaviorGateTests/testG7_query_ --min-count 1

verify-e2e-risk:
	$(PYTHON_BOOTSTRAP) Tools/checks/run_swift_test_exact.py \
		--filter DemoSliceProductBehaviorGateTests/testG3_window --min-count 1

verify-e2e-replay:
	$(PYTHON_BOOTSTRAP) Tools/checks/run_swift_test_exact.py \
		--filter DemoSliceProductBehaviorGateTests/testG7_replay_ --min-count 1

verify-e2e-cancel:
	$(PYTHON_BOOTSTRAP) Tools/checks/run_swift_test_exact.py \
		--filter DemoSliceProductBehaviorGateTests/testG7_cancel_ --min-count 1

verify-e2e-receipt:
	$(PYTHON_BOOTSTRAP) Tools/checks/run_swift_test_exact.py \
		--filter DemoSliceProductBehaviorGateTests/testG7_receipt_ --min-count 1
XCODEBUILD ?= xcodebuild
UI_E2E_TEST_IDENTIFIER ?= MAformacIOSUITests/FrontstageCustomerIngressUITests
UI_E2E_RESULT_PATH ?= $(PWD)/build/ui-e2e-$(shell date +%Y%m%d-%H%M%S).xcresult

# XCUITest CI integration (WP1b-4): runs FrontstageCustomerIngressUITests on iOS 26.5 simulator
# with pinned macos-26 runner, exact UDID resolution via simctl JSON (no fallback to "first iOS 26 device"),
# .xcresult parsing proves test execution. The xcodebuild command is deliberately
# not piped, so its exit status is captured directly and cannot be masked.
verify-ui-e2e:
	@echo "=== verify-ui-e2e: XCUITest CI Integration ==="
	@echo "Checking macOS runner..."
	@uname -m | grep -q 'arm64' || (echo "FAIL: Runner must be arm64 (macos-26)"; exit 1)
	@echo "Runner arch: $$(uname -m)"
	@echo "Checking Xcode version..."
	@$(XCODEBUILD) -version
	@echo "Resolving iPhone 17 Pro (iOS 26.5) simulator UDID..."; \
	IOS26_UDID=$$(xcrun simctl list devices available --json 2>/dev/null | python3 -c 'import json,sys; d=json.load(sys.stdin); [print(dev["udid"]) for rt,devs in d.get("devices",{}).items() if "iOS-26-5" in rt for dev in devs if dev.get("name")=="iPhone 17 Pro"]'); \
	if [ -z "$$IOS26_UDID" ]; then \
		echo "FAIL: No iPhone 17 Pro (iOS 26.5) simulator found. Available:"; \
		xcrun simctl list devices available --json 2>/dev/null | python3 -c 'import json,sys; d=json.load(sys.stdin); [print(f"{rt}: {dev[\"name\"]} ({dev[\"udid\"]})") for rt,devs in d.get("devices",{}).items() if "iOS-26-5" in rt for dev in devs]'; \
		exit 1; \
	fi; \
	echo "Found iPhone 17 Pro (iOS 26.5) UDID: $$IOS26_UDID"; \
	echo "Running $(UI_E2E_TEST_IDENTIFIER)..."; \
	XCRESULT_PATH="$(UI_E2E_RESULT_PATH)"; \
	mkdir -p "$$(dirname "$$XCRESULT_PATH")"; \
	$(XCODEBUILD) test -project MAformac.xcodeproj -scheme MAformacIOS \
		-only-testing:$(UI_E2E_TEST_IDENTIFIER) \
		-destination "platform=iOS Simulator,id=$$IOS26_UDID" \
		-resultBundlePath "$$XCRESULT_PATH" \
		-quiet; \
	XCBUILD_EXIT=$$?; \
	echo "xcodebuild exit: $$XCBUILD_EXIT"; \
	if [ ! -d "$$XCRESULT_PATH" ]; then \
		echo "FAIL: xcresult not found at $$XCRESULT_PATH"; \
		exit 1; \
	fi; \
	echo "Parsing .xcresult summary for test execution proof..."; \
	$(PYTHON_BOOTSTRAP) scripts/run_ui_e2e.py --xcresult "$$XCRESULT_PATH"; \
	SUMMARY_EXIT=$$?; \
	if [ "$$SUMMARY_EXIT" -ne 0 ]; then \
		echo "FAIL: xcresult summary did not prove a passed, non-empty UI test run."; \
		exit "$$SUMMARY_EXIT"; \
	fi; \
	echo "SUCCESS: xcodebuild exit=$$XCBUILD_EXIT and xcresult summary passed"; \
	exit "$$XCBUILD_EXIT"
verify-a4-target-exclusions:
	$(PYTHON_BOOTSTRAP) scripts/test_check_a4_app_target_exclusions.py
	$(PYTHON_BOOTSTRAP) scripts/check_a4_app_target_exclusions.py

verify-closure-work-packages: .venv/.deps.stamp
	$(PYTHON) -m pytest -q Tests/test_closure_work_packages.py
	$(PYTHON) scripts/check_closure_work_packages.py check \
		--registry contracts/closure-work-packages.v1.yaml \
		--schema contracts/schemas/closure-work-packages.v1.schema.json \
		--roadmap docs/roadmap-2026-07-11-v6-closure-baseline.md \
		--o6-policy contracts/closure-execution-window.v1.yaml \
		--subject-head "$$(git rev-parse HEAD)" \
		--receipt .build/closure/closure-registry-check.v1.json

verify-c6-authority-eval-live: .venv/.deps.stamp
	$(PYTHON) -B scripts/test_check_c6_corpus_lineage_candidate.py
	$(PYTHON) -B scripts/test_check_c6_corpus_freeze_packet.py
	$(PYTHON) -B scripts/test_check_c6_active_authority_candidate.py
	$(PYTHON) -B scripts/test_check_c6_active_authority_ratification_packet.py
	$(PYTHON) -B scripts/test_check_c6_eval_spine.py
	$(PYTHON) -B scripts/check_c6_corpus_lineage_candidate.py
	$(PYTHON) -B scripts/check_c6_active_authority_candidate.py \
		contracts/c6-active-authority/authority.v1.candidate.json

verify-closure-work-packages-static: .venv/.deps.stamp
	$(PYTHON) -m pytest -q Tests/test_closure_work_packages.py $$($(PYTHON) scripts/closure_path_classifier.py pytest-deselect)
	$(PYTHON) scripts/check_closure_work_packages.py check \
		--registry contracts/closure-work-packages.v1.yaml \
		--schema contracts/schemas/closure-work-packages.v1.schema.json \
		--roadmap docs/roadmap-2026-07-11-v6-closure-baseline.md \
		--o6-policy contracts/closure-execution-window.v1.yaml \
		--subject-head "$$(git rev-parse HEAD)" \
		--receipt .build/closure/closure-registry-check.v1.json

verify-closure-work-packages-local-fast: .venv/.deps.stamp
	@base="$${CLOSURE_BASE:-HEAD}"; subject="$${CLOSURE_SUBJECT:-HEAD}"; \
	result=$$($(PYTHON) scripts/closure_path_classifier.py tier \
		--repo . --base "$$base" --subject "$$subject" --show-reason); \
	tier=$$(printf '%s' "$$result" | cut -f1); \
	echo "closure-local-fast $$result"; \
	case "$$tier" in \
		ordinary_docs) git diff --check "$$base" "$$subject" && git diff --check HEAD && $(MAKE) verify-cross-section ;; \
		closure_authority) $(MAKE) verify-closure-work-packages ;; \
		full) $(MAKE) verify-ci ;; \
		*) echo "unknown classifier tier=$$tier" >&2; exit 2 ;; \
	esac

# Codex 审计 P2: make verify 只跑 python/source/regen/surface/diff/test, 不含 swift test → 靠人工双跑。
# verify-all additionally runs the product E2E gate and its anti-injection meta assertions.
verify-all: verify swift-test verify-e2e

# GitHub runner 没有本机 raw/source-snapshots,不能诚实执行 verify-source/regen(gen_c1 读 source snapshot)。
# verify-ci 只跑 source-free 的 committed-contract 引用/表面/default-scope/diff/python/swift 门;完整 head-bound 证明仍由本地 receipt 跑 verify-all。
verify-ci: verify-c1-checker-files verify-governance-hygiene .venv/.deps.stamp verify-refs verify-cross-section verify-surface verify-c6-shape verify-default-scope verify-register verify-a4-target-exclusions verify-c1-ownership verify-c1-finite-reason-authority verify-c1-matrix verify-c1-fallback verify-c1-probes verify-c1-s10 verify-mounted-catalog-no-delta verify-action-demo-proven-rename verify-closure-work-packages verify-c6-authority-eval-live verify-ci-receipt diff test swift-test verify-contentview-wiring verify-anti-placebo verify-e2e

# Source-free C1 checkers are hard CI dependencies. Missing files must stop verify-ci
# before any expensive gate runs; otherwise deleting a checker can manufacture green.
verify-c1-checker-files:
	@status=0; \
	for checker in Tools/checks/check_c1_ownership_map.py Tools/checks/check_runtime_finite_reason_authority.py Tools/checks/check_action_demo_proven_legacy_tokens.py Tools/checks/check_int_v5a_execution_receipt.py Tools/checks/run_swift_test_exact.py Tools/checks/check_fallback_scripts.py Tools/C6CorpusLineage/export_freeze_packet.py Tools/C6ActiveAuthority/export_ratification_packet.py scripts/check_governance_hygiene.py scripts/test_check_governance_hygiene.py scripts/check_s10_receipt.py scripts/check_closure_work_packages.py scripts/closure_path_classifier.py scripts/test_closure_path_classifier.py scripts/reanchor_closure_registry.py scripts/test_reanchor_closure_registry.py scripts/check_a4_app_target_exclusions.py scripts/test_check_a4_app_target_exclusions.py scripts/check_c6_corpus_lineage_candidate.py scripts/check_c6_active_authority_candidate.py scripts/test_check_c6_corpus_lineage_candidate.py scripts/test_check_c6_corpus_freeze_packet.py scripts/test_check_c6_active_authority_candidate.py scripts/test_check_c6_active_authority_ratification_packet.py scripts/test_check_c6_eval_spine.py contracts/closure-work-packages.v1.yaml contracts/schemas/closure-work-packages.v1.schema.json contracts/schemas/closure-status-transition-receipt.v1.schema.json contracts/schemas/closure-package-exit-envelope.v1.schema.json contracts/schemas/closure-gate-receipt.v1.schema.json contracts/closure-execution-window.v1.yaml Tests/test_closure_work_packages.py; do \
		if [ ! -f "$$checker" ]; then \
			echo "ERROR_MISSING_C1_CHECKER $$checker" >&2; \
			status=1; \
		fi; \
	done; \
	exit $$status
	$(PYTHON_BOOTSTRAP) scripts/test_check_a4_app_target_exclusions.py

verify-c1-ownership:
	mkdir -p .build/c1-run/receipts/c1
	$(PYTHON_BOOTSTRAP) -m unittest scripts/test_check_c1_ownership_map.py
	$(PYTHON_BOOTSTRAP) Tools/checks/check_c1_ownership_map.py \
		--receipt .build/c1-run/receipts/c1/ownership-map.json

verify-c1-finite-reason-authority:
	mkdir -p .build/c1-run/receipts/c1
	$(PYTHON_BOOTSTRAP) -m unittest -v scripts/test_check_runtime_finite_reason_authority.py
	$(PYTHON_BOOTSTRAP) -m unittest -v scripts/test_run_swift_test_exact.py
	$(PYTHON_BOOTSTRAP) Tools/checks/check_runtime_finite_reason_authority.py \
		--receipt .build/c1-run/receipts/c1/runtime-finite-reason-authority.json
	$(PYTHON_BOOTSTRAP) Tools/checks/run_swift_test_exact.py \
		--filter RuntimeFiniteReasonAuthorityTests --min-count 1
	$(PYTHON_BOOTSTRAP) Tools/checks/run_swift_test_exact.py \
		--filter RuntimeFiniteReasonAuthorityTests/testFallbackResolutionMatchesHardcodedTenReasonScriptTable
	$(PYTHON_BOOTSTRAP) Tools/checks/run_swift_test_exact.py \
		--filter RuntimeFiniteReasonAuthorityTests/testTraceRoundTripsHardcodedTenFiniteReasonsEndToEnd
	$(PYTHON_BOOTSTRAP) Tools/checks/run_swift_test_exact.py \
		--filter RuntimeFiniteReasonAuthorityTests/testDiagnosticFailuresTraverseProductionRunnerAndRedactPresentationTrace

verify-c1-matrix: verify-c1-probes verify-c1-action-probes
	mkdir -p .build/c1-run/receipts/c1
	$(PYTHON) -m unittest scripts/test_check_capability_matrix.py
	$(PYTHON) Tools/checks/check_capability_matrix.py check \
		--action-probe-receipt .build/c1-run/receipts/c1/runtime-action-readback-probes.json \
		--matrix contracts/demo-capability-matrix.json \
		--receipt .build/c1-run/receipts/c1/capability-matrix.json

# Fail closed on the full authority -> matrix -> Swift projection chain.  The
# temporary artifacts ensure a dirty tracked file cannot self-certify.
verify-c1-matrix-canonical: .venv/.deps.stamp
	mkdir -p .build/c1-run/canonical
	$(PYTHON) Tools/checks/check_capability_matrix.py materialize \
		--output .build/c1-run/canonical/demo-capability-matrix.json
	cmp -s contracts/demo-capability-matrix.json .build/c1-run/canonical/demo-capability-matrix.json
	$(PYTHON) Tools/generate_demo_capability_matrix_swift.py \
		--input .build/c1-run/canonical/demo-capability-matrix.json \
		--output .build/c1-run/canonical/DemoCapabilityMatrix.generated.swift
	cmp -s Core/Contracts/DemoCapabilityMatrix.generated.swift .build/c1-run/canonical/DemoCapabilityMatrix.generated.swift

verify-c1-fallback:
	@if [ ! -f Tools/checks/check_fallback_scripts.py ]; then \
		echo "ERROR_MISSING_C1_CHECKER Tools/checks/check_fallback_scripts.py" >&2; \
		exit 1; \
	else \
		mkdir -p /tmp/maformac-c1-checks; \
		$(PYTHON_BOOTSTRAP) Tools/checks/check_fallback_scripts.py \
			--source contracts/fallback-scripts.yaml \
			--schema contracts/schemas/fallback-scripts.schema.json \
			--generated-json generated/demo-fallback-scripts.catalog.json \
			--receipt /tmp/maformac-c1-checks/fallback-scripts.json; \
	fi

verify-c1-probes: .venv/.deps.stamp
	$(PYTHON) -m unittest scripts/test_check_runtime_no_mutation_receipts.py
	C1_RUN_DIR="$(CURDIR)/.build/c1-run" swift test --filter RuntimeNoMutationProbeTests
	$(PYTHON_BOOTSTRAP) Tools/checks/check_runtime_no_mutation_receipts.py check \
		--receipt .build/c1-run/receipts/c1/runtime-no-mutation-40-probes.json \
		--output .build/c1-run/receipts/c1/runtime-no-mutation-check.json

# Action/readback honesty gate is intentionally separate from CG-044 fallback probes.
# A failed action probe is a truthful observation and keeps actionDemoProven=false; it must
# never be replaced by a no-mutation fallback receipt.
verify-runtime-bundle: .venv/.deps.stamp
	$(PYTHON) -m unittest -v scripts/test_generate_demo_runtime_contract_bundle.py scripts/test_int_v5a_v5c_preflight_contract.py
	$(PYTHON) Tools/generate_demo_runtime_contract_bundle.py
	$(PYTHON) -c 'import json; from jsonschema import Draft202012Validator; from pathlib import Path; s=json.loads(Path("contracts/schemas/demo-runtime-contract-bundle-manifest.schema.json").read_text()); Draft202012Validator(s).validate(json.loads(Path("generated/demo-runtime-contract-bundle.manifest.json").read_text()))'
	test ! -e generated/demo-runtime-contract-bundle.receipt.json

# int-v5b containment half: local standalone deny route only. It is deliberately
# not wired into verify-ci until the T03/T04 production interface cut is ratified.
verify-frontstage-route: .venv/.deps.stamp
	$(PYTHON) -m unittest -v scripts/test_check_frontstage_route_receipt.py scripts/test_run_frontstage_route_gate.py scripts/test_frontstage_ui_harness.py scripts/test_finalize_frontstage_route_ui_abi.py
	PYTHON_BIN="$(PYTHON)" ./scripts/run_frontstage_route_gate.sh

verify-c1-action-probes: verify-runtime-bundle
	C1_RUN_DIR="$(CURDIR)/.build/c1-run" swift test --filter RuntimeActionReadbackProbeTests
	test -f .build/c1-run/receipts/c1/runtime-action-readback-probes.json
	$(PYTHON) -c 'import json; from jsonschema import Draft202012Validator; from pathlib import Path; s=json.loads(Path("contracts/schemas/runtime-action-readback-receipt-v2.schema.json").read_text()); Draft202012Validator(s).validate(json.loads(Path(".build/c1-run/receipts/c1/runtime-action-readback-probes.json").read_text()))'

verify-c1-s10:
	@if [ ! -f scripts/check_s10_receipt.py ]; then \
		echo "ERROR_MISSING_C1_CHECKER scripts/check_s10_receipt.py" >&2; \
		exit 1; \
	else \
		$(PYTHON_BOOTSTRAP) scripts/test_check_s10_receipt.py; \
	fi

verify-ci-receipt:
	$(PYTHON_BOOTSTRAP) scripts/test_write_verify_ci_receipt.py
	$(PYTHON_BOOTSTRAP) scripts/test_verify_ci_checker_presence.py

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

verify-action-demo-proven-rename: .venv/.deps.stamp verify-c1-finite-reason-authority verify-mounted-catalog-no-delta
	mkdir -p .build/c1-run/receipts/c1 .build/c1-run/canonical
	$(PYTHON) -m unittest -v scripts/test_check_capability_matrix.py
	$(PYTHON) Tools/checks/check_capability_matrix.py check \
		--matrix contracts/demo-capability-matrix.json \
		--receipt .build/c1-run/receipts/c1/capability-matrix-rename.json
	$(PYTHON) Tools/generate_demo_capability_matrix_swift.py \
		--input contracts/demo-capability-matrix.json \
		--output .build/c1-run/canonical/DemoCapabilityMatrix.rename.swift
	cmp -s Core/Contracts/DemoCapabilityMatrix.generated.swift .build/c1-run/canonical/DemoCapabilityMatrix.rename.swift
	$(PYTHON) -m unittest -v scripts/test_check_action_demo_proven_legacy_tokens.py
	$(PYTHON) Tools/checks/check_action_demo_proven_legacy_tokens.py \
		--allowlist contracts/action-demo-proven-legacy-token-allowlist.json
	$(PYTHON) -m unittest -v scripts/test_check_int_v5a_execution_receipt.py

verify-c5-phase1-gates: .venv/.deps.stamp
	$(PYTHON) scripts/test_query_zero_tolerance.py
	$(PYTHON) scripts/test_eval_mount_validity.py
	$(PYTHON) scripts/test_label_authority_conflicts.py

# source-free: 只校验已提交产物(JSONL/YAML/coverage/state-cells/manifest)自洽与引用,
# 不依赖 raw xlsx 快照(别人 clone 仓无 snapshot 也能验契约). verify-refs 只读 manifest+committed, 不读源表.
verify-generated: .venv/.deps.stamp verify-refs test verify-subset-budget

# 合成脏行 fixture: 坐实 quarantine 逻辑生效(source-free, 不需 raw 快照)
test: .venv/.deps.stamp
	$(PYTHON) -m unittest -v scripts/test_check_customer_route_avoids_legacy_decode.py scripts/test_check_t04a_customer_ingress.py
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
HANDWRITTEN_CONTRACTS := contracts/state-cells.yaml contracts/l1-demo-allowlist.yaml contracts/risk-policy.yaml contracts/demo-scenarios.yaml contracts/subset-grouping.yaml contracts/demo-runtime-bundle-selection.json contracts/c2-mounted-catalog-baseline.yaml

diff: verify-c1-matrix-canonical
	git diff --exit-code -- contracts/source-snapshot-manifest.yaml $(GENERATED_CONTRACTS) $(GENERATED_DOMAIN) $(GENERATED_SWIFT) $(HANDWRITTEN_CONTRACTS) scripts Makefile

# --- demo progress gauge (NON-GATING; user-goal oriented; w2 three-layer fields) ---
# DO NOT add to verify / verify-ci dependency chains. Always observational exit 0.
# Layers: actionDemoProven | runtime_path_reachable | operator_pass (ban single 「可演」).
demo-progress:
	@$(PYTHON_BOOTSTRAP) Tools/scripts/demo_progress_gauge.py \
		--receipt .build/c1-run/receipts/c1/capability-matrix.json \
		--matrix contracts/demo-capability-matrix.json \
		--app-registry contracts/demo-progress-app-scenarios.yaml \
		$(if $(REFRESH),--refresh,)

clean-venv:
	rm -rf .venv
