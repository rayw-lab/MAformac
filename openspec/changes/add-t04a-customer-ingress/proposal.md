## Why

Customer text, future ASR transcripts, and shortcuts need one typed ingress before any production C4 runner binding.

## What Changes

- Add one typed customer ingress facade with stable identity and exactly-once validation.
- Make visible text the primary input and MicDock typed-unavailable while ASR is absent.
- Consume int-v5b containment/receipt and the existing presentation bridge without extending their ownership.

## Non-goals

- No T04b, T09, W5c, default runner/backend/composition, alias policy, or action-success claim.
- No modification to `FrontstageRouteReceipt.swift`, its schema/checker, launch ABI, or `FrontstageRouteUITests.swift`.

## Proof cap

Local/unit/integration construction only; no runtime/operator/mobile/true-device/live-api/V-PASS claim.
