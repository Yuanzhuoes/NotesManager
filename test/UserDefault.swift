//
//  global.swift
//  test
//
//  Created by 李远卓 on 2021/6/11.
//
import Foundation
import UIKit
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
