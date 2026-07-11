## Decisions

### One facade owns validation

The facade assigns session/turn/event identity before invoking its validator exactly once. Views and downstream consumers do not revalidate.

### Rejections are typed and side-effect free

The implemented first-tranche facade produces typed, side-effect-free refusal for nil transcript, blank, oversized, unavailable-ASR, and injected validator rejection.

Stale session/turn/event and correlation-mismatch typed rejection are tracked as deferred and are not part of this tranche's normative acceptance. The requirement activates only after the W6 typed route-result/trace identities land; until then it stays `BLOCKED_WAIT_W6_TYPES`, and the receipt writer's current-turn guard is not a substitute for that future ingress contract.

### Existing owners remain unchanged

T04a consumes the int-v5b receipt and existing runtime-presentation bridge. It does not bind a runner/backend/default composition or extend receipt/launch ABI ownership.
