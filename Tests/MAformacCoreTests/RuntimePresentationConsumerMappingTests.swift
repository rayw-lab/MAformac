import XCTest
@testable import MAformacCore

final class RuntimePresentationConsumerMappingTests: XCTestCase {
    func testStableMainlineEventKindsExcludeTimeoutEventKind() {
        XCTAssertEqual(
            RuntimePresentationConsumerMapping.stableMainlineEventKinds,
            ["text_input", "mic_start", "mic_end", "card_tap", "cancel", "interruption"]
        )
        XCTAssertFalse(RuntimePresentationConsumerMapping.stableMainlineEventKinds.contains("timeout"))
    }

    func testStableMainlineEventSourcesAreSeparateFromScopeOrigin() {
        XCTAssertEqual(
            RuntimePresentationConsumerMapping.stableMainlineEventSources,
            ["user", "system", "demo_harness", "runtime_adapter"]
        )

        let scopeOriginNames = Set([ScopeOrigin.defaulted, .explicit, .fanout].map(\.rawValue))
        XCTAssertTrue(Set(RuntimePresentationConsumerMapping.stableMainlineEventSources).isDisjoint(with: scopeOriginNames))
    }

    func testRuntimeResultsMapFromStableMainlineNamesToExistingUIUESurfaces() {
        let expected: [(String, DemoRuntimeResultKind)] = [
            ("accepted_tool_call", .acceptedToolCall),
            ("clarify_missing_slot", .clarifyMissingSlot),
            ("refusal_no_available_tool", .refusalNoAvailableTool),
            ("refusal_safety_or_policy", .refusalSafetyOrPolicy),
            ("already_state_noop", .alreadyStateNoop),
            ("runtime_error", .runtimeError),
            ("cancelled", .cancelled),
            ("interrupted", .cancelled)
        ]

        XCTAssertEqual(RuntimePresentationConsumerMapping.resultEntries.map(\.mainlineResultName), expected.map(\.0))

        for (mainlineName, localKind) in expected {
            XCTAssertEqual(
                RuntimePresentationConsumerMapping.localResultKind(forMainlineResultName: mainlineName),
                localKind,
                mainlineName
            )
        }
    }

    func testD17PayloadSchemaAndFieldsConsumeOnlyStableMainlineNames() throws {
        XCTAssertEqual(RuntimePresentationConsumerMapping.payloadSchemaNames, ["r5_runtime_presentation_payload_v1"])
        XCTAssertEqual(
            RuntimePresentationConsumerMapping.payloadFieldNames,
            [
                "schemaVersion",
                "traceID",
                "turnID",
                "eventID",
                "isTerminal",
                "outcome",
                "proofClass",
                "cards",
                "cardSemantics",
                "readbacks",
                "reconciliation",
                "traceEnvelope"
            ]
        )

        try RuntimePresentationConsumerMapping.validatePayloadSchema("r5_runtime_presentation_payload_v1")
        try RuntimePresentationConsumerMapping.validatePresentationField("reconciliation")

        XCTAssertThrowsError(try RuntimePresentationConsumerMapping.validatePayloadSchema("r5_runtime_presentation_payload_v2")) { error in
            XCTAssertEqual(error as? RuntimePresentationConsumerValidationError, .unknownPayloadSchema("r5_runtime_presentation_payload_v2"))
        }
        XCTAssertThrowsError(try RuntimePresentationConsumerMapping.validatePresentationField("requestFingerprint")) { error in
            XCTAssertEqual(error as? RuntimePresentationConsumerValidationError, .forbiddenPrivateName("requestFingerprint"))
        }
        XCTAssertThrowsError(try RuntimePresentationConsumerMapping.validatePresentationField("uiueInventedSharedField")) { error in
            XCTAssertEqual(error as? RuntimePresentationConsumerValidationError, .unknownPresentationField("uiueInventedSharedField"))
        }
    }

    func testD17ProofAndReconciliationNamesFailClosed() throws {
        XCTAssertEqual(
            RuntimePresentationConsumerMapping.d15ProofClassNames,
            [
                "docs_local",
                "openspec_contract",
                "local_static_contract",
                "local_unit",
                "local_shape_no_model",
                "local_receipt_consistency",
                "simulator_mock",
                "external_gptpro_review"
            ]
        )
        XCTAssertEqual(
            RuntimePresentationConsumerMapping.reconciliationStatusNames,
            ["verified", "mismatch", "unavailable", "not_applicable"]
        )
        XCTAssertEqual(
            RuntimePresentationConsumerMapping.reconciliationMismatchClassNames,
            ["missing_readback", "value_mismatch", "revision_regression", "scope_mismatch", "unknown"]
        )

        try RuntimePresentationConsumerMapping.validateProofClass("local_unit")
        try RuntimePresentationConsumerMapping.validateReconciliationStatus("mismatch")
        try RuntimePresentationConsumerMapping.validateReconciliationMismatchClass("scope_mismatch")

        XCTAssertThrowsError(try RuntimePresentationConsumerMapping.validateProofClass("runtime_ready")) { error in
            XCTAssertEqual(error as? RuntimePresentationConsumerValidationError, .unknownProofClass("runtime_ready"))
        }
        XCTAssertThrowsError(try RuntimePresentationConsumerMapping.validateReconciliationStatus("failureLedger")) { error in
            XCTAssertEqual(error as? RuntimePresentationConsumerValidationError, .unknownReconciliationStatus("failureLedger"))
        }
        XCTAssertThrowsError(try RuntimePresentationConsumerMapping.validateReconciliationMismatchClass("parentRequestFingerprint")) { error in
            XCTAssertEqual(error as? RuntimePresentationConsumerValidationError, .unknownReconciliationMismatchClass("parentRequestFingerprint"))
        }
    }

    func testD17CoreConfigSceneMacroAndForceContextNamesFailClosed() throws {
        XCTAssertEqual(
            RuntimePresentationConsumerMapping.coreConfigNames,
            [
                "scene_macro_registry.version",
                "scene_macro_registry.stable_names",
                "d17.consumer_authority"
            ]
        )
        XCTAssertEqual(
            RuntimePresentationConsumerMapping.sceneMacroNames,
            [
                "scene1.human_language_comfort",
                "scene2.multi_intent_comfort",
                "scene3.followup_window_memory",
                "scene4.driver_window_generalization",
                "scene5.driving_safety_refusal"
            ]
        )
        XCTAssertEqual(
            RuntimePresentationConsumerMapping.forceContextDimensionNames,
            ["vehicle.speed", "vehicle.gear", "environment.weather", "environment.time_period"]
        )

        try RuntimePresentationConsumerMapping.validateCoreConfigName("d17.consumer_authority")
        try RuntimePresentationConsumerMapping.validateSceneMacroName("scene5.driving_safety_refusal")
        try RuntimePresentationConsumerMapping.validateForceContextDimension("vehicle.speed")

        XCTAssertThrowsError(try RuntimePresentationConsumerMapping.validateCoreConfigName("uiue.local.config")) { error in
            XCTAssertEqual(error as? RuntimePresentationConsumerValidationError, .unknownCoreConfigName("uiue.local.config"))
        }
        XCTAssertThrowsError(try RuntimePresentationConsumerMapping.validateSceneMacroName("scene6.uiue_invented")) { error in
            XCTAssertEqual(error as? RuntimePresentationConsumerValidationError, .unknownSceneMacroName("scene6.uiue_invented"))
        }
        XCTAssertThrowsError(try RuntimePresentationConsumerMapping.validateForceContextDimension("customer_facing")) { error in
            XCTAssertEqual(error as? RuntimePresentationConsumerValidationError, .unknownForceContextDimension("customer_facing"))
        }
    }

    func testD17ForbiddenPrivateRuntimeAndForceStateNamesAreRejected() {
        let forbiddenNames = [
            "DemoRuntimeAdapter",
            "DemoRuntimeAdapterResult",
            "RuntimeAdapterBox",
            "requestFingerprint",
            "parentRequestFingerprint",
            "failureLedger",
            "successLedger",
            "settledParentPlan",
            "rawRuntimeStore",
            "rawModelOutput",
            "trainingReceipt",
            "DemoForceStateContext",
            "DemoRuntimeAdapterPrivateField"
        ]

        for name in forbiddenNames {
            XCTAssertThrowsError(try RuntimePresentationConsumerMapping.rejectForbiddenConsumerName(name), name) { error in
                XCTAssertEqual(error as? RuntimePresentationConsumerValidationError, .forbiddenPrivateName(name))
            }
        }
    }

    func testRuntimeResultMappingUsesStructuredNamesRatherThanDisplayCopy() {
        for entry in RuntimePresentationConsumerMapping.resultEntries {
            XCTAssertEqual(entry.structuredSource, "mainline_structured_runtime_result")
            XCTAssertFalse(entry.mainlineResultName.contains("已"))
            XCTAssertFalse(entry.mainlineResultName.contains("为了安全"))
            XCTAssertTrue(DemoRuntimeResultPresentationMatrix.allEntries.map(\.motionKind).contains(entry.motionKind))
        }
    }

    func testTerminalStopsMapTimeoutToRuntimeErrorWithoutAddingTimeoutResult() {
        XCTAssertEqual(RuntimePresentationConsumerMapping.terminalStopResultNames["timeout"], "runtime_error")
        XCTAssertEqual(RuntimePresentationConsumerMapping.terminalStopResultNames["interrupted"], "interrupted")
        XCTAssertEqual(RuntimePresentationConsumerMapping.terminalStopResultNames["backgrounding"], "interrupted")
        XCTAssertNil(RuntimePresentationConsumerMapping.localResultKind(forMainlineResultName: "timeout"))
    }

    func testProofCapsStayAtDocsLocalUnitAndSimulatorMockOnly() {
        XCTAssertEqual(RuntimePresentationConsumerMapping.proofCaps, ["docs_local", "local_unit", "simulator_mock"])

        let forbiddenClaims = [
            "runtime_ready",
            "mobile",
            "true_device",
            "voice_ready",
            "model_ready",
            "golden_ready",
            "endpoint_ready",
            "UIUE_merge",
            "V" + "-PASS",
            "S" + "-PASS",
            "U" + "-PASS",
            "A-2" + " complete"
        ]

        for claim in forbiddenClaims {
            XCTAssertFalse(RuntimePresentationConsumerMapping.proofCaps.contains(claim), claim)
        }
    }

    func testDeferredGatesRemainMainlineOwned() throws {
        let deferredRows = ["C005", "C018", "C052", "C061"]

        for rowID in deferredRows {
            let row = try XCTUnwrap(RuntimePresentationConsumerMapping.disposition(for: rowID))
            XCTAssertEqual(row.disposition, .deferredMainlineOwner, rowID)
            XCTAssertNotEqual(row.owner, "UIUE", rowID)
        }
    }

    func testK1RowsRemainSpikeBeforeImplementationLedger() throws {
        let spikeRows = ["C082", "C083", "C096", "C117", "C182", "C197", "C207", "C208"]

        for rowID in spikeRows {
            let row = try XCTUnwrap(RuntimePresentationConsumerMapping.disposition(for: rowID))
            XCTAssertEqual(row.disposition, .spikeBeforeImplementation, rowID)
            XCTAssertEqual(row.owner, "future spike", rowID)
        }
    }

    func testC034ReduceMotionIsLocalPolicyOnly() throws {
        let row = try XCTUnwrap(RuntimePresentationConsumerMapping.disposition(for: "C034"))

        XCTAssertEqual(row.disposition, .localPolicyOnly)
        XCTAssertEqual(row.owner, "UIUE")
        XCTAssertEqual(PresentationReducedMotionPolicy.feedback(for: PresentationOrbState.think), .staticThinking)
        XCTAssertFalse(PresentationReducedMotionPolicy.allowsContinuousAnimation(reduceMotion: true))
    }
}
