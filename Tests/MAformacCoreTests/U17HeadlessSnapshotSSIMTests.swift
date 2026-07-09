import CoreGraphics
import SwiftUI
import XCTest
@testable import MAformacCore

@MainActor
final class U17HeadlessSnapshotSSIMTests: XCTestCase {
    private let size = CGSize(width: 192, height: 112)
    private let thresholdEnvKey = "D1H_U17_SSIM_THRESHOLD"
    private let regenerateEnvKey = "D1H_U17_REGENERATE_BASELINES"
    private let badSampleEnvKey = "D1H_U17_FORCE_BAD_SAMPLE"

    func testU17SevenStateHeadlessSnapshotsMatchSSIMBaselines() throws {
        let threshold = configuredThreshold()
        let badSample = ProcessInfo.processInfo.environment[badSampleEnvKey]
        var comparedStates: [String] = []

        for state in DemoVisualState.allCases {
            let actual = try renderSnapshot(state: state, forceBadSample: badSample == state.rawValue)
            let baselineURL = baselineURL(for: state)

            if shouldRegenerateBaselines() {
                try actual.writePGM(to: baselineURL)
                continue
            }

            let expected = try LuminanceImage.readPGM(from: baselineURL)
            let result = expected.ssim(comparedTo: actual)
            XCTAssertGreaterThanOrEqual(
                result,
                threshold,
                "U17 SSIM below threshold: state=\(state.rawValue) ssim=\(String(format: "%.6f", result)) threshold=\(threshold)"
            )
            comparedStates.append(state.rawValue)
        }

        if shouldRegenerateBaselines() {
            throw XCTSkip("regenerated U17 headless baselines")
        }

        XCTAssertEqual(comparedStates, DemoVisualState.allCases.map(\.rawValue))
    }

    func testU17SSIMGateRejectsKnownBadSample() throws {
        let baseline = try renderSnapshot(state: .changing)
        let knownBad = try renderSnapshot(state: .changing, forceBadSample: true)
        let ssim = baseline.ssim(comparedTo: knownBad)

        XCTAssertLessThan(
            ssim,
            configuredThreshold(),
            "Known-bad U17 fixture must fail the SSIM threshold; got \(String(format: "%.6f", ssim))"
        )
    }

    func testU17AccessibilityInjectedHeadlessSnapshotsRenderAllStates() throws {
        let injection = D1HAccessibilityInjection.fromProcessEnvironment()

        for state in DemoVisualState.allCases {
            let image = try renderSnapshot(state: state, accessibility: injection)
            XCTAssertEqual(image.width, Int(size.width))
            XCTAssertEqual(image.height, Int(size.height))
            XCTAssertGreaterThan(Set(image.values.map { Int(($0 * 255).rounded()) }).count, 8)
        }
    }

    private func configuredThreshold() -> Double {
        ProcessInfo.processInfo.environment[thresholdEnvKey].flatMap(Double.init) ?? 0.995
    }

    private func shouldRegenerateBaselines() -> Bool {
        ProcessInfo.processInfo.environment[regenerateEnvKey] == "1"
    }

    private func baselineURL(for state: DemoVisualState) -> URL {
        fixturesRoot()
            .appendingPathComponent("d1h-u17-snapshots", isDirectory: true)
            .appendingPathComponent("u17_\(state.rawValue)_deepSpace.pgm")
    }

    private func fixturesRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Fixtures", isDirectory: true)
    }

    private func renderSnapshot(
        state: DemoVisualState,
        forceBadSample: Bool = false,
        accessibility: D1HAccessibilityInjection = .defaultOff
    ) throws -> LuminanceImage {
        let token = DesignTokenValues.token(for: state, theme: .deepSpace)
        let content = U17HeadlessStateCard(
            state: state,
            token: token,
            forceBadSample: forceBadSample,
            accessibility: accessibility
        )
            .frame(width: size.width, height: size.height)

        let renderer = ImageRenderer(content: content)
        renderer.scale = 1
        renderer.proposedSize = ProposedViewSize(size)

        guard let cgImage = renderer.cgImage else {
            throw SnapshotError.renderFailed(state.rawValue)
        }

        return try LuminanceImage(cgImage: cgImage, width: Int(size.width), height: Int(size.height))
    }
}

private struct U17HeadlessStateCard: View {
    let state: DemoVisualState
    let token: SemanticStateToken
    let forceBadSample: Bool
    let accessibility: D1HAccessibilityInjection

    var body: some View {
        ZStack {
            Color(rgb: TokenThemeID.deepSpace.surface)
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(rgb: renderedToken.effectiveBackground(on: .deepSpace)))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(rgb: renderedToken.effectiveBorder(on: .deepSpace)), lineWidth: accessibility.increaseContrast ? 7 : 5)
                }
                .padding(12)
            stateBands
            if forceBadSample {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 76, height: 48)
                    .offset(x: 34, y: -10)
            }
        }
    }

    private var renderedToken: SemanticStateToken {
        accessibility.reduceTransparency || accessibility.reduceMotion ? token.reducedVariant(on: .deepSpace) : token
    }

    private var stateBands: some View {
        let index = DemoVisualState.allCases.firstIndex(of: state) ?? 0
        return VStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { row in
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(rgb: rowColor(row: row, stateIndex: index)))
                    .frame(width: CGFloat(44 + index * 8 + row * 10), height: 8)
            }
        }
    }

    private func rowColor(row: Int, stateIndex: Int) -> TokenRGB {
        switch row {
        case 0:
            return renderedToken.border
        case 1:
            let alpha = accessibility.increaseContrast ? 0.52 : 0.38
            return renderedToken.backgroundTint.composited(over: TokenThemeID.deepSpace.inkPrimary, alpha: alpha + Double(stateIndex) * 0.025)
        default:
            return TokenThemeID.deepSpace.inkPrimary.composited(over: renderedToken.effectiveBackground(on: .deepSpace), alpha: 0.72)
        }
    }
}

private struct D1HAccessibilityInjection {
    static let reduceTransparencyEnvKey = "D1H_A11Y_REDUCE_TRANSPARENCY"
    static let increaseContrastEnvKey = "D1H_A11Y_INCREASE_CONTRAST"
    static let reduceMotionEnvKey = "D1H_A11Y_REDUCE_MOTION"
    static let defaultOff = D1HAccessibilityInjection(reduceTransparency: false, increaseContrast: false, reduceMotion: false)

    let reduceTransparency: Bool
    let increaseContrast: Bool
    let reduceMotion: Bool

    static func fromProcessEnvironment() -> D1HAccessibilityInjection {
        let environment = ProcessInfo.processInfo.environment
        return D1HAccessibilityInjection(
            reduceTransparency: environment[reduceTransparencyEnvKey] == "1",
            increaseContrast: environment[increaseContrastEnvKey] == "1",
            reduceMotion: environment[reduceMotionEnvKey] == "1"
        )
    }
}

private struct LuminanceImage: Equatable {
    let width: Int
    let height: Int
    let values: [Double]

    init(width: Int, height: Int, values: [Double]) {
        self.width = width
        self.height = height
        self.values = values
    }

    init(cgImage: CGImage, width: Int, height: Int) throws {
        var rgba = [UInt8](repeating: 0, count: width * height * 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

        guard let context = CGContext(
            data: &rgba,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            throw SnapshotError.bitmapContextFailed
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        var luminance: [Double] = []
        luminance.reserveCapacity(width * height)

        for pixel in stride(from: 0, to: rgba.count, by: 4) {
            let r = Double(rgba[pixel]) / 255.0
            let g = Double(rgba[pixel + 1]) / 255.0
            let b = Double(rgba[pixel + 2]) / 255.0
            luminance.append(0.2126 * r + 0.7152 * g + 0.0722 * b)
        }

        self.init(width: width, height: height, values: luminance)
    }

    func ssim(comparedTo other: LuminanceImage) -> Double {
        precondition(width == other.width && height == other.height)
        let count = Double(values.count)
        let meanA = values.reduce(0, +) / count
        let meanB = other.values.reduce(0, +) / count

        var varianceA = 0.0
        var varianceB = 0.0
        var covariance = 0.0
        for index in values.indices {
            let da = values[index] - meanA
            let db = other.values[index] - meanB
            varianceA += da * da
            varianceB += db * db
            covariance += da * db
        }
        varianceA /= count - 1
        varianceB /= count - 1
        covariance /= count - 1

        let c1 = 0.01 * 0.01
        let c2 = 0.03 * 0.03
        return ((2 * meanA * meanB + c1) * (2 * covariance + c2)) /
            ((meanA * meanA + meanB * meanB + c1) * (varianceA + varianceB + c2))
    }

    func writePGM(to url: URL) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        let bytes = values
            .map { String(Int((min(max($0, 0), 1) * 255).rounded())) }
            .joined(separator: " ")
        let contents = "P2\n# D1H U17 headless ImageRenderer baseline\n\(width) \(height)\n255\n\(bytes)\n"
        try contents.write(to: url, atomically: true, encoding: .utf8)
    }

    static func readPGM(from url: URL) throws -> LuminanceImage {
        let source = try String(contentsOf: url, encoding: .utf8)
        let tokens = source
            .split(whereSeparator: \.isNewline)
            .filter { !$0.hasPrefix("#") }
            .joined(separator: " ")
            .split(whereSeparator: \.isWhitespace)
            .map(String.init)

        guard tokens.count > 4, tokens[0] == "P2" else {
            throw SnapshotError.invalidPGM(url.path)
        }
        let width = try intToken(tokens[1], url: url)
        let height = try intToken(tokens[2], url: url)
        let maxValue = try intToken(tokens[3], url: url)
        guard maxValue == 255 else {
            throw SnapshotError.invalidPGM(url.path)
        }
        let values = try tokens.dropFirst(4).map { Double(try intToken($0, url: url)) / 255.0 }
        guard values.count == width * height else {
            throw SnapshotError.invalidPGM(url.path)
        }
        return LuminanceImage(width: width, height: height, values: values)
    }

    private static func intToken(_ token: String, url: URL) throws -> Int {
        guard let value = Int(token) else {
            throw SnapshotError.invalidPGM(url.path)
        }
        return value
    }
}

private extension Color {
    init(rgb: TokenRGB) {
        self.init(red: rgb.r, green: rgb.g, blue: rgb.b)
    }
}

private enum SnapshotError: Error, CustomStringConvertible {
    case renderFailed(String)
    case bitmapContextFailed
    case invalidPGM(String)

    var description: String {
        switch self {
        case .renderFailed(let state):
            return "render failed for \(state)"
        case .bitmapContextFailed:
            return "bitmap context failed"
        case .invalidPGM(let path):
            return "invalid pgm: \(path)"
        }
    }
}
