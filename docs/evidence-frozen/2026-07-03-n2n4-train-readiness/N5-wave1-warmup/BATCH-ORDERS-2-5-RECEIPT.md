# BATCH-ORDERS-2-5 receipt

- status: DONE
- proof_class: local_order_plus_mock_dryrun_no_generation
- controller_builder_worktree: `/tmp/maformac-batch-orders-2-5`
- builder_source_commit: `1526a26bab943d3aba0ae26bb430b74f6a60c4c2`
- manifest_main_pin_sha: `b33d8eba152e5326f69bbe85fc356b73419ee9c3`
- boundary: order + lane prompt package only; no live generation, no judge, no training input writes

## Batches

| batch | lane | order | prompt | dryrun | DataGate | manifest | slices |
|---|---|---|---|---|---|---|---|
| batch-02 | `subcc-2` | `d42e914f26321950f7f978606264ebd2381967289a5a6f626c25793fe188a6e9` | `49509f04f39d13f069e085c637b3a25d2cdef515a309d4408f7472b233de30b5` | `PASS` | `data_gate_ready` | `pass` | seat_heat, seat_ventilation, seat_posture |
| batch-03 | `subcc-3` | `f8665ae832e3b77bb16e4463b0243c4839d81cb970355db81f053c9e3797ca38` | `32d74f545d03a9c2fbafa926aabbf02f0c81bf1b87ceaabda92f10f9a0e80463` | `PASS` | `data_gate_ready` | `pass` | window, door |
| batch-04 | `subcc-4` | `4568bbc0d76b404c902eb2f3ae7ab93adfc30e4f960b3053d9d405ad7a398b6d` | `c3b4ec24b5d2dc7dba7af891e1cc783dd60c53ca36741229c2b1d37149e36e89` | `PASS` | `data_gate_ready` | `pass` | light, screen, volume |
| batch-05 | `subcc-5` | `1acfc316ad7e7622bc0e0d04f0c84f75ef839cf2077f152264c463fcf9f7d2b0` | `c6a4f3714f266a68cd8d839c4188d0c03ed8c4b4304d8c66f716a54b61977f04` | `PASS` | `data_gate_ready` | `pass` | wiper, sunroof_fragrance |

## Validation

```bash
swift run Gate7DryRunCLI --limit 50 --batch-id warmup-batch-0{2..5} --lane-id subcc-{2..5} --main-pin-sha b33d8eba... --contract-row-id <seed>
# each: status=PASS samples=50 data_gate=data_gate_ready manifest=pass quarantine=1

python3 -m json.tool batch-0{2..5}/batch-0{2..5}-order.json
# pass
```

## Non-Claims

- not generated
- not judged
- not train-ready
- not V-PASS
- not run authorization
