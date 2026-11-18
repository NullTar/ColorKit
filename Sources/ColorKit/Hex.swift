//
//  Hex.swift
//  RidePlay
//
//  Created by NullSilck on 2026/11/18.
//

import SwiftUI

extension Color {
    /// 将十六进制颜色字符串转换为 SwiftUI Color
    ///
    /// 支持带有或不带 `#` 前缀的十六进制颜色格式
    ///
    /// 支持以下两种格式：
    /// - `RRGGBB`：RGB 颜色，默认透明度为 `1.0`
    /// - `RRGGBBAA`：RGBA 颜色，包含透明度信息
    ///
    /// 转换时会将 RGB 和 Alpha 分量分别归一化到 `0...1` 范围
    ///
    /// - Parameter hex: 十六进制颜色字符串
    ///
    /// - Returns: 转换后的 SwiftUI Color；如果字符串格式不正确或无法解析，则返回系统强调色（`.accentColor`）
    ///
    /// - Note: 颜色使用 `sRGB` 颜色空间创建
    static func fromHex(_ hex: String) -> Color {
        var hexString = hex
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }
        guard hexString.count == 6 || hexString.count == 8 else {
            return .accentColor
        }
        var rgbValue: UInt64 = 0
        guard Scanner(string: hexString).scanHexInt64(&rgbValue) else {
            return .accentColor
        }

        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double

        if hexString.count == 6 {
            // RRGGBB format, alpha = 1
            red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
            green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
            blue = Double(rgbValue & 0x0000FF) / 255.0
            alpha = 1.0
        } else {
            // RRGGBBAA format
            red = Double((rgbValue & 0xFF000000) >> 24) / 255.0
            green = Double((rgbValue & 0x00FF0000) >> 16) / 255.0
            blue = Double((rgbValue & 0x0000FF00) >> 8) / 255.0
            alpha = Double(rgbValue & 0x000000FF) / 255.0
        }

        return Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }

    /// 将 Color 转换为十六进制颜色字符串
    ///
    /// 根据当前颜色提取 RGBA 分量，并将每个分量转换为两位十六进制数
    ///
    /// - Parameters:
    ///   - includePrefix: 是否在结果前添加 `#`，默认为 `true`
    ///   - includeAlpha: 是否在结果中包含 Alpha 通道，默认为 `true`
    ///
    /// - Returns: 十六进制颜色字符串
    ///   - 包含 Alpha：`#RRGGBBAA`
    ///   - 不包含 Alpha：`#RRGGBB`
    ///
    /// - Note:
    ///   - macOS 使用 `NSColor` 获取颜色分量
    ///   - iOS 等平台使用 `UIColor` 获取颜色分量
    ///   - 如果无法转换为 RGB 颜色空间，则返回默认黑色
    ///   - RGBA 分量会限制在 `0...1` 范围内，并四舍五入转换为 `0...255`
    func toHex(_ includePrefix: Bool = true, _ includeAlpha: Bool = true) -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        let prefix = includePrefix ? "#" : ""
        let defaultColor = includeAlpha ? "\(prefix)000000FF" : "\(prefix)000000"

        #if os(macOS)
            let nsColor = NSColor(self)
            guard let rgbColor = nsColor.usingColorSpace(.deviceRGB) else {
                return defaultColor
            }
            rgbColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        #else
            let uiColor = UIColor(self)
            guard uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) else {
                return defaultColor
            }
        #endif

        let red = Int(round(min(max(r, 0), 1) * 255))
        let green = Int(round(min(max(g, 0), 1) * 255))
        let blue = Int(round(min(max(b, 0), 1) * 255))
        let alpha = Int(round(min(max(a, 0), 1) * 255))

        let hexString: String
        if includeAlpha {
            hexString = String(format: "%@%02X%02X%02X%02X", prefix, red, green, blue, alpha)
        } else {
            hexString = String(format: "%@%02X%02X%02X", prefix, red, green, blue)
        }
        return hexString
    }
}
