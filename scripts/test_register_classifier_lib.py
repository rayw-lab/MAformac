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
    failures += assert_case("你能不能懂我座椅不舒服", "can_question", is_meta=True)
    failures += assert_case("能不能打开车窗", "can_question")
    failures += assert_case("能不能帮我把车窗打开", "can_question", hedged_overlay=True)
    failures += assert_case("空调温度调低可以吗", "can_question")
    failures += assert_case("能把音量调大一点吗", "can_question")
    failures += assert_case("空调关了行不行", "can_question")
    failures += assert_case("屏幕不是刚调到最暗了嘛，别再调了", "imperative")
    failures += assert_case("车窗不是早就关好了吗，别再关了", "imperative")
    failures += assert_case("别再调低空调温度了嘛", "imperative")
    failures += assert_case("不是让你把空调关了嘛", "imperative")
    failures += assert_case("空调关了嘛", "imperative")
    failures += assert_case("能不能看下车窗开着吗", "status_query")
    failures += assert_case("现在空调开着吗", "status_query")
    failures += assert_case("你能不能控制空调", "can_question", is_meta=True)
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
