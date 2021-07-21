//
//  global.swift
//  test
//
//  Created by 李远卓 on 2021/6/11.
//
import Foundation
import UIKit
import Alamofire
import CryptoSwift
// userDefault
// 全局常量保存key（一致性，但不方便使用, 没有自动提示) let jwt = "jwt"
// 结构体保存 (一致性，方便使用，但初始化麻烦，每次使用都要初始化 myStruct())
// 结构体和静态常量属性结合 （一致性，不用初始化，但需手动设置key）
// 结构体和枚举结合，遵循string协议, 用默认的rawValue作为key，可分组
// 待优化，key值路径太长，无上下文推断
struct UserDefaultKeys {
    enum AccountInfo: String {
        case userName, userPassword, jwt
    }
}
let userDefault = UserDefaults.standard
// 获取时间戳 IS0 8601
func getDateIS08601() -> String {
    let now = NSDate()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
    return formatter.string(from: now as Date)
}

// 十六进制颜色转换 结构体类型属性 用类型名调用
struct MyColor {
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
