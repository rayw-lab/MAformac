import Foundation

enum DistributionAudience: String, CaseIterable, Equatable, Sendable {
    case personalInternalSelfUse = "personal_internal_self_use"
    case appStore = "app_store"
    case testFlight = "testflight"
    case externalCustomerPackage = "external_customer_package"
}

enum DistributionArtifactKind: String, CaseIterable, Equatable, Sendable {
    case internalReceipt = "internal_receipt"
    case appStoreScreenshot = "app_store_screenshot"
    case privacyNutrition = "privacy_nutrition"
    case storeDescription = "store_description"
    case releaseNotes = "release_notes"
    case customerFacingClaim = "customer_facing_claim"
}

enum DistributionClaimKind: String, CaseIterable, Equatable, Sendable {
    case localUnitComplete = "local_unit_complete"
    case releaseReady = "release_ready"
    case runtimeReady = "runtime_ready"
    case mobileReady = "mobile_ready"
    case trueDeviceReady = "true_device_ready"
    case vPass = "v_pass"
}

enum DistributionBoundaryGuard {
    static func allows(audience: DistributionAudience) -> Bool {
        switch audience {
        case .personalInternalSelfUse:
            return true
        case .appStore, .testFlight, .externalCustomerPackage:
            return false
        }
    }

    static func allows(artifact: DistributionArtifactKind) -> Bool {
        switch artifact {
        case .internalReceipt:
            return true
        case .appStoreScreenshot, .privacyNutrition, .storeDescription, .releaseNotes, .customerFacingClaim:
            return false
        }
    }

    static func allows(claim: DistributionClaimKind) -> Bool {
        switch claim {
        case .localUnitComplete:
            return true
        case .releaseReady, .runtimeReady, .mobileReady, .trueDeviceReady, .vPass:
            return false
        }
    }
}
