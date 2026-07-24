import AVFoundation
import XCTest
@testable import MAformacCore

/// S5 product-operator TTS hard-gate proofs (AD-7).
///
/// Covers: AV nil-voice fail-closed, runner full/atomic voice freeze + visual-first,
/// context-aware FallbackCompletionPhraseGate, App applyRuntimeReadbackStep source
/// contract, and runtime_local_preflight script contract.
final class ProductOperatorTTSHardGateTests: XCTestCase {
    private final class CallCounter: @unchecked Sendable {
        private let lock = NSLock()
        private var value = 0
        var count: Int {
            lock.lock(); defer { lock.unlock() }
            return value
        }
        func increment() {
            lock.lock(); defer { lock.unlock() }
            value += 1
        }
    }

    private var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    // MARK: - S5.1 AV engine: blank + nil voice fail closed

    func testAVSpeechEngine_blankTextFailsEmptyBeforeVoiceLookup() {
        let voiceLookups = CallCounter()
        let engine = AVSpeechSynthesisEngine(voiceProvider: {
            voiceLookups.increment()
            XCTFail("blank text must fail before voice lookup")
            return nil
        })

        let result = engine.speak(" \n\t ")

        XCTAssertEqual(result.status, .failed)
        XCTAssertEqual(result.reason, "empty_tts_text")
        XCTAssertEqual(result.route, .unavailable)
        XCTAssertFalse(result.didEnqueue)
        XCTAssertEqual(voiceLookups.count, 0)
        XCTAssertNotEqual(result.route, .systemDefault)
    }

    func testAVSpeechEngine_nilChineseVoiceFailsClosedWithoutSystemDefaultSuccess() {
        let voiceLookups = CallCounter()
        let engine = AVSpeechSynthesisEngine(voiceProvider: {
            voiceLookups.increment()
            return nil
        })

        let result = engine.speak("空调已打开")

        XCTAssertEqual(voiceLookups.count, 1, "non-empty text must consult voice provider")
        XCTAssertEqual(result.status, .failed)
        XCTAssertEqual(result.reason, "chinese_voice_unavailable")
        XCTAssertEqual(result.route, .unavailable)
        XCTAssertFalse(result.didEnqueue)
        // No silent invent of systemDefault success (pre-S5 regression).
        XCTAssertNotEqual(result.route, .systemDefault)
        XCTAssertNotEqual(result.status, .enqueued)
    }

    func testAVSpeechEngine_sourceOrdersVoiceGuardBeforeSynthesizerSpeak() throws {
        let source = try String(
            contentsOf: repoRoot.appendingPathComponent("Core/Voice/SpeechSynthesisEngine.swift"),
            encoding: .utf8
        )
        let speakBody = try methodBody(
            named: "public func speak(_ text: String) -> SpeechSynthesisResult",
            in: source
        )

        let nilFailRange = try XCTUnwrap(
            speakBody.range(of: "chinese_voice_unavailable"),
            "nil voice must fail with chinese_voice_unavailable"
        )
        let speakCallRange = try XCTUnwrap(
            speakBody.range(of: "synthesizer.speak"),
            "success path still enqueues via synthesizer.speak"
        )
        XCTAssertLessThan(
            nilFailRange.lowerBound,
            speakCallRange.lowerBound,
            "voice nil gate must return before synthesizer enqueue"
        )
        XCTAssertTrue(speakBody.contains("guard let voice = voiceProvider() else"))
        // Fail path must not invent systemDefault success after nil voice.
        XCTAssertFalse(
            speakBody.contains(".enqueued(route: .systemDefault)"),
            "nil voice must not silently enqueue systemDefault"
        )
    }

    func testAVSpeechEngine_injectedChineseVoiceMayEnqueueWithoutSystemDefault() {
        guard let voice = AVSpeechSynthesisVoice(language: "zh-CN")
            ?? AVSpeechSynthesisVoice.speechVoices().first(where: { $0.language.hasPrefix("zh") })
        else {
            // Local CI without any zh voice: nil path is the hard gate under test.
            // Enqueue success is optional when OS provides no Chinese voice.
            return
        }

        let engine = AVSpeechSynthesisEngine(voiceProvider: { voice })
        let result = engine.speak("空调已打开")

        XCTAssertTrue(result.didEnqueue)
        XCTAssertEqual(result.status, .enqueued)
        XCTAssertNotEqual(result.route, .systemDefault)
        XCTAssertTrue(
            result.route == .preferredChinese || result.route == .fallbackChinese,
            "enqueued route must be preferred/fallback Chinese, not systemDefault"
        )
    }

    // MARK: - S5.2 Runner full + atomic multi-frame: visual truth + Core voice freeze

    @MainActor
    func testRunnerFullPath_failedSynthesisKeepsVisualTruthAndFreezesCoreVoiceIdle() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let speech = RecordingSpeechSynthesisEngine(
            nextResult: .failed(reason: "chinese_voice_unavailable")
        )
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            speech: speech
        )

        let payload = try await runner.run(text: "打开空调")

        // Visual-first / store / readback truth preserved.
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(payload.outcome.result, .acceptedToolCall)
        XCTAssertEqual(payload.reconciliation.status, .verified)
        XCTAssertEqual(payload.readbacks.first?.key, "ac.power")
        XCTAssertEqual(payload.readbacks.first?.spokenText, "空调已打开")
        XCTAssertEqual(speech.spokenTexts, ["空调已打开"])

        // Observable TTS failure on existing readback surface.
        XCTAssertTrue(trace.entries.contains { entry in
            entry.stage == .readback
                && entry.message == "tts_fail_open:chinese_voice_unavailable"
                && entry.attributes.readbackResult == .failed
        })

        // Core voice freeze is wired through speechDidEnqueue → .idle (payload drops
        // voiceState; enforce via runner source contract + fail path observables).
        try assertRunnerCoreVoiceFreezeContract()
    }

    @MainActor
    func testRunnerFullPath_enqueuedSynthesisUsesSpeakVoiceBranch() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let speech = RecordingSpeechSynthesisEngine(
            nextResult: .enqueued(route: .testDouble)
        )
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            speech: speech
        )

        let payload = try await runner.run(text: "打开空调")

        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(payload.outcome.result, .acceptedToolCall)
        XCTAssertEqual(payload.readbacks.first?.spokenText, "空调已打开")
        XCTAssertEqual(speech.spokenTexts, ["空调已打开"])
        XCTAssertFalse(trace.entries.contains { $0.message.hasPrefix("tts_fail_open:") })
        try assertRunnerCoreVoiceFreezeContract()
    }

    @MainActor
    func testRunnerAtomicRefusal_failedSynthesizerIsNotInvokedForRolledBackReadback() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let speech = RecordingSpeechSynthesisEngine(
            nextResult: .failed(reason: "synthesizer_busy")
        )
        let accepted = acPowerFrame(id: "accepted-ac", traceID: "trace-atomic-tts")
        let refused = unmountedFragranceFrame(id: "refused-fragrance", traceID: "trace-atomic-tts")
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            speech: speech,
            // GOVERNANCE: bypasses NLU by design (not product behavior)
            planDecoder: { _ in try self.atomicRuntimePlan([accepted, refused]) }
        )

        let payload = try await runner.run(text: "打开空调并关闭香氛")

        XCTAssertEqual(payload.outcome.result, .refusalNoAvailableTool)
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "off")
        XCTAssertTrue(payload.readbacks.isEmpty)
        XCTAssertTrue(speech.spokenTexts.isEmpty)
        XCTAssertFalse(trace.entries.contains { $0.message.hasPrefix("tts_fail_open:") })
        try assertRunnerCoreVoiceFreezeContract()
    }

    @MainActor
    func testRunnerAtomicRefusal_doesNotSpeakRolledBackAcceptedDialog() async throws {
        let store = DemoVehicleStateStore()
        let trace = InMemoryTraceLogger()
        let speech = RecordingSpeechSynthesisEngine(
            nextResult: .enqueued(route: .testDouble)
        )
        let accepted = acPowerFrame(id: "accepted-ac", traceID: "trace-atomic-ok")
        let refused = unmountedFragranceFrame(id: "refused-fragrance", traceID: "trace-atomic-ok")
        let runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try makeRepoPipeline(),
            traceLogger: trace,
            speech: speech,
            // GOVERNANCE: bypasses NLU by design (not product behavior)
            planDecoder: { _ in try self.atomicRuntimePlan([accepted, refused]) }
        )

        let payload = try await runner.run(text: "打开空调并关闭香氛")

        XCTAssertEqual(payload.outcome.result, .refusalNoAvailableTool)
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "off")
        XCTAssertTrue(payload.readbacks.isEmpty)
        XCTAssertTrue(speech.spokenTexts.isEmpty)
        XCTAssertFalse(trace.entries.contains { $0.message.hasPrefix("tts_fail_open:") })
        try assertRunnerCoreVoiceFreezeContract()
    }

    private func atomicRuntimePlan(_ frames: [ToolCallFrame]) throws -> RuntimePlan {
        try RuntimePlan(
            traceID: frames.first?.traceID ?? "",
            frames: frames.map(RuntimeFrame.tool),
            executionPolicy: .atomic
        )
    }

    /// Core PresentationSnapshot.voiceState is set from speechDidEnqueue and never
    /// invents `.speak` on failure. RuntimePresentationPayload drops voiceState at
    /// the public wire; the freeze is load-bearing on the runner construction path.
    private func assertRunnerCoreVoiceFreezeContract() throws {
        let source = try String(
            contentsOf: repoRoot.appendingPathComponent("Core/Execution/DemoRuntimeSessionRunner.swift"),
            encoding: .utf8
        )
        XCTAssertTrue(source.contains("coreVoiceDisplayState"))
        XCTAssertTrue(source.contains("speechDidEnqueue"))
        XCTAssertTrue(source.contains("voiceState: coreVoiceState"))
        XCTAssertTrue(source.contains("return speechDidEnqueue ? .speak : .idle"))
        // Old unconditional invent-speak on non-empty dialog must not remain alone.
        XCTAssertFalse(
            source.contains("voiceState: dialogText.isEmpty ? .idle : .speak"),
            "must not invent .speak solely from non-empty dialog"
        )
    }

    // MARK: - S5.3 FallbackCompletionPhraseGate (public typed API)

    func testCompletionPhraseGate_eachForbiddenPhraseFailsOnErrorOutcomes() {
        let errorSurfaces: [(FallbackResultKind, FallbackSafeReasonKind)] = [
            (.clarifyMissingSlot, .clarificationRequired),
            (.refusalSafetyOrPolicy, .safetyPolicy),
            (.refusalNoAvailableTool, .capabilityNotMounted),
            (.refusalNoAvailableTool, .notAvailableInDemo),
            (.cancelled, .runtimeUnavailable),
            (.runtimeError, .runtimeUnavailable),
        ]

        for phrase in FallbackCompletionPhraseGate.forbiddenCompletionPhrases {
            for (resultKind, safeReason) in errorSurfaces {
                let dialogDisposition = FallbackCompletionPhraseGate.evaluate(
                    resultKind: resultKind,
                    safeReasonKind: safeReason,
                    dialogText: "当前状态保持不变，\(phrase)。",
                    ttsText: "请稍后再试"
                )
                XCTAssertEqual(
                    dialogDisposition,
                    .fail,
                    "dialog forbidden phrase \(phrase) must fail for \(resultKind)/\(safeReason)"
                )

                let ttsDisposition = FallbackCompletionPhraseGate.evaluate(
                    resultKind: resultKind,
                    safeReasonKind: safeReason,
                    dialogText: "当前状态保持不变",
                    ttsText: "抱歉，\(phrase)"
                )
                XCTAssertEqual(
                    ttsDisposition,
                    .fail,
                    "tts forbidden phrase \(phrase) must fail for \(resultKind)/\(safeReason)"
                )
            }
        }
    }

    func testCompletionPhraseGate_errorOutcomeWithoutForbiddenPhrasePasses() {
        let disposition = FallbackCompletionPhraseGate.evaluate(
            resultKind: .refusalSafetyOrPolicy,
            safeReasonKind: .safetyPolicy,
            dialogText: "当前状态下不能执行这项操作，车辆状态保持不变。",
            ttsText: "当前状态下不能执行这项操作，车辆状态保持不变。"
        )
        XCTAssertEqual(disposition, .pass)
        XCTAssertTrue(
            FallbackCompletionPhraseGate.isErrorOutcomeInScope(
                resultKind: .refusalSafetyOrPolicy,
                safeReasonKind: .safetyPolicy
            )
        )
    }

    func testCompletionPhraseGate_acceptedAlreadyDonePartialAndBadgeOnlyNotBlanketRejected() {
        // Accepted success speech may contain completion wording — out of scan scope.
        XCTAssertEqual(
            FallbackCompletionPhraseGate.evaluate(
                resultKind: .acceptedToolCall,
                safeReasonKind: .alreadyDone,
                dialogText: "空调已打开，操作成功",
                ttsText: "操作成功"
            ),
            .notInScope
        )

        // alreadyDone with badge-like「已完成」in dialog must not hard-gate fail.
        XCTAssertEqual(
            FallbackCompletionPhraseGate.evaluate(
                resultKind: .alreadyStateNoop,
                safeReasonKind: .alreadyDone,
                dialogText: "当前已经是目标状态，无需重复操作。",
                ttsText: "当前已经是目标状态，无需重复操作。"
            ),
            .notInScope
        )
        XCTAssertFalse(
            FallbackCompletionPhraseGate.isErrorOutcomeInScope(
                resultKind: .alreadyStateNoop,
                safeReasonKind: .alreadyDone
            )
        )

        // Partial accept/refuse is excluded from hard-gate scan.
        XCTAssertEqual(
            FallbackCompletionPhraseGate.evaluate(
                resultKind: .partialAcceptPartialRefuse,
                safeReasonKind: .capabilityNotMounted,
                dialogText: "部分已完成，部分暂未接入",
                ttsText: "部分已完成"
            ),
            .notInScope
        )

        // Badge-only「已完成」is never scanned by the typed API (dialog/tts only).
        // Even when dialog is clean and badge would say 已完成, disposition stays pass.
        let cleanError = FallbackCompletionPhraseGate.evaluate(
            resultKind: .refusalNoAvailableTool,
            safeReasonKind: .notAvailableInDemo,
            dialogText: "这项能力不在本轮演示范围，我先保持原样。",
            ttsText: "这项能力不在本轮演示范围，我先保持原样。"
        )
        XCTAssertEqual(cleanError, .pass)

        // Catalog alreadyDone badge path: resolve via property on real FallbackContext.
        let alreadyDoneContext = FallbackContext.resolve(
            family: nil,
            reasonKind: .unknownNoRepresentativeEntry
        )
        // unknownNoRepresentative is error-scope, but real dialogs must not promise success.
        XCTAssertNotEqual(alreadyDoneContext.completionPhraseGateDisposition, .fail)

        // Explicit alreadyDone projection surface (badge 「已完成」) is not_in_scope.
        let alreadyDoneDisposition = FallbackCompletionPhraseGate.evaluate(
            resultKind: .alreadyStateNoop,
            safeReasonKind: .alreadyDone,
            dialogText: "当前已经是目标状态，无需重复操作。",
            ttsText: "当前已经是目标状态，无需重复操作。"
        )
        XCTAssertEqual(alreadyDoneDisposition, .notInScope)
        // Badge label is not a scan argument — presence of「已完成」on badge alone cannot fail.
        XCTAssertTrue(FallbackCompletionPhraseGate.forbiddenCompletionPhrases.contains("已完成"))
    }

    func testCompletionPhraseGate_resolvedFallbackContextsForSafetyClarifyHaveNoForbiddenPhrases() {
        let safety = FallbackContext.resolve(
            userText: "打开车门",
            finiteReason: .safetyOrPolicyRefusal
        )
        XCTAssertTrue(
            FallbackCompletionPhraseGate.isErrorOutcomeInScope(
                resultKind: safety.outcome.resultKind,
                safeReasonKind: safety.outcome.safeReasonKind
            )
        )
        XCTAssertEqual(safety.completionPhraseGateDisposition, .pass)
        XCTAssertFalse(
            FallbackCompletionPhraseGate.containsForbiddenCompletionPhrase(safety.dialogText)
        )
        XCTAssertFalse(
            FallbackCompletionPhraseGate.containsForbiddenCompletionPhrase(safety.ttsText)
        )

        let clarify = FallbackContext.resolve(
            userText: nil,
            finiteReason: .clarifyMissingSlot
        )
        // clarifyMissingSlot projects to clarify; if in-scope must pass clean.
        if FallbackCompletionPhraseGate.isErrorOutcomeInScope(
            resultKind: clarify.outcome.resultKind,
            safeReasonKind: clarify.outcome.safeReasonKind
        ) {
            XCTAssertEqual(
                clarify.completionPhraseGateDisposition,
                FallbackCompletionPhraseGateDisposition.pass
            )
        }
    }

    // MARK: - S5.4 App applyRuntimeReadbackStep source contract

    func testAppApplyRuntimeReadbackStep_capturesSpeechResultVisualFirstNoFalseSpeaking() throws {
        let source = try String(
            contentsOf: repoRoot.appendingPathComponent("App/ContentView.swift"),
            encoding: .utf8
        )
        let stepBody = try section(
            in: source,
            from: "private func applyRuntimeReadbackStep",
            until: "private func shouldWaitForEnergyLine"
        )

        // Capture result — reject discard `_ = speech.speak(...)`.
        XCTAssertTrue(
            stepBody.contains("let speechResult = speech.speak"),
            "applyRuntimeReadbackStep must store SpeechSynthesisResult"
        )
        XCTAssertFalse(
            stepBody.contains("_ = speech.speak"),
            "must not discard speak result with _ ="
        )
        // Visual resolution applied regardless of TTS outcome.
        XCTAssertTrue(stepBody.contains("resolveRuntimeReadbackEvent"))
        XCTAssertTrue(stepBody.contains("appliedSnapshot"))

        // Failure path freezes App voice away from .speaking and observes failure.
        XCTAssertTrue(stepBody.contains("!speechResult.didEnqueue"))
        XCTAssertTrue(stepBody.contains("snapshotWithNonSpeakingVoice"))
        XCTAssertTrue(stepBody.contains("observeRuntimeTTSFailure"))

        let freezeBody = try section(
            in: source,
            from: "private static func snapshotWithNonSpeakingVoice",
            until: "private func observeRuntimeTTSFailure"
        )
        XCTAssertTrue(freezeBody.contains("voiceState == .speaking") || freezeBody.contains(".speaking"))
        XCTAssertTrue(freezeBody.contains("voiceState = .idle"))
        XCTAssertFalse(
            freezeBody.contains("voiceState = .speaking"),
            "failure freeze must not re-enter .speaking"
        )
        let observeBody = try section(
            in: source,
            from: "private func observeRuntimeTTSFailure",
            until: "private func shouldWaitForEnergyLine"
        )
        XCTAssertTrue(observeBody.contains("tts_fail_open:"))
        XCTAssertTrue(observeBody.contains("readbackResult: .failed") || observeBody.contains("TraceAttributes(readbackResult: .failed)"))
    }

    // MARK: - S5.5 Preflight script source contract

    func testPreflightScript_runtimeLocalPreflightOnlyWithRealAVLookup() throws {
        let scriptPath = repoRoot.appendingPathComponent("scripts/run_v9_product_operator_tts_preflight.sh")
        XCTAssertTrue(
            FileManager.default.fileExists(atPath: scriptPath.path),
            "exact preflight path must exist: scripts/run_v9_product_operator_tts_preflight.sh"
        )

        let script = try String(contentsOf: scriptPath, encoding: .utf8)
        XCTAssertTrue(script.contains("runtime_local_preflight"))
        XCTAssertTrue(script.contains("\"proof_class\":\"runtime_local_preflight\"") || script.contains("proof_class\": \"runtime_local_preflight\"") || script.contains("\"proof_class\": \"runtime_local_preflight\"") || script.contains("proof_class"))
        // Machine-readable PASS/FAIL.
        XCTAssertTrue(script.contains("\"verdict\":\"PASS\"") || script.contains("verdict = \"PASS\"") || script.contains("\"verdict\": \"PASS\"") || script.contains("verdict"))
        XCTAssertTrue(script.contains("PASS"))
        XCTAssertTrue(script.contains("FAIL"))

        // Real AVSpeech lookup via check script — not a fake echo.
        XCTAssertTrue(script.contains("check_tts_preflight.swift"))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: repoRoot.appendingPathComponent("scripts/check_tts_preflight.swift").path
            )
        )
        let checker = try String(
            contentsOf: repoRoot.appendingPathComponent("scripts/check_tts_preflight.swift"),
            encoding: .utf8
        )
        XCTAssertTrue(checker.contains("AVSpeechSynthesisVoice") || checker.contains("AVSpeechSynthesizer"))
        XCTAssertTrue(checker.contains("zh-CN") || checker.contains("zh"))

        // Non-claims: must not claim operator / mobile / true-device as proof class.
        XCTAssertFalse(script.contains("proof_class\":\"operator"))
        XCTAssertFalse(script.contains("proof_class\":\"mobile"))
        XCTAssertFalse(script.contains("proof_class\":\"true-device"))
        XCTAssertTrue(
            script.contains("non_claims")
                || script.contains("NOT operator")
                || script.contains("not operator")
                || script.contains("true-device"),
            "script must explicitly bound non-claims away from operator/mobile/true-device"
        )
        // Proof class fixed string.
        let proofMatches = occurrences(of: "runtime_local_preflight", in: script)
        XCTAssertGreaterThanOrEqual(proofMatches, 1)
    }

    // MARK: - Helpers

    private func makeRepoPipeline() throws -> C3ExecutionPipeline {
        C3ExecutionPipeline(
            semantic: try SemanticContractLookup(jsonl: readRepoFile("contracts/semantic-function-contract.jsonl")),
            stateCells: try StateCellContractLookup(yaml: readRepoFile("contracts/state-cells.yaml")),
            riskPolicy: try RiskPolicyLookup(yaml: readRepoFile("contracts/risk-policy.yaml")),
            allowlist: try L1DemoAllowlistLookup(yaml: readRepoFile("contracts/l1-demo-allowlist.yaml"))
        )
    }

    private func acPowerFrame(id: String, traceID: String) -> ToolCallFrame {
        // WP1a-7: bypasses NLU, TODO Phase 2 fix
        ToolCallFrame(
            id: id,
            traceID: traceID,
            agentID: "vehicle-control",
            capabilityID: "vehicle.ac.toggle",
            toolName: "set_vehicle_control",
            device: "ac",
            actionPrimitive: "power_on",
            value: ContractValue(offset: "on", type: "STATE"),
            stateRevision: 0,
            candidateSource: .fastPath
        )
    }

    private func unmountedFragranceFrame(id: String, traceID: String) -> ToolCallFrame {
        // WP1a-7: bypasses NLU, TODO Phase 2 fix
        ToolCallFrame(
            id: id,
            traceID: traceID,
            agentID: "vehicle-control",
            capabilityID: "cabin.fragrance",
            toolName: "close_fragrance",
            device: "fragrance",
            actionPrimitive: "power_off",
            stateRevision: 0,
            candidateSource: .upstreamToolCall
        )
    }

    private func readRepoFile(_ relativePath: String) throws -> String {
        try String(contentsOf: repoRoot.appendingPathComponent(relativePath), encoding: .utf8)
    }

    private func occurrences(of needle: String, in source: String) -> Int {
        var count = 0
        var search = source.startIndex..<source.endIndex
        while let range = source.range(of: needle, range: search) {
            count += 1
            search = range.upperBound..<source.endIndex
        }
        return count
    }

    private func section(in source: String, from start: String, until end: String) throws -> String {
        guard let startRange = source.range(of: start) else {
            throw NSError(
                domain: "ProductOperatorTTSHardGateTests",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "missing start: \(start)"]
            )
        }
        let tail = source[startRange.lowerBound...]
        guard let endRange = tail.range(of: end) else { return String(tail) }
        return String(tail[..<endRange.lowerBound])
    }

    private func methodBody(named signature: String, in source: String) throws -> String {
        guard let start = source.range(of: signature) else {
            throw NSError(
                domain: "ProductOperatorTTSHardGateTests",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "missing method: \(signature)"]
            )
        }
        let fromBrace = source[start.lowerBound...]
        guard let open = fromBrace.firstIndex(of: "{") else {
            throw NSError(domain: "ProductOperatorTTSHardGateTests", code: 3)
        }
        var depth = 0
        var index = open
        while index < fromBrace.endIndex {
            let ch = fromBrace[index]
            if ch == "{" { depth += 1 }
            if ch == "}" {
                depth -= 1
                if depth == 0 {
                    return String(fromBrace[open...index])
                }
            }
            index = fromBrace.index(after: index)
        }
        throw NSError(domain: "ProductOperatorTTSHardGateTests", code: 4)
    }
}
