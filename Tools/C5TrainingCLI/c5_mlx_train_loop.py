#!/usr/bin/env python3
"""MAformac C5 MLX LoRA training loop.

This is a dev-only wrapper around mlx-lm 0.31.1 internals. It intentionally
copies the stock trainer.train() body so C5 can insert finite checks and
gradient clipping immediately before optimizer.update.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import os
import shutil
import sys
import time
import types
from dataclasses import asdict
from functools import partial
from importlib import metadata
from pathlib import Path
from typing import Any, Iterable

import mlx.core as mx
import mlx.nn as nn
import mlx.optimizers as optim
import numpy as np
import yaml
from mlx.nn.utils import average_gradients
from mlx.utils import tree_flatten, tree_map, tree_reduce
from tqdm import tqdm
from transformers import AutoTokenizer

from mlx_lm.lora import CONFIG_DEFAULTS, build_parser, yaml_loader
from mlx_lm.tuner.datasets import CacheDataset, load_dataset
from mlx_lm.tuner.trainer import TrainingArgs, default_loss, evaluate, grad_checkpoint
from mlx_lm.tuner.trainer import iterate_batches as stock_iterate_batches
from mlx_lm.tuner.utils import (
    build_schedule,
    linear_to_lora_layers,
    print_trainable_parameters,
)
from mlx_lm.utils import load, save_config


REQUIRED_MLX_LM_VERSION = "0.31.1"
DEFAULT_GRAD_CLIP_NORM = 1.0
DEFAULT_NONFINITE_FALLBACK_LR = 5e-5


class NonFiniteTrainingError(RuntimeError):
    def __init__(self, payload: dict[str, Any]):
        super().__init__(json.dumps(payload, ensure_ascii=False, sort_keys=True))
        self.payload = payload


class LossMaskValidationError(RuntimeError):
    pass


class MetricsWriter:
    def __init__(self, path: str | None):
        self.path = Path(path) if path else None
        self.handle = None
        if self.path:
            self.path.parent.mkdir(parents=True, exist_ok=True)
            self.handle = self.path.open("w", encoding="utf-8")

    def write(self, event: dict[str, Any]) -> None:
        if not self.handle:
            return
        self.handle.write(json.dumps(event, ensure_ascii=False, sort_keys=True) + "\n")
        self.handle.flush()

    def close(self) -> None:
        if self.handle:
            self.handle.close()


def parse_args(argv: list[str]) -> types.SimpleNamespace:
    parser = build_parser()
    parser.add_argument("--grad-clip-norm", type=float, default=None)
    parser.add_argument("--disable-grad-clip", action="store_true")
    parser.add_argument("--stock-update-inside-compile", action="store_true")
    parser.add_argument("--metrics-jsonl", type=str, default=None)
    parser.add_argument("--source-snapshot-output", type=str, default=None)
    parser.add_argument("--nonfinite-fallback-lr", type=float, default=None)
    parser.add_argument("--allow-mlx-lm-version-mismatch", action="store_true")
    parser.add_argument("--inspect-batches", type=int, default=0)
    parser.add_argument("--inspect-output", type=str, default=None)
    parser.add_argument("--require-maformac-loss-mask", action="store_true")
    args = vars(parser.parse_args(argv))

    config_path = args.get("config")
    if config_path:
        print("Loading configuration file", config_path)
        with open(config_path, "r", encoding="utf-8") as file:
            config = yaml.load(file, yaml_loader)
        for key, value in config.items():
            if args.get(key, None) is None:
                args[key] = value

    defaults = dict(CONFIG_DEFAULTS)
    defaults.update(
        {
            "grad_clip_norm": DEFAULT_GRAD_CLIP_NORM,
            "metrics_jsonl": None,
            "source_snapshot_output": None,
            "nonfinite_fallback_lr": DEFAULT_NONFINITE_FALLBACK_LR,
            "inspect_batches": 0,
            "inspect_output": None,
            "require_maformac_loss_mask": False,
        }
    )
    for key, value in defaults.items():
        if args.get(key, None) is None:
            args[key] = value

    return types.SimpleNamespace(**args)


def require_pinned_mlx_lm(allow_mismatch: bool) -> str:
    version = metadata.version("mlx-lm")
    if version != REQUIRED_MLX_LM_VERSION and not allow_mismatch:
        raise RuntimeError(
            f"mlx-lm version mismatch: required {REQUIRED_MLX_LM_VERSION}, got {version}. "
            "Use --allow-mlx-lm-version-mismatch only for local probes, never for C5 acceptance."
        )
    return version


def to_float(value: Any) -> float:
    if hasattr(value, "item"):
        return float(value.item())
    return float(value)


def file_sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def global_grad_norm(grads: Any) -> mx.array:
    def add_square_sum(acc, grad):
        grad = grad.astype(mx.float32)
        return acc + (grad * grad).sum()

    norm_squared = tree_reduce(add_square_sum, grads, mx.array(0.0, dtype=mx.float32))
    return mx.sqrt(norm_squared)


def save_adapter_weights(model, adapter_file: Path, iteration: int | None = None) -> None:
    adapter_weights = dict(tree_flatten(model.trainable_parameters()))
    mx.save_safetensors(str(adapter_file), adapter_weights)
    if iteration is not None:
        checkpoint = adapter_file.parent / f"{iteration:07d}_adapters.safetensors"
        mx.save_safetensors(str(checkpoint), adapter_weights)
        print(
            f"Iter {iteration}: Saved adapter weights to {adapter_file} and {checkpoint}.",
            flush=True,
        )
    else:
        print(f"Saved final weights to {adapter_file}.", flush=True)


def clipped_train(
    model,
    optimizer,
    train_dataset,
    val_dataset=None,
    args: TrainingArgs = TrainingArgs(),
    loss: callable = default_loss,
    iterate_batches: callable = stock_iterate_batches,
    metrics: MetricsWriter | None = None,
    grad_clip_norm: float = DEFAULT_GRAD_CLIP_NORM,
    disable_grad_clip: bool = False,
    stock_update_inside_compile: bool = False,
    nonfinite_fallback_lr: float = DEFAULT_NONFINITE_FALLBACK_LR,
):
    if mx.metal.is_available():
        mx.set_wired_limit(mx.device_info()["max_recommended_working_set_size"])
    print(f"Starting training..., iters: {args.iters}", flush=True)
    world = mx.distributed.init()
    world_size = world.size()
    rank = world.rank()
    if world_size > 1:
        print(f"Node {rank} of {world_size}", flush=True)

    if args.grad_checkpoint:
        grad_checkpoint(model.layers[0])

    loss_value_and_grad = nn.value_and_grad(model, loss)
    grad_accum_steps = args.grad_accumulation_steps
    if grad_accum_steps < 1:
        raise ValueError("grad_accumulation_steps must be at least 1")

    clip_enabled = (not disable_grad_clip) and grad_clip_norm > 0
    loop_semantics = (
        "stock_update_inside_compile"
        if stock_update_inside_compile
        else "repo_update_outside_compile"
    )
    if stock_update_inside_compile and clip_enabled:
        raise ValueError("--stock-update-inside-compile requires --disable-grad-clip")

    if stock_update_inside_compile:
        state = [model.state, optimizer.state, mx.random.state]

        @partial(mx.compile, inputs=state, outputs=state)
        def step(batch, prev_grad, do_update):
            (lvalue, toks), grad = loss_value_and_grad(model, *batch)

            if prev_grad is not None:
                grad = tree_map(lambda x, y: x + y, grad, prev_grad)

            grad_norm_preclip = mx.array(0.0, dtype=mx.float32)
            if do_update:
                grad = average_gradients(grad)
                if grad_accum_steps > 1:
                    grad = tree_map(lambda x: x / grad_accum_steps, grad)
                grad_norm_preclip = global_grad_norm(grad)
                optimizer.update(model, grad)
                grad = None

            return lvalue, toks, grad, None, grad_norm_preclip

    else:
        state = [model.state, mx.random.state]

        @partial(mx.compile, inputs=state, outputs=state)
        def step(batch, prev_grad, do_update):
            (lvalue, toks), grad = loss_value_and_grad(model, *batch)

            if prev_grad is not None:
                grad = tree_map(lambda x, y: x + y, grad, prev_grad)

            grad_for_update = None
            grad_norm_preclip = mx.array(0.0, dtype=mx.float32)

            if do_update:
                grad = average_gradients(grad)
                if grad_accum_steps > 1:
                    grad = tree_map(lambda x: x / grad_accum_steps, grad)
                if clip_enabled:
                    grad_for_update, grad_norm_preclip = optim.clip_grad_norm(
                        grad, grad_clip_norm
                    )
                else:
                    grad_norm_preclip = global_grad_norm(grad)
                    grad_for_update = grad
                grad = None

            return lvalue, toks, grad, grad_for_update, grad_norm_preclip

    model.train()
    losses = 0
    n_tokens = 0
    steps = 0
    trained_tokens = 0
    train_time = 0
    grad_accum = None
    update_step = 0
    update_loss_values: list[float] = []

    for it, batch in zip(
        range(1, args.iters + 1),
        iterate_batches(
            dataset=train_dataset,
            batch_size=args.batch_size,
            max_seq_length=args.max_seq_length,
            loop=True,
            comm_group=world,
        ),
    ):
        tic = time.perf_counter()
        if val_dataset and (
            it == 1 or it % args.steps_per_eval == 0 or it == args.iters
        ):
            tic = time.perf_counter()
            val_loss = evaluate(
                model=model,
                dataset=val_dataset,
                loss=loss,
                batch_size=args.batch_size,
                num_batches=args.val_batches,
                max_seq_length=args.max_seq_length,
                iterate_batches=iterate_batches,
            )
            model.train()
            val_time = time.perf_counter() - tic
            if rank == 0:
                print(f"Iter {it}: Val loss {val_loss:.3f}, Val took {val_time:.3f}s", flush=True)
                if metrics:
                    metrics.write(
                        {
                            "event": "val",
                            "iteration": it,
                            "val_loss": val_loss,
                            "val_time": val_time,
                        }
                    )
            tic = time.perf_counter()

        do_update = it % grad_accum_steps == 0
        lvalue, toks, grad_accum, grad_for_update, grad_norm_preclip = step(
            batch,
            grad_accum,
            do_update,
        )

        if do_update:
            if grad_for_update is None:
                mx.eval(lvalue, toks, grad_accum, grad_norm_preclip)
            else:
                mx.eval(lvalue, toks, grad_accum, grad_for_update, grad_norm_preclip)
        else:
            mx.eval(lvalue, toks, grad_accum)

        loss_value = to_float(lvalue)
        update_loss_values.append(loss_value)
        loss_finite = math.isfinite(loss_value)
        grad_norm_value = to_float(grad_norm_preclip) if do_update else None
        grad_finite = True if grad_norm_value is None else math.isfinite(grad_norm_value)

        if not loss_finite or not grad_finite:
            payload = {
                "event": "nonfinite_stop",
                "iteration": it,
                "update_step": update_step + (1 if do_update else 0),
                "loss": loss_value,
                "loss_finite": loss_finite,
                "grad_norm_preclip": grad_norm_value,
                "grad_finite": grad_finite,
                "fallback_recommendation": {
                    "restart_learning_rate": nonfinite_fallback_lr,
                    "restart_reason": "nonfinite_loss_or_gradient",
                },
            }
            if rank == 0 and metrics:
                metrics.write(payload)
            raise NonFiniteTrainingError(payload)

        if do_update:
            update_loss = sum(update_loss_values) / len(update_loss_values)
            update_step += 1
            if rank == 0 and metrics:
                metrics.write(
                    {
                        "event": "optimizer_update",
                        "loop_semantics": loop_semantics,
                        "iteration": it,
                        "update_step": update_step,
                        "loss": update_loss,
                        "loss_kind": "grad_accumulation_mean_microbatch_loss",
                        "grad_norm_preclip": grad_norm_value,
                        "grad_clip_enabled": clip_enabled,
                        "grad_clip_norm": grad_clip_norm if clip_enabled else None,
                        "grad_clip_applied": bool(
                            clip_enabled and grad_norm_value is not None and grad_norm_value > grad_clip_norm
                        ),
                        "learning_rate": optimizer.learning_rate.item(),
                    }
                )
            if not stock_update_inside_compile:
                optimizer.update(model, grad_for_update)
                mx.eval(model.state, optimizer.state)
            update_loss_values = []

        losses += lvalue
        n_tokens += toks
        steps += 1
        mx.eval(state, losses, n_tokens, grad_accum)
        train_time += time.perf_counter() - tic

        if it % args.steps_per_report == 0 or it == args.iters:
            train_loss = mx.distributed.all_sum(losses, stream=mx.cpu).item()
            train_loss /= steps * world_size
            n_tokens = mx.distributed.all_sum(n_tokens, stream=mx.cpu).item()
            learning_rate = optimizer.learning_rate.item()
            it_sec = args.steps_per_report / train_time
            tokens_sec = float(n_tokens) / train_time
            trained_tokens += n_tokens
            peak_mem = mx.get_peak_memory() / 1e9
            if rank == 0:
                print(
                    f"Iter {it}: Train loss {train_loss:.3f}, "
                    f"Learning Rate {learning_rate:.3e}, "
                    f"It/sec {it_sec:.3f}, "
                    f"Tokens/sec {tokens_sec:.3f}, "
                    f"Trained Tokens {trained_tokens}, "
                    f"Peak mem {peak_mem:.3f} GB, "
                    f"Grad Norm Preclip {grad_norm_value if grad_norm_value is not None else 0.0:.6f}",
                    flush=True,
                )
                if metrics:
                    metrics.write(
                        {
                            "event": "train_report",
                            "iteration": it,
                            "train_loss": train_loss,
                            "learning_rate": learning_rate,
                            "iterations_per_second": it_sec,
                            "tokens_per_second": tokens_sec,
                            "trained_tokens": trained_tokens,
                            "peak_memory": peak_mem,
                            "last_grad_norm_preclip": grad_norm_value,
                        }
                    )

            losses = 0
            n_tokens = 0
            steps = 0
            train_time = 0

        if it % args.steps_per_save == 0 and rank == 0:
            save_adapter_weights(model, Path(args.adapter_file), iteration=it)

    if rank == 0:
        save_adapter_weights(model, Path(args.adapter_file), iteration=None)


def train_model(args, model: nn.Module, train_set, valid_set, metrics: MetricsWriter):
    mx.random.seed(args.seed)
    model.freeze()
    if args.num_layers > len(model.layers):
        raise ValueError(
            f"Requested to train {args.num_layers} layers "
            f"but the model only has {len(model.layers)} layers."
        )

    if args.fine_tune_type == "full":
        for layer in model.layers[-max(args.num_layers, 0) :]:
            layer.unfreeze()
        args.lora_parameters = None
    elif args.fine_tune_type in ["lora", "dora"]:
        linear_to_lora_layers(
            model,
            args.num_layers,
            args.lora_parameters,
            use_dora=(args.fine_tune_type == "dora"),
        )
    else:
        raise ValueError(f"Received unknown fine-tune-type {args.fine_tune_type}")

    if args.resume_adapter_file is not None:
        print(f"Loading fine-tuned weights from {args.resume_adapter_file}", flush=True)
        model.load_weights(args.resume_adapter_file, strict=False)

    print_trainable_parameters(model)
    adapter_path = Path(args.adapter_path)
    adapter_path.mkdir(parents=True, exist_ok=True)
    adapter_file = adapter_path / "adapters.safetensors"
    save_config(vars(args), adapter_path / "adapter_config.json")

    training_args = TrainingArgs(
        batch_size=args.batch_size,
        iters=args.iters,
        val_batches=args.val_batches,
        steps_per_report=args.steps_per_report,
        steps_per_eval=args.steps_per_eval,
        steps_per_save=args.save_every,
        adapter_file=adapter_file,
        max_seq_length=args.max_seq_length,
        grad_checkpoint=args.grad_checkpoint,
        grad_accumulation_steps=args.grad_accumulation_steps,
    )

    lr = build_schedule(args.lr_schedule) if args.lr_schedule else args.learning_rate
    optimizer_name = args.optimizer.lower()
    optimizer_config = args.optimizer_config.get(optimizer_name, {})
    if optimizer_name == "adam":
        opt_class = optim.Adam
    elif optimizer_name == "adamw":
        opt_class = optim.AdamW
    elif optimizer_name == "muon":
        opt_class = optim.Muon
    elif optimizer_name == "sgd":
        opt_class = optim.SGD
    elif optimizer_name == "adafactor":
        opt_class = optim.Adafactor
    else:
        raise ValueError(f"Unsupported optimizer: {optimizer_name}")
    opt = opt_class(learning_rate=lr, **optimizer_config)

    clipped_train(
        model=model,
        args=training_args,
        optimizer=opt,
        train_dataset=CacheDataset(train_set),
        val_dataset=CacheDataset(valid_set) if valid_set else None,
        metrics=metrics,
        grad_clip_norm=args.grad_clip_norm,
        disable_grad_clip=args.disable_grad_clip,
        stock_update_inside_compile=args.stock_update_inside_compile,
        nonfinite_fallback_lr=args.nonfinite_fallback_lr,
    )


def evaluate_model(args, model: nn.Module, test_set):
    test_loss = evaluate(
        model=model,
        dataset=CacheDataset(test_set),
        batch_size=args.batch_size,
        num_batches=args.test_batches,
        max_seq_length=args.max_seq_length,
    )
    print(f"Test loss {test_loss:.3f}, Test ppl {math.exp(test_loss):.3f}.", flush=True)


def batch_signature(batch_index: int, batch_tuple: Any) -> dict[str, Any]:
    batch, lengths = batch_tuple
    batch_np = np.array(batch)
    lengths_np = np.array(lengths)
    return {
        "batch_index": batch_index,
        "shape": list(batch_np.shape),
        "offsets_lengths": lengths_np.astype(int).tolist(),
        "token_sum": int(batch_np.sum()),
        "token_nonzero": int(np.count_nonzero(batch_np)),
    }


def validate_maformac_loss_mask_files(data_dir: str | Path, require_train: bool) -> dict[str, Any]:
    root = Path(data_dir)
    if not root.exists():
        raise LossMaskValidationError(f"maformac_loss_mask_data_dir_missing:{root}")

    summary: dict[str, Any] = {
        "event": "maformac_loss_mask_preflight",
        "data_dir": str(root),
        "records": 0,
        "trainable_records": 0,
        "ignored_label_records": 0,
        "splits": {},
    }
    errors: list[str] = []

    for split in ["train", "valid", "test"]:
        path = root / f"{split}.jsonl"
        split_summary = {"records": 0, "trainable_records": 0, "ignored_label_records": 0}
        if not path.exists():
            if split == "train" and require_train:
                errors.append(f"{split}.jsonl_missing")
            summary["splits"][split] = split_summary
            continue

        with path.open("r", encoding="utf-8") as handle:
            for line_number, line in enumerate(handle, start=1):
                if not line.strip():
                    continue
                split_summary["records"] += 1
                summary["records"] += 1
                try:
                    record = json.loads(line)
                except json.JSONDecodeError as error:
                    errors.append(f"{split}:{line_number}:json_decode:{error.msg}")
                    continue

                loss_mask = record.get("loss_mask")
                if not isinstance(loss_mask, dict):
                    errors.append(f"{split}:{line_number}:loss_mask_missing")
                    continue

                labels = loss_mask.get("labels")
                if not isinstance(labels, list) or not labels:
                    errors.append(f"{split}:{line_number}:loss_mask_labels_missing_or_empty")
                    continue
                if not all(isinstance(label, int) for label in labels):
                    errors.append(f"{split}:{line_number}:loss_mask_labels_not_int")
                    continue

                ignore_index = loss_mask.get("ignore_index", -100)
                if ignore_index != -100:
                    errors.append(f"{split}:{line_number}:ignore_index_not_minus_100")

                has_ignored = any(label == -100 for label in labels)
                has_trainable = any(label != -100 for label in labels)
                if has_ignored:
                    split_summary["ignored_label_records"] += 1
                    summary["ignored_label_records"] += 1
                else:
                    errors.append(f"{split}:{line_number}:no_ignored_labels")

                enforcement = loss_mask.get("enforcement")
                if has_trainable:
                    split_summary["trainable_records"] += 1
                    summary["trainable_records"] += 1
                elif enforcement != "all_masked_not_train_eligible":
                    errors.append(f"{split}:{line_number}:no_trainable_labels")

        if split == "train" and require_train and split_summary["records"] == 0:
            errors.append("train.jsonl_empty")
        summary["splits"][split] = split_summary

    if require_train and summary["trainable_records"] == 0:
        errors.append("trainable_loss_mask_records_missing")
    if errors:
        raise LossMaskValidationError(json.dumps({"errors": errors[:25], "summary": summary}, ensure_ascii=False, sort_keys=True))
    return summary


def inspect_batches(args) -> None:
    tokenizer = AutoTokenizer.from_pretrained(args.model, trust_remote_code=True)
    train_set, _, _ = load_dataset(args, tokenizer)
    cached = CacheDataset(train_set)
    rows = []
    for index, batch in zip(
        range(1, args.inspect_batches + 1),
        stock_iterate_batches(
            dataset=cached,
            batch_size=args.batch_size,
            max_seq_length=args.max_seq_length,
            loop=False,
            seed=args.seed,
        ),
    ):
        rows.append(batch_signature(index, batch))
    output = args.inspect_output
    if output:
        path = Path(output)
        path.parent.mkdir(parents=True, exist_ok=True)
        with path.open("w", encoding="utf-8") as handle:
            for row in rows:
                handle.write(json.dumps(row, sort_keys=True) + "\n")
    else:
        for row in rows:
            print(json.dumps(row, sort_keys=True), flush=True)


def run(args) -> None:
    version = require_pinned_mlx_lm(args.allow_mlx_lm_version_mismatch)
    os.environ["TOKENIZERS_PARALLELISM"] = "true"
    np.random.seed(args.seed)
    mx.random.seed(args.seed)
    script_path = Path(__file__).resolve()
    script_sha256 = file_sha256(script_path)
    source_snapshot = None
    if args.source_snapshot_output:
        source_snapshot = Path(args.source_snapshot_output)
        source_snapshot.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(script_path, source_snapshot)
    print(
        "MAformac C5 repo training loop "
        f"(mlx-lm={version}, script_sha256={script_sha256}, "
        f"grad_clip_norm={args.grad_clip_norm}, "
        f"clip_disabled={args.disable_grad_clip}, "
        f"stock_update_inside_compile={args.stock_update_inside_compile})",
        flush=True,
    )

    if args.inspect_batches:
        inspect_batches(args)
        return

    metrics = MetricsWriter(args.metrics_jsonl)
    try:
        metrics.write(
            {
                "event": "run_metadata",
                "mlx_lm_version": version,
                "training_loop_source": str(script_path),
                "training_loop_source_sha256": script_sha256,
                "source_snapshot": str(source_snapshot) if source_snapshot else None,
                "disable_grad_clip": args.disable_grad_clip,
                "grad_clip_norm": args.grad_clip_norm,
                "stock_update_inside_compile": args.stock_update_inside_compile,
            }
        )
        if args.require_maformac_loss_mask:
            loss_mask_summary = validate_maformac_loss_mask_files(
                args.data,
                require_train=bool(args.train),
            )
            metrics.write(loss_mask_summary)
            print(
                "MAformac loss_mask preflight "
                f"records={loss_mask_summary['records']} "
                f"trainable_records={loss_mask_summary['trainable_records']} "
                f"ignored_label_records={loss_mask_summary['ignored_label_records']}",
                flush=True,
            )
        print("Loading pretrained model", flush=True)
        model, tokenizer = load(args.model, tokenizer_config={"trust_remote_code": True})
        print("Loading datasets", flush=True)
        train_set, valid_set, test_set = load_dataset(args, tokenizer)
        if args.train:
            print("Training", flush=True)
            train_model(args, model, train_set, valid_set, metrics)
        if args.test:
            print("Testing", flush=True)
            evaluate_model(args, model, test_set)
        if not args.train and not args.test:
            raise ValueError("Must provide at least one of --train, --test, or --inspect-batches")
    finally:
        metrics.close()


def main(argv: Iterable[str] | None = None) -> int:
    args = parse_args(list(argv if argv is not None else sys.argv[1:]))
    try:
        run(args)
        return 0
    except NonFiniteTrainingError as error:
        print("NONFINITE_TRAINING_STOP " + json.dumps(error.payload, sort_keys=True), file=sys.stderr)
        return 70
    except LossMaskValidationError as error:
        print(f"LOSS_MASK_PREFLIGHT_FAILED {error}", file=sys.stderr)
        return 66


if __name__ == "__main__":
    raise SystemExit(main())
