//
//  tabelViewCell.swift
//  test
//
//  Created by 李远卓 on 2021/7/27.
//

import UIKit
// nested TableViewCell with collectionview
class MyTableViewCell: UITableViewCell {

    let privateLabel = UILabel()
    let contentLabel = UILabel()
    let tagLayOut = DisplayTagFlowLayout()
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: tagLayOut)
    var currRow: Int = 0
    var noteLabelArray: [String] = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI() {
        setCollectionView()
        setPrivateLabel()
        setContentLabel()
        setSubview()
        setDelegate()
        setConstraints()
    }

    func setCollectionView() {
        collectionView.backgroundColor = UIColor.white
        collectionView.isScrollEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        // default is true, set false to ignore and remove from the event queue.
        collectionView.isUserInteractionEnabled = false
        collectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: MyCollectionViewCell.description())
    }

    func setPrivateLabel() {
        privateLabel.font = UIFont.systemFont(ofSize: 11)
        privateLabel.textAlignment = .center
        privateLabel.textColor = UIColor.white
        privateLabel.layer.cornerRadius = 1
        privateLabel.layer.backgroundColor = UIColor.greenColor.cgColor
    }

    func setContentLabel() {
        contentLabel.backgroundColor = UIColor.white
        contentLabel.font = UIFont.systemFont(ofSize: 14)
        contentLabel.textAlignment = .left
        contentLabel.textColor = UIColor.textColor
        contentLabel.numberOfLines = 2
    }

    func setSubview() {
        self.contentView.addSubview(self.collectionView)
        self.contentView.addSubview(self.privateLabel)
        self.contentView.addSubview(self.contentLabel)
    }

    func setDelegate() {
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
            $0.height.equalTo(1).priority(.low) // priority
        }
        contentLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.top.equalTo(collectionView.snp.bottom)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
}

// set cell
extension MyTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        setEmptyLabel(labelArray: &noteLabelArray)
        return noteLabelArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.description(), for: indexPath)
        if let cell = cell as? MyCollectionViewCell {
            cell.noteLabel.text = noteLabelArray[indexPath.row]
            cell.noteLabel.textColor = UIColor.textColor
            if SearchResults.isSubsequence(keyword: SearchResults.keyword, target: noteLabelArray[indexPath.row]) {
                cell.noteLabel.textColor = UIColor.greenColor
            }
        }
        return cell
    }
}

// set system flowlayout
extension MyTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: labelWidth(noteLabelArray[indexPath.item], 18, indexPath),
                      height: 18)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

// set coustom flowlayout of hight
extension MyTableViewCell: DisplayTagFlowLayoutDelegate {
    // delegate: update the hight of collectionView
    func getCollectionViewHeight(height: CGFloat) {
        collectionView.snp.updateConstraints {
            $0.height.equalTo(height + 8).priority(.low)
        }
    }
}

private extension MyTableViewCell {
    func labelWidth(_ text: String, _ height: CGFloat, _ indexPath: IndexPath) -> CGFloat {
        let size = CGSize(width: 2000, height: height)
        let font = UIFont.systemFont(ofSize: 11)
        let attributes = [NSAttributedString.Key.font: font]
        let labelSize = NSString(string: text).boundingRect(
                                with: size,
                                options: .usesLineFragmentOrigin,
                                attributes: attributes,
                                context: nil)

        if indexPath.row == 0 && labelSize.width >= collectionView.frame.width - 28 {
            return collectionView.frame.width - 28
        } else if indexPath.row > 0 && labelSize.width >= collectionView.frame.width {
            return collectionView.frame.width
        }

        return labelSize.width + 8
    }

    func setEmptyLabel(labelArray: inout [String]) {
        if labelArray.count == 1 && labelArray[0] == "" {
            labelArray[0] = "无标签"
        }
        if labelArray.isEmpty {
            labelArray.append("无标签")
        }
    }
}
