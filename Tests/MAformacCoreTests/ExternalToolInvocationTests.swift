import XCTest
@testable import MAformacCore

final class ExternalToolInvocationTests: XCTestCase {
    func testDisabledMcpProviderInvokeReturnsPlannedConnectorDisabledWithoutSuccess() async throws {
        let provider = DisabledMcpToolProvider(domainID: .music)
        let invocation = ExternalToolInvocation(
            domainID: .music,
            toolName: "music.play",
            arguments: ["query": .string("随便放首歌")],
            connector: .mcp,
            proofClass: .localUnit,
            status: .mockNotExecuted
        )

        let result = try await provider.invoke(invocation)

        XCTAssertEqual(result.status, .plannedUnavailable)
        XCTAssertEqual(result.reasonCode, "planned_connector_disabled")
        XCTAssertEqual(Set(ExternalToolStatus.allCases), [.plannedUnavailable, .blocked, .mockNotExecuted])
        XCTAssertFalse(ExternalToolStatus.allCases.map(\.rawValue).contains("success"))
    }

    func testDomainProviderGuardRejectsDisabledProviderBeforeInvoke() async throws {
        let provider = DisabledMcpToolProvider(domainID: .navigation)
        let invocation = ExternalToolInvocation(
            domainID: .navigation,
            toolName: "navigation.route",
            arguments: [:],
            connector: .mcp,
            proofClass: .localUnit,
            status: .mockNotExecuted
        )

        XCTAssertThrowsError(try DomainProviderGuard().validate(invocation, providerDescriptor: provider.descriptor)) { error in
            XCTAssertEqual(error as? DomainProviderGuardError, .providerDisabled)
        }
    }

    func testDomainProviderGuardRejectsUnsupportedConnectorAndUnregisteredDomain() {
        let guardrail = DomainProviderGuard()
        let mockConnectorProvider = ToolProviderDescriptor(
            domainID: .music,
            connector: .mock,
            enabled: true,
            availability: .planned,
            proofCap: .localUnit
        )
        let musicInvocation = ExternalToolInvocation(
            domainID: .music,
            toolName: "music.search",
            arguments: [:],
            connector: .mock,
            proofClass: .localUnit,
            status: .mockNotExecuted
        )

        XCTAssertThrowsError(try guardrail.validate(musicInvocation, providerDescriptor: mockConnectorProvider)) { error in
            XCTAssertEqual(error as? DomainProviderGuardError, .unsupportedConnector(.mock))
        }

        let vehicleProvider = ToolProviderDescriptor(
            domainID: .vehicle,
            connector: .mcp,
            enabled: true,
            availability: .planned,
            proofCap: .localUnit
        )
        let vehicleInvocation = ExternalToolInvocation(
            domainID: .vehicle,
            toolName: "vehicle.not_external",
            arguments: [:],
            connector: .mcp,
            proofClass: .localUnit,
            status: .mockNotExecuted
        )

        XCTAssertThrowsError(try guardrail.validate(vehicleInvocation, providerDescriptor: vehicleProvider)) { error in
            XCTAssertEqual(error as? DomainProviderGuardError, .domainNotRegistered(.vehicle))
        }
    }

    func testExternalInvocationDoesNotExposeVehicleIRFields() throws {
        let invocation = ExternalToolInvocation(
            domainID: .foodDelivery,
            toolName: "food.order",
            arguments: ["merchant": .string("coffee")],
            connector: .mcp,
            proofClass: .localUnit,
            status: .mockNotExecuted
        )
        let keys = try JSONSerialization.jsonObject(with: JSONEncoder().encode(invocation)) as? [String: Any]

        XCTAssertEqual(keys?["domainID"] as? String, "food-delivery")
        XCTAssertNil(keys?["device"])
        XCTAssertNil(keys?["actionPrimitive"])
        XCTAssertNil(keys?["value"])
    }
}
