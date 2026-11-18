//
//  Colour.swift
//  ApplePaint
//
//  Created by NullSilck on 2025/9/22.
//

import SwiftUI

/// SwiftUI `Color` 的可编码表示
///
/// `Colour` 存储色彩组件、色彩空间信息和alpha值, 允许对颜色进行编码和解码
///
/// 使用 `Color.toColour` 将 SwiftUI `Color` 转换为 `Colour`
struct Colour: Codable, Hashable, Equatable {
    /// 从底层提取的颜色组件值 `CGColor`
    private var components: [CGFloat]

    /// 色彩空间模型的原始值
    private var colorSpaceModel: CGColorSpaceModel.RawValue

    /// 颜色空间的名称 (如果可用)
    private var colorSpaceName: String?

    /// 颜色的不透明度, 范围从 `0.0` 到 `1.0`
    private var alpha: CGFloat

    /// - Parameter color: 要转换的 SwiftUI 颜色
    ///
    /// - Note: 使用 `Color.toColour` 而不是直接调用此初始化
    init(from color: Color) {
        let cgColor = UIColor(color).cgColor
        self.components = cgColor.components?.map { $0 } ?? []
        self.alpha = cgColor.alpha
        guard let colorSpace = cgColor.colorSpace else {
            self.colorSpaceModel = CGColorSpaceModel.unknown.rawValue
            self.colorSpaceName = nil
            return
        }
        self.colorSpaceModel = colorSpace.model.rawValue
        self.colorSpaceName = colorSpace.name as String?
    }
}

extension Colour {
    /// 将存储的颜色表示转换为SwiftUI `Color`.
    ///
    /// 该转换是基于存储的颜色分量的数量和原始颜色空间信息
    ///
    /// 支持的组件布局
    /// - 1 component: 没有显式alpha的灰度
    /// - 2 components: 灰度与alpha
    /// - 3 components: 没有显式alpha的RGB
    /// - 4 components: 带有alpha的RGB
    ///
    /// 使用`.displayP3` 颜色空间恢复显示 颜色
    /// 其他支持的颜色, 默认为 `.sRGB`
    ///
    /// - Returns: 重构的 SwiftUI 颜色, 如果不支持将返回 `.clear`
    ///
    /// - Important: 此转换支持灰度、sRGB和Display P3布局, 其他色彩空间模型可能无法准确重建
    func toColor() -> Color {
        if components.count == 1 || components.count == 2 {
            let white = Double(components[0])
            return Color(.sRGB, red: white, green: white, blue: white, opacity: Double(alpha))
        }
        let red = Double(components[0])
        let green = Double(components[1])
        let blue = Double(components[2])
        if components.count == 3 {
            if let spaceName = colorSpaceName, spaceName.contains("DisplayP3") {
                return Color(.displayP3, red: red, green: green, blue: blue)
            }
            return Color(.sRGB, red: red, green: green, blue: blue)
        }
        if components.count == 4 {
            let alpha = Double(components[3])
            if let spaceName = colorSpaceName, spaceName.contains("DisplayP3") {
                return Color(.displayP3, red: red, green: green, blue: blue, opacity: Double(alpha))
            }
            return Color(.sRGB, red: red, green: green, blue: blue, opacity: Double(alpha))
        }
        return Color.clear
    }
}
