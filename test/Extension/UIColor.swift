//
//  ExtensionUIColor.swift
//  test
//
//  Created by ζθΏε on 2021/7/27.
//

import UIKit
// hex color to UIColor
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
