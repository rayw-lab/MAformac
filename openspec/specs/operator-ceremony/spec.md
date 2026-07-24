# operator-ceremony Specification

## Purpose
Define the versioned T07 operator-ceremony envelope, exact subject/artifact joins, immutable launch attempts, expiry/retest semantics, and local/synthetic evidence caps while keeping T07b blocked on real prerequisites.

## Requirements

### Requirement: T07a Sectioned Ceremony Envelope

The system SHALL represent an operator-ceremony candidate with six typed sections: `subject`, `environment`, `attempt`, `axes`, `expiry`, and `evidence`. The envelope SHALL carry a schema version and SHALL reject missing, unknown, or version-incompatible required fields.

#### Scenario: Complete ceremony sections are required

GIVEN a ceremony candidate is being evaluated
WHEN any of the six required sections or the schema version is absent
THEN the candidate SHALL be rejected
AND it SHALL NOT be reported as a complete ceremony result.

#### Scenario: Environment and evidence carry exact identity inputs

GIVEN a ceremony candidate has all six sections
WHEN its environment or evidence omits required build, artifact, subject, or digest identity
THEN the candidate SHALL remain ineligible
AND a filename or human-readable label SHALL NOT substitute for the missing identity.

### Requirement: Exact Subject and Artifact Join

The system SHALL establish a same-subject ceremony join only when the required subject, environment, build, artifact, and T06 identity fields are exact equal. The join SHALL include repo SHA, dirty verdict, scheme/config, bundle/version/hash, T06 subject identity, machine/OS/target, scenario version, and contract version. Branch metadata SHALL NOT replace repo SHA, and artifact bytes/digests SHALL be join inputs.

#### Scenario: Exact identity produces a local join candidate

GIVEN two receipts contain equal values for every required subject, environment, build, artifact, and T06 identity field
WHEN the join is evaluated
THEN it MAY produce a `local_schema_join_only` candidate
AND it SHALL preserve the exact identity tuple in the result.

#### Scenario: Near-match identity fails closed

GIVEN two receipts share a branch or bundle/version but differ in repo SHA, dirty verdict, artifact hash, environment, scenario version, or contract version
WHEN the join is evaluated
THEN the join SHALL fail closed
AND it SHALL NOT be repaired by branch, filename, version, or manual override.

### Requirement: Independent O1 Axis Predicates

The system SHALL evaluate the `decision`, `execution`, and `proof` axes independently using the canonical O1 state vocabulary. Each axis SHALL carry a predicate version, current flag, pass result, typed reason, and claim cap. An invalid axis SHALL block that axis and its downstream joins without rewriting unrelated axis facts.

#### Scenario: One axis failure does not wash another axis

GIVEN the decision axis is valid and the execution axis has a missing or invalid predicate field
WHEN the three axes are evaluated
THEN the execution axis and its downstream joins SHALL be blocked
AND the original decision-axis result SHALL remain unchanged.

#### Scenario: Unknown O1 state fails closed

GIVEN an axis contains an unknown or version-incompatible O1 state
WHEN that axis is evaluated
THEN the axis SHALL fail closed
AND the ceremony SHALL NOT copy or invent a V2-local replacement enum.

### Requirement: Immutable Launch Attempt Ledger

The system SHALL use a finite launch-mode vocabulary of `xcode_run`, `signed_app`, and `archive`. Every launch mode, artifact, or environment change SHALL create a new immutable attempt ID. A failed attempt SHALL remain append-only with its artifact, mode, typed reason, timestamp, and evidence; a later success SHALL NOT update or delete that failure.

#### Scenario: Mode switch creates a new attempt

GIVEN an attempt fails under one launch mode
WHEN the operator switches launch mode or artifact
THEN a new attempt ID SHALL be appended
AND the original failed attempt SHALL remain unchanged.

#### Scenario: Hidden retry is not success evidence

GIVEN a launch fails and a later launch succeeds
WHEN the attempt ledger is read
THEN both the failed and successful attempts SHALL remain visible
AND the success SHALL NOT overwrite the failure or be silently attributed to the old attempt.

### Requirement: Expiry and Versioned Retest

The system SHALL transition a current ceremony result to `EXPIRED` when the build, environment, scenario, contract, waiver, or recovery conditions that support it change. Expiry SHALL produce versioned `RETEST_REQUIRED` requirements, and only a new immutable attempt satisfying all required predicates may become current.

#### Scenario: Supporting identity change expires a result

GIVEN a current ceremony result is tied to a build, environment, scenario, contract, waiver, or recovery identity
WHEN that supporting identity changes or the waiver expires
THEN the result SHALL become `EXPIRED`
AND the previous result SHALL remain historical rather than current.

#### Scenario: Retest requires a fresh attempt

GIVEN a result is `EXPIRED` and has versioned retest requirements
WHEN a retest is requested
THEN the system SHALL require a new immutable attempt and the listed predicates
AND it SHALL NOT reactivate the expired attempt by editing its row.

### Requirement: Synthetic T06 Evidence Cap

The system SHALL permit synthetic T06 fixtures only for local schema, join, mismatch, missing, duplicate, and stale-shape checks. Every synthetic fixture SHALL carry `synthetic=true`, `proof_class=local`, and `satisfies_t07b_prerequisite=false`.

#### Scenario: Synthetic fields are mandatory

GIVEN a fixture is marked synthetic
WHEN any of the three synthetic-cap fields is absent or contradictory
THEN the fixture SHALL fail closed
AND it SHALL NOT be accepted as a ceremony evidence input.

#### Scenario: Synthetic green cannot unlock T07b

GIVEN synthetic fixtures pass local schema or mismatch checks
WHEN T07b readiness is evaluated
THEN the result SHALL remain capped at local schema evidence
AND it SHALL NOT satisfy the real T06 prerequisite, operator-pass, V2 DONE, or V-PASS.

### Requirement: Phased Source and Final Ceremony Gates

The system SHALL keep `verify-operator-ceremony-source` as `PLANNED_GATE_NOT_YET_EXECUTABLE` until its target, official wiring, independent checker/behavior suite, and deliberate-red negatives exist. T07b and the final ceremony gate SHALL remain `PHASED_BLOCKED_UNTIL_REAL_T06` until a real current T06 same-subject receipt, all registry prerequisites, and an explicit ignition key are present.

#### Scenario: Missing source-gate materialization is not green

GIVEN the source-gate target or its official wiring/checker/negative suite is absent
WHEN status is reported
THEN the gate SHALL remain planned and non-executable
AND OpenSpec strict validation SHALL NOT be described as source-gate green.

#### Scenario: T07b lacks a real prerequisite or ignition

GIVEN a real current T06 receipt, a registry prerequisite, or the explicit ignition key is missing
WHEN T07b or P8 status is evaluated
THEN the status SHALL remain blocked
AND synthetic/local results SHALL NOT unlock operator-pass or V2 DONE.

### Requirement: Offline and Mock Evidence Does Not Become Operator Success

The system SHALL distinguish offline/local/mock or synthetic ceremony evidence from operator evidence. A successful local shape check, mock vehicle state, or readable receipt SHALL count only within its declared proof class and SHALL NOT become operator success without the exact real-subject joins and required evidence.

#### Scenario: Local offline evidence stays local

GIVEN a ceremony is evaluated from offline local fixtures or mock vehicle state
WHEN the local checks pass
THEN the result SHALL remain local or `local_schema_join_only`
AND it SHALL NOT be reported as operator-pass, V-PASS, or a real T07b ceremony.

#### Scenario: Missing evidence is not a success

GIVEN an axis, attempt, expiry, or evidence reference is missing or invalid
WHEN the ceremony result is computed
THEN the result SHALL fail closed or remain blocked
AND it SHALL NOT be rendered as a successful ceremony.
