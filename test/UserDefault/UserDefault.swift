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
