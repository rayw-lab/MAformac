import XCTest

final class FrontstageContainmentSourceContractTests: XCTestCase {
    private var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    func testCustomerMicDockCallbacksUseCompositionSessionAndNeverMockPlanner() throws {
        let source = try String(contentsOf: repoRoot.appendingPathComponent("App/ContentView.swift"), encoding: .utf8)

        XCTAssertEqual(occurrences(of: "onMockVoiceSubmit: submitCustomerMicDock", in: source), 2)
        XCTAssertFalse(source.contains("onMockVoiceSubmit: applyMockVoiceColdIntent"))
        let submission = try section(in: source, from: "private func submitCustomerMicDock", until: "private func applyMockVoiceColdIntent")
        XCTAssertTrue(submission.contains("frontstageRuntimeComposition.session"))
        XCTAssertTrue(submission.contains("frontstageRuntimeComposition.scheduleIngressRoute"))
        XCTAssertFalse(
            submission.contains("Task { @MainActor"),
            "G4 knife3: customer path must not spawn anonymous MainActor Tasks"
        )
        XCTAssertTrue(submission.contains("applyDemoSliceExecution"))
        XCTAssertTrue(submission.contains("FrontstageRouteReceiptWriter.writeCurrent"))
        XCTAssertTrue(submission.contains("frontstageRuntimeComposition.isCurrentTurn"))
        XCTAssertTrue(submission.contains("FRONTSTAGE_ROUTE_RECEIPT_CONFIGURATION_REJECTED"))
        XCTAssertTrue(submission.contains("FRONTSTAGE_ROUTE_RECEIPT_WRITE_FAILED"))
        XCTAssertFalse(submission.contains("try? FrontstageRouteReceiptConfiguration.environment"))
        XCTAssertFalse(submission.contains("_ = try? FrontstageRouteReceiptWriter.writeCurrent"))
        XCTAssertFalse(submission.contains("MockVoicePresetPlanner"))
        XCTAssertFalse(submission.contains("applyMockVoiceColdIntent"))
    }

    func testCompositionBindsOnlyOneNarrowDemoSliceRouteAndKeepsMockPlannerOut() throws {
        let source = try String(contentsOf: repoRoot.appendingPathComponent("App/FrontstageRuntimeComposition.swift"), encoding: .utf8)

        XCTAssertTrue(source.contains("let session: FrontstageVoiceSession"))
        XCTAssertTrue(source.contains("private var demoSliceRoute: DemoSliceRoute?"))
        XCTAssertTrue(source.contains("private var ingressRouteTask: Task<Void, Never>?"))
        XCTAssertTrue(source.contains("func scheduleIngressRoute"))
        XCTAssertTrue(source.contains("func routeDemoSlice"))
        XCTAssertTrue(source.contains("cancelPendingSpeech"))
        XCTAssertTrue(source.contains("RuntimeTurnLease("))
        XCTAssertTrue(source.contains("lease: lease"))
        XCTAssertEqual(occurrences(of: "= try DemoSliceRoute(", in: source), 1)
        XCTAssertFalse(source.contains("DemoRuntimePartialPlan"))
        XCTAssertFalse(source.contains("MockVoicePresetPlanner"))
    }

    func testCompositionPreemptsOldIngressBeforeCancelPendingSpeech() throws {
        let source = try String(contentsOf: repoRoot.appendingPathComponent("App/FrontstageRuntimeComposition.swift"), encoding: .utf8)
        let scheduleBody = try section(in: source, from: "func scheduleIngressRoute", until: "func routeDemoSlice")

        XCTAssertTrue(scheduleBody.contains("ingressRouteTask?.cancel()"))
        XCTAssertTrue(scheduleBody.contains("markCurrent(turn)"))
        XCTAssertTrue(scheduleBody.contains("speech.cancelPendingSpeech()"))
        XCTAssertTrue(
            scheduleBody.contains("self.ingressRouteTask = nil"),
            "completed ingress Task must clear its handle"
        )
        XCTAssertTrue(
            scheduleBody.contains("if !Task.isCancelled"),
            "completion clear must not wipe a preempt successor"
        )

        let cancelTaskIdx = try index(of: "ingressRouteTask?.cancel()", in: scheduleBody)
        let markIdx = try index(of: "markCurrent(turn)", in: scheduleBody)
        let speechIdx = try index(of: "speech.cancelPendingSpeech()", in: scheduleBody)
        XCTAssertLessThan(cancelTaskIdx, markIdx, "cancel old Task before switching current identity")
        XCTAssertLessThan(markIdx, speechIdx, "switch current identity before cancelPendingSpeech")
    }

    func testCompositionProductionCallsitePassesCorrelationProviderAndFailClosedIdentity() throws {
        let source = try String(
            contentsOf: repoRoot.appendingPathComponent("App/FrontstageRuntimeComposition.swift"),
            encoding: .utf8
        )

        // S1: production binding is the per-turn factory, not a mutable context box.
        XCTAssertTrue(source.contains("ProductionRouteCorrelationProvider.make"))
        XCTAssertTrue(source.contains("routeTurnID:"))
        XCTAssertTrue(source.contains("sessionRef:"))
        XCTAssertTrue(source.contains("generationRef:"))
        XCTAssertTrue(source.contains("groupOrdinal:"))
        XCTAssertTrue(source.contains("correlationProvider: correlationProvider"))
        XCTAssertFalse(source.contains(".route(text: turn.utterance)"),
        "production path must pass correlationProvider (not legacy single-arg route)")

        // Fail-closed identity assembly before route success.
        XCTAssertTrue(source.contains("FrontstageRuntimeCompositionError.currentTurnMismatch"))
        XCTAssertTrue(source.contains("FrontstageRuntimeCompositionError.invalidTurnSequence"))
        XCTAssertTrue(source.contains("FrontstageRuntimeCompositionError.emptyTurnIdentity"))
        XCTAssertTrue(source.contains("UInt32(exactly: turn.sequence)"))
        XCTAssertTrue(source.contains("ensureActive"))

        // No second production root / global mutable correlation box.
        XCTAssertFalse(source.contains("static var correlation"))
        XCTAssertFalse(source.contains("sharedCorrelation"))
        XCTAssertEqual(occurrences(of: "final class FrontstageRuntimeComposition", in: source), 1)
    }

    func testContentViewCustomerPathDoesNotConstructLocalProductionRunner() throws {
        let source = try String(
            contentsOf: repoRoot.appendingPathComponent("App/ContentView.swift"),
            encoding: .utf8
        )
        XCTAssertTrue(source.contains("frontstageRuntimeComposition.scheduleIngressRoute"))
        XCTAssertEqual(occurrences(of: "= try DemoSliceRoute(", in: source), 0)
        XCTAssertEqual(occurrences(of: "DemoSliceRoute(", in: source), 0)
        XCTAssertEqual(occurrences(of: "DemoRuntimeSessionRunner(", in: source), 0)
        XCTAssertFalse(source.contains("ProductionRouteCorrelationProvider"))
    }

    // MARK: - S5 TTS hard gate (App + preflight source contracts; preserve S0/S1 above)

    func testS5ApplyRuntimeReadbackStepCapturesSpeechResultAndFreezesAppVoiceOnFailure() throws {
        let source = try String(
            contentsOf: repoRoot.appendingPathComponent("App/ContentView.swift"),
            encoding: .utf8
        )
        let stepBody = try section(
            in: source,
            from: "private func applyRuntimeReadbackStep",
            until: "private func shouldWaitForEnergyLine"
        )

        XCTAssertTrue(
            stepBody.contains("let speechResult = speech.speak"),
            "S5: applyRuntimeReadbackStep must capture SpeechSynthesisResult"
        )
        XCTAssertFalse(stepBody.contains("_ = speech.speak"),
        "S5: reject discarded speak result")
        XCTAssertTrue(stepBody.contains("resolveRuntimeReadbackEvent"))
        XCTAssertTrue(stepBody.contains("appliedSnapshot"))
        XCTAssertTrue(stepBody.contains("!speechResult.didEnqueue"))
        XCTAssertTrue(stepBody.contains("snapshotWithNonSpeakingVoice"))
        XCTAssertTrue(stepBody.contains("observeRuntimeTTSFailure"))

        XCTAssertTrue(source.contains("frozen.voiceState = .idle") || source.contains("voiceState = .idle"))
        XCTAssertTrue(source.contains("tts_fail_open:"))
        XCTAssertTrue(source.contains("readbackResult: .failed") || source.contains("TraceAttributes(readbackResult: .failed)"))
    }

    func testS5PreflightScriptIsRuntimeLocalPreflightWithRealAVSpeechLookup() throws {
        let scriptURL = repoRoot.appendingPathComponent("scripts/run_v9_product_operator_tts_preflight.sh")
        XCTAssertTrue(
            FileManager.default.fileExists(atPath: scriptURL.path),
            "S5: scripts/run_v9_product_operator_tts_preflight.sh must exist"
        )
        let script = try String(contentsOf: scriptURL, encoding: .utf8)

        XCTAssertTrue(script.contains("runtime_local_preflight"))
        XCTAssertTrue(script.contains("PASS"))
        XCTAssertTrue(script.contains("FAIL"))
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
        XCTAssertTrue(checker.contains("import AVFoundation"))
        XCTAssertTrue(checker.contains("AVSpeechSynthesisVoice"))

        // Proof class is local preflight only — not operator / mobile / true-device.
        XCTAssertFalse(script.contains("\"proof_class\":\"operator"))
        XCTAssertFalse(script.contains("\"proof_class\":\"mobile"))
        XCTAssertFalse(script.contains("\"proof_class\":\"true_device"))
        XCTAssertTrue(
            script.contains("non_claims")
                || script.contains("true-device")
                || script.contains("NOT operator")
                || script.contains("not operator")
        )
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
            throw NSError(domain: "FrontstageContainmentSourceContractTests", code: 1)
        }
        let tail = source[startRange.lowerBound...]
        guard let endRange = tail.range(of: end) else { return String(tail) }
        return String(tail[..<endRange.lowerBound])
    }

    private func index(of needle: String, in source: String) throws -> String.Index {
        guard let range = source.range(of: needle) else {
            throw NSError(
                domain: "FrontstageContainmentSourceContractTests",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "missing needle: \(needle)"]
            )
        }
        return range.lowerBound
    }
}
