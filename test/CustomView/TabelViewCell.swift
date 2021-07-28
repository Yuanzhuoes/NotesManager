//
//  tabelViewCell.swift
//  test
//
//  Created by 李远卓 on 2021/7/27.
//

import UIKit
// nested TableViewCell with collectionview
class MyTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource,
                       UICollectionViewDelegateFlowLayout, DisplayTagFlowLayoutDelegate {
    let privateLabel = UILabel()
    let contentLabel = UILabel()
    let tagLayOut = DisplayTagFlowLayout()
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
        collectionView.backgroundColor = UIColor.white
        collectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: MyCollectionViewCell.description())
        collectionView.isScrollEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsSelection = true

        privateLabel.font = UIFont.systemFont(ofSize: 11)
        privateLabel.textAlignment = .center
        privateLabel.textColor = UIColor.white
        privateLabel.backgroundColor = UIColor.greenColor

        contentLabel.backgroundColor = UIColor.white
        contentLabel.font = UIFont.systemFont(ofSize: 14)
        contentLabel.textAlignment = .left
        contentLabel.textColor = UIColor.textColor
        // setting zero will grow with the label contents
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
            $0.height.equalTo(1).priority(.low) // priority
        }
        contentLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.top.equalTo(collectionView.snp.bottom)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }

    // delegate: update the hight of collectionView
    func getCollectionViewHeight(height: CGFloat) {
        collectionView.snp.updateConstraints {
            $0.height.equalTo(height + 8).priority(.low)
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: labelWidth(noteLabelArray[indexPath.item], 15, indexPath),
                      height: 15)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    func labelWidth(_ text: String, _ height: CGFloat, _ indexPath: IndexPath) -> CGFloat {
        let size = CGSize(width: 2000, height: height)
        let font = UIFont.systemFont(ofSize: 11)
        let attributes = [NSAttributedString.Key.font: font]
        let labelSize = NSString(string: text).boundingRect(
                                with: size,
                                options: .usesLineFragmentOrigin,
                                attributes: attributes,
                                context: nil)

        if indexPath.row == 0 && labelSize.width + 8 > collectionView.frame.width - 18 {
            return collectionView.frame.width - 20
        } else if indexPath.row > 0 && labelSize.width + 8 > collectionView.frame.width {
            return collectionView.frame.width
        }

        return labelSize.width + 8
    }
}
