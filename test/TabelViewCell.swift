//
//  tabelViewCell.swift
//  test
//
//  Created by 李远卓 on 2021/7/27.
//

import UIKit
// 自定义显示界面TableViewCell 嵌套 collectionview
class MyTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource,
                       UICollectionViewDelegateFlowLayout, DisplayTagFlowLayoutDelegate {
    let privateLabel = UILabel()
    let contentLabel = UILabel()
    let tagLayOut = DisplayTagFlowLayout() // 用自定义的layout初始化collectionView
    // 延迟加载属性在第一次调用时才初始化
    // 因为它依赖taglayout, 而taglayout要在cell构造结束后才存在, 所以实例化cell后才能实例化collectionView, 必须延迟加载
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: tagLayOut)
    var currRow: Int = 0
    var noteLabelArray: [String] = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
        setConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {
//         collection view
        collectionView.backgroundColor = UIColor.white
        collectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: MyCollectionViewCell.description())
        collectionView.isScrollEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsSelection = true
        // 状态标签 固定大小 collection view
        privateLabel.font = UIFont.systemFont(ofSize: 11)
        privateLabel.textAlignment = .center
        privateLabel.textColor = UIColor.white
        privateLabel.backgroundColor = UIColor.greenColor
        // 内容标签
        contentLabel.backgroundColor = UIColor.white
        contentLabel.font = UIFont.systemFont(ofSize: 14)
        contentLabel.textAlignment = .left
        contentLabel.textColor = UIColor.textColor
        // 最大行，set to zero will grow with the label contents
        contentLabel.numberOfLines = 2
        self.contentView.addSubview(self.collectionView)
        self.contentView.addSubview(self.privateLabel)
        self.contentView.addSubview(self.contentLabel)
        collectionView.delegate = self
        collectionView.dataSource = self
        tagLayOut.delegate = self
    }

    func setConstraints() {
        privateLabel.snp.makeConstraints {
            $0.width.height.equalTo(18)
            $0.top.equalToSuperview().offset(12)
            $0.right.equalToSuperview().offset(-16)
        }
        collectionView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.top.equalToSuperview().offset(12)
            $0.height.equalTo(1).priority(.low) // 不设置优先级会冲突
        }
        contentLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.top.equalTo(collectionView.snp.bottom)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
    // collectionview的最大高度 后于tabelview autolayout，所以tabelview高度不能准确更新
    func getCollectionViewHeight(height: CGFloat) {
        collectionView.snp.updateConstraints {
            $0.height.equalTo(height + 8).priority(.low)
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 消除空字符串的显示bug
        if noteLabelArray.count == 1 && noteLabelArray[0] == "" {
            return 0
        }
        return noteLabelArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.description(), for: indexPath)
        if let cell = cell as? MyCollectionViewCell {
            cell.noteLabel.text = noteLabelArray[indexPath.row]
        }
        return cell
    }
    // 每个item的大小, item之间的间距由自定义layout实现，长度由函数实现
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: labelWidth(noteLabelArray[indexPath.item], 15, indexPath),
                      height: 15)
    }
    // 行间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    // 根据内容和高度计算每一个label的宽度
    func labelWidth(_ text: String, _ height: CGFloat, _ indexPath: IndexPath) -> CGFloat {
        let size = CGSize(width: 2000, height: height)
        let font = UIFont.systemFont(ofSize: 11)
        let attributes = [NSAttributedString.Key.font: font]
        let labelSize = NSString(string: text).boundingRect(with: size,
                                options: .usesLineFragmentOrigin,
                                attributes: attributes, context: nil)
        // 如果标签大于屏幕宽度，则设置一个定值
        if indexPath.row == 0 && labelSize.width + 8 > collectionView.frame.width - 18 {
            return collectionView.frame.width - 20
        } else if indexPath.row > 0 && labelSize.width + 8 > collectionView.frame.width {
            return collectionView.frame.width
        }
        return labelSize.width + 8
    }
}
