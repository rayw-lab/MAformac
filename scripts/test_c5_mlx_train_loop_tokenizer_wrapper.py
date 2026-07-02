import importlib.util
from pathlib import Path


MODULE_PATH = Path(__file__).resolve().parents[1] / "Tools" / "C5TrainingCLI" / "c5_mlx_train_loop.py"
spec = importlib.util.spec_from_file_location("c5_mlx_train_loop", MODULE_PATH)
c5_mlx_train_loop = importlib.util.module_from_spec(spec)
assert spec.loader is not None
spec.loader.exec_module(c5_mlx_train_loop)


class OffsetTokenizer:
    def __call__(self, text, add_special_tokens=False, return_offsets_mapping=False):
        assert add_special_tokens is False
        assert return_offsets_mapping is True
        return {
            "input_ids": [ord(char) for char in text],
            "offset_mapping": [(index, index + 1) for index, _ in enumerate(text)],
        }


class TokenizerWrapper:
    def __init__(self):
        self._tokenizer = OffsetTokenizer()

    def apply_chat_template(self, messages, tools=None, add_generation_prompt=False, return_dict=False):
        assert return_dict is False
        text = "".join(str(message.get("content") or "") for message in messages)
        return [ord(char) for char in text]


def test_assistant_tokenization_uses_wrapped_hf_tokenizer_for_offsets():
    record = {
        "messages": [
            {"role": "user", "content": "开空调"},
            {"role": "assistant", "content": "<tool_call>"},
        ],
        "tools": [],
    }

    full_tokens, assistant_tokens, offsets, assistant_start = c5_mlx_train_loop.assistant_tokenization(
        record,
        TokenizerWrapper(),
    )

    assert assistant_tokens == [ord(char) for char in "<tool_call>"]
    assert offsets == [(index, index + 1) for index, _ in enumerate("<tool_call>")]
    assert full_tokens[assistant_start : assistant_start + len(assistant_tokens)] == assistant_tokens


def test_zero_trainable_token_loss_is_finite_and_reports_zero_ntoks():
    c5_mlx_train_loop.ensure_mlx_runtime()

    logits = c5_mlx_train_loop.mx.array([[[8.0, 0.0], [0.0, 8.0]]], dtype=c5_mlx_train_loop.mx.float32)
    labels = c5_mlx_train_loop.mx.array([[-100, -100]], dtype=c5_mlx_train_loop.mx.int32)

    loss, ntoks = c5_mlx_train_loop.maformac_masked_cross_entropy_from_logits(logits, labels)
    c5_mlx_train_loop.mx.eval(loss, ntoks)

    assert int(ntoks.item()) == 0
    assert float(loss.item()) == 0.0


class LongTokenDataset:
    def __init__(self, tokens):
        self.tokens = tokens

    def __len__(self):
        return 1

    def __getitem__(self, index):
        return {"sample_id": f"row-{index}"}

    def process(self, record):
        return self.tokens, [0 for _ in self.tokens]


def test_loss_mask_preflight_rejects_measured_token_length_over_max_seq_length():
    datasets = {
        "train": LongTokenDataset([1, 2, 3]),
        "valid": LongTokenDataset([]),
        "test": LongTokenDataset([]),
    }

    try:
        c5_mlx_train_loop.validate_maformac_loss_mask_datasets(
            datasets,
            require_train=True,
            max_seq_length=2,
        )
    except c5_mlx_train_loop.LossMaskValidationError as error:
        text = str(error)
    else:
        raise AssertionError("expected length gate to fail")

    assert "token_length_exceeds_max_seq_length:train:1:3>2" in text
    assert '"max_token_length": 3' in text
