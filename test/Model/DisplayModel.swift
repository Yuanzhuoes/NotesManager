//
//  DisplayModel.swift
//  test
//
//  Created by 李远卓 on 2021/7/28.
//

import Foundation

struct SearchResults {
    static var noteArray = [SQLNote]()
    static var hiddenMode = true
    static var sortedLabelArray = [String]()

    static func isSubsequence(keyword: String, target: String) -> Bool {
        let keywordCount = keyword.count, targetCount = target.count
        var keywordIndex = 0, targetIndex = 0

        while keywordIndex < keywordCount && targetIndex < targetCount {
            if keyword[keyword.index(keyword.startIndex, offsetBy: keywordIndex)]
                == target[target.index(target.startIndex, offsetBy: targetIndex)] {
                keywordIndex += 1
            }
            targetIndex += 1
        }

        return keywordIndex == keywordCount
    }

    static func sort(keyword: String, text: [String]) -> [String] {
        var results = [String]()
        for item in text {
            if isSubsequence(keyword: keyword, target: item) {
                if results.isEmpty {
                    results.append(item)
                } else {
                    results.insert(item, at: 0)
                }
            } else {
                results.append(item)
            }
        }
        return results
    }
}
