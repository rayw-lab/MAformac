import XCTest
@testable import MAformacCore

final class ExactRationalTests: XCTestCase {
    func testParse_bounded_19digits3decimals_accepted() throws {
        // Grammar: total significant digits ≤19 and ≤3 fractional digits, and scaled numerator fits Int64.
        // 19-digit integer:
        let whole = try ExactRational.parse("1234567890123456789")
        XCTAssertEqual(whole.numerator, 1_234_567_890_123_456_789)
        XCTAssertEqual(whole.denominator, 1)
        // 16 + 3 = 19 significant digits with fractional part:
        let withFrac = try ExactRational.parse("1234567890123456.123")
        XCTAssertEqual(withFrac.numerator, 1_234_567_890_123_456_123)
        XCTAssertEqual(withFrac.denominator, 1000)
    }

    func testParse_20digits_rejected_numericOverflow() {
        XCTAssertThrowsError(try ExactRational.parse("12345678901234567890")) { error in
            XCTAssertEqual(error as? ExactRational.ParseFailure, .numericOverflow)
        }
    }

    func testParse_4decimalPlaces_rejected_unsupportedPrecision() {
        XCTAssertThrowsError(try ExactRational.parse("1.2345")) { error in
            XCTAssertEqual(error as? ExactRational.ParseFailure, .unsupportedPrecision)
        }
    }

    func testParse_comma_scientific_nan_inf_rejected_lexicalInvalid() {
        for lexeme in ["26,5", "1e3", "NaN", "Infinity", "+inf", "-Infinity"] {
            XCTAssertThrowsError(try ExactRational.parse(lexeme), lexeme) { error in
                XCTAssertEqual(error as? ExactRational.ParseFailure, .lexicalInvalid, lexeme)
            }
        }
    }

    func testParse_negativeZero_normalizedToZero() throws {
        let value = try ExactRational.parse("-0")
        XCTAssertEqual(value.numerator, 0)
        XCTAssertEqual(value.denominator, 1)
        let withFrac = try ExactRational.parse("-0.000")
        XCTAssertEqual(withFrac.numerator, 0)
        XCTAssertEqual(withFrac.denominator, 1)
    }
}
