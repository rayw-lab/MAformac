import XCTest
@testable import MAformacCore

final class ProductOperatorT07aLedgerConsumerTests: XCTestCase {
    private static var fixturesDirectory: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Fixtures/t07a-synthetic")
    }

    // MARK: - Envelope validation

    func testValidSyntheticEnvelopePassesValidation() throws {
        let url = Self.fixturesDirectory.appendingPathComponent("valid-synthetic.json")
        let data = try Data(contentsOf: url)
        let container = try JSONDecoder().decode(SyntheticFixtureContainer.self, from: data)
        let envelope = try XCTUnwrap(container.envelope)

        let result = validateCeremonyEnvelope(envelope)
        XCTAssertEqual(result, .success)
    }

    func testEnvelopeMissingSchemaVersionFails() {
        let envelope = makeEnvelope(schemaVersion: "")
        XCTAssertEqual(validateCeremonyEnvelope(envelope), .failure("Missing schema version"))
    }

    func testEnvelopeMissingSubjectRepoSHAFails() {
        let envelope = makeEnvelope(subjectRepoSHA: "")
        XCTAssertEqual(validateCeremonyEnvelope(envelope), .failure("Missing subject.repoSHA"))
    }

    func testEnvelopeMissingEnvironmentMachineFails() {
        let envelope = makeEnvelope(envMachine: "")
        XCTAssertEqual(validateCeremonyEnvelope(envelope), .failure("Missing environment.machine"))
    }

    func testEnvelopeMissingAttemptIDFails() {
        let envelope = makeEnvelope(attemptID: "")
        XCTAssertEqual(validateCeremonyEnvelope(envelope), .failure("Missing attempt.attemptID"))
    }

    func testEnvelopeMissingAxisPredicateVersionFails() {
        let envelope = makeEnvelope(decisionPredicateVersion: "")
        XCTAssertEqual(validateCeremonyEnvelope(envelope), .failure("Missing axes.decision.predicateVersion"))
    }

    func testEnvelopeMissingEvidenceProofClassFails() {
        let envelope = makeEnvelope(evidenceProofClass: "")
        XCTAssertEqual(validateCeremonyEnvelope(envelope), .failure("Missing evidence.proofClass"))
    }

    // MARK: - Synthetic three-field cap

    func testValidSyntheticFixturePassesThreeFieldCheck() throws {
        let url = Self.fixturesDirectory.appendingPathComponent("valid-synthetic.json")
        let data = try Data(contentsOf: url)
        let container = try JSONDecoder().decode(SyntheticFixtureContainer.self, from: data)

        XCTAssertNoThrow(try validateSyntheticFixture(
            synthetic: container.synthetic,
            proofClass: container.proofClass,
            satisfiesT07bPrerequisite: container.satisfiesT07bPrerequisite
        ))
    }

    func testMissingSyntheticTrueFails() throws {
        let url = Self.fixturesDirectory.appendingPathComponent("missing-synthetic-true.json")
        let data = try Data(contentsOf: url)
        let container = try JSONDecoder().decode(SyntheticFixtureContainer.self, from: data)

        XCTAssertThrowsError(try validateSyntheticFixture(
            synthetic: container.synthetic,
            proofClass: container.proofClass,
            satisfiesT07bPrerequisite: container.satisfiesT07bPrerequisite
        )) { error in
            XCTAssertEqual(
                error as? SyntheticFixtureError,
                .missingOrContradictory("synthetic must be true")
            )
        }
    }

    func testWrongProofClassFails() throws {
        let url = Self.fixturesDirectory.appendingPathComponent("wrong-proof-class.json")
        let data = try Data(contentsOf: url)
        let container = try JSONDecoder().decode(SyntheticFixtureContainer.self, from: data)

        XCTAssertThrowsError(try validateSyntheticFixture(
            synthetic: container.synthetic,
            proofClass: container.proofClass,
            satisfiesT07bPrerequisite: container.satisfiesT07bPrerequisite
        )) { error in
            XCTAssertEqual(
                error as? SyntheticFixtureError,
                .missingOrContradictory("proof_class must be 'local'")
            )
        }
    }

    func testContradictoryT07bPrerequisiteFails() throws {
        let url = Self.fixturesDirectory.appendingPathComponent("contradictory-t07b-prereq.json")
        let data = try Data(contentsOf: url)
        let container = try JSONDecoder().decode(SyntheticFixtureContainer.self, from: data)

        XCTAssertThrowsError(try validateSyntheticFixture(
            synthetic: container.synthetic,
            proofClass: container.proofClass,
            satisfiesT07bPrerequisite: container.satisfiesT07bPrerequisite
        )) { error in
            XCTAssertEqual(
                error as? SyntheticFixtureError,
                .missingOrContradictory("satisfies_t07b_prerequisite must be false")
            )
        }
    }

    // MARK: - Immutable append-only ledger

    func testLedgerAppendsNewAttempts() {
        let ledger = OperatorCeremonyAttemptLedger()
        let attempt1 = makeAttempt(id: "001", mode: .xcodeRun)
        let attempt2 = makeAttempt(id: "002", mode: .signedApp)

        ledger.append(attempt1)
        ledger.append(attempt2)

        XCTAssertEqual(ledger.count, 2)
        XCTAssertEqual(ledger.latestAttempt?.attemptID, "002")
    }

    func testLedgerDoesNotOverwritePriorFailure() {
        let ledger = OperatorCeremonyAttemptLedger()
        let failed = makeAttempt(id: "001", mode: .xcodeRun, disposition: "failed")
        let success = makeAttempt(id: "002", mode: .xcodeRun, disposition: "passed")

        ledger.append(failed)
        ledger.append(success)

        XCTAssertEqual(ledger.count, 2)
        // First attempt remains
        XCTAssertEqual(ledger.attempts[0].attemptID, "001")
        XCTAssertEqual(ledger.attempts[0].disposition, "failed")
        // Second attempt is new
        XCTAssertEqual(ledger.attempts[1].attemptID, "002")
        XCTAssertEqual(ledger.attempts[1].disposition, "passed")
    }

    func testModeSwitchCreatesNewAttempt() {
        let ledger = OperatorCeremonyAttemptLedger()
        let xcodeAttempt = makeAttempt(id: "001", mode: .xcodeRun, disposition: "failed")
        let archiveAttempt = makeAttempt(id: "002", mode: .archive, disposition: "passed")

        ledger.append(xcodeAttempt)
        ledger.append(archiveAttempt)

        XCTAssertEqual(ledger.count, 2)
        XCTAssertEqual(ledger.attempts[0].launchMode, .xcodeRun)
        XCTAssertEqual(ledger.attempts[1].launchMode, .archive)
    }

    // MARK: - Identity join

    func testExactIdentityJoinReturnsLocalSchemaJoinOnly() {
        let envelope1 = makeValidEnvelope()
        let envelope2 = makeValidEnvelope()

        let result = joinCeremonyIdentities(envelope1, envelope2)
        XCTAssertEqual(result, .localSchemaJoinOnly)
    }

    func testNearMatchSHAFailsJoin() throws {
        let url = Self.fixturesDirectory.appendingPathComponent("near-match-sha.json")
        let data = try Data(contentsOf: url)
        let container = try JSONDecoder().decode(SyntheticFixtureContainer.self, from: data)
        let nearMatch = try XCTUnwrap(container.envelope)

        let valid = makeValidEnvelope()
        let result = joinCeremonyIdentities(valid, nearMatch)
        guard case .mismatch(let reason) = result else {
            return XCTFail("Expected mismatch, got \(result)")
        }
        XCTAssertTrue(reason.contains("subject") || reason.contains("artifact"))
    }

    func testDifferentEnvironmentFailsJoin() {
        let env1 = makeValidEnvelope()
        let env2 = makeEnvelope(envOSVersion: "15.0")

        let result = joinCeremonyIdentities(env1, env2)
        XCTAssertEqual(result, .mismatch("environment mismatch"))
    }

    func testDifferentContractVersionFailsJoin() {
        let env1 = makeValidEnvelope()
        let env2 = makeEnvelope(envContractVersion: "v2")

        let result = joinCeremonyIdentities(env1, env2)
        // The join function checks environment equality first (which includes contractVersion),
        // so the mismatch message is "environment mismatch" not "contract version mismatch"
        XCTAssertEqual(result, .mismatch("environment mismatch"))
    }

    // MARK: - Non-claim enforcement

    func testLocalJoinCannotSatisfyT07b() {
        let envelope = makeValidEnvelope()
        let result = joinCeremonyIdentities(envelope, envelope)
        XCTAssertEqual(result, .localSchemaJoinOnly)
        // Structural: no code path in this change sets satisfies_t07b_prerequisite=true
    }

    func testSyntheticFixtureDoesNotSatisfyT07bPrerequisite() throws {
        let url = Self.fixturesDirectory.appendingPathComponent("valid-synthetic.json")
        let data = try Data(contentsOf: url)
        let container = try JSONDecoder().decode(SyntheticFixtureContainer.self, from: data)

        XCTAssertFalse(container.satisfiesT07bPrerequisite)
    }

    // MARK: - Helpers

    private func makeValidEnvelope() -> OperatorCeremonyEnvelope {
        makeEnvelope()
    }

    private func makeEnvelope(
        schemaVersion: String = "t07a_v1",
        subjectRepoSHA: String = "aae8a8acc48edde889b121ece24215676c134b9a",
        subjectDirtyVerdict: Bool = false,
        envMachine: String = "macOS",
        envOSVersion: String = "14.5",
        envTarget: String = "arm64",
        envScenarioVersion: String = "v1",
        envContractVersion: String = "v1",
        attemptID: String = "test-001",
        attemptLaunchMode: OperatorCeremonyLaunchMode = .xcodeRun,
        artifactRepoSHA: String = "aae8a8acc48edde889b121ece24215676c134b9a",
        artifactDirtyVerdict: Bool = false,
        artifactBuildScheme: String = "MAformacCore",
        artifactBundleVersion: String = "1.0",
        artifactBundleHash: String = "abc123",
        decisionPredicateVersion: String = "v1",
        decisionIsCurrent: Bool = true,
        decisionPass: Bool = true,
        decisionClaimCap: String = "local_schema_join_only",
        executionPredicateVersion: String = "v1",
        proofPredicateVersion: String = "v1",
        evidenceProofClass: String = "local",
        evidenceIDs: [String] = ["ev-001"],
        expiryIsExpired: Bool = false,
        expiryRetestRequired: Bool = false
    ) -> OperatorCeremonyEnvelope {
        OperatorCeremonyEnvelope(
            schemaVersion: schemaVersion,
            subject: OperatorCeremonySubjectIdentity(
                repoSHA: subjectRepoSHA,
                dirtyVerdict: subjectDirtyVerdict
            ),
            environment: OperatorCeremonyEnvironmentIdentity(
                machine: envMachine,
                osVersion: envOSVersion,
                target: envTarget,
                scenarioVersion: envScenarioVersion,
                contractVersion: envContractVersion
            ),
            attempt: OperatorCeremonyAttempt(
                attemptID: attemptID,
                launchMode: attemptLaunchMode,
                artifact: OperatorCeremonyArtifactIdentity(
                    repoSHA: artifactRepoSHA,
                    dirtyVerdict: artifactDirtyVerdict,
                    buildScheme: artifactBuildScheme,
                    bundleVersion: artifactBundleVersion,
                    bundleHash: artifactBundleHash
                ),
                environment: OperatorCeremonyEnvironmentIdentity(
                    machine: envMachine,
                    osVersion: envOSVersion,
                    target: envTarget,
                    scenarioVersion: envScenarioVersion,
                    contractVersion: envContractVersion
                ),
                timestamp: Date(timeIntervalSince1970: 1_800_000_000),
                disposition: "passed",
                reason: nil
            ),
            axes: OperatorCeremonyAxes(
                decision: OperatorCeremonyAxis(
                    predicateVersion: decisionPredicateVersion,
                    isCurrent: decisionIsCurrent,
                    pass: decisionPass,
                    reason: nil,
                    claimCap: decisionClaimCap
                ),
                execution: OperatorCeremonyAxis(
                    predicateVersion: executionPredicateVersion,
                    isCurrent: true,
                    pass: true,
                    reason: nil,
                    claimCap: "local_schema_join_only"
                ),
                proof: OperatorCeremonyAxis(
                    predicateVersion: proofPredicateVersion,
                    isCurrent: true,
                    pass: true,
                    reason: nil,
                    claimCap: "local_schema_join_only"
                )
            ),
            expiry: OperatorCeremonyExpiry(
                isExpired: expiryIsExpired,
                expiredReason: nil,
                retestRequired: expiryRetestRequired
            ),
            evidence: OperatorCeremonyEvidence(
                evidenceIDs: evidenceIDs,
                proofClass: evidenceProofClass
            )
        )
    }

    private func makeAttempt(id: String, mode: OperatorCeremonyLaunchMode, disposition: String = "passed") -> OperatorCeremonyAttempt {
        OperatorCeremonyAttempt(
            attemptID: id,
            launchMode: mode,
            artifact: OperatorCeremonyArtifactIdentity(
                repoSHA: "aae8a8acc48edde889b121ece24215676c134b9a",
                dirtyVerdict: false,
                buildScheme: "MAformacCore",
                bundleVersion: "1.0",
                bundleHash: "abc123"
            ),
            environment: OperatorCeremonyEnvironmentIdentity(
                machine: "macOS",
                osVersion: "14.5",
                target: "arm64",
                scenarioVersion: "v1",
                contractVersion: "v1"
            ),
            timestamp: Date(),
            disposition: disposition,
            reason: nil
        )
    }
}

// MARK: - Synthetic fixture container (for JSON decoding)

private struct SyntheticFixtureContainer: Decodable {
    let synthetic: Bool
    let proofClass: String
    let satisfiesT07bPrerequisite: Bool
    let envelope: OperatorCeremonyEnvelope?

    enum CodingKeys: String, CodingKey {
        case synthetic
        case proofClass = "proof_class"
        case satisfiesT07bPrerequisite = "satisfies_t07b_prerequisite"
        case envelope
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.synthetic = try container.decode(Bool.self, forKey: .synthetic)
        self.proofClass = try container.decode(String.self, forKey: .proofClass)
        self.satisfiesT07bPrerequisite = try container.decode(Bool.self, forKey: .satisfiesT07bPrerequisite)
        // envelope is optional — synthetic-only fixtures (missing-synthetic-true, wrong-proof-class, contradictory-t07b-prereq)
        // may not have an envelope field
        self.envelope = try container.decodeIfPresent(OperatorCeremonyEnvelope.self, forKey: .envelope)
    }
}
