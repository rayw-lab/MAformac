#!/usr/bin/env swift
import AppKit
import CoreGraphics
import Foundation
import Vision

struct Arguments {
    var caseID = ""
    var imagePath = ""
    var uiTreePath = ""
    var anchorPath = ""
    var outputPath = ""
    var expectedTexts: [String] = []
    var contrastThreshold = 1.5
}

enum CheckError: Error, CustomStringConvertible {
    case message(String)

    var description: String {
        switch self {
        case .message(let value): return value
        }
    }
}

struct ContrastSample: Encodable {
    let name: String
    let contrastRatio: Double
}

struct SSIMResult: Encodable {
    let status: String
    let value: Double?
    let anchorPath: String?
}

func parseArguments() throws -> Arguments {
    var result = Arguments()
    var iterator = CommandLine.arguments.dropFirst().makeIterator()
    while let argument = iterator.next() {
        switch argument {
        case "--case":
            result.caseID = iterator.next() ?? ""
        case "--image":
            result.imagePath = iterator.next() ?? ""
        case "--ui-tree":
            result.uiTreePath = iterator.next() ?? ""
        case "--anchor":
            result.anchorPath = iterator.next() ?? ""
        case "--output":
            result.outputPath = iterator.next() ?? ""
        case "--expected":
            result.expectedTexts.append(iterator.next() ?? "")
        case "--contrast-threshold":
            guard let raw = iterator.next(), let value = Double(raw) else {
                throw CheckError.message("--contrast-threshold requires a number")
            }
            result.contrastThreshold = value
        default:
            throw CheckError.message("unknown argument: \(argument)")
        }
    }

    if result.caseID.isEmpty || result.imagePath.isEmpty || result.uiTreePath.isEmpty || result.outputPath.isEmpty {
        throw CheckError.message("usage: check-8c2-l2-readability.swift --case <id> --image <png> --ui-tree <txt> --anchor <png> --output <json> --expected <text> ...")
    }
    if result.expectedTexts.isEmpty {
        throw CheckError.message("at least one --expected text is required")
    }
    return result
}

func cgImage(at path: String) throws -> CGImage {
    let url = URL(fileURLWithPath: path)
    guard let image = NSImage(contentsOf: url) else {
        throw CheckError.message("failed to load image: \(path)")
    }
    var rect = NSRect(origin: .zero, size: image.size)
    guard let cgImage = image.cgImage(forProposedRect: &rect, context: nil, hints: nil) else {
        throw CheckError.message("failed to decode CGImage: \(path)")
    }
    return cgImage
}

func recognizeText(in image: CGImage) throws -> [String] {
    let request = VNRecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true
    request.recognitionLanguages = ["zh-Hans", "en-US"]
    let handler = VNImageRequestHandler(cgImage: image, options: [:])
    do {
        try handler.perform([request])
    } catch {
        throw CheckError.message("Vision OCR failed: \(error)")
    }
    return (request.results ?? []).compactMap { observation in
        observation.topCandidates(1).first?.string
    }
}

func normalized(_ value: String) -> String {
    value
        .replacingOccurrences(of: " ", with: "")
        .replacingOccurrences(of: "\n", with: "")
        .replacingOccurrences(of: "\t", with: "")
        .replacingOccurrences(of: "℃", with: "°C")
        .lowercased()
}

func containsExpected(_ expected: String, in recognized: [String]) -> Bool {
    let needle = normalized(expected)
    let haystack = normalized(recognized.joined(separator: " "))
    if haystack.contains(needle) {
        return true
    }
    if needle == "按住说话" {
        return haystack.contains("按住") && haystack.contains("说话")
    }
    return false
}

func rgbaPixels(from image: CGImage) throws -> (pixels: [UInt8], width: Int, height: Int) {
    let width = image.width
    let height = image.height
    var pixels = [UInt8](repeating: 0, count: width * height * 4)
    guard
        let context = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
    else {
        throw CheckError.message("failed to create bitmap context")
    }
    context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
    return (pixels, width, height)
}

func luminance(r: UInt8, g: UInt8, b: UInt8) -> Double {
    func linear(_ value: UInt8) -> Double {
        let channel = Double(value) / 255.0
        if channel <= 0.03928 {
            return channel / 12.92
        }
        return pow((channel + 0.055) / 1.055, 2.4)
    }
    return 0.2126 * linear(r) + 0.7152 * linear(g) + 0.0722 * linear(b)
}

func contrastSamples(image: CGImage) throws -> [ContrastSample] {
    let bitmap = try rgbaPixels(from: image)
    let regions: [(String, ClosedRange<Double>, ClosedRange<Double>)] = [
        ("dialogue", 0.31...0.49, 0.00...1.00),
        ("vehicle_cards", 0.50...0.88, 0.00...1.00),
        ("mic_dock", 0.87...0.98, 0.05...0.95)
    ]

    return regions.map { name, yRange, xRange in
        let x0 = max(0, min(bitmap.width - 1, Int(Double(bitmap.width) * xRange.lowerBound)))
        let x1 = max(x0 + 1, min(bitmap.width, Int(Double(bitmap.width) * xRange.upperBound)))
        let y0 = max(0, min(bitmap.height - 1, Int(Double(bitmap.height) * yRange.lowerBound)))
        let y1 = max(y0 + 1, min(bitmap.height, Int(Double(bitmap.height) * yRange.upperBound)))
        var values: [Double] = []
        values.reserveCapacity((x1 - x0) * (y1 - y0) / 16)
        for y in stride(from: y0, to: y1, by: 4) {
            for x in stride(from: x0, to: x1, by: 4) {
                let index = (y * bitmap.width + x) * 4
                values.append(luminance(r: bitmap.pixels[index], g: bitmap.pixels[index + 1], b: bitmap.pixels[index + 2]))
            }
        }
        values.sort()
        let low = values[max(0, Int(Double(values.count - 1) * 0.01))]
        let high = values[min(values.count - 1, Int(Double(values.count - 1) * 0.99))]
        let contrast = (high + 0.05) / (low + 0.05)
        return ContrastSample(name: name, contrastRatio: contrast)
    }
}

func grayscaleGrid(from image: CGImage, width: Int = 96, height: Int = 192) throws -> [Double] {
    let bitmap = try rgbaPixels(from: image)
    var values: [Double] = []
    values.reserveCapacity(width * height)
    for gy in 0..<height {
        let y = min(bitmap.height - 1, Int((Double(gy) + 0.5) * Double(bitmap.height) / Double(height)))
        for gx in 0..<width {
            let x = min(bitmap.width - 1, Int((Double(gx) + 0.5) * Double(bitmap.width) / Double(width)))
            let index = (y * bitmap.width + x) * 4
            values.append(luminance(r: bitmap.pixels[index], g: bitmap.pixels[index + 1], b: bitmap.pixels[index + 2]))
        }
    }
    return values
}

func ssim(anchor: CGImage, current: CGImage) throws -> Double {
    let left = try grayscaleGrid(from: anchor)
    let right = try grayscaleGrid(from: current)
    let count = Double(left.count)
    let meanLeft = left.reduce(0, +) / count
    let meanRight = right.reduce(0, +) / count
    var varianceLeft = 0.0
    var varianceRight = 0.0
    var covariance = 0.0
    for index in left.indices {
        let dl = left[index] - meanLeft
        let dr = right[index] - meanRight
        varianceLeft += dl * dl
        varianceRight += dr * dr
        covariance += dl * dr
    }
    varianceLeft /= max(1, count - 1)
    varianceRight /= max(1, count - 1)
    covariance /= max(1, count - 1)
    let c1 = 0.01 * 0.01
    let c2 = 0.03 * 0.03
    let numerator = (2 * meanLeft * meanRight + c1) * (2 * covariance + c2)
    let denominator = (meanLeft * meanLeft + meanRight * meanRight + c1) * (varianceLeft + varianceRight + c2)
    return numerator / denominator
}

func makeJSONObject(arguments: Arguments) throws -> [String: Any] {
    let image = try cgImage(at: arguments.imagePath)
    let recognized = try recognizeText(in: image)
    let missingOCR = arguments.expectedTexts.filter { !containsExpected($0, in: recognized) }
    let uiTree = (try? String(contentsOfFile: arguments.uiTreePath, encoding: .utf8)) ?? ""
    let uiTreeMissing = arguments.expectedTexts.filter { !normalized(uiTree).contains(normalized($0)) }
    let contrast = try contrastSamples(image: image)
    let minContrast = contrast.map(\.contrastRatio).min() ?? 0
    let ssimResult: SSIMResult
    if !arguments.anchorPath.isEmpty, FileManager.default.fileExists(atPath: arguments.anchorPath) {
        let anchor = try cgImage(at: arguments.anchorPath)
        ssimResult = SSIMResult(status: "RECORDED", value: try ssim(anchor: anchor, current: image), anchorPath: arguments.anchorPath)
    } else {
        ssimResult = SSIMResult(status: "MISSING_ANCHOR", value: nil, anchorPath: arguments.anchorPath.isEmpty ? nil : arguments.anchorPath)
    }
    let ocrPass = missingOCR.isEmpty
    let contrastPass = minContrast >= arguments.contrastThreshold
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    let contrastData = try encoder.encode(contrast)
    let ssimData = try encoder.encode(ssimResult)
    return [
        "case_id": arguments.caseID,
        "proof_class": "local_l2_ocr_contrast_ssim",
        "image_path": arguments.imagePath,
        "ui_tree_path": arguments.uiTreePath,
        "ocr": [
            "engine": "VNRecognizeTextRequest",
            "status": ocrPass ? "PASS" : "FAIL",
            "recognized_text": recognized,
            "expected_text": arguments.expectedTexts,
            "missing_text": missingOCR
        ],
        "contrast": [
            "status": contrastPass ? "PASS" : "FAIL",
            "threshold": arguments.contrastThreshold,
            "method": "region_1st_to_99th_percentile_luminance_ratio",
            "min_ratio": minContrast,
            "samples": try JSONSerialization.jsonObject(with: contrastData)
        ],
        "ssim": try JSONSerialization.jsonObject(with: ssimData),
        "ui_tree_corroboration": [
            "status": uiTreeMissing.isEmpty ? "PASS" : "WARN",
            "missing_text": uiTreeMissing,
            "note": "UI tree is corroboration only and cannot replace OCR"
        ],
        "verdict": (ocrPass && contrastPass) ? "PASS" : "FAIL",
        "claims_not_made": ["L3", "V-PASS", "mobile", "true_device", "A-2 complete"]
    ]
}

do {
    let arguments = try parseArguments()
    let payload = try makeJSONObject(arguments: arguments)
    let data = try JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys])
    let outputURL = URL(fileURLWithPath: arguments.outputPath)
    try FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
    try data.write(to: outputURL)
    if payload["verdict"] as? String == "PASS" {
        print("PASS: \(arguments.caseID) L2 readability evidence")
        exit(0)
    } else {
        writeStderr("FAIL: \(arguments.caseID) L2 readability evidence")
        exit(1)
    }
} catch {
    writeStderr("FAIL: \(error)")
    exit(1)
}

func writeStderr(_ message: String) {
    FileHandle.standardError.write(Data((message + "\n").utf8))
}
