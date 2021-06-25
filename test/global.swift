//
//  global.swift
//  test
//
//  Created by 李远卓 on 2021/6/11.
//

import Foundation
import UIKit
import Alamofire

// url
enum URL {
    static let connectionProtocol = "http://"
    static let host = "47.96.170.11/"
    static let api = "api/v1/user/"
}
// 解析JSON
struct ServerDescription: Codable {
    struct Data: Codable {
        let token: String?
    }
    struct Error: Codable {
        let code: String?
        let info: String?
        let message: String?
    }
    let data: Data?
    let error: Error?
    let success: Bool?
}
// 接口属性，枚举
enum Function {
    case login, register, verify_code, reset
}
// 请求服务器，可选+默认值，防止调用时形参强制解析
func requestAndResponse(email: String? = nil, pwd: String? = nil, code: String? = nil,
                        function: Function, method: HTTPMethod, completion: @escaping (_: ServerDescription) -> Void) {
    let parameters: [String: String?]
    let url: String
    switch function {
    case .login:
        url = URL.connectionProtocol + URL.host + URL.api + "login"
        parameters = ["email": email,
                      "password": pwd]
    case .register:
        url = URL.connectionProtocol + URL.host + URL.api + "register"
        parameters = ["email": email,
                      "password": pwd]
    case .verify_code:
        url = URL.connectionProtocol + URL.host + URL.api + "password/reset/" + "verify_code"
        parameters = ["email": email]
    case .reset:
        url = URL.connectionProtocol + URL.host + URL.api + "password/" + "reset"
        parameters = ["email": email,
                      "new_password": pwd,
                      "verify_code": code]
    }
    AF.request(url, method: method, parameters: parameters).responseJSON { response in
        // 大括号是closure，匿名函数，response是参数，捕获上下文
        switch response.result {
        case .success(let json):
                guard let data = response.data else { return }
                // 解析JSON和捕获异常
                do {
                    let serverDescription = try JSONDecoder().decode(ServerDescription.self, from: data)
                    completion(serverDescription)
                    print(json)
                } catch let jsonErr {
                        print("json 解析出错 : ", jsonErr)
                }
        case .failure(let error):
                print(error)
        }
    }
}
// 邮箱格式检测
func validateEmail(email: String) -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
    let emailTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return emailTest.evaluate(with: email)
}
// 自定义文本边框, 继承和重写方法，拓展是添加方法，不能重写方法
class LineTextField: UITextField {
    override func draw(_ rect: CGRect) {
            // 线条的高度
        let lineHeight: CGFloat = 0.5
            // 线条的颜色
        let lineColor = MyColor.eyeColor
            guard let content = UIGraphicsGetCurrentContext() else { return }
            content.setFillColor(lineColor.cgColor)
            content.fill(CGRect.init(x: 0, y: self.frame.height - lineHeight,
                                     width: self.frame.width, height: lineHeight))
            UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        }
}
// 自定义警告窗口 KVC运行时访问和修改对象属性
class MyAlertController: UIAlertController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let attributedString = NSAttributedString(string: self.message!, attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15),
            NSAttributedString.Key.foregroundColor: MyColor.textColor])
        self.setValue(attributedString, forKey: "attributedMessage")
    }
    override func addAction(_ action: UIAlertAction ) {
        super.addAction(action)
        // 通过tintColor实现按钮颜色的修改。
        self.view.tintColor = MyColor.greenColor
//        也可以通过设置 action.setValue 来实现
//        action.setValue(UIColor.orange, forKey: "titleTextColor")
    }
}
// 十六进制颜色转换 枚举作为命名空间 枚举不能是存储属性 所以必须加static
enum MyColor {
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
}
// 模拟数据
var dataSuorceArrary = ["哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈hahahahah", "你好", "a", "b", "c", "d"]
