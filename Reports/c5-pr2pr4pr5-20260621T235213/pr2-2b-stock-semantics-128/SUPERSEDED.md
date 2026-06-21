# Superseded Probe

Status: superseded_interrupted

This run was intentionally interrupted after independent PR2 2a audit found two receipt-shape gaps:

- `optimizer_update` events lacked a per-update loss field.
- Training artifacts did not bundle the exact training script snapshot.

The partial metrics/logs in this directory are retained for traceability only and are not used for PR2 2b gate evidence.
