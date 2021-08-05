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
        // system info of cell layout
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        // reset horizontal space
        if attributes.count > 0 {
            var row = 1
            // first label on the left
            attributes[0].frame.origin.x = 0

            // adjust space from the second cell
            for i in 1..<attributes.count {
                let curAttr = attributes[i]
                let preAttr = attributes[i - 1]
                let origin = preAttr.frame.maxX
                let targetX = origin + maxSpacing
                let targetY = preAttr.frame.origin.y

                if targetX + curAttr.frame.width <= collectionViewContentSize.width {
                    curAttr.frame.origin.x = targetX
                    curAttr.frame.origin.y = targetY
                // else automatically wrap to the next line
                } else {
                    curAttr.frame.origin.x = 0
                    row += 1
                }

                // get the hight of collection view from the last cell
                if i == attributes.count - 1 {
                    self.delegate?.getCollectionViewHeightAndRows(height: curAttr.frame.maxY, row: row)
                }
            }
        }
        return attributes
    }
}

// delegate design pattern
// AnyObject: class-only protocol
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
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        if attributes.count > 0 {
            var row = 1
            attributes[0].frame.origin.x = 0

            if attributes.count == 1 {
                self.delegate?.getCollectionViewHeight(height: attributes[0].frame.maxY)
                return attributes
            }

            for i in 1..<attributes.count {
                let curAttr = attributes[i]
                let preAttr = attributes[i - 1]
                let origin = preAttr.frame.maxX
                let targetX = origin + maxSpacing
                let targetY = preAttr.frame.origin.y
                if targetX + curAttr.frame.width <= collectionViewContentSize.width - 28 && row == 1 {
                    curAttr.frame.origin.x = targetX
                    curAttr.frame.origin.y = targetY
                } else if targetX + curAttr.frame.width <= collectionViewContentSize.width && row > 1 {
                    curAttr.frame.origin.x = targetX
                    curAttr.frame.origin.y = targetY
                } else {
                    curAttr.frame.origin.x = 0
                    row += 1
                }

                // get max hight and rows
                if i == attributes.count - 1 {
                    self.delegate?.getCollectionViewHeight(height: curAttr.frame.maxY)
                }
            }
        }
        return attributes
    }
}
