PYTHON_BOOTSTRAP ?= python3
PYTHON := .venv/bin/python
PIP := .venv/bin/pip
GENERATED_CONTRACTS := \
	contracts/semantic-function-contract.jsonl \
	contracts/semantic-followup-transitions.jsonl \
	contracts/semantic-quarantine.jsonl \
	contracts/function-spec-full.yaml \
	contracts/semantic-coverage-report.md

.PHONY: verify regen verify-source verify-refs diff clean-venv

.venv/.deps.stamp: scripts/requirements.txt
	$(PYTHON_BOOTSTRAP) -m venv .venv
	$(PIP) install --upgrade pip
	$(PIP) install -r scripts/requirements.txt
	touch .venv/.deps.stamp

verify: .venv/.deps.stamp verify-source regen verify-refs diff

verify-source: .venv/.deps.stamp
	$(PYTHON) scripts/freeze_snapshot.py --check

regen: .venv/.deps.stamp
	$(PYTHON) scripts/gen_c1.py

verify-refs: .venv/.deps.stamp
	$(PYTHON) scripts/verify_refs.py

# state-cells.yaml 为手写 C2 契约(非生成), 纳入 diff 防未提交漂移; 不进 regen
HANDWRITTEN_CONTRACTS := contracts/state-cells.yaml

diff:
	git diff --exit-code -- contracts/source-snapshot-manifest.yaml $(GENERATED_CONTRACTS) $(HANDWRITTEN_CONTRACTS) scripts Makefile

clean-venv:
	rm -rf .venv
