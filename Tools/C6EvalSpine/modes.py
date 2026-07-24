from __future__ import annotations

from enum import Enum


class Mode(str, Enum):
    FIXTURE = "fixture"
    DRY_RUN = "dry_run"
    REAL = "real"


def normalize_mode(value: str | Mode | None) -> Mode:
    if isinstance(value, Mode):
        return value
    if value is None:
        return Mode.FIXTURE
    text = str(value).strip().lower()
    for mode in Mode:
        if mode.value == text:
            return mode
    raise ValueError(f"unknown mode: {value!r}; expected fixture|dry_run|real")
