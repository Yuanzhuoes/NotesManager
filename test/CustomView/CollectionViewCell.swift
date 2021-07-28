//
//  collectionViewCell.swift
//  test
//
//  Created by 李远卓 on 2021/7/27.
//

import UIKit
// custom collectionViewCell
class MyCollectionViewCell: UICollectionViewCell {
    let noteLabel = UILabel()
    let view = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        // notelable, single line default
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
            // zero?
            make.left.right.top.bottom.equalTo(0)
        }
        noteLabel.snp.makeConstraints { make in
            make.left.top.right.bottom.equalTo(0)
        }
    }
}
