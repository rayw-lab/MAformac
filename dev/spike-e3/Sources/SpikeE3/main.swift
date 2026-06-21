import Darwin
import Foundation
import HuggingFace
import MLXHuggingFace
import MLXLLM
import MLXLMCommon
import Tokenizers

// Keep the default pinned to the current 1.7B baseline; Qwen3.5 runs only via explicit spike args.
private let defaultModelID = "mlx-community/Qwen3-1.7B-4bit"
private let mlxSwiftLMTag = "3.31.3"
private let snapshotTime = "2026-06-18T00:00:00+08:00"

@main
struct SpikeE3Main {
    static func main() async {
        do {
            try await SpikeRunner(arguments: CommandLine.arguments).run()
        } catch {
            fputs("BLOCKED: \(error)\n", stderr)
            exit(1)
        }
    }
}

private struct SpikeRunner {
    let arguments: [String]

    func run() async throws {
        let options = try RunOptions(arguments: arguments)
        let outputDir = URL(fileURLWithPath: options.outputDir, isDirectory: true)
        try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
        let requestedToolCallFormat = try options.resolvedToolCallFormat()

        let configuration = ModelConfiguration(
            id: options.modelID,
            defaultPrompt: "打开空调",
            toolCallFormat: requestedToolCallFormat
        )

        print("Loading \(options.modelID) with mlx-swift-lm \(mlxSwiftLMTag), toolCallFormat=\(options.toolCallFormatMode)")
        let modelContext = try await #huggingFaceLoadModel(configuration: configuration) { progress in
            if progress.totalUnitCount > 0 {
                let percent = Double(progress.completedUnitCount) / Double(progress.totalUnitCount) * 100
                print(String(format: "download/load progress %.1f%%", percent))
            }
        }
        let resolvedToolCallFormat = formatName(modelContext.configuration.toolCallFormat)
        print("Model loaded; resolvedToolCallFormat=\(resolvedToolCallFormat)")
        var loraAdapterConfigNormalization: LoRAAdapterConfigNormalization?
        if let loraAdapterPath = options.loraAdapterPath {
            let adapterURL = URL(fileURLWithPath: loraAdapterPath, isDirectory: true)
            let normalized = try normalizedLoRAAdapterDirectory(
                originalAdapterURL: adapterURL,
                outputDir: outputDir,
                model: modelContext.model
            )
            loraAdapterConfigNormalization = normalized.normalization
            let adapter = try LoRAContainer.from(directory: normalized.adapterURL)
            try adapter.load(into: modelContext.model)
            print(
                "Loaded LoRA adapter path=\(adapterURL.path) effectivePath=\(normalized.adapterURL.path) id=\(options.loraAdapterID) checkpoint=\(options.loraCheckpointID) rank=\(adapter.configuration.loraParameters.rank) scale=\(adapter.configuration.loraParameters.scale)"
            )
        }

        let loadedCases = try options.casesJSONL.map(loadC6Cases(from:)) ?? sampleCases
        let limitedCases = Array(loadedCases.prefix(options.limit ?? loadedCases.count))
        let cases = (0..<options.repeatCount).flatMap { runIndex in
            limitedCases.map { $0.withRunIndex(runIndex) }
        }
        var results: [CaseResult] = []
        results.reserveCapacity(cases.count)

        for (index, sample) in cases.enumerated() {
            print("[\(index + 1)/\(cases.count)] \(sample.id): \(sample.utterance)")
            let result = try await runCase(sample, modelContext: modelContext)
            results.append(result)
            let toolNames = result.toolCalls.map { $0.name }.joined(separator: ",")
            print("  toolCalls=\(result.toolCalls.count) [\(toolNames)] elapsedMs=\(result.elapsedMs)")
        }

        let summary = Summary(results: results)
        let envelope = ResultEnvelope(
            status: "done",
            modelID: options.modelID,
            mlxSwiftLMTag: mlxSwiftLMTag,
            requestedToolCallFormat: options.toolCallFormatMode,
            resolvedToolCallFormat: resolvedToolCallFormat,
            loraAdapterID: options.loraAdapterPath == nil ? nil : options.loraAdapterID,
            loraCheckpointID: options.loraAdapterPath == nil ? nil : options.loraCheckpointID,
            loraAdapterPath: options.loraAdapterPath,
            loraAdapterConfigNormalization: loraAdapterConfigNormalization,
            snapshotTime: snapshotTime,
            totalCases: results.count,
            summary: summary,
            results: results
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let jsonData = try encoder.encode(envelope)
        let jsonURL = outputDir.appendingPathComponent("spike-e3-results.json")
        try jsonData.write(to: jsonURL)

        let report = renderReport(envelope)
        let reportURL = outputDir.appendingPathComponent("spike-e3-report.md")
        try report.write(to: reportURL, atomically: true, encoding: .utf8)

        print("Wrote \(reportURL.path)")
        print("Wrote \(jsonURL.path)")
        print("Decision: \(summary.decision)")
    }

    private func runCase(_ sample: EvalCase, modelContext: ModelContext) async throws -> CaseResult {
        let session = ChatSession(
            modelContext,
            instructions: systemInstructions,
            generateParameters: GenerateParameters(
                maxTokens: sample.maxTokens,
                temperature: 0.0,
                topP: 1.0,
                topK: 1
            ),
            additionalContext: ["enable_thinking": false],
            tools: toolSpecs
        )

        let start = DispatchTime.now()
        var firstEventMs: Int?
        var chunks = ""
        var toolCalls: [ToolCallSnapshot] = []
        var completion: CompletionInfoSnapshot?

        for try await event in session.streamDetails(to: sample.utterance, images: [], videos: []) {
            if firstEventMs == nil {
                firstEventMs = elapsedMilliseconds(since: start)
            }

            switch event {
            case .chunk(let text):
                chunks += text
            case .toolCall(let toolCall):
                toolCalls.append(ToolCallSnapshot(
                    name: toolCall.function.name,
                    arguments: toolCall.function.arguments
                ))
            case .info(let info):
                completion = CompletionInfoSnapshot(info)
            }
        }

        let elapsed = elapsedMilliseconds(since: start)
        let contentLooksLikeToolCall =
            chunks.contains("<tool_call>")
            || (chunks.contains("\"name\"") && chunks.contains("\"arguments\""))
        let thinkLeak = chunks.contains("<think>") || chunks.contains("</think>")
        let expectedToolHit: Bool
        if let expectedTool = sample.expectedTool {
            expectedToolHit = toolCalls.contains { $0.name == expectedTool }
        } else {
            expectedToolHit = toolCalls.isEmpty
        }

        return CaseResult(
            id: sample.id,
            runIndex: sample.runIndex,
            capability: sample.capability,
            sourceLevel: sample.sourceLevel,
            utterance: sample.utterance,
            expectedTool: sample.expectedTool,
            expectedToolHit: expectedToolHit,
            isNegative: sample.isNegative,
            tags: sample.tags,
            toolCalls: toolCalls,
            chunkText: chunks,
            contentLooksLikeToolCall: contentLooksLikeToolCall,
            thinkLeak: thinkLeak,
            elapsedMs: elapsed,
            firstEventMs: firstEventMs,
            completion: completion
        )
    }
}

private struct RunOptions {
    var modelID = defaultModelID
    var toolCallFormatMode = "json"
    var limit: Int?
    var outputDir = "Reports"
    var casesJSONL: String?
    var repeatCount = 1
    var loraAdapterPath: String?
    var loraAdapterID = ""
    var loraCheckpointID = ""

    init(arguments: [String]) throws {
        var iterator = arguments.dropFirst().makeIterator()
        while let argument = iterator.next() {
            switch argument {
            case "--model-id":
                if let value = iterator.next() {
                    modelID = value
                }
            case "--tool-call-format":
                if let value = iterator.next() {
                    toolCallFormatMode = value
                }
            case "--limit":
                if let value = iterator.next() {
                    limit = Int(value)
                }
            case "--output-dir":
                if let value = iterator.next() {
                    outputDir = value
                }
            case "--cases-jsonl":
                if let value = iterator.next() {
                    casesJSONL = value
                }
            case "--repeat":
                if let value = iterator.next(), let count = Int(value) {
                    repeatCount = max(1, count)
                }
            case "--lora-adapter-path":
                if let value = iterator.next() {
                    loraAdapterPath = value
                }
            case "--lora-adapter-id":
                if let value = iterator.next() {
                    loraAdapterID = value
                }
            case "--lora-checkpoint-id":
                if let value = iterator.next() {
                    loraCheckpointID = value
                }
            default:
                break
            }
        }
        _ = try resolvedToolCallFormat()
        try validateLoRAOptions()
    }

    func resolvedToolCallFormat() throws -> ToolCallFormat? {
        switch toolCallFormatMode.lowercased() {
        case "auto", "infer", "nil":
            return nil
        case "json":
            return .json
        case "xml_function", "xml-function", "xmlfunction":
            return .xmlFunction
        default:
            throw SpikeError.invalidToolCallFormat(toolCallFormatMode)
        }
    }

    func validateLoRAOptions() throws {
        if loraAdapterPath == nil && (!loraAdapterID.isEmpty || !loraCheckpointID.isEmpty) {
            throw SpikeError.incompleteLoRAOptions("--lora-adapter-path is required when LoRA identifiers are provided")
        }
        if loraAdapterPath != nil && (loraAdapterID.isEmpty || loraCheckpointID.isEmpty) {
            throw SpikeError.incompleteLoRAOptions("--lora-adapter-id and --lora-checkpoint-id are required with --lora-adapter-path")
        }
    }
}

private enum SpikeError: Error, CustomStringConvertible {
    case invalidToolCallFormat(String)
    case incompleteLoRAOptions(String)
    case invalidLoRAAdapterConfig(String)

    var description: String {
        switch self {
        case .invalidToolCallFormat(let value):
            return "invalid --tool-call-format \(value); expected json, xml_function, or auto"
        case .incompleteLoRAOptions(let value):
            return "invalid LoRA options: \(value)"
        case .invalidLoRAAdapterConfig(let value):
            return "invalid LoRA adapter config: \(value)"
        }
    }
}

private struct LoRAAdapterConfigNormalization: Codable, Sendable {
    let status: String
    let originalAdapterPath: String
    let effectiveAdapterPath: String
    let originalNumLayers: Int
    let normalizedNumLayers: Int
    let reason: String
}

private func normalizedLoRAAdapterDirectory(
    originalAdapterURL: URL,
    outputDir: URL,
    model: any LanguageModel
) throws -> (adapterURL: URL, normalization: LoRAAdapterConfigNormalization?) {
    let configURL = originalAdapterURL.appending(component: "adapter_config.json")
    let data = try Data(contentsOf: configURL)
    guard var root = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
        throw SpikeError.invalidLoRAAdapterConfig("adapter_config.json is not an object")
    }
    let originalNumLayers = root["num_layers"] as? Int
    guard let originalNumLayers, originalNumLayers < 0 else {
        return (originalAdapterURL, nil)
    }
    guard let loraModel = model as? LoRAModel else {
        throw SpikeError.invalidLoRAAdapterConfig("num_layers=\(originalNumLayers) requires a LoRAModel-compatible base")
    }
    let normalizedNumLayers = loraModel.loraLayers.count
    guard normalizedNumLayers > 0 else {
        throw SpikeError.invalidLoRAAdapterConfig("LoRAModel exposed no loraLayers")
    }
    root["num_layers"] = normalizedNumLayers
    let normalizedDir = outputDir.appending(component: "normalized-lora-adapter", directoryHint: .isDirectory)
    try FileManager.default.createDirectory(at: normalizedDir, withIntermediateDirectories: true)
    let normalizedConfigData = try JSONSerialization.data(
        withJSONObject: root,
        options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    )
    try normalizedConfigData.write(to: normalizedDir.appending(component: "adapter_config.json"), options: .atomic)
    let originalWeightsURL = originalAdapterURL.appending(component: "adapters.safetensors")
    let normalizedWeightsURL = normalizedDir.appending(component: "adapters.safetensors")
    if FileManager.default.fileExists(atPath: normalizedWeightsURL.path) {
        try FileManager.default.removeItem(at: normalizedWeightsURL)
    }
    try FileManager.default.createSymbolicLink(at: normalizedWeightsURL, withDestinationURL: originalWeightsURL)
    return (
        normalizedDir,
        LoRAAdapterConfigNormalization(
            status: "normalized",
            originalAdapterPath: originalAdapterURL.path,
            effectiveAdapterPath: normalizedDir.path,
            originalNumLayers: originalNumLayers,
            normalizedNumLayers: normalizedNumLayers,
            reason: "MLX Python adapter_config uses num_layers=-1 for all layers; MLX Swift LoRAContainer requires a non-negative suffix length."
        )
    )
}

private func formatName(_ format: ToolCallFormat?) -> String {
    guard let format else {
        return "nil"
    }
    return String(describing: format)
}

private func elapsedMilliseconds(since start: DispatchTime) -> Int {
    let nanos = DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds
    return Int(Double(nanos) / 1_000_000.0)
}

private let systemInstructions = """
你是 MAformac 的离线车控 demo 助手。只能对已声明的本地 mock 座舱工具发起工具调用。
用户提出支持的空调、座椅、车窗、氛围灯、屏幕亮度、风量或舒适状态查询请求时，优先发起且只发起一个工具调用。
用户闲聊、跨域、请求写作/翻译/股票/导航/音乐/邮件/餐饮或明确说不要执行时，不要调用任何工具，只用一句中文拒识或简短回答。
不要输出思考过程，不要输出 <think>，不要把工具调用写进普通文本。
"""

private typealias ToolSpec = MLXLMCommon.ToolSpec

private func functionTool(
    name: String,
    description: String,
    parameters: [String: any Sendable]
) -> ToolSpec {
    [
        "type": "function",
        "function": [
            "name": name,
            "description": description,
            "parameters": parameters,
        ] as [String: any Sendable],
    ] as ToolSpec
}

private func objectParameters(
    properties: [String: any Sendable],
    required: [String]
) -> [String: any Sendable] {
    [
        "type": "object",
        "additionalProperties": false,
        "properties": properties,
        "required": required,
    ] as [String: any Sendable]
}

private func stringEnum(_ values: [String]) -> [String: any Sendable] {
    ["type": "string", "enum": values] as [String: any Sendable]
}

private func intRange(_ minimum: Int, _ maximum: Int) -> [String: any Sendable] {
    ["type": "integer", "minimum": minimum, "maximum": maximum] as [String: any Sendable]
}

private let toolSpecs: [ToolSpec] = [
    functionTool(
        name: "set_cabin_ac",
        description: "控制本地 mock 空调开关、温度和冷暖模式。",
        parameters: objectParameters(
            properties: [
                "power": stringEnum(["on", "off", "unchanged"]),
                "target_temperature": intRange(16, 30),
                "delta": stringEnum(["warmer", "cooler", "none"]),
                "mode": stringEnum(["auto", "cooling", "heating"]),
            ] as [String: any Sendable],
            required: ["power"]
        )
    ),
    functionTool(
        name: "set_cabin_seat_heating",
        description: "调整本地 mock 座椅加热挡位。",
        parameters: objectParameters(
            properties: [
                "position": stringEnum(["driver", "passenger", "all"]),
                "level": intRange(0, 3),
            ] as [String: any Sendable],
            required: ["position", "level"]
        )
    ),
    functionTool(
        name: "set_cabin_seat_ventilation",
        description: "调整本地 mock 座椅通风挡位。",
        parameters: objectParameters(
            properties: [
                "position": stringEnum(["driver", "passenger", "all"]),
                "level": intRange(0, 3),
            ] as [String: any Sendable],
            required: ["position", "level"]
        )
    ),
    functionTool(
        name: "set_cabin_window",
        description: "调整本地 mock 车窗开度百分比。",
        parameters: objectParameters(
            properties: [
                "position": stringEnum(["driver", "passenger", "rear_left", "rear_right", "all"]),
                "percent": intRange(0, 100),
            ] as [String: any Sendable],
            required: ["position", "percent"]
        )
    ),
    functionTool(
        name: "set_cabin_ambient_light",
        description: "调整本地 mock 氛围灯开关和颜色。",
        parameters: objectParameters(
            properties: [
                "power": stringEnum(["on", "off", "unchanged"]),
                "color": stringEnum(["warm", "cool", "blue", "amber", "white"]),
            ] as [String: any Sendable],
            required: ["power"]
        )
    ),
    functionTool(
        name: "set_cabin_screen_brightness",
        description: "调整本地 mock 中控屏幕亮度百分比。",
        parameters: objectParameters(
            properties: [
                "percent": intRange(0, 100),
                "delta": stringEnum(["brighter", "dimmer", "none"]),
            ] as [String: any Sendable],
            required: ["percent"]
        )
    ),
    functionTool(
        name: "set_cabin_fan",
        description: "调整本地 mock 空调风量挡位。",
        parameters: objectParameters(
            properties: [
                "level": intRange(0, 5),
            ] as [String: any Sendable],
            required: ["level"]
        )
    ),
    functionTool(
        name: "query_cabin_comfort",
        description: "读取本地 mock 舒适状态，不写入车控状态。",
        parameters: objectParameters(
            properties: [
                "topic": stringEnum(["temperature", "hvac", "seat", "all"]),
            ] as [String: any Sendable],
            required: ["topic"]
        )
    ),
]

private struct EvalCase: Codable, Sendable {
    let id: String
    let capability: String
    let sourceLevel: String
    let utterance: String
    let expectedTool: String?
    let isNegative: Bool
    let tags: [String]
    let maxTokens: Int
    let runIndex: Int?

    init(
        id: String,
        capability: String,
        sourceLevel: String,
        utterance: String,
        expectedTool: String?,
        isNegative: Bool = false,
        tags: [String] = [],
        maxTokens: Int = 96,
        runIndex: Int? = nil
    ) {
        self.id = id
        self.capability = capability
        self.sourceLevel = sourceLevel
        self.utterance = utterance
        self.expectedTool = expectedTool
        self.isNegative = isNegative
        self.tags = tags
        self.maxTokens = maxTokens
        self.runIndex = runIndex
    }

    func withRunIndex(_ runIndex: Int) -> EvalCase {
        EvalCase(
            id: id,
            capability: capability,
            sourceLevel: sourceLevel,
            utterance: utterance,
            expectedTool: expectedTool,
            isNegative: isNegative,
            tags: tags,
            maxTokens: maxTokens,
            runIndex: runIndex
        )
    }
}

private func loadC6Cases(from path: String) throws -> [EvalCase] {
    let text = try String(contentsOfFile: path, encoding: .utf8)
    let decoder = JSONDecoder()
    return try text
        .split(whereSeparator: \.isNewline)
        .map { try decoder.decode(C6InputCase.self, from: Data(String($0).utf8)).evalCase }
}

private struct C6InputCase: Decodable {
    var caseID: String
    var inputZh: String
    var expectedToolCalls: [C6ExpectedToolCall]
    var expectNoCall: Bool
    var tags: C6InputTags

    enum CodingKeys: String, CodingKey {
        case caseID = "case_id"
        case inputZh = "input_zh"
        case expectedToolCalls = "expected_tool_calls"
        case expectNoCall = "expect_no_call"
        case tags
    }

    var evalCase: EvalCase {
        EvalCase(
            id: caseID,
            capability: tags.contractDevice.isEmpty ? "c6" : tags.contractDevice,
            sourceLevel: tags.sampleKind,
            utterance: inputZh,
            expectedTool: expectNoCall ? nil : expectedToolCalls.first?.name,
            isNegative: expectNoCall,
            tags: [tags.bucket, tags.sampleKind],
            maxTokens: 96
        )
    }
}

private struct C6ExpectedToolCall: Decodable {
    var name: String
}

private struct C6InputTags: Decodable {
    var bucket: String
    var contractDevice: String
    var sampleKind: String

    enum CodingKeys: String, CodingKey {
        case bucket
        case contractDevice = "contract_device"
        case sampleKind = "sample_kind"
    }
}

private let sampleCases: [EvalCase] = [
    EvalCase(id: "P001", capability: "cabin.ac", sourceLevel: "L1_exact", utterance: "打开空调", expectedTool: "set_cabin_ac"),
    EvalCase(id: "P002", capability: "cabin.ac", sourceLevel: "L1_exact", utterance: "把空调关掉", expectedTool: "set_cabin_ac"),
    EvalCase(id: "P003", capability: "cabin.ac", sourceLevel: "L2_feeling", utterance: "我有点热", expectedTool: "set_cabin_ac"),
    EvalCase(id: "P004", capability: "cabin.ac", sourceLevel: "L3_scene", utterance: "太阳晒了一路，车里越来越闷热", expectedTool: "set_cabin_ac"),
    EvalCase(id: "P005", capability: "cabin.ac", sourceLevel: "L4_free", utterance: "热得像蒸笼，帮我降一降", expectedTool: "set_cabin_ac"),

    EvalCase(id: "P006", capability: "cabin.seat_heating", sourceLevel: "L1_exact", utterance: "打开主驾座椅加热到2挡", expectedTool: "set_cabin_seat_heating"),
    EvalCase(id: "P007", capability: "cabin.seat_heating", sourceLevel: "L1_exact", utterance: "副驾暖座调到3挡", expectedTool: "set_cabin_seat_heating"),
    EvalCase(id: "P008", capability: "cabin.seat_heating", sourceLevel: "L2_feeling", utterance: "屁股有点冷", expectedTool: "set_cabin_seat_heating"),
    EvalCase(id: "P009", capability: "cabin.seat_heating", sourceLevel: "L3_scene", utterance: "冬天刚上车，座椅太冰了", expectedTool: "set_cabin_seat_heating"),
    EvalCase(id: "P010", capability: "cabin.seat_heating", sourceLevel: "L4_free", utterance: "座垫像冰块，给我暖一下", expectedTool: "set_cabin_seat_heating"),

    EvalCase(id: "P011", capability: "cabin.seat_ventilation", sourceLevel: "L1_exact", utterance: "打开主驾座椅通风到2挡", expectedTool: "set_cabin_seat_ventilation"),
    EvalCase(id: "P012", capability: "cabin.seat_ventilation", sourceLevel: "L1_exact", utterance: "副驾座椅吹风调到1挡", expectedTool: "set_cabin_seat_ventilation"),
    EvalCase(id: "P013", capability: "cabin.seat_ventilation", sourceLevel: "L2_feeling", utterance: "后背出汗了", expectedTool: "set_cabin_seat_ventilation"),
    EvalCase(id: "P014", capability: "cabin.seat_ventilation", sourceLevel: "L3_scene", utterance: "夏天坐垫太闷了", expectedTool: "set_cabin_seat_ventilation"),
    EvalCase(id: "P015", capability: "cabin.seat_ventilation", sourceLevel: "L4_free", utterance: "座椅像捂着热气，帮我散散", expectedTool: "set_cabin_seat_ventilation"),

    EvalCase(id: "P016", capability: "cabin.window", sourceLevel: "L1_exact", utterance: "把主驾车窗打开一半", expectedTool: "set_cabin_window"),
    EvalCase(id: "P017", capability: "cabin.window", sourceLevel: "L1_exact", utterance: "关上所有车窗", expectedTool: "set_cabin_window"),
    EvalCase(id: "P018", capability: "cabin.window", sourceLevel: "L2_feeling", utterance: "副驾有点闷，透透气", expectedTool: "set_cabin_window"),
    EvalCase(id: "P019", capability: "cabin.window", sourceLevel: "L3_scene", utterance: "下雨了，帮我把窗户关好", expectedTool: "set_cabin_window"),
    EvalCase(id: "P020", capability: "cabin.window", sourceLevel: "L4_free", utterance: "车里像不通风，开条缝", expectedTool: "set_cabin_window"),

    EvalCase(id: "P021", capability: "cabin.ambient_light", sourceLevel: "L1_exact", utterance: "打开蓝色氛围灯", expectedTool: "set_cabin_ambient_light"),
    EvalCase(id: "P022", capability: "cabin.ambient_light", sourceLevel: "L1_exact", utterance: "关掉氛围灯", expectedTool: "set_cabin_ambient_light"),
    EvalCase(id: "P023", capability: "cabin.ambient_light", sourceLevel: "L2_alias", utterance: "换成暖色灯", expectedTool: "set_cabin_ambient_light"),
    EvalCase(id: "P024", capability: "cabin.ambient_light", sourceLevel: "G3_open_word_to_enum", utterance: "我想要大海颜色的氛围灯", expectedTool: "set_cabin_ambient_light", tags: ["g3_parameter_planning"]),
    EvalCase(id: "P025", capability: "cabin.ambient_light", sourceLevel: "G3_open_word_to_enum", utterance: "车里来点夜晚海边的感觉", expectedTool: "set_cabin_ambient_light", tags: ["g3_parameter_planning"]),

    EvalCase(id: "P026", capability: "cabin.screen_brightness", sourceLevel: "L1_exact", utterance: "把屏幕亮度调到40%", expectedTool: "set_cabin_screen_brightness"),
    EvalCase(id: "P027", capability: "cabin.screen_brightness", sourceLevel: "L2_delta", utterance: "屏幕调暗一点", expectedTool: "set_cabin_screen_brightness"),
    EvalCase(id: "P028", capability: "cabin.screen_brightness", sourceLevel: "L2_feeling", utterance: "屏幕太亮了", expectedTool: "set_cabin_screen_brightness"),
    EvalCase(id: "P029", capability: "cabin.screen_brightness", sourceLevel: "L3_scene", utterance: "晚上开车屏幕晃眼", expectedTool: "set_cabin_screen_brightness"),
    EvalCase(id: "P030", capability: "cabin.screen_brightness", sourceLevel: "L4_free", utterance: "亮得我头疼，柔和一点", expectedTool: "set_cabin_screen_brightness"),

    EvalCase(id: "P031", capability: "cabin.fan", sourceLevel: "L1_exact", utterance: "风量调到3挡", expectedTool: "set_cabin_fan"),
    EvalCase(id: "P032", capability: "cabin.fan", sourceLevel: "L1_exact", utterance: "把风量关到0挡", expectedTool: "set_cabin_fan"),
    EvalCase(id: "P033", capability: "cabin.fan", sourceLevel: "L2_delta", utterance: "风小一点", expectedTool: "set_cabin_fan"),
    EvalCase(id: "P034", capability: "cabin.fan", sourceLevel: "L3_scene", utterance: "车里空气不流动", expectedTool: "set_cabin_fan"),
    EvalCase(id: "P035", capability: "cabin.fan", sourceLevel: "L4_free", utterance: "闷得没风，吹大点", expectedTool: "set_cabin_fan"),

    EvalCase(id: "P036", capability: "cabin.comfort_query", sourceLevel: "L1_exact", utterance: "查一下车里几度", expectedTool: "query_cabin_comfort"),
    EvalCase(id: "P037", capability: "cabin.comfort_query", sourceLevel: "L1_exact", utterance: "空调现在什么状态", expectedTool: "query_cabin_comfort"),
    EvalCase(id: "P038", capability: "cabin.comfort_query", sourceLevel: "L2_topic", utterance: "座椅现在什么状态", expectedTool: "query_cabin_comfort"),
    EvalCase(id: "P039", capability: "cabin.comfort_query", sourceLevel: "L3_scene", utterance: "现在车里舒适状态怎么样", expectedTool: "query_cabin_comfort"),
    EvalCase(id: "P040", capability: "cabin.comfort_query", sourceLevel: "L4_free", utterance: "帮我看看这会儿车里舒服不舒服", expectedTool: "query_cabin_comfort"),

    EvalCase(id: "N001", capability: "negative.chat", sourceLevel: "OOD_chat", utterance: "今天天气怎么样", expectedTool: nil, isNegative: true),
    EvalCase(id: "N002", capability: "negative.chat", sourceLevel: "OOD_writing", utterance: "帮我写一首关于海的诗", expectedTool: nil, isNegative: true),
    EvalCase(id: "N003", capability: "negative.translation", sourceLevel: "OOD_translation", utterance: "把这句话翻译成英文", expectedTool: nil, isNegative: true),
    EvalCase(id: "N004", capability: "negative.chat", sourceLevel: "OOD_joke", utterance: "讲个笑话", expectedTool: nil, isNegative: true),
    EvalCase(id: "N005", capability: "negative.finance", sourceLevel: "OOD_finance", utterance: "查一下今天美股行情", expectedTool: nil, isNegative: true),
    EvalCase(id: "N006", capability: "negative.food", sourceLevel: "OOD_food", utterance: "给我订一杯咖啡", expectedTool: nil, isNegative: true),
    EvalCase(id: "N007", capability: "negative.navigation", sourceLevel: "OOD_navigation", utterance: "导航去公司", expectedTool: nil, isNegative: true),
    EvalCase(id: "N008", capability: "negative.music", sourceLevel: "OOD_music", utterance: "播放周杰伦的歌", expectedTool: nil, isNegative: true),
    EvalCase(id: "N009", capability: "negative.mail", sourceLevel: "OOD_mail", utterance: "给老板发邮件", expectedTool: nil, isNegative: true),
    EvalCase(id: "N012", capability: "negative.calendar", sourceLevel: "OOD_calendar", utterance: "明天提醒我开会", expectedTool: nil, isNegative: true),
    EvalCase(id: "N013", capability: "negative.search", sourceLevel: "OOD_local_search", utterance: "搜索附近餐厅", expectedTool: nil, isNegative: true),
    EvalCase(id: "N014", capability: "negative.knowledge", sourceLevel: "OOD_knowledge", utterance: "解释一下量子力学", expectedTool: nil, isNegative: true),
    EvalCase(id: "N015", capability: "negative.asr_hallucination", sourceLevel: "OOD_hallucination", utterance: "请不吝点赞", expectedTool: nil, isNegative: true),
    EvalCase(id: "N016", capability: "negative.restraint", sourceLevel: "restraint", utterance: "不要开空调", expectedTool: nil, isNegative: true, tags: ["restraint"]),
    EvalCase(id: "N017", capability: "negative.restraint", sourceLevel: "restraint", utterance: "已经26度了，不要再调", expectedTool: nil, isNegative: true, tags: ["restraint"]),
]

private struct ToolCallSnapshot: Codable, Sendable {
    let name: String
    let arguments: [String: JSONValue]
}

private struct CompletionInfoSnapshot: Codable, Sendable {
    let promptTokenCount: Int
    let generationTokenCount: Int
    let promptTime: Double
    let generationTime: Double
    let tokensPerSecond: Double
    let stopReason: String

    init(_ info: GenerateCompletionInfo) {
        self.promptTokenCount = info.promptTokenCount
        self.generationTokenCount = info.generationTokenCount
        self.promptTime = info.promptTime
        self.generationTime = info.generateTime
        self.tokensPerSecond = info.tokensPerSecond.isFinite ? info.tokensPerSecond : 0
        self.stopReason = String(describing: info.stopReason)
    }
}

private struct CaseResult: Codable, Sendable {
    let id: String
    let runIndex: Int?
    let capability: String
    let sourceLevel: String
    let utterance: String
    let expectedTool: String?
    let expectedToolHit: Bool
    let isNegative: Bool
    let tags: [String]
    let toolCalls: [ToolCallSnapshot]
    let chunkText: String
    let contentLooksLikeToolCall: Bool
    let thinkLeak: Bool
    let elapsedMs: Int
    let firstEventMs: Int?
    let completion: CompletionInfoSnapshot?
}

private struct Summary: Codable, Sendable {
    let positiveCount: Int
    let negativeCount: Int
    let g1TriggerCount: Int
    let g1TriggerRate: Double
    let positiveExpectedToolHitRate: Double
    let g2ContentToolCallCount: Int
    let g2ContentToolCallRate: Double
    let g3NegativeFalseCallCount: Int
    let g3NegativeFalseCallRate: Double
    let g4AverageElapsedMs: Double
    let g4AverageFirstEventMs: Double
    let g4AverageTokensPerSecond: Double
    let g5Cases: Int
    let g5EnumSuccessCount: Int
    let g5EnumSuccessRate: Double
    let thinkLeakCount: Int
    let decision: String

    init(results: [CaseResult]) {
        let positives = results.filter { !$0.isNegative }
        let negatives = results.filter(\.isNegative)
        positiveCount = positives.count
        negativeCount = negatives.count

        g1TriggerCount = positives.filter { !$0.toolCalls.isEmpty }.count
        g1TriggerRate = rate(g1TriggerCount, positives.count)
        positiveExpectedToolHitRate = rate(positives.filter(\.expectedToolHit).count, positives.count)

        g2ContentToolCallCount = positives.filter { $0.toolCalls.isEmpty && $0.contentLooksLikeToolCall }.count
        g2ContentToolCallRate = rate(g2ContentToolCallCount, positives.count)

        g3NegativeFalseCallCount = negatives.filter { !$0.toolCalls.isEmpty }.count
        g3NegativeFalseCallRate = rate(g3NegativeFalseCallCount, negatives.count)

        g4AverageElapsedMs = average(results.map { Double($0.elapsedMs) })
        g4AverageFirstEventMs = average(results.compactMap { $0.firstEventMs.map(Double.init) })
        g4AverageTokensPerSecond = average(results.compactMap { $0.completion?.tokensPerSecond })

        let g5 = results.filter { $0.tags.contains("g3_parameter_planning") }
        g5Cases = g5.count
        g5EnumSuccessCount = g5.filter { result in
            result.toolCalls.contains { call in
                call.name == "set_cabin_ambient_light"
                    && ["blue", "cool"].contains(colorArgument(call.arguments))
            }
        }.count
        g5EnumSuccessRate = rate(g5EnumSuccessCount, g5.count)

        thinkLeakCount = results.filter(\.thinkLeak).count

        if g1TriggerRate < 0.5 {
            decision = "no-go: LoRA 前置 + HIGH 停下让磊哥拍"
        } else if g1TriggerRate < 0.8 {
            decision = "go+LoRA: change3 可继续薄层验证，但 LoRA Day1 必采漏触发样本"
        } else if g3NegativeFalseCallRate > 0.2 {
            decision = "go-with-restraint-risk: 触发率达标但拒识误调偏高，change3 继续且 intent-routing/LoRA 加强负样本"
        } else {
            decision = "go: base 触发率达到 task 0.1 门槛"
        }
    }
}

private struct ResultEnvelope: Codable, Sendable {
    let status: String
    let modelID: String
    let mlxSwiftLMTag: String
    let requestedToolCallFormat: String
    let resolvedToolCallFormat: String
    let loraAdapterID: String?
    let loraCheckpointID: String?
    let loraAdapterPath: String?
    let loraAdapterConfigNormalization: LoRAAdapterConfigNormalization?
    let snapshotTime: String
    let totalCases: Int
    let summary: Summary
    let results: [CaseResult]
}

private func rate(_ numerator: Int, _ denominator: Int) -> Double {
    guard denominator > 0 else { return 0 }
    return Double(numerator) / Double(denominator)
}

private func average(_ values: [Double]) -> Double {
    guard !values.isEmpty else { return 0 }
    return values.reduce(0, +) / Double(values.count)
}

private func colorArgument(_ arguments: [String: JSONValue]) -> String? {
    guard case .string(let value)? = arguments["color"] else {
        return nil
    }
    return value
}

private func percent(_ value: Double) -> String {
    String(format: "%.1f%%", value * 100)
}

private func decimal(_ value: Double) -> String {
    String(format: "%.2f", value)
}

private func g1GateNote(_ summary: Summary) -> String {
    if summary.g1TriggerRate >= 0.8 {
        return "gate: \(percent(summary.g1TriggerRate)) reaches the 80.0% pure-go trigger threshold; final decision still includes G2/G3/G5 risk checks."
    }
    if summary.g1TriggerRate >= 0.5 {
        return "gate: \(percent(summary.g1TriggerRate)) is between the 50.0% and 80.0% trigger thresholds, so the G1 band is `go+LoRA`, not plain `go`."
    }
    return "gate: \(percent(summary.g1TriggerRate)) is below the 50.0% trigger threshold, so the G1 band is LoRA-first + HIGH risk."
}

private func renderReport(_ envelope: ResultEnvelope) -> String {
    let summary = envelope.summary
    let failedPositiveRows = envelope.results
        .filter { !$0.isNegative && !$0.expectedToolHit }
        .map { "- \($0.id) \($0.capability): expected=\($0.expectedTool ?? "none"), got=\($0.toolCalls.map(\.name).joined(separator: ",")), contentTool=\($0.contentLooksLikeToolCall)" }
        .joined(separator: "\n")
    let falseNegativeRows = envelope.results
        .filter { $0.isNegative && !$0.toolCalls.isEmpty }
        .map { "- \($0.id) \($0.sourceLevel): got=\($0.toolCalls.map(\.name).joined(separator: ",")) utterance=\($0.utterance)" }
        .joined(separator: "\n")
    let g5Rows = envelope.results
        .filter { $0.tags.contains("g3_parameter_planning") }
        .map { result in
            let args = result.toolCalls.first?.arguments ?? [:]
            return "- \(result.id): got=\(result.toolCalls.map(\.name).joined(separator: ",")) color=\(colorArgument(args) ?? "nil") utterance=\(result.utterance)"
        }
        .joined(separator: "\n")

    return """
    # spike E3 function-call report

    status: \(envelope.status)
    model: \(envelope.modelID)
    mlx-swift-lm: \(envelope.mlxSwiftLMTag)
    requested_tool_call_format: \(envelope.requestedToolCallFormat)
    resolved_tool_call_format: \(envelope.resolvedToolCallFormat)
    lora_adapter_id: \(envelope.loraAdapterID ?? "none")
    lora_checkpoint_id: \(envelope.loraCheckpointID ?? "none")
    lora_adapter_config_normalization: \(envelope.loraAdapterConfigNormalization?.status ?? "none")
    snapshot_time: \(envelope.snapshotTime)
    cases: \(envelope.totalCases) total = \(summary.positiveCount) positive + \(summary.negativeCount) negative
    decision: \(summary.decision)

    ## G1 trigger rate
    - positive `.toolCall` trigger: \(summary.g1TriggerCount)/\(summary.positiveCount) = \(percent(summary.g1TriggerRate))
    - expected tool hit rate: \(percent(summary.positiveExpectedToolHitRate))
    - \(g1GateNote(summary))

    ## G2 format stability
    - content-embedded tool JSON without `.toolCall`: \(summary.g2ContentToolCallCount)/\(summary.positiveCount) = \(percent(summary.g2ContentToolCallRate))
    - scoring: content-embedded tool JSON is counted as G2 instability only; it is not counted as a successful `.toolCall`.
    - think leak count: \(summary.thinkLeakCount)

    ## G3 refusal / restraint
    - negative false tool calls: \(summary.g3NegativeFalseCallCount)/\(summary.negativeCount) = \(percent(summary.g3NegativeFalseCallRate))

    ## G4 latency / streaming
    - average elapsed: \(decimal(summary.g4AverageElapsedMs)) ms
    - average first stream event: \(decimal(summary.g4AverageFirstEventMs)) ms
    - average generation tok/s: \(decimal(summary.g4AverageTokensPerSecond))
    - anchor: elapsed is prompt submit to stream completion; first event is prompt submit to first `.chunk` / `.toolCall` / `.info`.

    ## G5 G3 parameter-planning mini-spike
    - open-word to color enum success: \(summary.g5EnumSuccessCount)/\(summary.g5Cases) = \(percent(summary.g5EnumSuccessRate))
    \(g5Rows.isEmpty ? "- no G5 cases" : g5Rows)

    ## Positive misses
    \(failedPositiveRows.isEmpty ? "- none" : failedPositiveRows)

    ## Negative false calls
    \(falseNegativeRows.isEmpty ? "- none" : falseNegativeRows)

    ## Notes
    - `toolCallFormat` requested=\(envelope.requestedToolCallFormat), resolved=\(envelope.resolvedToolCallFormat).
    - `additionalContext["enable_thinking"] = false`; `<think>` in chunks is recorded as `thinkLeak`.
    - Samples are derived from `contracts/capabilities.yaml` 8 active capabilities and project restraint/OOD seeds; no model-generated samples are used.
    - This is an isolated SpikeE3 model-eval harness. It may run base-only or a LoRA adapter when explicit LoRA args are provided; no main app integration or real vehicle control is exercised.
    """
}
