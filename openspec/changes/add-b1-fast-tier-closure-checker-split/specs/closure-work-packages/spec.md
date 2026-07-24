## ADDED Requirements

### Requirement: Closure local-fast classification SHALL use a fail-closed three-tier lattice

The system SHALL classify repository changes as `ordinary_docs`, `closure_authority`, or `full`, selecting the strongest tier across all paths and both sides of rename/copy changes. Ordinary documentation SHALL exclude decisions, roadmap, handoffs, CURRENT, OpenSpec changes, closure receipts, and commander documents. Everything outside ordinary or closure-authority documentation SHALL be `full`.

#### Scenario: Mixed documentation and product change

- **GIVEN** one ordinary documentation path and one product path
- **WHEN** classification runs
- **THEN** the result SHALL be `full`.

#### Scenario: Authority-only change

- **GIVEN** changed paths are ordinary documentation plus at least one closure-authority path
- **WHEN** classification runs
- **THEN** the result SHALL be `closure_authority`.

#### Scenario: Referenced deletion

- **GIVEN** a deleted authority or registry-referenced path
- **WHEN** classification runs
- **THEN** the result SHALL be `full`.

### Requirement: The git adapter SHALL preserve live change truth

The adapter SHALL require explicit base and subject commits, require complete ancestry, parse NUL-safe `git diff --name-status -z` records for A/M/D/R/C, inspect both rename/copy paths, and union committed-range, staged, unstaged, untracked, and optional manifest paths. An optional manifest SHALL never replace live changes.

#### Scenario: Incomplete history or malformed input

- **GIVEN** shallow history, a missing base/subject, missing ancestry, or malformed name-status output
- **WHEN** collection runs
- **THEN** classification SHALL fail closed to `full`.

#### Scenario: Worktree and manifest union

- **GIVEN** staged, unstaged, untracked, and manifest paths
- **WHEN** collection runs
- **THEN** all paths SHALL participate in strongest-tier aggregation.

### Requirement: Local-fast dispatch SHALL retain tier-specific gates

`ordinary_docs` SHALL run `git diff --check` and `verify-cross-section`. `closure_authority` SHALL run the full `verify-closure-work-packages` target. `full` SHALL run `verify-ci`. `verify-ci` SHALL retain its direct dependency on full closure verification and SHALL NOT depend on local-fast.

#### Scenario: Full change dispatches without recursion

- **GIVEN** a classified `full` change set
- **WHEN** local-fast dispatch runs
- **THEN** it SHALL invoke `verify-ci`
- **AND** `verify-ci` SHALL invoke full closure verification without invoking local-fast.

### Requirement: Closure pytest partition SHALL preserve the ratified 16/4 source split

The system SHALL preserve exactly 20 closure source test functions: 16 static and four stable-name clone/history-heavy functions. Static closure verification SHALL deselect only those four names and still run the real checker. No wall-clock speed guarantee is implied by the semantic partition.

#### Scenario: Static closure roster runs

- **GIVEN** the explicit static closure-test target
- **WHEN** pytest is invoked
- **THEN** exactly four stable-name heavy functions SHALL be deselected
- **AND** the remaining 16 source functions and real checker SHALL run.
