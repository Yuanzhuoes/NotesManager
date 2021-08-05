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
    static var keyword = ""
    static var clippedNoteContent = ""

    // 关键词是否是字符串的子序列
    static func isSubsequence(keyword: String, target: String) -> Bool {
        let keywordCount = keyword.count, targetCount = target.count
        var keywordIndex = 0, targetIndex = 0

        if keyword.isEmpty {
            return false
        }

        while keywordIndex < keywordCount && targetIndex < targetCount {
            if keyword[keyword.index(keyword.startIndex, offsetBy: keywordIndex)]
                == target[target.index(target.startIndex, offsetBy: targetIndex)] {
                keywordIndex += 1
            }
            targetIndex += 1
        }

        return keywordIndex == keywordCount
    }

    // 将含有关键词的字符数组排到数组最前
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

    // 寻找字符串中，最小覆盖关键字子串的起始位置
    static func indexOfMinWindow(keyword: String, text: String) -> Int {
        let textArr = [Character](text)
        var windowDict = [Character: Int]()
        var needDict = [Character: Int]()

        for character in keyword {
            needDict[character, default: 0] += 1
        }

        var left = 0, right = 0
        var matchCount = 0
        var start = 0
        var minLen = Int.max

        while right < textArr.count {
            let rChar = textArr[right]

            right += 1

            if needDict[rChar] == nil { continue }

            windowDict[rChar, default: 0] += 1

            if windowDict[rChar] == needDict[rChar] {
                matchCount += 1
            }

            while matchCount == needDict.count {
                if right - left < minLen {
                    start = left
                    minLen = right - left
                }

                let lChar = textArr[left]
                left += 1

                if needDict[lChar] == nil { continue }
                if needDict[lChar] == windowDict[lChar] {
                    matchCount -= 1
                }

                windowDict[lChar]! -= 1
            }
        }
        return minLen == Int.max ? -1 : start
    }

    // 裁去关键字之前的字符串
    static func clipNoteContent(keyword: String, text: String) -> String {
        let firstIndex = indexOfMinWindow(keyword: keyword, text: text)
        var content = text
        if firstIndex == -1 {
            return content
        }
        content.removeSubrange(content.startIndex..<content.index(content.startIndex, offsetBy: firstIndex))
        return content
    }
}
