# Design

`DDomainCompletionEnvelope` is the only production input to the strict parser. The
parser first validates source and finish metadata, then requires the content to consist
exclusively of one or more complete `<tool_call>...</tool_call>` blocks. It compares the
parsed count with the declared count before applying `ToolPlanCardinalityPolicy`.

`DDomainToolPlanBackend` consumes the envelope and projects every accepted call through
the existing mounted-name, IR normalization, and frame bridge path. It never chooses the
first call from an unchecked multi-call response.

The `LLMBackend.generateToolPlan` protocol surface remains unchanged. A compatibility
initializer for existing fixture/runtime writers may adapt a bare string explicitly,
but the customer decode route is mechanically guarded to use the envelope-aware parser.

Stale turn/trace state remains owned by the downstream state gate and is not represented
as a parser error.
