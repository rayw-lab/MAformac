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
