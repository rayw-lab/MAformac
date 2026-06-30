## iOS Build Defaults

This worktree is preconfigured for Codex `build-ios-apps`.

- Profile: `ios`
- Project: `/Users/wanglei/workspace/MAformac-uiue/MAformac.xcodeproj`
- Scheme: `MAformacIOS`
- Simulator: `iPhone 17 Pro Max`

Use this flow in new Codex windows:

1. Call `session_show_defaults`.
2. If the active profile is not `ios`, call `session_use_defaults_profile({ profile: "ios" })`.
3. Run `build_run_sim()`.

Do not switch this worktree to the main-worktree simulator by default. The iOS bundle id is shared across worktrees, so one simulator per worktree keeps installs isolated.
