#!/usr/bin/env swift
import AVFoundation
import Foundation

private struct TTSPreflightReceipt: Encodable {
    let preferred_zh_CN: Bool
    let fallback_zh: Bool
    let premium_zh_CN: Bool
    let voice_count: Int
    let disposition: String
    let warnings: [String]
}

private let voices = AVSpeechSynthesisVoice.speechVoices()
private let preferredZhCN = AVSpeechSynthesisVoice(language: "zh-CN") != nil
private let fallbackZh = voices.contains { $0.language.hasPrefix("zh") }
private let premiumZhCN = voices.contains { voice in
    voice.language == "zh-CN" && voice.quality == .premium
}

private var warnings: [String] = []
if !preferredZhCN, fallbackZh {
    warnings.append("preferred_zh_CN_missing_using_fallback_zh")
}
if !premiumZhCN {
    warnings.append("premium_zh_CN_missing")
}

private let disposition: String
if !fallbackZh {
    disposition = "fail"
} else if warnings.isEmpty {
    disposition = "pass"
} else {
    disposition = "warning"
}

private let receipt = TTSPreflightReceipt(
    preferred_zh_CN: preferredZhCN,
    fallback_zh: fallbackZh,
    premium_zh_CN: premiumZhCN,
    voice_count: voices.count,
    disposition: disposition,
    warnings: warnings
)

let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
let data = try encoder.encode(receipt)
FileHandle.standardOutput.write(data)
FileHandle.standardOutput.write(Data("\n".utf8))

if disposition == "fail" {
    exit(66)
}
