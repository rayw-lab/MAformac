# C3 execution apply note — 2026-06-20

## Scope

This apply implements `define-execution-contract` in Swift. The change consumes C1/C2 contract artifacts as read-only inputs and does not modify `contracts/`, `openspec/specs/`, or `openspec/changes/define-execution-contract/`.

## Verified inputs

- `openspec validate define-execution-contract --strict`: pass on branch `feat/c3-execution-apply`.
- `make verify`: pass with `state_cells=ok`, `c1_c2_closure=active`, `l1_closure=ok`, `risk_policy=ok`, and `demo_scenarios=ok`.
- Initial `git diff -- contracts openspec/specs openspec/changes/define-execution-contract`: empty.

## Apply rule

If implementation requires changing C1/C2 contracts, OpenSpec specs, or the aligned `define-execution-contract` artifacts, stop and open a separate change. Do not silently patch the contract from C3 apply.
