import XCTest
@testable import MAformacCore

final class FamilyIconMapperTests: XCTestCase {
    func testEveryFamilyHasCuratedSFSymbol() {
        let symbols = FamilyCardID.allCases.map { family in
            FamilyIconMapper.sfSymbol(for: family)
        }

        XCTAssertEqual(symbols.count, 10)
        XCTAssertTrue(symbols.allSatisfy { !$0.isEmpty })
        XCTAssertEqual(Set(symbols).count, FamilyCardID.allCases.count)
    }

    func testRepresentativeStableSymbols() {
        XCTAssertEqual(FamilyIconMapper.sfSymbol(for: .ac), "fan.fill")
        XCTAssertEqual(FamilyIconMapper.sfSymbol(for: .ambient), "lightbulb.led.fill")
        XCTAssertEqual(FamilyIconMapper.sfSymbol(for: .volume), "speaker.wave.2.fill")
    }
}
