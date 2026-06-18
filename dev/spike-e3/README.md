# spike E3 function-call harness

Scope: isolated SwiftPM harness for `define-execution-contract` task 0.1.

- Model: `mlx-community/Qwen3-1.7B-4bit`
- Runtime: `mlx-swift-lm` pinned exact `3.31.3`
- Tokenizer/HF bridge: `swift-transformers` pinned exact `1.3.3`, `swift-huggingface` pinned exact `0.9.0`
- Output: `Reports/spike-e3-report.md` and `Reports/spike-e3-results.json`
- Boundary: this package is isolated under `dev/spike-e3/`; do not add MLX deps to the repo root package until change3 adopts the path.

Run:

```bash
cd /Users/wanglei/workspace/MAformac/dev/spike-e3
swift build -c release
DERIVED_DATA_PATH="$PWD/DerivedData"
xcodebuild -scheme SpikeE3FunctionCall -configuration Release -destination 'platform=macOS,arch=arm64' -derivedDataPath "$DERIVED_DATA_PATH" -skipMacroValidation -skipPackagePluginValidation build

PRODUCT_DIR="$DERIVED_DATA_PATH/Build/Products/Release"
test -x "$PRODUCT_DIR/spike-e3"
test -f "$PRODUCT_DIR/mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib"
"$PRODUCT_DIR/spike-e3" --limit 3 --output-dir /Users/wanglei/workspace/MAformac/dev/spike-e3/Reports
"$PRODUCT_DIR/spike-e3" --output-dir /Users/wanglei/workspace/MAformac/dev/spike-e3/Reports
```

`swift run` can build the executable but does not package MLX's `default.metallib`;
use the Xcode-built product so `mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib`
is beside the binary.

The harness loads one base model, creates a fresh `ChatSession` per case to avoid history contamination, sets `additionalContext["enable_thinking"] = false`, and streams `.chunk` / `.toolCall` / `.info` events.
