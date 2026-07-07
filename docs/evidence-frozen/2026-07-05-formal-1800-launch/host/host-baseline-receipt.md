# W-I Host Baseline Receipt

status: `HOST_BASELINE_HOLD`
verdict: `DO_NOT_START_FORMAL_1800`
proof_class: `runtime_host_probe`
created_at: `2026-07-05T20:03:05+08:00`
repo: `/Users/wanglei/workspace/MAformac`
branch: `codex/rebuild-c6-doc-absorption-20260624`
receipt_kind: `authoritative_launch_adjacent_host_gate_receipt`
raw_sample: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch/host/host-sample-raw.txt`

## Conclusion

Host gate does **not** pass.

The swap gate passes (`0.290GB <= 1.0GB`), but the free/reclaimable gate does not pass under the chosen basis or the conservative basis. Per the frozen host policy, formal 1800 must remain HOLD until commander/human performs quiet actions, then this worker or another host-gate worker re-samples and produces a new receipt.

This worker did not start training, did not arm watchdog, did not kill GUI/worker processes, and did not modify the repo.

## Authority Read

| authority | relevant line/evidence | impact |
| --- | --- | --- |
| `host-watchdog-preflight.md` | Lines 16-19 say host/watchdog stay realtime and the previous sample was not launch baseline; lines 159-170 define fail-closed rules. | This task must produce a fresh runtime host receipt, not reuse the prior dry run. |
| `prelaunch-adversarial-audit.md` | Lines 21-24 preserve the realtime hold; lines 80-83 identify host/watchdog as launch risks; lines 93-100 require quiet, fresh baseline, and armed watchdog before actual launch. | `READY_FOR_RUN_AUTH` was not `READY_TO_LAUNCH`; this receipt is the host gate. |
| `formal-host-baseline.json` | Policy lines 12-17: D-094/D-102 fail-closed, `swap_used_gb_max=1.0`, `free_or_reclaimable_gb_min=21.0`, swap above 1GB escalates. | PASS requires both swap and free/reclaimable. |
| `baseline-roadmap-2026-07-05-c5-d106.md` | Lines 406-422: formal is evidence run only and requires host baseline + watchdog true pid; lines 443-449: host baseline not pass means D-094 escalation, no self-relaxation. | No launch while host baseline HOLD. |

## Sample Summary

| command | key output | gate impact |
| --- | --- | --- |
| `date -Iseconds` | `2026-07-05T20:03:05+08:00` | launch-adjacent sample timestamp |
| `sysctl vm.swapusage` | total `1024.00M`, used `297.19M`, free `726.81M` | `0.290GB` used; swap gate PASS |
| `memory_pressure` | system memory `34359738368`; free percentage `52%` | chosen basis gives `17.867GB`; free gate FAIL |
| `vm_stat` | page size `16384`; free `23956`; speculative `2981`; purgeable `18867`; inactive `523323` | conservative basis `0.750GB`; broad basis including inactive `9.325GB`; both FAIL |
| `df -h / /Users/wanglei/Projects/agent-tmux-stack-research` | `/` and Data volume both show `325Gi` available | disk not the blocker |
| `ps ... top 25 by RSS` | top RSS includes Claude, Codex renderer/app, ChatGPT Atlas renderers/app, WeChat, Feishu/Lark, WPS, Foxmail | quiet candidates exist; no kill performed |
| `pgrep -af 'c5_mlx_train_loop.py|mlx_lm|mlx_lm.lora|formal'` | exit `1`, no output | no residual formal/trainer process detected by this exact pattern |

## Free/Reclaimable Basis

The policy field is `free_or_reclaimable_gb`, but the frozen packet does not define a single arithmetic formula. I therefore report multiple bases and choose the non-favorable one for the gate.

| basis | formula | result | verdict |
| --- | --- | ---: | --- |
| chosen basis | `hw.memsize * memory_pressure_free_pct` = `34359738368 * 0.52 / 1e9` | `17.867GB` | FAIL |
| conservative basis | `(Pages free + Pages speculative + Pages purgeable) * 16384 / 1e9` | `0.750GB` | FAIL |
| broad-but-still-not-enough basis | `(Pages free + Pages speculative + Pages purgeable + Pages inactive) * 16384 / 1e9` | `9.325GB` | FAIL |

Because all three bases are below `21.0GB`, there is no ambiguous favorable interpretation that can pass this host gate.

## Trainer Process Exclusion

`pgrep -af 'c5_mlx_train_loop.py|mlx_lm|mlx_lm.lora|formal'` returned no matches (`exit=1`). No grep/rg/commander/poll false positive needed exclusion in the returned output.

The broader process table does show active GUI/worker load. Notable quiet candidates from the top RSS sample:

- `claude --resume 0f215415-...` RSS `568192`
- Codex renderer RSS `565568`
- multiple ChatGPT Atlas renderers/app RSS `505472`, `425232`, `416384`, `351472`, etc.
- WeChat RSS `459552`, plus `wxocr` RSS `271632`
- Feishu/Lark renderer RSS `297600`
- WPS Office RSS `223216`
- Foxmail RSS `219440`

These are recommendations for commander/human quieting only. This worker did not kill or close them.

## Gate Decision

```text
swap_used_gb = 0.290 <= 1.0
free_or_reclaimable_gb_chosen = 17.867 < 21.0
free_or_reclaimable_gb_conservative = 0.750 < 21.0

HOST_BASELINE_PASS = false
status = HOST_BASELINE_HOLD
```

## Minimal Self-Service Quiet Recommendations

Do not start formal training now. Minimal reversible next steps for commander/human:

1. Put nonessential workers into standby, especially browser-heavy/Codex/Claude side lanes not needed for the trainer.
2. Close or pause heavy GUI apps observed in top RSS: ChatGPT Atlas renderers, Codex desktop/renderers, WeChat/wxocr, Feishu/Lark renderers, WPS, Foxmail, if commander/human approves.
3. Avoid Xcode, browser-heavy work, model inference, C6 eval, and UIUE work during the next host gate sample.
4. Re-run the same host sample after quieting and write a new receipt.
5. If the gate still fails, request explicit `host-waiver-key`; do not reinterpret `free_or_reclaimable_gb` silently.

## Executor Candidate Note

This pane is the high Codex host-gate worker and can be considered a formal training executor candidate only after:

- commander explicitly assigns executor role;
- a new host receipt reaches `HOST_BASELINE_PASS` or a signed host waiver is recorded;
- watchdog is armed against the real trainer pid;
- frozen trainpack sha/row checks pass.

Current task scope remains host sampling only. No trainer was launched.

## Non-Claims

- not launch
- not watchdog armed
- not candidate
- not C6/V-PASS
- not model behavior proof
- not train health proof
- not host waiver
- not permission to start formal 1800

## Residual Risk

- Host memory can change immediately after this sample; any future launch needs a new adjacent receipt if quiet actions happen.
- The `free_or_reclaimable_gb` arithmetic should be codified by the launch owner before a later PASS receipt; this receipt uses transparent non-favorable bases and therefore does not pass.
- `pgrep` exact pattern can miss a future trainer launched under a different wrapper name; watchdog binding still must verify the real leaf trainer pid at launch.
