import Foundation

enum AmbientBurstColorMapper {
    private static let aliases: [String: String] = [
        "紫": "紫色", "紫色": "紫色",
        "红": "红色", "红色": "红色",
        "青": "青色", "青色": "青色",
        "绿": "绿色", "绿色": "绿色",
        "蓝": "蓝色", "蓝色": "蓝色",
        "白": "白色", "白色": "白色",
        "橙": "橙色", "橙色": "橙色",
        "黄": "黄色", "黄色": "黄色"
    ]

    private static let burstGradients: [String: [String]] = [
        "紫色": ["紫色", "黄色"],
        "红色": ["红色", "橙色"],
        "青色": ["青色", "紫色"],
        "绿色": ["绿色", "青色"],
        "蓝色": ["蓝色", "青色"],
        "白色": ["白色", "黄色"],
        "橙色": ["橙色", "黄色"],
        "黄色": ["黄色", "橙色"]
    ]

    static func burstGradient(for color: String) -> [String] {
        guard let normalized = aliases[color] else {
            assertionFailure("Unhandled ambient.color alias: \(color)")
            return ["紫色", "黄色"]
        }
        guard let gradient = burstGradients[normalized] else {
            assertionFailure("Missing burst gradient for ambient.color: \(normalized)")
            return ["紫色", "黄色"]
        }
        return gradient
    }
}
