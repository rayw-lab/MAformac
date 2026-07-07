# ARCHEO-bridge-schema-verdict

- reviewer: %44 Codex
- task: bridge schema archaeology + verdict
- proof class: `local` read-only git/file-line archaeology
- main truth target: `origin/main` @ `f4af8ccfc7d5f9249db53491d64648948aea03ca`
- current PR30 repair head observed: `3bb42613fd940f07af4d963f165bc312ba0d69d9`
- merge-base(`origin/main`, `HEAD`): `db0550026ef3f86d560a039696275da95b152ab3`
- verdict: **NO SEPARATE MAIN RESTORE PR NEEDED; DO NOT TREAT THE SCHEMA AS SUPERSEDED**

## Conclusion

The 104-line `public_fixture_schema.v1.json` block is **not** "main intentionally removed" and is **not** superseded. It is an intentional D23 main-owned contract artifact that is present on `origin/main`.

So the answer to the recovery question is:

- For `origin/main`: **no standalone recovery PR is needed**, because main already contains the schema file, manifest `sharedSchema` block, and `partialAcceptPartialRefuse` enum/usage.
- For current PR30 repair head `3bb42613`: its final tree is missing `Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json`; if this branch is rebased/linearized onto main as a tree state, that deletion must be fixed by restoring the file from `origin/main` or `c5016f89`. Direct 3-way merge prediction keeps the schema in the merged tree, but the PR also has unrelated doc merge conflicts, so this should not be hand-waved.

## Evidence: main tip contains the schema contract

`origin/main` contains `partialAcceptPartialRefuse` in the bridge enum and emits it through partial accept/refuse:

```text
/tmp/archeo-bridge-schema-main/Core/Presentation/RuntimePresentationBridge.swift:53
case partialAcceptPartialRefuse = "partial_accept_partial_refuse"

/tmp/archeo-bridge-schema-main/Core/Presentation/RuntimePresentationBridge.swift:638
result: .partialAcceptPartialRefuse
```

`origin/main` contains the manifest `sharedSchema` block:

```text
/tmp/archeo-bridge-schema-main/Tests/Fixtures/RuntimePresentationPayload/manifest.json:3-11
"sharedSchema": {
  "name": "public_fixture_schema.v1.json",
  "schemaVersion": "r5_runtime_presentation_public_fixture_schema_v1",
  "ownerRepo": "MAformac",
  "ownerPath": "Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json",
  "sha256": "0833e599921bb680c8a6a80a51aecf4fb6e08241b1392661e2466ae5f345849b",
  "consumerRepo": "MAformac-uiue",
  "consumerPath": "Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json",
  "updateRule": "UIUE must copy this main-owned schema artifact unchanged or fail parity review."
}
```

`origin/main` contains the schema file itself:

```text
/tmp/archeo-bridge-schema-main/Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json:1-7
{
  "schemaVersion": "r5_runtime_presentation_public_fixture_schema_v1",
  "ownerRepo": "MAformac",
  "ownerPath": "Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json",
  "manifestSchemaVersion": "r5_runtime_presentation_payload_fixture_manifest_v1",
  "payloadSchemaVersion": "r5_runtime_presentation_payload_v1",
  "fixtureCount": 9,

/tmp/archeo-bridge-schema-main/Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json:26-31
"allowedResults": [
  "accepted_tool_call",
  "refusal_safety_or_policy",
  "runtime_error",
  "partial_accept_partial_refuse"
]
```

File-presence proof:

```text
$ git cat-file -e origin/main:Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json && echo origin_main_schema=present
origin_main_schema=present
```

## Evidence: D22/D23 commit archaeology

The D22/D23 line is in `origin/main`.

Relevant path log on `origin/main`:

```text
$ git log --oneline origin/main -- Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json Tests/Fixtures/RuntimePresentationPayload/manifest.json Tests/MAformacCoreTests/RuntimePresentationPayloadPublicFixtureTests.swift Core/Presentation/RuntimePresentationBridge.swift
f15f473e merge: reconcile UIUE branch after D24 main absorption
609f3258 test(uiue): adopt shared public fixture schema
09525cf8 test(runtime): add shared public fixture schema
b24dafcd D22 fix GPT Pro payload contract findings
2091dbde D22 consume expanded runtime payload corpus
db055002 D22 expand runtime payload fixture corpus
...
```

Twin/duplicate-message commit check:

```text
db055002 D22 expand runtime payload fixture corpus                     contains_origin_main=yes
2091dbde D22 consume expanded runtime payload corpus                   contains_origin_main=yes
3ff0eba4 D22 fix GPT Pro payload contract findings                     contains_origin_main=no
b24dafcd D22 fix GPT Pro payload contract findings                     contains_origin_main=yes
a1fe4c9b test(runtime): add shared public fixture schema               contains_origin_main=no
09525cf8 test(runtime): add shared public fixture schema               contains_origin_main=yes
5875b8fb test(uiue): adopt shared public fixture schema                contains_origin_main=no
609f3258 test(uiue): adopt shared public fixture schema                contains_origin_main=yes
7c5c8a8a docs(runtime): record d23 advisory audits                     contains_origin_main=yes
1b84af5f docs(uiue): record d23 advisory audits                        contains_origin_main=yes
02f0722f ci: allow temporary D24 self-hosted verify runner             contains_origin_main=yes
```

`09525cf8` is the main-side schema commit:

```text
$ git show --name-status --oneline 09525cf8 -- Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json Tests/Fixtures/RuntimePresentationPayload/manifest.json Tests/MAformacCoreTests/RuntimePresentationPayloadPublicFixtureTests.swift
09525cf8 test(runtime): add shared public fixture schema
M	Tests/Fixtures/RuntimePresentationPayload/manifest.json
A	Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json
M	Tests/MAformacCoreTests/RuntimePresentationPayloadPublicFixtureTests.swift
```

`b24dafcd` is the D22 partial-accept/refuse correction:

```text
$ git show --name-status --oneline b24dafcd -- Core/Presentation/RuntimePresentationBridge.swift Tests/MAformacCoreTests/RuntimePresentationBridgeTests.swift Tests/MAformacCoreTests/RuntimePresentationPayloadPublicFixtureTests.swift
b24dafcd D22 fix GPT Pro payload contract findings
M	Core/Presentation/RuntimePresentationBridge.swift
M	Tests/MAformacCoreTests/RuntimePresentationBridgeTests.swift
M	Tests/MAformacCoreTests/RuntimePresentationPayloadPublicFixtureTests.swift
```

No later `origin/main` path-log deletion/revert of `public_fixture_schema.v1.json` was found:

```text
$ git log --oneline origin/main -- Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json
09525cf8 test(runtime): add shared public fixture schema
```

Pickaxe also only finds add/adopt/route-control references, not a superseding deletion:

```text
$ git log --oneline -S'public_fixture_schema.v1.json' origin/main -- ...
a0177b1d docs: add D24 UIUE absorption route control
609f3258 test(uiue): adopt shared public fixture schema
09525cf8 test(runtime): add shared public fixture schema
```

## Receipts confirm intent

D23 main receipt explicitly says main owns the schema artifact:

```text
docs/project/phase0/r5-d23-shared-schema-checker-main-receipt-2026-06-30.md:7
Main owns `Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json`.

docs/project/phase0/r5-d23-shared-schema-checker-main-receipt-2026-06-30.md:8
Main manifest now references that schema artifact with sha256, owner path, UIUE consumer path, and update rule.

docs/project/phase0/r5-d23-shared-schema-checker-main-receipt-2026-06-30.md:14-16
Changed Main Paths include `public_fixture_schema.v1.json`, `manifest.json`, and `RuntimePresentationPayloadPublicFixtureTests.swift`.
```

D23 commander verdict records the same main-owned schema/checker surface:

```text
docs/project/phase0/r5-d23-shared-schema-checker-commander-verdict-2026-06-30.md:44
Main schema/checker | `Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json`, `manifest.json`, `RuntimePresentationPayloadPublicFixtureTests.swift` ... | Main owns the portable schema artifact and schema-driven tests.
```

D22 receipt records the partial accept/refuse enum as the GPT Pro P1 fix:

```text
docs/project/phase0/r5-d22-runtime-payload-corpus-expansion-main-receipt-2026-06-30.md:39
main now includes `DemoRuntimeResult.partialAcceptPartialRefuse = "partial_accept_partial_refuse"` ...
```

## Current PR30 repair head caveat

Current observed PR30 repair head `3bb42613` deleted the schema file relative to `c5016f89`:

```text
$ git diff --name-status c5016f89..3bb42613 -- Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json Tests/Fixtures/RuntimePresentationPayload/manifest.json
M	Tests/Fixtures/RuntimePresentationPayload/manifest.json
D	Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json

$ git diff --stat c5016f89..3bb42613 -- Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json Tests/Fixtures/RuntimePresentationPayload/manifest.json
.../manifest.json                         |   8 +-
.../public_fixture_schema.v1.json         | 104 ---------------------
2 files changed, 4 insertions(+), 108 deletions(-)
```

Current PR30 repair head final tree lacks the schema, while `origin/main` has it:

```text
$ git cat-file -e origin/main:Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json && echo origin_main_schema=present
origin_main_schema=present

$ git cat-file -e HEAD:Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json && echo head_schema=present || echo head_schema=absent
head_schema=absent

$ git cat-file -e $(git merge-base origin/main HEAD):Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json && echo merge_base_schema=present || echo merge_base_schema=absent
merge_base_schema=absent
```

Two-dot tree comparison from `origin/main` to current `HEAD` therefore shows a deletion:

```text
$ git diff --exit-code origin/main -- Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json
deleted file mode 100644
@@ -1,104 +0,0 @@
```

But direct 3-way merge prediction keeps the schema in the virtual merged tree:

```text
$ git merge-tree --write-tree origin/main HEAD
94e139105e1c7d5e4d5eaa9ebf88c03172ec7528
... unrelated docs conflicts ...

$ git cat-file -e 94e139105e1c7d5e4d5eaa9ebf88c03172ec7528:Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json && echo merge_tree_schema=present
merge_tree_schema=present
```

This happens because the merge base `db055002` lacked the schema, main added it in `09525cf8`, and the current PR head final tree also lacks it. In normal 3-way semantics, "main added; PR did not net-change the path relative to merge base" keeps main's file. If the branch is rebased or tree-linearized onto main, the missing file becomes a real deletion and must be fixed.

## Minimal recovery plan if needed

If a future integration step makes the schema absent from the target tree, use a tiny recovery PR with only this path:

```text
Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json
```

Source:

```text
git show origin/main:Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json
# or equivalent identical source:
git show c5016f89c696dccebcf73ef3958b1a173e746f14:Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json
```

Integrity check:

```text
shasum -a 256 Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json
# expected: 0833e599921bb680c8a6a80a51aecf4fb6e08241b1392661e2466ae5f345849b
```

Minimal validation:

```text
swift test --filter RuntimePresentationPayloadPublicFixtureTests
```

Do not modify bridge code, payload fixtures, or OpenSpec tasks in that recovery PR unless a fresh diff proves they diverged from `origin/main`.

## Final verdict

**KEEP_MAIN_SCHEMA / NO_STANDALONE_RESTORE_FOR_MAIN / WATCH_PR30_INTEGRATION_MODE**

The schema is main-intended and live on `origin/main`; it is not superseded. The only actionable risk is PR30's current head as a standalone tree lacks the schema, so any rebase/linearized recovery must restore the exact 104-line artifact before claiming main parity.
