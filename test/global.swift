//
//  global.swift
//  test
//
//  Created by 李远卓 on 2021/6/11.
//

import Foundation

// 全局函数和变量

func validateEmail(email: String) -> Bool {

    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
    let emailTest:NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return emailTest.evaluate(with: email)
    
}
