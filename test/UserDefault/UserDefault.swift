//
//  global.swift
//  test
//
//  Created by ζθΏε on 2021/6/11.
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
