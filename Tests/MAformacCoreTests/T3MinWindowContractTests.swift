import XCTest
@testable import MAformacCore

final class T3MinWindowContractTests: XCTestCase {
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

    func testMacWindowLocksContentMinimumSizeForFiveByTwoPanorama() throws {
        let app = try source(at: "App/MAformacApp.swift")
        let contentView = try source(at: "App/ContentView.swift")

        XCTAssertTrue(app.contains(".windowResizability(.contentMinSize)"))
        XCTAssertTrue(app.contains("T3MacWindowContract.minWidth"))
        XCTAssertTrue(app.contains("T3MacWindowContract.minHeight"))
        XCTAssertTrue(contentView.contains("T3MacWindowContract.minWidth"))
        XCTAssertTrue(contentView.contains("T3MacWindowContract.minHeight"))
        XCTAssertTrue(contentView.contains("vehicle-cards-mac-panorama"))
    }

    func testMacPanoramaStaysFiveColumnsAndTwoRowsAtMinimumWindow() throws {
        let source = try source(at: "App/ContentView.swift")
        let columnCount = try section(
            in: source,
            from: "private var columnCount: Int",
            until: "private var activeFamilyID"
        )
        let gridContent = try section(
            in: source,
            from: "private func compactGridContent(for items: [VehicleCardDisplay]) -> some View",
            until: "private func display(for family: FamilyCardID)"
        )

        XCTAssertTrue(columnCount.contains("case .macPanorama:"))
        XCTAssertTrue(columnCount.contains("return 5"))
        XCTAssertTrue(gridContent.contains("rows(for: items)"))
        XCTAssertFalse(gridContent.contains("LazyVGrid"))
        XCTAssertFalse(gridContent.contains(".adaptive("))
    }

    func testMacMinimumWindowWarningIsRenderedForOverflowRisk() throws {
        let source = try source(at: "App/ContentView.swift")
        let body = try section(in: source, from: "var body: some View", until: "@ViewBuilder")

        XCTAssertTrue(source.contains("t3-min-window-warning"))
        XCTAssertTrue(source.contains("T3MacWindowContract.warningText"))
        XCTAssertTrue(body.contains("minWindowWarningBanner(size: size)"))
        XCTAssertTrue(body.contains("T3MacWindowContract.shouldShowWarning(size)"))
    }

    func testMacPanoramaUsesFeaturedContentWithoutScrollView() throws {
        let source = try source(at: "App/ContentView.swift")
        let body = try section(in: source, from: "var body: some View", until: "private var gridContent")
        let macBranch = try section(in: body, from: "if layout == .macPanorama", until: "} else {")

        XCTAssertTrue(macBranch.contains("macFeaturedContent"))
        XCTAssertTrue(macBranch.contains("vehicle-cards-mac-panorama"))
        XCTAssertFalse(macBranch.contains("ScrollView"))
        XCTAssertFalse(macBranch.contains("gridContent"))
    }

    func testMacHeroSlotIsFixedToACAndDoesNotMigrateWithActiveFamily() throws {
        let source = try source(at: "App/ContentView.swift")
        let heroFamily = try section(
            in: source,
            from: "private var featuredHeroFamily: FamilyCardID",
            until: "private var hasActiveFamily"
        )
        let macFeatured = try section(
            in: source,
            from: "private var macFeaturedContent: some View",
            until: "private var phoneFeaturedContent"
        )

        XCTAssertTrue(heroFamily.contains(".ac"))
        XCTAssertFalse(heroFamily.contains("activeFamily"))
        XCTAssertTrue(macFeatured.contains("let heroFamily = featuredHeroFamily"))
        XCTAssertTrue(macFeatured.contains("isHero: true"))
        XCTAssertTrue(macFeatured.contains("isFaded: false"))
    }

    func testMacHeroWidthUsesCommanderClampAcrossThreeWidthBands() throws {
        let source = try source(at: "App/ContentView.swift")
        let contract = try section(
            in: source,
            from: "enum T3MacWindowContract",
            until: "struct ContentView"
        )

        XCTAssertTrue(contract.contains("contentWidth < 900"))
        XCTAssertTrue(contract.contains("0.28"))
        XCTAssertTrue(contract.contains("0.32"))
        XCTAssertTrue(contract.contains("240"))
        XCTAssertTrue(contract.contains("260"))
        XCTAssertTrue(contract.contains("340"))
        XCTAssertTrue(source.contains("T3MacWindowContract.heroWidth"))
        XCTAssertTrue(source.contains("macHeroColumnWidth(for: available)"))
    }

    func testHeroTextPrefersScaleBeforeTailTruncation() throws {
        let source = try source(at: "App/ContentView.swift")
        let cardBody = try section(in: source, from: "private var fullCardBody", until: "private var compactBody")

        XCTAssertTrue(cardBody.contains(".minimumScaleFactor(isHero ? 0.85"))
        XCTAssertTrue(cardBody.contains(".truncationMode(.tail)"))
    }

    func testMacSecondaryCardsAreNineCardsInThreeByThreeMatrix() throws {
        let source = try source(at: "App/ContentView.swift")
        let macFeatured = try section(
            in: source,
            from: "private var macFeaturedContent: some View",
            until: "private var phoneFeaturedContent"
        )

        XCTAssertTrue(macFeatured.contains("macSecondaryRows"))
        XCTAssertTrue(source.contains("private var macSecondaryFamilies"))
        XCTAssertTrue(source.contains("private var macSecondaryRows"))
        XCTAssertTrue(source.contains("Array(macSecondaryFamilies[index ..< min(index + 3, macSecondaryFamilies.count)])"))
        XCTAssertTrue(source.contains("stride(from: 0, to: macSecondaryFamilies.count, by: 3)"))
    }

    func testMacWaterfallOrderKeepsHeroFirstThenRowMajorSecondaryCards() throws {
        let source = try source(at: "App/ContentView.swift")
        let macFeatured = try section(
            in: source,
            from: "private var macFeaturedContent: some View",
            until: "private var phoneFeaturedContent"
        )

        XCTAssertTrue(macFeatured.contains("cardWaterfallEntrance(index: 0"))
        XCTAssertTrue(macFeatured.contains("cardWaterfallEntrance(index: macSecondaryWaterfallIndex"))
        XCTAssertTrue(source.contains("private func macSecondaryWaterfallIndex"))
        XCTAssertTrue(source.contains("return row * 3 + column + 1"))
    }

    func testMacPanoramaEnergyLineAnchorsAttachToHeroAndAllSecondaryCards() throws {
        let source = try source(at: "App/ContentView.swift")
        let macFeatured = try section(
            in: source,
            from: "private var macFeaturedContent: some View",
            until: "private var phoneFeaturedContent"
        )
        let heroBlock = try section(
            in: macFeatured,
            from: "if let display = display(for: heroFamily)",
            until: "Grid(alignment:"
        )
        let secondaryBlock = try section(
            in: macFeatured,
            from: "ForEach(Array(families.enumerated())",
            until: ".frame(width: secondaryWidth"
        )

        let anchorCount = macFeatured.components(separatedBy: ".energyLineCardAnchor(family: display.familyCardID)").count - 1
        XCTAssertEqual(anchorCount, 2)
        XCTAssertTrue(heroBlock.contains(".energyLineCardAnchor(family: display.familyCardID)"))
        XCTAssertTrue(secondaryBlock.contains(".energyLineCardAnchor(family: display.familyCardID)"))
        XCTAssertTrue(source.contains("FamilyCardID.displayOrder.filter { $0 != featuredHeroFamily }"))
        XCTAssertTrue(macFeatured.contains("ForEach(Array(macSecondaryRows.enumerated())"))
        XCTAssertTrue(macFeatured.contains("ForEach(Array(families.enumerated())"))
    }

    func testSevenStateSnapshotBaselineUsesMacPanoramaLayout() throws {
        let debugGallery = try source(at: "App/DebugGallery.swift")
        let uiTests = try source(at: "MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift")

        XCTAssertTrue(debugGallery.contains("layout: .macPanorama"))
        XCTAssertTrue(uiTests.contains("force_state_normal_mac_hero"))
        XCTAssertTrue(uiTests.contains("force_state_satisfied_mac_hero"))
        XCTAssertTrue(uiTests.contains("force_state_changing_mac_hero"))
        XCTAssertTrue(uiTests.contains("force_state_blocked_with_alternative_mac_hero"))
        XCTAssertTrue(uiTests.contains("force_state_blocked_hard_mac_hero"))
        XCTAssertTrue(uiTests.contains("force_state_unsafe_mac_hero"))
        XCTAssertTrue(uiTests.contains("force_state_unknown_mac_hero"))
    }
}
