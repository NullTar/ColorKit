//
//  ColorConverter.swift
//  ApplePaint
//
//  Created by NullSilck on 2025/9/22.
//

import SwiftUI

extension Color {
    /// 将 SwiftUI Color 转换为 Colour 类型
    ///
    /// 通过当前颜色创建对应的 Colour 实例
    ///
    /// - Returns: 转换后的 Colour 实例
    func toColour() -> Colour {
        return Colour(from: self)
    }
}

extension Color {
    // MARK: - Private

    /// 获取当前颜色的 RGB 分量。
    private var rgbComponents: (red: Double, green: Double, blue: Double, alpha: Double)? {
        #if os(macOS)
        guard let color = NSColor(self).usingColorSpace(.sRGB) else {
            return nil
        }
        return (
            Double(color.redComponent),
            Double(color.greenComponent),
            Double(color.blueComponent),
            Double(color.alphaComponent)
        )
        #else
        let color = UIColor(self)

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }

        return (Double(red), Double(green), Double(blue), Double(alpha))
        #endif
    }

    /// 获取当前颜色的 HSB 分量。
    private var hsbComponents: (hue: Double, saturation: Double, brightness: Double, alpha: Double)? {
        #if os(macOS)
        guard let color = NSColor(self).usingColorSpace(.deviceRGB) else {
            return nil
        }
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

        return (Double(hue), Double(saturation), Double(brightness), Double(alpha))
        #else
        let color = UIColor(self)

        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        guard color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else {
            return nil
        }

        return (Double(hue), Double(saturation), Double(brightness), Double(alpha))
        #endif
    }
}

extension Color {
    // MARK: - Color.inverted

    /// 返回反转后的颜色，同时保留原始透明度
    ///
    /// 通过 `1 - component` 分别反转 RGB 颜色分量
    /// 例如：将黑色转换为白色，将白色转换为黑色
    ///
    /// 反转前会先将颜色转换为设备 RGB 颜色空间
    ///
    /// - Returns: 反转后的颜色；如果无法转换为 RGB 颜色空间，则返回原始颜色
    ///
    /// - Note: 动态颜色会先根据当前外观模式解析为实际颜色，然后再进行反转
    func inverted() -> Color {
        guard let components = rgbComponents else {
            return self
        }

        return Color(.sRGB, red: 1 - components.red, green: 1 - components.green, blue: 1 - components.blue, opacity: components.alpha)
    }

    /// 根据指定角度旋转当前颜色的色相
    ///
    /// - Parameter angle: 色相旋转角度，可以为正数或负数
    ///
    /// - Returns: 旋转后的颜色；如果无法提取 HSB 分量，则返回原始颜色
    func rotatedHue(_ angle: Double) -> Color {
        guard let components = hsbComponents else {
            return self
        }

        let hue = (components.hue + angle / 360)
            .truncatingRemainder(dividingBy: 1)

        let normalizedHue = hue < 0 ? hue + 1 : hue

        return Color(hue: normalizedHue, saturation: components.saturation, brightness: components.brightness, opacity: components.alpha)
    }
}

extension Color {
    // MARK: - Color.complementary

    /// 返回当前颜色的互补色
    ///
    /// 通过将色相旋转 180°，获取色轮上与原始颜色相对的颜色
    ///
    /// - Returns: 与原始颜色相差 180° 的互补色；如果无法提取 HSB 分量，则返回原始颜色
    func complementary() -> Color {
        rotatedHue(180)
    }

    // MARK: - Color.analogous

    /// 返回当前颜色的类似色
    ///
    /// 通过向色轮两侧旋转指定角度，获取与原始颜色相邻的两个颜色
    ///
    /// - Parameter angle: 色相偏移角度，默认为 30°
    ///
    /// - Returns: 分别向正负方向偏移指定角度的两个颜色
    ///
    /// - Note: 结果顺序为负角度、正角度。
    func analogous(angle: Double = 30) -> (Color, Color) {
        (rotatedHue(-angle), rotatedHue(angle))
    }

    // MARK: - Color.triadic

    /// 返回当前颜色的三角色
    ///
    /// 通过将色相分别旋转 120° 和 240°, 获取色轮上均匀分布的另外两个颜色
    ///
    /// - Returns: 两个三角色，分别对应 120° 和 240° 的色相偏移
    func triadic() -> (Color, Color) {
        (rotatedHue(120), rotatedHue(240))
    }

    // MARK: - Color.splitComplementary

    /// 返回当前颜色的分裂互补色
    ///
    /// 以互补色（180°）为中心，向两侧偏移指定角度, 获取两个分裂互补色
    ///
    /// - Parameter angle: 相对于互补色的偏移角度，默认为 30°
    ///
    /// - Returns: 分别对应 `180° - angle` 和 `180° + angle` 的两个颜色
    func splitComplementary(angle: Double = 30) -> (Color, Color) {
        (rotatedHue(180 - angle), rotatedHue(180 + angle))
    }

    // MARK: - Color.tetradic

    /// 返回当前颜色的四角色
    ///
    /// 通过色轮上的两组互补色构成矩形配色方案, 分别旋转 60°、180° 和 240°
    ///
    /// - Returns: 三个额外颜色，与原始颜色共同组成四角色配色
    func tetradic() -> (Color, Color, Color) {
        (rotatedHue(60), rotatedHue(180), rotatedHue(240))
    }

    // MARK: - Color.square

    /// 返回当前颜色的正方形配色
    ///
    /// 通过将色相分别旋转 90°、180° 和 270°, 获取色轮上均匀分布的三个颜色
    ///
    /// - Returns: 三个额外颜色，与原始颜色共同组成正方形配色
    func square() -> (Color, Color, Color) {
        (rotatedHue(90), rotatedHue(180), rotatedHue(270))
    }
}
