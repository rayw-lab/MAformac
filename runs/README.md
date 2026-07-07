# MAformac Runs Pointer

status: ACTIVE_POINTER_ONLY
updated_at: 2026-07-06T13:47:21+08:00

This directory is a tracked pointer/backstop only. Raw commander run dirs live outside the repo:

`/Users/wanglei/Projects/agent-tmux-stack-research/runs`

Do not put adapters, checkpoints, metrics dumps, training logs, browser captures, generated media, or ad hoc run directories here. Project-level cascade rules are in `docs/commander-log/RUNS-CASCADE.md`.

Non-README contents under this directory are local residue by default and must not be staged with `git add .`. At W14, local residue was observed at:

- `runs/tiny-ablation-adjudication-A/DONE-XPR25`
- `runs/tiny-ablation-adjudication-A/XAUDIT-PR25.md`

Maintenance probes:

```bash
git ls-files runs
find runs -maxdepth 4 -type f -print | sort
find /Users/wanglei/Projects/agent-tmux-stack-research/runs -maxdepth 2 -type d | sort
```
