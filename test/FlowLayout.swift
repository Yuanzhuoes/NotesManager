//
//  flowLayout.swift
//  test
//
//  Created by 李远卓 on 2021/7/27.
//

import UIKit

protocol TagFlowLayoutDelegate: AnyObject {
    func getCollectionViewHeightAndRows(height: CGFloat, row: Int)
}

class TagFlowLayout: UICollectionViewFlowLayout {
    weak var delegate: TagFlowLayoutDelegate?
    let maxSpacing: CGFloat = 8

    override func prepare() {
        super.prepare()
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        super.layoutAttributesForElements(in: rect)
        // 系统计算的结果，所有cell布局信息的数组
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        // 水平间距调整
        if attributes.count > 0 {
            var row = 1
            // 第一个标签居左
            attributes[0].frame.origin.x = 0
            for i in 1..<attributes.count {
                let curAttr = attributes[i]
                let preAttr = attributes[i - 1]
                let origin = preAttr.frame.maxX
                let targetX = origin + maxSpacing
                let targetY = preAttr.frame.origin.y
                // 如果一行内还放得下 调整x, 否则换行（系统自动的）居左 (当前item宽度 + 前一个item的最大x坐标 + 间距 <= collectionview的宽度)
                if targetX + curAttr.frame.width <= collectionViewContentSize.width {
                    curAttr.frame.origin.x = targetX
                    // 为什么不限制y会出错
                    curAttr.frame.origin.y = targetY
                } else {
                    curAttr.frame.origin.x = 0
                    row += 1
                }
                // 获取最大高度和行数
                if i == attributes.count - 1 {
                    self.delegate?.getCollectionViewHeightAndRows(height: curAttr.frame.maxY, row: row)
                }
            }
        }
        return attributes
    }
}
// 委托/代理 设计模式：将一个类要做的事委托给另一个符合要求的类去做
// AnyObject 类专属协议
protocol DisplayTagFlowLayoutDelegate: AnyObject {
    func getCollectionViewHeight(height: CGFloat)
}

class DisplayTagFlowLayout: UICollectionViewFlowLayout {
    weak var delegate: DisplayTagFlowLayoutDelegate?
    let maxSpacing: CGFloat = 8

    override func prepare() {
        super.prepare()
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        super.layoutAttributesForElements(in: rect)
        // 系统计算的结果，所有cell布局信息的数组
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        // 水平间距调整 如果有标签就重新布局 否则默认值
        if attributes.count > 0 {
            var row = 1
            // 第一个标签居左
            attributes[0].frame.origin.x = 0
            // 只有一个标签 只记录高度 不调整间距
            if attributes.count == 1 {
                self.delegate?.getCollectionViewHeight(height: attributes[0].frame.maxY)
                return attributes
            }
            // 两个标签开始调整间距
            for i in 1..<attributes.count {
                let curAttr = attributes[i]
                let preAttr = attributes[i - 1]
                let origin = preAttr.frame.maxX
                let targetX = origin + maxSpacing
                let targetY = preAttr.frame.origin.y
                // 如果一行内还放得下 调整x, 否则换行（系统自动的）居左 (当前item宽度 + 前一个item的最大x坐标 + 间距 <= collectionview的宽度)
                if targetX + curAttr.frame.width <= collectionViewContentSize.width - 18 && row == 1 {
                    curAttr.frame.origin.x = targetX
                    // 不限制y会出错 why?
                    curAttr.frame.origin.y = targetY
                } else if targetX + curAttr.frame.width <= collectionViewContentSize.width && row > 1 {
                    curAttr.frame.origin.x = targetX
                    curAttr.frame.origin.y = targetY
                } else {
                    curAttr.frame.origin.x = 0
                    row += 1
                }
                // 获取最大高度和行数
                if i == attributes.count - 1 {
                    self.delegate?.getCollectionViewHeight(height: curAttr.frame.maxY)
                }
            }
        }
        return attributes
    }
}
