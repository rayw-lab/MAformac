# Agent Platform Plugin References

Local symlink index for agents working on iOS/macOS frontend, runtime, visual, simulator, or packaging tasks.

Read this directory before SwiftUI, iOS, macOS, Liquid Glass, simulator, performance, signing, or app packaging work.

## Worktree iOS Build Default

This main worktree is preconfigured for Codex `build-ios-apps`.

- Default profile: `ios`
- Project: `MAformac.xcodeproj`
- Scheme: `MAformacIOS`
- Dedicated simulator: `iPhone 17 Pro`
- Local config file: `.xcodebuildmcp/config.yaml`

New Codex windows in this worktree should use this order:

1. Read this file and `.xcodebuildmcp/README.md`.
2. Call `session_show_defaults`.
3. If the active profile is not `ios`, call `session_use_defaults_profile({ profile: "ios" })`.
4. Build/run with `build_run_sim()`.

Do not point this worktree at the UIUE simulator by default. Both worktrees currently use the same iOS bundle id, so sharing one simulator causes install overwrite churn.

## Symlink Targets

- `build-ios-apps-plugin` -> `/Users/wanglei/.codex/plugins/cache/openai-curated-remote/build-ios-apps/0.1.2`
- `build-ios-apps-skills` -> `/Users/wanglei/.codex/plugins/cache/openai-curated-remote/build-ios-apps/0.1.2/skills`
- `build-macos-apps-plugin` -> `/Users/wanglei/.codex/plugins/cache/openai-curated-remote/build-macos-apps/0.1.4`
- `build-macos-apps-skills` -> `/Users/wanglei/.codex/plugins/cache/openai-curated-remote/build-macos-apps/0.1.4/skills`

These links are local operator references, not project source. If a symlink is broken, re-check the current plugin cache under `/Users/wanglei/.codex/plugins/cache/openai-curated-remote/`.
