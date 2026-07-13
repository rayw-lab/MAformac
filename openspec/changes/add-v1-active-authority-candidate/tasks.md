# Add V1 Active Authority Candidate — Tasks

> DRAFT. Task checklist for the V1 active authority candidate change.

## 0. Documentation Absorption

- [x] 0.1 Read D-147, B7/V1 registry entry, rebuild-c6 specs, and closure-work-packages.v1.yaml V1 entry
- [x] 0.2 Confirm writable set boundaries (no-touch list verified)
- [ ] 0.3 Validate with `openspec validate add-v1-active-authority-candidate --strict`
- [ ] 0.4 Validate workspace OpenSpec consistency with `openspec validate --all --strict` (optional; record gap if unavailable)
- [ ] 0.5 Run `git diff --check`
- [ ] 0.6 Confirm diff touches only the writable set

## 1. Authority Schema

- [x] 1.1 Create `contracts/c6-active-authority/authority-schema.v1.json` with all required fields + exact `source_members`
- [x] 1.2 Create `contracts/c6-active-authority/authority-subject.v1.schema.json` for subject tuple
- [x] 1.3 Create `contracts/c6-active-authority/authority.v1.candidate.json` with status=CANDIDATE, live hashes, source_members
- [ ] 1.4 Validate authority instance against schema with `python3 -m jsonschema -i contracts/c6-active-authority/authority.v1.candidate.json contracts/c6-active-authority/authority-schema.v1.json`

## 2. Source Checker

- [x] 2.1 Create `scripts/check_c6_active_authority_candidate.py` with:
  - Structural required fields including source_members
  - Ratification ref SHA256 non-placeholder + non-all-zero check
  - Decision ref D-format and required_state check
  - Subject value exact-set checks (subject mismatch fail-closed)
  - Exact source_members live path/hash/member-set + stale/duplicate/missing/ambiguous fail-closed
  - Digest self-consistency check
  - Exit code 0 on pass, non-zero on any failure
- [x] 2.2 Create `scripts/test_check_c6_active_authority_candidate.py` with:
  - Positive test: valid candidate passes
  - Deliberate-red: stale source_member
  - Deliberate-red: duplicate source_member
  - Deliberate-red: missing source_member
  - Deliberate-red: subject mismatch
  - Deliberate-red: all-zero SHA256
  - Plus existing structural negatives
  - Live candidate integration test
- [ ] 2.3 Run checker on authority.v1.candidate.json: exit 0
- [ ] 2.4 Run test suite: `python3 -B scripts/test_check_c6_active_authority_candidate.py` exit 0

## 3. Candidate Receipt

- [x] 3.1 Create `closure/candidates/V1/V1.v1.candidate-receipt.json` with:
  - Schema version, package_id=V1, status=CANDIDATE (not DONE / not V1 DONE)
  - Live registry_digest / native_receipt.sha256 / authority_digest / pool32 hash
  - Subject tuple covering load-bearing fields + is_canonical=false + is_v1_done=false
  - Explicit non-claims
- [ ] 3.2 Note: exit-envelope schema requires status=DONE; candidate intentionally uses status=CANDIDATE so full DONE envelope validation is deferred until ratification

## 4. Tool Documentation

- [x] 4.1 Create `Tools/C6ActiveAuthority/README.md` with:
  - Authority identity and version
  - Machine-readable source_members table
  - D-147 T01 narrative mapping
  - Subject tuple reference
  - Migration/fan-in instructions
  - Consumer guidance / non-claims

## 5. OpenSpec Change

- [x] 5.1 Create `proposal.md` with typed_status frontmatter
- [x] 5.2 Create `design.md` with AD-V1-001 through AD-V1-010
- [x] 5.3 Create `tasks.md` (this file)
- [x] 5.4 Create `specs/c6-active-authority/spec.md` with OpenSpec capability delta (`## ADDED Requirements` + Requirement/Scenario)
- [ ] 5.5 Run `openspec validate add-v1-active-authority-candidate --strict`
