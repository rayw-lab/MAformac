# P1-B Audit Evidence Appendix

## Root Transcript Identity

- `parser-transcript.jsonl` is byte-identical to `qwen35-2b-s1-fixed/parser-transcript.jsonl`.
- `baseline-parser-transcript.jsonl` is byte-identical to `qwen3-1_7b-s1-fixed/parser-transcript.jsonl`.

```text
root_matches_qwen35
root_diff_baseline
```

## artifact-inventory.txt

```text
# Qwen3.5-2B Artifact Inventory
Sat Jun 20 19:39:08 CST 2026

snapshot_path=/Users/wanglei/.cache/huggingface/hub/models--mlx-community--Qwen3.5-2B-4bit/snapshots/674aaa7240b91e8012fcad5d791b7dfe5ba90207

lrwxr-xr-x@ 1 wanglei  staff    52B Jun 20 19:25 /Users/wanglei/.cache/huggingface/hub/models--mlx-community--Qwen3.5-2B-4bit/snapshots/674aaa7240b91e8012fcad5d791b7dfe5ba90207/.gitattributes -> ../../blobs/52373fe24473b1aa44333d318f578ae6bf04b49b
lrwxr-xr-x@ 1 wanglei  staff    52B Jun 20 19:25 /Users/wanglei/.cache/huggingface/hub/models--mlx-community--Qwen3.5-2B-4bit/snapshots/674aaa7240b91e8012fcad5d791b7dfe5ba90207/README.md -> ../../blobs/64df3a653e6fc35ea9cfd441e687aa5e136b0ef8
lrwxr-xr-x@ 1 wanglei  staff    52B Jun 20 19:25 /Users/wanglei/.cache/huggingface/hub/models--mlx-community--Qwen3.5-2B-4bit/snapshots/674aaa7240b91e8012fcad5d791b7dfe5ba90207/chat_template.jinja -> ../../blobs/0ef09f214eaa6d9bca297988afc1454b5827b2c7
lrwxr-xr-x@ 1 wanglei  staff    52B Jun 20 19:25 /Users/wanglei/.cache/huggingface/hub/models--mlx-community--Qwen3.5-2B-4bit/snapshots/674aaa7240b91e8012fcad5d791b7dfe5ba90207/config.json -> ../../blobs/6d901903a287e72c3677c1f8242a9f30c39dd117
lrwxr-xr-x@ 1 wanglei  staff    76B Jun 20 19:36 /Users/wanglei/.cache/huggingface/hub/models--mlx-community--Qwen3.5-2B-4bit/snapshots/674aaa7240b91e8012fcad5d791b7dfe5ba90207/model.safetensors -> ../../blobs/713fe7e5d3c3965f7106b0d0ee17615f7869c23c8d327996df8c1196fbcf07d5
lrwxr-xr-x@ 1 wanglei  staff    52B Jun 20 19:25 /Users/wanglei/.cache/huggingface/hub/models--mlx-community--Qwen3.5-2B-4bit/snapshots/674aaa7240b91e8012fcad5d791b7dfe5ba90207/model.safetensors.index.json -> ../../blobs/2d9ef9d4c10685ab801a5d2011821d700b688d5f
lrwxr-xr-x@ 1 wanglei  staff    52B Jun 20 19:25 /Users/wanglei/.cache/huggingface/hub/models--mlx-community--Qwen3.5-2B-4bit/snapshots/674aaa7240b91e8012fcad5d791b7dfe5ba90207/preprocessor_config.json -> ../../blobs/2ea84a437d448ff71b08df68fdd949d5cc4ebb64
lrwxr-xr-x@ 1 wanglei  staff    52B Jun 20 19:25 /Users/wanglei/.cache/huggingface/hub/models--mlx-community--Qwen3.5-2B-4bit/snapshots/674aaa7240b91e8012fcad5d791b7dfe5ba90207/processor_config.json -> ../../blobs/7ad6acdf4203f22b7b990e36ccc3a1fe38563d5e
lrwxr-xr-x@ 1 wanglei  staff    76B Jun 20 19:25 /Users/wanglei/.cache/huggingface/hub/models--mlx-community--Qwen3.5-2B-4bit/snapshots/674aaa7240b91e8012fcad5d791b7dfe5ba90207/tokenizer.json -> ../../blobs/87a7830d63fcf43bf241c3c5242e96e62dd3fdc29224ca26fed8ea333db72de4
lrwxr-xr-x@ 1 wanglei  staff    52B Jun 20 19:25 /Users/wanglei/.cache/huggingface/hub/models--mlx-community--Qwen3.5-2B-4bit/snapshots/674aaa7240b91e8012fcad5d791b7dfe5ba90207/tokenizer_config.json -> ../../blobs/a068e2468cff426a9b105006e74e044030a6faf4
lrwxr-xr-x@ 1 wanglei  staff    52B Jun 20 19:25 /Users/wanglei/.cache/huggingface/hub/models--mlx-community--Qwen3.5-2B-4bit/snapshots/674aaa7240b91e8012fcad5d791b7dfe5ba90207/video_preprocessor_config.json -> ../../blobs/3ba673a5ad7d4d13f54155ecd38b2a94a6dac8fe
lrwxr-xr-x@ 1 wanglei  staff    52B Jun 20 19:25 /Users/wanglei/.cache/huggingface/hub/models--mlx-community--Qwen3.5-2B-4bit/snapshots/674aaa7240b91e8012fcad5d791b7dfe5ba90207/vocab.json -> ../../blobs/0aa0ce0658d60ac4a5d609f4eadb0e8e43514176

{
  "model_type": "qwen3_5",
  "architectures": [
    "Qwen3_5ForConditionalGeneration"
  ],
  "text_config": {
    "model_type": "qwen3_5_text",
    "architectures": null,
    "hidden_size": 2048,
    "num_hidden_layers": 24,
    "num_attention_heads": 8
  },
  "vision_config": {
    "model_type": "qwen3_5"
  }
}
```

## xctrace-devices-s2.log

```text
== Devices ==
王磊的MacBook Pro (96363CC7-7B5F-5428-A5A7-7874CAAD56B6)

== Simulators ==
Apple Watch SE 3 (40mm) Simulator (26.5) (A7F2996F-25EE-4E31-B8D3-B34B8299AFE0)
Apple Watch SE 3 (44mm) Simulator (26.5) (11085352-75C1-4F42-AE56-BEF92E61B1F2)
iPad (A16) Simulator (26.5) (F1F14BCB-0780-455F-AAF8-336F07AFD5F2)
iPad Air 11-inch (M4) Simulator (26.5) (95673F54-D64C-4CFC-AD6B-2D6429FF17D2)
iPad Air 13-inch (M4) Simulator (26.5) (3A0B39D2-A801-4A84-BD51-6014685EE229)
iPad Pro 11-inch (M5) Simulator (26.5) (76CF1AED-A652-4556-B44A-E705C8FABA3F)
iPad Pro 13-inch (M5) Simulator (26.5) (B9C909E8-4A52-45D1-9AFC-78CCE65E29D8)
iPad mini (A17 Pro) Simulator (26.5) (47732237-66FB-4BF5-B01D-89B26B6F9E79)
iPhone 17 Simulator (26.5) (0BB4DEAF-1B7F-435A-A3EB-ABE5A03E94C3)
iPhone 17 Simulator (26.5) + Apple Watch Ultra 3 (49mm) (26.5) (3B653379-113C-43CE-96CB-20C1E5580A85)
iPhone 17 Pro Simulator (26.5) (20DBE274-364F-4030-835A-529FE8A6D56B)
iPhone 17 Pro Max Simulator (26.5) (9E9EC0D0-E4EF-4D29-AAE5-911EB3F02D6D)
iPhone 17 Pro Max Simulator (26.5) + Apple Watch Series 11 (46mm) (26.5) (FE4B4DB6-8869-4A84-A8FD-E3EBF16A3162)
iPhone 17e Simulator (26.5) (83BD1DCD-BC8B-46A5-B4E9-D38DD5C8D56B)
iPhone Air Simulator (26.5) (69A04DC2-4E4F-4982-B813-B68057B36F25)
iPhone Air Simulator (26.5) + Apple Watch Series 11 (42mm) (26.5) (8CFD3FB4-B008-4CC5-A2CC-12BEDA0CB493)
```
