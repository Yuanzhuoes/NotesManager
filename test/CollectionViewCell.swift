//
//  collectionViewCell.swift
//  test
//
//  Created by 李远卓 on 2021/7/27.
//

import UIKit
// 自定义MyCollectionViewCell
class MyCollectionViewCell: UICollectionViewCell {
    let noteLabel = UILabel()
    let view = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        // 笔记标签 默认单行
        noteLabel.font = UIFont.systemFont(ofSize: 11)
        noteLabel.textAlignment = .center
        noteLabel.textColor = UIColor.textColor
        noteLabel.backgroundColor = UIColor.navigationColor
        self.contentView.addSubview(view)
        self.view.addSubview(noteLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        view.snp.makeConstraints { make in
            // 距离content的约束 0相当于填满整个父视图
            make.left.right.top.bottom.equalTo(0)
        }
        noteLabel.snp.makeConstraints { make in
            // 距离view的约束
            make.left.top.right.bottom.equalTo(0)
        }
    }
}
