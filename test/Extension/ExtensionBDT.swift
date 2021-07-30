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
    func attributedString(lineSpaceing: CGFloat, lineBreakModel: NSLineBreakMode) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpaceing
        style.lineBreakMode = lineBreakModel
        let attributes = [NSAttributedString.Key.paragraphStyle: style]
            as [NSAttributedString.Key: Any]
        let attrStr = NSMutableAttributedString.init(string: self, attributes: attributes)
        return attrStr
    }

    // divide string to array: "a/" -> ["a", ""] -> ["a"], "/" -> ["", ""] -> []
    var array: [String] {
        if self == "/" {
            return []
        }
        let dividedFlag: CharacterSet = NSCharacterSet(charactersIn: "/") as CharacterSet
        var result = self.components(separatedBy: dividedFlag)
        if result.last == "" {
            result.removeLast()
        }
        return result
    }

    // email format validate
    var isValidateEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: self)
    }
}

extension Int {
    var intToString: String {
        return self == 1 ? "公" : "私"
    }
}

// set default optional value of string to ""
extension Optional where Wrapped == String {
    var safe: String {
       return self ?? ""
    }
}
