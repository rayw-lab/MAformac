## Decisions

### One facade owns validation

The facade assigns session/turn/event identity before invoking its validator exactly once. Views and downstream consumers do not revalidate.

### Rejections are typed and side-effect free

Nil transcript, blank, oversized, unavailable-ASR, stale, and correlation-mismatch inputs produce typed refusal, zero mutation, and zero readback.

### Existing owners remain unchanged

T04a consumes the int-v5b receipt and existing runtime-presentation bridge. It does not bind a runner/backend/default composition or extend receipt/launch ABI ownership.
