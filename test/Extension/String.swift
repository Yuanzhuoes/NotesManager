//
//  ExtensionString.swift
//  test
//
//  Created by 李远卓 on 2021/7/27.
//

import Foundation
import UIKit

extension String {
    // arrtibuted string setting: eg. line spacing, breakMode, color, font size
    func attributedString(lineSpaceing: CGFloat, lineBreakModel: NSLineBreakMode, keyword: String = "") -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpaceing
        style.lineBreakMode = lineBreakModel

        let attributes = [NSAttributedString.Key.paragraphStyle: style] as [NSAttributedString.Key: Any]
        let attrStr = NSMutableAttributedString.init(string: self, attributes: attributes)

        let theRange = NSString(string: self).range(of: keyword)
        attrStr.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.greenColor], range: theRange)

        return attrStr
    }

    // divide string to array: "a/" -> ["a", ""] -> ["a"], "/" -> ["", ""] -> []
    var array: [String] {
        let dividedFlag: CharacterSet = NSCharacterSet(charactersIn: "/") as CharacterSet
        var result = self.components(separatedBy: dividedFlag)
        result = result.filter({ label in
            return label != ""
        })
        return result
    }
}

// set default optional value of string to ""
extension Optional where Wrapped == String {
    var safe: String {
       return self ?? ""
    }
}
