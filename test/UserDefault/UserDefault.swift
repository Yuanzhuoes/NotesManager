//
//  global.swift
//  test
//
//  Created by 李远卓 on 2021/6/11.
//
import Foundation
import UIKit

// userAccount
struct UserDefaultKeys {
    enum AccountInfo: String {
        case userName, userPassword, jwt
    }
}

let userAccount = UserDefaults.standard

// TODO: extension NSDte
func getDateIS08601() -> String {
    let now = NSDate()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
    return formatter.string(from: now as Date)
}
