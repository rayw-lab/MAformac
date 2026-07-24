# B3a P1 Fix Receipt
- branch: c1/b3a-ingress
- base_commit: eeed2734bdf2ff2e00e808cdce65200e9f94f507
- head_commit: d882891136b53c16ce4e08083726028018ee1fde (receipt update commit)
- changed_files:
  - Core/Execution/DemoRuntimeSessionRunner.swift
  - Core/Trace/TraceLogger.swift
  - Tests/MAformacCoreTests/DemoRuntimeSessionRunnerTests.swift

## P1-1 Fixed: Multi-Frame Rejection Trace
- Added stateMutation field to TraceAttributes
- Added recordGuard call before throwing multiFramePlanRequiresPartialExecution
- Updated test to assert trace has guardReason, toolCallCount=0, stateMutation=false
- No execute/readback traces present when rejected

## P1-2: Governance Receipt
- Risk scope: HIGH (modified DemoRuntimeSessionRunner.run)
- Impact: multi-frame plan now fails closed with trace proof
- Pre-change audit: no mutations, no regressions
- Rollback plan: git checkout eeed2734 -- <files>
- Post-change verify: `make test` (exit 0); stdout is reproducible from the command above.
- Impact/detect: B3a ingress-only change; no downstream contracts or public fields changed. GitNexus impact and `git diff --name-status HEAD^` both show the three files listed above.
- Proof class: executable regression tests plus trace assertions (P1-1); governance receipt (P1-2).
- Residual scope: canonical before/after digest evidence remains owned by B2c; this receipt does not claim that closure.
