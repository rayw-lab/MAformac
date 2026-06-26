import XCTest
@testable import MAformacCore

final class U44LiquidGlassHardeningInventoryTests: XCTestCase {
    private var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func source(at path: String) throws -> String {
        try String(contentsOf: repoRoot.appendingPathComponent(path), encoding: .utf8)
    }

    func testInventoryLocksTheThreeAllowedNoProjectionGlassSurfaces() {
        XCTAssertEqual(LiquidGlassHardeningInventory.items.map(\.id), [
            .micDock,
            .contextCapsule,
            .demoControlPanel
        ])
        XCTAssertEqual(Set(LiquidGlassHardeningInventory.items.map(\.sourcePath)), [
            "App/ContentView.swift",
            "App/ContextCapsule.swift",
            "App/DemoControlPanel.swift"
        ])
    }

    func testInventoryKeepsGlassOffContentCardsAndDoesNotRequireContainerByDefault() {
        XCTAssertFalse(LiquidGlassHardeningInventory.contentCardGlassAllowed)

        for item in LiquidGlassHardeningInventory.items {
            XCTAssertNotEqual(item.role, .contentCard, item.id.rawValue)
            XCTAssertTrue(item.usesGlassEffect, item.id.rawValue)
            XCTAssertFalse(item.requiresContainerByDefault, item.id.rawValue)
        }
    }

    func testEveryGlassSurfaceCarriesHardeningConcerns() {
        let expectedConcerns: Set<LiquidGlassHardeningConcern> = [
            .reduceTransparency,
            .lowBrightnessContrast,
            .iOS26PointRelease,
            .glassEffectContainerReview
        ]

        for item in LiquidGlassHardeningInventory.items {
            XCTAssertEqual(item.concerns, expectedConcerns, item.id.rawValue)
        }
    }

    func testSourceFilesStillContainOnlyInventoryGlassSurfaces() throws {
        let contentView = stripLineComments(try source(at: "App/ContentView.swift"))
        let contextCapsule = stripLineComments(try source(at: "App/ContextCapsule.swift"))
        let demoControlPanel = stripLineComments(try source(at: "App/DemoControlPanel.swift"))
        let expandedFamilyCard = stripLineComments(try source(at: "App/ExpandedFamilyCard.swift"))

        XCTAssertTrue(contentView.contains(".glassEffect()"))
        XCTAssertTrue(contextCapsule.contains(".glassEffect()"))
        XCTAssertTrue(demoControlPanel.contains(".glassEffect()"))
        XCTAssertFalse(expandedFamilyCard.contains(".glassEffect("))
    }

    func testNoExtraAppGlassEffectSurfaceOutsideInventory() throws {
        let appURL = repoRoot.appendingPathComponent("App")
        let appSwiftFiles = try FileManager.default.contentsOfDirectory(atPath: appURL.path)
            .filter { $0.hasSuffix(".swift") }
            .map { "App/\($0)" }

        let inventoryPaths = Set(LiquidGlassHardeningInventory.items.map(\.sourcePath))
        var pathsWithGlassEffect: [String: Int] = [:]
        for path in appSwiftFiles {
            let count = occurrenceCount(of: ".glassEffect(", in: stripLineComments(try source(at: path)))
            if count > 0 {
                pathsWithGlassEffect[path] = count
            }
        }

        XCTAssertEqual(Set(pathsWithGlassEffect.keys), inventoryPaths)
        XCTAssertEqual(pathsWithGlassEffect["App/ContentView.swift"], 1)
        XCTAssertEqual(pathsWithGlassEffect["App/ContextCapsule.swift"], 1)
        XCTAssertEqual(pathsWithGlassEffect["App/DemoControlPanel.swift"], 1)
    }

    private func stripLineComments(_ source: String) -> String {
        source
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { line in
                guard let comment = line.range(of: "//") else { return String(line) }
                return String(line[..<comment.lowerBound])
            }
            .joined(separator: "\n")
    }

    private func occurrenceCount(of needle: String, in source: String) -> Int {
        var count = 0
        var searchRange = source.startIndex..<source.endIndex
        while let range = source.range(of: needle, range: searchRange) {
            count += 1
            searchRange = range.upperBound..<source.endIndex
        }
        return count
    }
}
