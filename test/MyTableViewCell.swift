//
//  MyTableViewCell.swift
//  test
//
//  Created by 李远卓 on 2021/6/24.
//

import UIKit

class MyTableViewCell: UITableViewCell {
    let privateLable = UILabel()
    let noteLable = UILabel()
    let textLable = UILabel()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        myAdd()
        myConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func myAdd() {
        // 状态标签 固定大小 collection view
        privateLable.font = UIFont.systemFont(ofSize: 11)
        privateLable.textAlignment = .center
        privateLable.textColor = UIColor.white
        noteLable.layer.cornerRadius = 3
        privateLable.backgroundColor = MyColor.greenColor
        // 笔记标签 默认单行
        noteLable.font = UIFont.systemFont(ofSize: 11)
        noteLable.textAlignment = .center
        noteLable.layer.cornerRadius = 3
        noteLable.textColor = MyColor.textColor
        noteLable.backgroundColor = MyColor.navigationColor
        // 内容标签
        textLable.font = UIFont.systemFont(ofSize: 14)
        textLable.textAlignment = .left
        textLable.textColor = MyColor.textColor
        textLable.numberOfLines = 2
        // 设置最大行和省略号模式
//        textLable.lineBreakMode = NSLineBreakMode.byTruncatingTail
        self.addSubview(self.privateLable)
        self.addSubview(self.noteLable)
        self.addSubview(self.textLable)
    }
    func myConstraints() {
        privateLable.snp.makeConstraints { (make) in
            make.width.height.equalTo(18)
            make.top.equalTo(self.snp.top).offset(12)
            make.right.equalTo(self.snp.right).offset(-16)
        }
        // 标签位于第一行 跟状态标签保持距离
        // 标签最大长度为屏幕宽度-30，超出部分省略
        // 标签过多换行处理
        noteLable.snp.makeConstraints { (make) in
            make.height.equalTo(18)
            make.top.equalTo(self.snp.top).offset(12)
            make.left.equalTo(self.snp.left).offset(16)
        }
        textLable.snp.makeConstraints { (make) in
            make.width.equalTo(self.snp.width).offset(-32)
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(privateLable.snp.bottom).offset(8)
            make.bottom.equalTo(self.snp.bottom).offset(-12)
        }
    }
}
