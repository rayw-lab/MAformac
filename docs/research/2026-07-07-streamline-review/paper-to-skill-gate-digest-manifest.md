---
artifact_kind: retire_digest_manifest
status: EXECUTION_PREP_ONLY_NOT_EXECUTED
batch: batch4_paper_to_skill_gate_retire
created_at: 2026-07-07
as_of_head: da0479b8
authority: physical_cleanup_execution_prep_not_ssot
source_plan: docs/research/2026-07-07-streamline-review/physical-cleanup-execution-pack.md
execution_script: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-07-ma-opt-refactor/out/batch4-paper-to-skill-gate-retire.sh
proof_class: local_git_ls_files + sha256_digest + external_ref_scan
non_claims:
  - not_executed
  - not_git_rm_done
  - not_validation_pass_after_execution
---

# Paper-To-Skill-Gate Digest Manifest

Batch 4 prepares `Tools/paper-to-skill-gate/` tracked retirement from 28 tracked files to 10 retained files. Exact path external ref scan for tracked files found no outside path references. Concept-level references still point to `docs/project/phase0/paper-to-skill-gate-absorption-ledger-2026-06-24.md`, not to files under `Tools/paper-to-skill-gate/`.

## Retain 10

| Path | sha256 | External referrers | Restore command |
|---|---|---|---|
| `Tools/paper-to-skill-gate/README.md` | `95dcf76d818717c5d1c30e9f2b41335c11e45fba1b14c4388073bd2d54d12e6d` | none | `git checkout da0479b8 -- Tools/paper-to-skill-gate/README.md` |
| `Tools/paper-to-skill-gate/SKILL.md` | `d19c4275c8af1590b835dbc17d174eece9ee0330189427303ce7953ada651fc0` | none | `git checkout da0479b8 -- Tools/paper-to-skill-gate/SKILL.md` |
| `Tools/paper-to-skill-gate/maformac-integration-map.md` | `db8b429d9e0c2918f7e012dae5dd7c2bc2828e5ec6ee6162479682085184cd70` | none | `git checkout da0479b8 -- Tools/paper-to-skill-gate/maformac-integration-map.md` |
| `Tools/paper-to-skill-gate/pipeline.md` | `7d21787773fdc3950ef0a574d3aa142b86dd9e40b576abe6d58039de0c004ecb` | none | `git checkout da0479b8 -- Tools/paper-to-skill-gate/pipeline.md` |
| `Tools/paper-to-skill-gate/reference-repos-ledger.md` | `b70543534012f411296a8e28d521c5f2848f031bf23f3a983e37a76c3d03a4df` | none | `git checkout da0479b8 -- Tools/paper-to-skill-gate/reference-repos-ledger.md` |
| `Tools/paper-to-skill-gate/schemas/gate-packet.schema.json` | `0ed794f8c52e9c79a422232dfca60b1d8ff0c0ddd4d569d06cc43c126f62a267` | none | `git checkout da0479b8 -- Tools/paper-to-skill-gate/schemas/gate-packet.schema.json` |
| `Tools/paper-to-skill-gate/scripts/validate_gate_packet.py` | `74723ed138ad7280ae837cd74f1abaaed3391088a6a880ef66199663392800d7` | none | `git checkout da0479b8 -- Tools/paper-to-skill-gate/scripts/validate_gate_packet.py` |
| `Tools/paper-to-skill-gate/templates/gate-report.md` | `2b8d3bdb74d70d352639dd895c06e7b876250ad56ac8aa4c6f8362b764b8f946` | none | `git checkout da0479b8 -- Tools/paper-to-skill-gate/templates/gate-report.md` |
| `Tools/paper-to-skill-gate/trial-runs/2026-06-24-p0-five-pack-audit.md` | `8f9645db8607a9ac0dccfdd8c791e7f1e8690d72930f3bf8ada0e28fc40560d1` | none | `git checkout da0479b8 -- Tools/paper-to-skill-gate/trial-runs/2026-06-24-p0-five-pack-audit.md` |
| `Tools/paper-to-skill-gate/trial-runs/2026-06-24-p0-five-pack-index.md` | `00cd6dcd912d70d46691426fd87064fae9523ba92fa37c101bbeb3b66b950159` | none | `git checkout da0479b8 -- Tools/paper-to-skill-gate/trial-runs/2026-06-24-p0-five-pack-index.md` |

## Retire 18

| Path | sha256 | External referrers | Restore command |
|---|---|---|---|
| `Tools/paper-to-skill-gate/paper-repos/.gitignore` | `457dd7debe2350de332fb5bbe49f49e9ff5ff7f3eb99f01719534c8695d844ab` | none | `git checkout da0479b8 -- Tools/paper-to-skill-gate/paper-repos/.gitignore` |
| `Tools/paper-to-skill-gate/reference-repos/.gitignore` | `db7582d9491e6e245d254ea78d940edbcdfaaaf37afcea4a3dfe255ad589b421` | none | `git checkout da0479b8 -- Tools/paper-to-skill-gate/reference-repos/.gitignore` |
| `Tools/paper-to-skill-gate/trial-runs/abc-rigorous-agentic-benchmarks-p0.gate.json` | `5a3a8c838472e84bf330a5a843db0799b404e322273213f95b53a5f9fddc60a6` | none | `git checkout da0479b8 -- Tools/paper-to-skill-gate/trial-runs/abc-rigorous-agentic-benchmarks-p0.gate.json` |
| `Tools/paper-to-skill-gate/trial-runs/abc-rigorous-agentic-benchmarks-p0.md` | `c08148ed18343c20c24dc4c831336994935814f3a4c5e54892d6059b2ca5130b` | none | `git checkout da0479b8 -- Tools/paper-to-skill-gate/trial-runs/abc-rigorous-agentic-benchmarks-p0.md` |
| `Tools/paper-to-skill-gate/trial-runs/function-calling-data-generation-pack-p0.gate.json` | `c583c1c2639357c1a9c7e150c37cb85410c6860dd78f58ef34d6e22e048f5c2e` | none | `git checkout da0479b8 -- Tools/paper-to-skill-gate/trial-runs/function-calling-data-generation-pack-p0.gate.json` |
| `Tools/paper-to-skill-gate/trial-runs/function-calling-data-generation-pack-p0.md` | `4480632862d9a6f70c0d8d464493e8745f9c3d1a63e3bbe9c2bed2d32b79a74f` | none | `git checkout da0479b8 -- Tools/paper-to-skill-gate/trial-runs/function-calling-data-generation-pack-p0.md` |
| `Tools/paper-to-skill-gate/trial-runs/in-vehicle-function-calling-p0.gate.json` | `cb54add822214216d086464e91c97dc005a9a38a379c91254beb43f54661a692` | none | `git checkout da0479b8 -- Tools/paper-to-skill-gate/trial-runs/in-vehicle-function-calling-p0.gate.json` |
| `Tools/paper-to-skill-gate/trial-runs/in-vehicle-function-calling-p0.md` | `71904240ecbc8bac4995aa0fcb12a8a157065c0339548c744e273d8e216c95e3` | none | `git checkout da0479b8 -- Tools/paper-to-skill-gate/trial-runs/in-vehicle-function-calling-p0.md` |
| `Tools/paper-to-skill-gate/trial-runs/internalizing-tool-knowledge-in-slms-via-qlora.gate.json` | `60cff124319ef9bab4d078a6090f87ac41c1135dbd59ef40107758a55d1ad0a4` | none | `git checkout da0479b8 -- Tools/paper-to-skill-gate/trial-runs/internalizing-tool-knowledge-in-slms-via-qlora.gate.json` |
| `Tools/paper-to-skill-gate/trial-runs/internalizing-tool-knowledge-in-slms-via-qlora.md` | `80bef239da21a0e2e115d0c05a55bbf549a236baf2aaa8ff3ed075247bbd119d` | none | `git checkout da0479b8 -- Tools/paper-to-skill-gate/trial-runs/internalizing-tool-knowledge-in-slms-via-qlora.md` |
| `Tools/paper-to-skill-gate/trial-runs/leakage-decontamination-pack-p0.gate.json` | `db986400a1084a9381c19d211e0f004c49ea43263a71167df07e8f1025b593da` | none | `git checkout da0479b8 -- Tools/paper-to-skill-gate/trial-runs/leakage-decontamination-pack-p0.gate.json` |
| `Tools/paper-to-skill-gate/trial-runs/leakage-decontamination-pack-p0.md` | `cbf3b8fe1a6e270691fd7b07ea7ffdcf847542958cb0028e3707b054fa966e6f` | none | `git checkout da0479b8 -- Tools/paper-to-skill-gate/trial-runs/leakage-decontamination-pack-p0.md` |
| `Tools/paper-to-skill-gate/trial-runs/learning-rate-matters-vanilla-lora-may-suffice.gate.json` | `70b65a23f0122c9c93940e7109fa05bbf9c6fecd98a35ba9db624d996a306382` | none | `git checkout da0479b8 -- Tools/paper-to-skill-gate/trial-runs/learning-rate-matters-vanilla-lora-may-suffice.gate.json` |
| `Tools/paper-to-skill-gate/trial-runs/learning-rate-matters-vanilla-lora-may-suffice.md` | `d3d22cc02378873eaccdc489927e7784501a7e2d519c0a42b761f2c607347058` | none | `git checkout da0479b8 -- Tools/paper-to-skill-gate/trial-runs/learning-rate-matters-vanilla-lora-may-suffice.md` |
| `Tools/paper-to-skill-gate/trial-runs/tinyagent-function-calling-at-the-edge.gate.json` | `9d8162b85a80ec84f68da3232203510e6f274e559954d2449578be65c6722ef9` | none | `git checkout da0479b8 -- Tools/paper-to-skill-gate/trial-runs/tinyagent-function-calling-at-the-edge.gate.json` |
| `Tools/paper-to-skill-gate/trial-runs/tinyagent-function-calling-at-the-edge.md` | `862e929b39de77fc9c2e2254e4fceec652acf1507bf680b3a7281dd922191b44` | none | `git checkout da0479b8 -- Tools/paper-to-skill-gate/trial-runs/tinyagent-function-calling-at-the-edge.md` |
| `Tools/paper-to-skill-gate/trial-runs/when2call-tool-decision-p0.gate.json` | `84781d00d55e78f167a19ca5ddc6e2db255a5ab3b250cd2cbff60969d37ee383` | none | `git checkout da0479b8 -- Tools/paper-to-skill-gate/trial-runs/when2call-tool-decision-p0.gate.json` |
| `Tools/paper-to-skill-gate/trial-runs/when2call-tool-decision-p0.md` | `abff37b10aa8ddd26a07eb7933c6c65c992ac0588cc2979e4182931007cbdece` | none | `git checkout da0479b8 -- Tools/paper-to-skill-gate/trial-runs/when2call-tool-decision-p0.md` |

## Execution guard

After commander runs the script, expected tracked count:

```bash
git ls-files Tools/paper-to-skill-gate | wc -l
git ls-files Tools/paper-to-skill-gate
```

Expected result: count `10`, matching the retain list above.
