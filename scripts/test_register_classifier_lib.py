#!/usr/bin/env python3
"""Regression tests for register_classifier.py."""

from __future__ import annotations

from register_classifier import classify_register


def assert_case(
    text: str,
    register: str,
    *,
    is_meta: bool = False,
    hedged_overlay: bool = False,
) -> list[str]:
    result = classify_register(text)
    failures: list[str] = []
    if result.register != register:
        failures.append(f"{text!r}: register expected {register!r}, got {result.register!r}")
    if result.is_meta_capability_question is not is_meta:
        failures.append(
            f"{text!r}: is_meta_capability_question expected {is_meta!r}, "
            f"got {result.is_meta_capability_question!r}"
        )
    if result.hedged_overlay is not hedged_overlay:
        failures.append(f"{text!r}: hedged_overlay expected {hedged_overlay!r}, got {result.hedged_overlay!r}")
    return failures


def main() -> int:
    failures: list[str] = []
    failures += assert_case("你能不能控制车窗", "can_question", is_meta=True)
    failures += assert_case("能不能打开车窗", "can_question")
    failures += assert_case("能不能帮我把车窗打开", "can_question", hedged_overlay=True)
    failures += assert_case("能不能看下车窗开着吗", "status_query")
    failures += assert_case("麻烦打开车窗", "hedged_request", hedged_overlay=True)
    failures += assert_case("车窗已经开着了", "already_state_assertion")

    if failures:
        print("test_register_classifier_lib FAILED")
        for failure in failures:
            print(f"  - {failure}")
        return 1
    print("test_register_classifier_lib=ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
