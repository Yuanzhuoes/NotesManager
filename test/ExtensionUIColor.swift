//
//  ExtensionUIColor.swift
//  test
//
//  Created by 李远卓 on 2021/7/27.
//

import UIKit
// 十六进制颜色转换 结构体类型属性 用类型名调用
extension UIColor {
    static let placeHolderColor = UIColor(hexColor: "aaaaaa")
    static let eyeColor = UIColor(hexColor: "aaaaaa")
    static let greenColor = UIColor(hexColor: "#36B59D")
    static let buttonDisabledColor = UIColor(hexColor: "#e5e5e5")
    static let errorColor = UIColor(hexColor: "#dc663e")
    static let textColor = UIColor(hexColor: "#5d5d5d")
    static let grayColor = UIColor(hexColor: "#aaaaaa")
    static let logOutColor = UIColor(hexColor: "#8E8E8E")
    static let whiteColor = UIColor(hexColor: "#FFFFFF")
    static let deleteColor = UIColor(hexColor: "#DC663E")
    static let navigationColor = UIColor(hexColor: "#ECEDEE")
    static let segmentColor = UIColor(hexColor: "#f4f5f9")
}

extension UIColor {
    // 便利构造函数可返回nil
    convenience init(hexColor: String) {
        let hexColor = hexColor.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexColor)
        if hexColor.hasPrefix("#") {
            scanner.currentIndex = scanner.string.index(after: scanner.currentIndex)
        }
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)

        let mask = 0x000000FF
        let red = Int(color >> 16) & mask
        let green = Int(color >> 8) & mask
        let blue = Int(color) & mask
        let redCGF   = CGFloat(red) / 255.0
        let greenCGF = CGFloat(green) / 255.0
        let blueCGF  = CGFloat(blue) / 255.0
        self.init(red: redCGF, green: greenCGF, blue: blueCGF, alpha: 1)
    }
}
