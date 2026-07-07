#!/usr/bin/env python3
"""Pure register classifier for register-window data gates."""

from __future__ import annotations

from dataclasses import dataclass
import re
import unicodedata


REGISTER_ENUM = (
    "imperative",
    "can_question",
    "status_query",
    "hedged_request",
    "already_state_assertion",
)

_CAN_SHELL_RE = re.compile(
    r"^(?:你|您|系统|助手|这个系统|这个助手)?(?:能不能|能否|可否|可以不可以|可不可以|能不能够|能不能帮我|能帮我|可以帮我)"
)
_HEDGED_RE = re.compile(r"(帮我|帮忙|麻烦|劳驾|拜托|可以帮我|能不能帮我|能帮我)")
_META_VERB_RE = re.compile(r"^(?:帮我|帮忙)?(?:控制|操控|操作|支持|处理|管理|识别|理解|懂|执行)(?:一下|下)?")
_ACTION_RE = re.compile(
    r"(打开|关上|关闭|调到|调至|调高|调低|升高|降低|开一下|关一下|开个|关个|切到|切换|设置|设成)"
)
_STATUS_RE = re.compile(
    r"(现在|目前|当前|状态|多少|几档|几度|有没有|是否|是不是|开着|关着|运行|在吗|亮着|看下|查下|查询|看看)"
)
_QUESTION_RE = re.compile(r"(吗|么|嘛|呢|是否|是不是|有没有|多少|几档|几度|可不可以|能不能|能否|可否)")
_ALREADY_RE = re.compile(r"(已经|已|早就|本来就).*(开着|关着|打开|关闭|调到|在运行|亮着)")


@dataclass(frozen=True)
class RegisterClassification:
    register: str
    is_meta_capability_question: bool
    hedged_overlay: bool

    def to_dict(self) -> dict[str, object]:
        return {
            "register": self.register,
            "is_meta_capability_question": self.is_meta_capability_question,
            "hedged_overlay": self.hedged_overlay,
        }


def normalize_input(text: str) -> str:
    text = unicodedata.normalize("NFKC", str(text)).strip().lower()
    text = re.sub(r"\s+", "", text)
    return re.sub(r"[。.!！?？]+$", "", text)


def _strip_shell(text: str) -> str:
    text = re.sub(r"^(?:你|您|系统|助手|这个系统|这个助手)", "", text)
    text = _CAN_SHELL_RE.sub("", text)
    text = re.sub(r"^(?:可以|请|麻烦|帮我|帮忙|拜托|劳驾)", "", text)
    text = re.sub(r"^(?:把|给我|一下|下)", "", text)
    return text


def classify_register(text: str) -> RegisterClassification:
    """Classify utterance register without side effects or I/O.

    Q13 rule: a leading can-question shell is only style. The inner predicate
    decides whether the utterance is an action, status query, or meta question.
    """

    normalized = normalize_input(text)
    can_shell = bool(_CAN_SHELL_RE.search(normalized))
    hedged_overlay = bool(_HEDGED_RE.search(normalized))
    inner = _strip_shell(normalized)

    is_meta = bool(can_shell and _META_VERB_RE.search(inner) and not _ACTION_RE.search(inner))
    if is_meta:
        return RegisterClassification(
            register="can_question",
            is_meta_capability_question=True,
            hedged_overlay=hedged_overlay,
        )

    if _ALREADY_RE.search(normalized) and not _QUESTION_RE.search(normalized):
        return RegisterClassification(
            register="already_state_assertion",
            is_meta_capability_question=False,
            hedged_overlay=hedged_overlay,
        )

    if _STATUS_RE.search(inner) and (_QUESTION_RE.search(normalized) or "看下" in inner or "查下" in inner):
        return RegisterClassification(
            register="status_query",
            is_meta_capability_question=False,
            hedged_overlay=hedged_overlay,
        )

    if can_shell:
        return RegisterClassification(
            register="can_question",
            is_meta_capability_question=False,
            hedged_overlay=hedged_overlay,
        )

    if hedged_overlay:
        return RegisterClassification(
            register="hedged_request",
            is_meta_capability_question=False,
            hedged_overlay=True,
        )

    return RegisterClassification(
        register="imperative",
        is_meta_capability_question=False,
        hedged_overlay=False,
    )


def main() -> int:
    import json
    import sys

    for item in sys.argv[1:]:
        print(json.dumps(classify_register(item).to_dict(), ensure_ascii=False, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
