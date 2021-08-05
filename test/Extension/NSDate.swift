//
//  NSDate.swift
//  test
//
//  Created by 李远卓 on 2021/8/5.
//

import Foundation

// TODO: extension NSDate
func getDateIS08601() -> String {
    let now = NSDate()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
    return formatter.string(from: now as Date)
}
