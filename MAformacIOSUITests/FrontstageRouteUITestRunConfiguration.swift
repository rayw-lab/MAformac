import Foundation

enum FrontstageRouteUITestRunConfigurationError: Error, LocalizedError, Equatable {
    case missingKey(String)
    case invalidKey(String)

    var errorDescription: String? {
        switch self {
        case .missingKey(let key):
            return "FRONTSTAGE_UI_HARNESS_MISSING_KEY:\(key)"
        case .invalidKey(let key):
            return "FRONTSTAGE_UI_HARNESS_INVALID_KEY:\(key)"
        }
    }
}

struct FrontstageRouteUITestRunConfiguration: Equatable {
    static let requiredKeys = [
        "C1_FRONTSTAGE_RECEIPT_EMIT",
        "C1_FRONTSTAGE_RUN_ID",
        "C1_FRONTSTAGE_RUN_NONCE",
        "C1_RUN_DIR",
        "C1_FRONTSTAGE_SOURCE_HEAD_SHA"
    ]

    let receiptEmit: String
    let runID: String
    let runNonce: String
    let runDirectory: URL
    let sourceHeadSHA: String

    init(formalEnvironment values: [String: String]) throws {
        for key in Self.requiredKeys where values[key] == nil {
            throw FrontstageRouteUITestRunConfigurationError.missingKey(key)
        }

        let receiptEmit = values["C1_FRONTSTAGE_RECEIPT_EMIT"] ?? ""
        let runID = values["C1_FRONTSTAGE_RUN_ID"] ?? ""
        let runNonce = values["C1_FRONTSTAGE_RUN_NONCE"] ?? ""
        let runDirectoryPath = values["C1_RUN_DIR"] ?? ""
        let sourceHeadSHA = values["C1_FRONTSTAGE_SOURCE_HEAD_SHA"] ?? ""

        guard receiptEmit == "1" else {
            throw FrontstageRouteUITestRunConfigurationError.invalidKey("C1_FRONTSTAGE_RECEIPT_EMIT")
        }
        guard !runID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw FrontstageRouteUITestRunConfigurationError.invalidKey("C1_FRONTSTAGE_RUN_ID")
        }
        guard Self.isLowerHex(runNonce, length: 32) else {
            throw FrontstageRouteUITestRunConfigurationError.invalidKey("C1_FRONTSTAGE_RUN_NONCE")
        }
        guard runDirectoryPath.hasPrefix("/") else {
            throw FrontstageRouteUITestRunConfigurationError.invalidKey("C1_RUN_DIR")
        }
        guard Self.isLowerHex(sourceHeadSHA, length: 40) else {
            throw FrontstageRouteUITestRunConfigurationError.invalidKey("C1_FRONTSTAGE_SOURCE_HEAD_SHA")
        }

        self.receiptEmit = receiptEmit
        self.runID = runID
        self.runNonce = runNonce
        self.runDirectory = URL(fileURLWithPath: runDirectoryPath, isDirectory: true)
        self.sourceHeadSHA = sourceHeadSHA
    }

    var appLaunchEnvironment: [String: String] {
        [
            "C1_FRONTSTAGE_RECEIPT_EMIT": receiptEmit,
            "C1_FRONTSTAGE_RUN_ID": runID,
            "C1_FRONTSTAGE_RUN_NONCE": runNonce,
            "C1_RUN_DIR": runDirectory.path,
            "C1_FRONTSTAGE_SOURCE_HEAD_SHA": sourceHeadSHA
        ]
    }

    private static func isLowerHex(_ value: String, length: Int) -> Bool {
        value.range(of: "^[0-9a-f]{\(length)}$", options: .regularExpression) != nil
    }
}
