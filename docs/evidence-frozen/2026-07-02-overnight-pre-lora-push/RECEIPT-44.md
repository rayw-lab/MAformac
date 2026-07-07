# RECEIPT-44 — gate8 tool_count 实算

## verdict

- status: `local-pass`
- worker: `%44`
- worktree: `/Users/wanglei/workspace/MAformac-g8-tool`
- branch: `c5gate/g8-tool-count`
- base HEAD at start: `ab355f6cdb82`
- R7 boundary: kept. No training, no data generation, no C6 acceptance, no model evaluation, no cloud/API calls.

## changed files

| file:line | change | evidence |
|---|---|---|
| `generated/family-device-allowlist.json:302` | `meta.tool_count` changed from TBD string to numeric `562` | true count derived from D-domain tool catalog count, not copied from `demo_intents` |
| `generated/family-device-allowlist.json:303` | added `tool_count_derivation` | records `ToolContractCompiler.loadDDomainCatalog(repoRoot:).count over generated/D_domain.tools.demo.json` and explicitly says `not demo_intents reuse` |
| `Tests/MAformacCoreTests/ToolContractCompilerTests.swift:30` | added contract test | decodes allowlist meta and compares `tool_count` to `ToolContractCompiler.loadDDomainCatalog(...).count` |
| `Tests/MAformacCoreTests/ToolContractCompilerTests.swift:35` | anti-fake-green assertion | fails if allowlist `tool_count` diverges from compiler-loaded D-domain catalog count |
| `Tests/MAformacCoreTests/ToolContractCompilerTests.swift:36` | derivation assertion | requires `ToolContractCompiler.loadDDomainCatalog` to be named in metadata |
| `Tests/MAformacCoreTests/ToolContractCompilerTests.swift:37` | 562-intent misuse guard | requires metadata to state `not demo_intents reuse` |
| `Tests/MAformacCoreTests/ToolContractCompilerTests.swift:298` | added local decode fixture | test-only decoder for `meta.tool_count` / `tool_count_derivation` |

## tool_count 实算

Command:

```bash
python3 - <<'PY'
import json, pathlib, statistics
root=pathlib.Path('.')
catalog=json.loads((root/'generated/D_domain.tools.demo.json').read_text())
schemas=[{'type': e['type'], 'function': e['function']} for e in catalog]
rendered=json.dumps({'tools': schemas}, ensure_ascii=False, separators=(',', ':'))
per_tool=[len(json.dumps({'type': e['type'], 'function': e['function']}, ensure_ascii=False, separators=(',', ':'))) for e in catalog]
print(f'tool_count={len(catalog)}')
print(f'rendered_tools_chars={len(rendered)}')
print(f'avg_chars_per_tool={sum(per_tool)/len(per_tool):.1f}')
print(f'p50_chars_per_tool={statistics.median(per_tool):.1f}')
print(f'p95_chars_per_tool={sorted(per_tool)[int(len(per_tool)*0.95)-1]}')
for divisor in (3.0, 3.5, 4.0):
    print(f'est_tokens_chars/{divisor:g}={len(rendered)/divisor:.0f}')
print('budget_8k_status=' + ('OVER' if len(rendered)/4.0 > 8192 else 'OK'))
print('budget_32k_status=' + ('OVER' if len(rendered)/4.0 > 32768 else 'OK'))
PY
```

Output:

```text
tool_count=562
rendered_tools_chars=297727
avg_chars_per_tool=528.7
p50_chars_per_tool=536.0
p95_chars_per_tool=982
est_tokens_chars/3=99242
est_tokens_chars/3.5=85065
est_tokens_chars/4=74432
budget_8k_status=OVER
budget_32k_status=OVER
```

Interpretation:

- true D-domain named tool count is `562`, but this receipt does not use `demo_intents=562` as authority.
- Authority path is `ToolContractCompiler.loadDDomainCatalog(repoRoot:)` reading `generated/D_domain.tools.demo.json`, then `catalog.count`.
- `generated/family-device-allowlist.json` now records the derivation so future readers can tell this from the intent-count coincidence.

## E-2 context budget

- Full D-domain schema surface estimate: `297,727` compact JSON chars.
- Conservative token proxy:
  - chars/4: `~74,432` tokens
  - chars/3.5: `~85,065` tokens
  - chars/3: `~99,242` tokens
- Result: ⚠️ `OVER` for both Qwen3-1.7B `8K base` and `32K chat`.
- Risk: full 562-tool schema injected into one system prompt can exceed context and recreate θ-α style surface truncation / behavior collapse risk.
- Recommended downstream mitigation: retrieval/subset tool surface or constrained decoding table, not full-catalog prompt stuffing.

## validation

```bash
swift build
```

Result: exit `0`; build complete. Warning only: existing unhandled files (`MAformacIOSUITests/U17GoldenPathUITests.swift`, `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift`, `UBIQUITOUS_LANGUAGE.md`).

```bash
swift test --filter ToolContractCompiler
```

Result: exit `0`; `23` selected tests passed, including:

- `ToolContractCompilerTests.testFamilyAllowlistToolCountMatchesDDomainCatalog`
- existing `testLoadDDomainCatalogProduces562Tools`
- existing `testDDomainSurfaceConsumesCatalogNotHardcoded`

```bash
python3 scripts/gen_family_allowlist.py --check
```

Result: exit `0`; all 10 families match, total `device 191/191`, `intent 562/562`, `行 2159/2159`; out-of-scope `device 480/480`, `intent 976/976`, `行 1831/1831`.

```bash
git diff --check
```

Result: exit `0`.

## git state

```text
 M Tests/MAformacCoreTests/ToolContractCompilerTests.swift
 M generated/family-device-allowlist.json
```

No commit or push performed; dispatch only required receipt + commander report.

## residual risk

- Token estimate uses compact JSON char/token proxy, not a Qwen tokenizer. It is already far above 32K even under chars/4, so the warning is robust.
- `scripts/gen_family_allowlist.py --check` does not validate `tool_count`; the new Swift test covers this gap.
