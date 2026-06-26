import XCTest
@testable import MAformacCore

final class U14MacLayoutContractTests: XCTestCase {
    private var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func source(at path: String) throws -> String {
        try String(contentsOf: repoRoot.appendingPathComponent(path), encoding: .utf8)
    }

    private func section(in source: String, from start: String, until end: String) throws -> String {
        guard let startRange = source.range(of: start) else {
            XCTFail("missing section start: \(start)")
            return ""
        }
        let tail = source[startRange.lowerBound...]
        guard let endRange = tail.range(of: end) else {
            return String(tail)
        }
        return String(tail[..<endRange.lowerBound])
    }

    func testMacSplitStageUsesAnyLayoutHStackAndPanoramaGrid() throws {
        let source = try source(at: "App/ContentView.swift")
        let stageBody = try section(
            in: source,
            from: "private func stageBody(size: CGSize) -> some View",
            until: "private func macConversationColumn(size: CGSize) -> some View"
        )

        XCTAssertTrue(stageBody.contains("usesMacSplit(size: size)"))
        XCTAssertTrue(stageBody.contains("AnyLayout(HStackLayout"))
        XCTAssertTrue(stageBody.contains("VehicleCardsGrid(displays: familyDisplays"))
        XCTAssertTrue(stageBody.contains("layout: .macPanorama"))
    }

    func testUsesMacSplitIsGeometryWidthDrivenAndNotSizeClassDriven() throws {
        let source = try source(at: "App/ContentView.swift")
        let usesMacSplit = try section(
            in: source,
            from: "private func usesMacSplit(size: CGSize) -> Bool",
            until: "private func horizontalPadding(for size: CGSize) -> CGFloat"
        )

        XCTAssertTrue(usesMacSplit.contains("#if os(macOS)"))
        XCTAssertTrue(usesMacSplit.contains("size.width"))
        XCTAssertTrue(usesMacSplit.contains("return false"))
        XCTAssertFalse(usesMacSplit.contains("horizontalSizeClass"))
        XCTAssertFalse(usesMacSplit.contains("sizeClass"))
    }

    func testU14DoesNotIntroduceSplitViewOrAdaptiveLazyGrid() throws {
        let source = try source(at: "App/ContentView.swift")

        XCTAssertFalse(source.contains("NavigationSplitView"))
        XCTAssertFalse(source.contains("SplitView("))
        XCTAssertFalse(source.contains("LazyVGrid"))
    }

    func testPhoneSizeClassRemainsExplicitlyNonMacOnly() throws {
        let source = try source(at: "App/ContentView.swift")
        let vehicleGrid = try section(
            in: source,
            from: "struct VehicleCardsGrid: View",
            until: "var body: some View"
        )

        XCTAssertTrue(vehicleGrid.contains("#if !os(macOS)"))
        XCTAssertTrue(vehicleGrid.contains("@Environment(\\.horizontalSizeClass)"))
    }

    func testLocalCheckScriptExistsAndScopesToContentView() throws {
        let script = try source(at: "Tools/checks/check-u14-mac-layout-contract.sh")

        XCTAssertTrue(script.contains("App/ContentView.swift"))
        XCTAssertTrue(script.contains("AnyLayout(HStackLayout"))
        XCTAssertTrue(script.contains("layout: .macPanorama"))
        XCTAssertFalse(script.contains("git grep"))
    }
}
