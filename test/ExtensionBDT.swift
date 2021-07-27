//
//  ExtensionString.swift
//  test
//
//  Created by 李远卓 on 2021/7/27.
//

import Foundation
import UIKit
// 扩展string
extension String {
// 富文本设置 行间距 字间距
    // 按需要可以设置所有的属性 字体 颜色 大小等
    func attributedString(lineSpaceing: CGFloat, lineBreakModel: NSLineBreakMode) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpaceing
        style.lineBreakMode = lineBreakModel
        let attributes = [NSAttributedString.Key.paragraphStyle: style]
            as [NSAttributedString.Key: Any]
        let attrStr = NSMutableAttributedString.init(string: self, attributes: attributes)
        return attrStr
    }
    // 字符串分割
    var array: [String] {
        let dividedFlag: CharacterSet = NSCharacterSet(charactersIn: "/") as CharacterSet
        return self.components(separatedBy: dividedFlag)
    }
    // 邮箱格式检测
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
