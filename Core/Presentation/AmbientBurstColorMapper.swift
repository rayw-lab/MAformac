import Foundation

enum AmbientBurstColorMapper {
    static let canonicalColorOptions: [String] = ["白", "红", "橙", "黄", "绿", "青", "蓝", "紫"]

    private static let aliases: [String: String] = [
        "紫": "紫色", "紫色": "紫色",
        "红": "红色", "红色": "红色",
        "青": "青色", "青色": "青色",
        "绿": "绿色", "绿色": "绿色",
        "蓝": "蓝色", "蓝色": "蓝色",
        "冰蓝": "青色", "冰蓝色": "青色",
        "浅蓝紫": "浅蓝紫色", "浅蓝紫色": "浅蓝紫色",
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
        "浅蓝紫色": ["蓝色", "紫色"],
        "白色": ["白色", "黄色"],
        "橙色": ["橙色", "黄色"],
        "黄色": ["黄色", "橙色"]
    ]

    static func normalizedColorName(for color: String) -> String {
        guard let normalized = aliases[color] else {
            return "紫色"
        }
        return normalized
    }

    static func burstGradient(for color: String) -> [String] {
        let normalized = normalizedColorName(for: color)
        guard let gradient = burstGradients[normalized] else {
            return ["紫色", "黄色"]
        }
        return gradient
    }
}

enum AmbientBurstTriggerPolicy {
    static func triggerColor(key: String, previousValue: String?, nextValue: String) -> String? {
        guard ScopedStateKey(key).base == "ambient.color" else { return nil }

        let next = AmbientBurstColorMapper.normalizedColorName(for: nextValue)
        let previous = previousValue.map(AmbientBurstColorMapper.normalizedColorName(for:))
        guard previous != next else { return nil }
        return next
    }
}
