---
status: F044_TRAIN_HEALTH_PASS_ARTIFACT_BOUND
artifact_kind: f044_shorttrain_train_receipt
proof_class: local/train_health_plus_artifact_binding_no_behavior_claim
run_dir: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/F044-shorttrain-run-20260703T175733+0800
basis_id:
  code: CODE-2026-07-03-PR38 (pin 266783468ac38542574ea4787bec650d16ba6b02)
  data: DATA-WAVE1-SUBSTRATE-v3 + wave1-corpus-250 (rendered mlx-data, DataGate/preflight receipt=F044-DATA-READY-RECEIPT.md)
train_health:
  optimizer_updates: 150/150
  nonfinite: 0
  peak_memory_gb_max: 17.974 (fail 22.34, hard 32)
  wall_clock: 2026-07-03T17:57+0800 -> 21:51+0800 (~14040s, fail 42375s)
  final_train_loss: 0.0598
  val_loss_curve: '3.0945(it1) -> 0.1613(200) -> 0.042(400) -> 0.0192(600)'
  blocked_receipts: none
  watchdog: exit0, supervisor restarts=0
claim_boundary: train_health + artifact binding only; NO behavior/model-quality/train-ready/C6/V-PASS claim; behavior eval next per F044-VERDICT-DECISION-TREE.md
artifact_sha256:
  adapters-rank16/adapters.safetensors: b68db1738d7f99a32167439ee148781a33844c615d2ced05fbd2799c1cee4083
  adapters-rank16/adapter_config.json: a971122af19a4d2548ee2a19db4b34ea9a8e39f909bb3c0810162d780154ac0e
  adapters-rank16/0000600_adapters.safetensors: b68db1738d7f99a32167439ee148781a33844c615d2ced05fbd2799c1cee4083
  metrics.jsonl: 3eb5441ecce1ccc9520887191ffb1249a611cffaa3d4d1c252d29554083156b8
  train.log: 3b6eb06a7a137805522c1d9c51180e50f4dbde611e32096ad633818af17bec70
  c5_mlx_train_loop.snapshot.py: 9714f6f2700a4c0f77be6bfdc005d291a894e858606a87a1a3838fd9a8f71748
