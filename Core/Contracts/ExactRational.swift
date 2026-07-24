import Foundation

/// Bounded exact rational for C3 numeric authority (G1).
/// Construct only via restricted decimal grammar — no BigInt, no locale, no `Double` source of truth.
public struct ExactRational: Equatable, Sendable {
    public let numerator: Int64
    public let denominator: Int64

    public enum ParseFailure: Error, Equatable, Sendable {
        case lexicalInvalid
        case numericOverflow
        case unsupportedPrecision
    }

    public enum ArithmeticFailure: Error, Equatable, Sendable {
        case numericOverflow
        case arithmeticOverflow
        case unsupportedPrecision
    }

    public init(numerator: Int64, denominator: Int64) throws {
        guard denominator > 0 else {
            throw ParseFailure.lexicalInvalid
        }
        let gcd = Self.gcd(Swift.abs(numerator), denominator)
        self.numerator = numerator / gcd
        self.denominator = denominator / gcd
    }

    /// Restricted decimal grammar: optional sign, digits, optional `.` + digits.
    /// Significant digits ≤ 19; fractional digits ≤ 3.
    /// Rejects comma, scientific, NaN/Inf. Normalizes `-0` / `+0` to zero.
    public static func parse(_ lexeme: String) throws -> ExactRational {
        let trimmed = lexeme.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw ParseFailure.lexicalInvalid }

        let lower = trimmed.lowercased()
        if lower == "nan" || lower == "inf" || lower == "+inf" || lower == "-inf"
            || lower == "infinity" || lower == "+infinity" || lower == "-infinity" {
            throw ParseFailure.lexicalInvalid
        }
        if trimmed.contains(",") || trimmed.contains("e") || trimmed.contains("E") {
            throw ParseFailure.lexicalInvalid
        }

        var index = trimmed.startIndex
        var negative = false
        if trimmed[index] == "+" {
            index = trimmed.index(after: index)
        } else if trimmed[index] == "-" {
            negative = true
            index = trimmed.index(after: index)
        }
        guard index < trimmed.endIndex else { throw ParseFailure.lexicalInvalid }

        let body = String(trimmed[index...])
        let parts = body.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count == 1 || parts.count == 2 else { throw ParseFailure.lexicalInvalid }

        let intPart = String(parts[0])
        let fracPart = parts.count == 2 ? String(parts[1]) : ""
        guard !intPart.isEmpty, intPart.allSatisfy(\.isNumber) else { throw ParseFailure.lexicalInvalid }
        guard fracPart.allSatisfy(\.isNumber) else { throw ParseFailure.lexicalInvalid }
        guard fracPart.count <= 3 else { throw ParseFailure.unsupportedPrecision }

        let significant: String = {
            let strippedInt = intPart.drop { $0 == "0" }
            if strippedInt.isEmpty {
                let strippedFrac = fracPart.drop { $0 == "0" }
                return strippedFrac.isEmpty ? "0" : String(strippedFrac)
            }
            return String(strippedInt) + fracPart
        }()
        guard significant.count <= 19 else { throw ParseFailure.numericOverflow }

        let scale = Int64(fracPart.count)
        let digitString = intPart + fracPart
        guard let magnitude = Int64(digitString) else { throw ParseFailure.numericOverflow }

        let signed: Int64
        if magnitude == 0 {
            signed = 0
        } else if negative {
            let (negated, overflow) = magnitude.multipliedReportingOverflow(by: -1)
            if overflow { throw ParseFailure.numericOverflow }
            signed = negated
        } else {
            signed = magnitude
        }

        var denominator: Int64 = 1
        if scale > 0 {
            for _ in 0..<scale {
                let (next, overflow) = denominator.multipliedReportingOverflow(by: 10)
                if overflow { throw ParseFailure.numericOverflow }
                denominator = next
            }
        }
        return try ExactRational(numerator: signed, denominator: denominator)
    }

    /// Absolute Fahrenheit → Celsius: `C = (F - 32) × 5 / 9`, checked at each step.
    public func celsiusFromFahrenheit() throws -> ExactRational {
        let (scaled32, mulOverflow) = denominator.multipliedReportingOverflow(by: 32)
        if mulOverflow { throw ArithmeticFailure.numericOverflow }
        let (shifted, subOverflow) = numerator.subtractingReportingOverflow(scaled32)
        if subOverflow { throw ArithmeticFailure.arithmeticOverflow }
        let (times5, mul5Overflow) = shifted.multipliedReportingOverflow(by: 5)
        if mul5Overflow { throw ArithmeticFailure.numericOverflow }
        let (den9, denOverflow) = denominator.multipliedReportingOverflow(by: 9)
        if denOverflow { throw ArithmeticFailure.numericOverflow }
        return try ExactRational(numerator: times5, denominator: den9)
    }

    /// Exact integer value (denominator must divide numerator).
    public func exactInt64() throws -> Int64 {
        guard numerator % denominator == 0 else {
            throw ArithmeticFailure.unsupportedPrecision
        }
        return numerator / denominator
    }

    /// Integer cell value that is an exact multiple of `step` (step ≥ 1).
    public func integerMultiple(ofStep step: Int) throws -> Int {
        guard step >= 1 else { throw ArithmeticFailure.unsupportedPrecision }
        let value = try exactInt64()
        guard value % Int64(step) == 0 else {
            throw ArithmeticFailure.unsupportedPrecision
        }
        guard let asInt = Int(exactly: value) else {
            throw ArithmeticFailure.numericOverflow
        }
        return asInt
    }

    private static func gcd(_ a: Int64, _ b: Int64) -> Int64 {
        var x = a
        var y = b
        while y != 0 {
            let r = x % y
            x = y
            y = r
        }
        return x == 0 ? 1 : x
    }
}
