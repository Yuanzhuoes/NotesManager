//
//  EditView.swift
//  test
//
//  Created by 李远卓 on 2021/7/28.
//

import UIKit

class EditView: UIView {
    let contentView = UIView()
    let scrollView = UIScrollView()
    let tagLayOut = TagFlowLayout()
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: tagLayOut)
    let saveButton = UIButton(type: .system)
    let statusLabel = UILabel()
    var statusSegment = UISegmentedControl()
    let labelLine = UIView()
    let contentLine = UIView()
    let screenFrame = UIScreen.main.bounds
    let textLabelView = TextViewWithPlacehodler(holder: "请输入标签，示例：标签/标签")
    let textContenView = TextViewWithPlacehodler(holder: "请输入搜记内容")

    func setStatusLabel() {
        // 状态标签
        statusLabel.text = "状态"
        statusLabel.font = UIFont.systemFont(ofSize: 15)
        statusLabel.textColor = UIColor.grayColor
    }

    func setStatusSegment() {
        // 状态选择
        statusSegment = UISegmentedControl(items: ["私有", "公开"])
        statusSegment.backgroundColor = UIColor.segmentColor
        statusSegment.selectedSegmentTintColor = UIColor.greenColor
        statusSegment.setTitleTextAttributes([.foregroundColor: UIColor.grayColor], for: .normal)
        statusSegment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        statusSegment.selectedSegmentIndex = 0
        // statusSegment.selectedSegmentIndex = 0
    }

    func setScrollView() {
        // scroll view, display area
        scrollView.frame = screenFrame
        scrollView.showsVerticalScrollIndicator = false
    }

    func setTextLabelView() {
        // textLabelView
        textLabelView.font = UIFont.systemFont(ofSize: 15)
        textLabelView.isScrollEnabled = false
        textLabelView.textColor = UIColor.textColor
        textLabelView.tintColor = UIColor.greenColor
    }

    func setTextContentView() {
        // textContentView
        textContenView.font = UIFont.systemFont(ofSize: 15)
        textContenView.textColor = UIColor.textColor
        textContenView.tintColor = UIColor.greenColor
    }

    func setCollectionView() {
        collectionView.backgroundColor = UIColor.white
        collectionView.register(MyCollectionViewCell.self,
                                forCellWithReuseIdentifier:
                                MyCollectionViewCell.description())
        collectionView.isScrollEnabled = false
    }

    func setLine() {
        labelLine.backgroundColor = UIColor.grayColor
        contentLine.backgroundColor = UIColor.grayColor
    }

    func setSubview() {
        self.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(statusLabel)
        contentView.addSubview(statusSegment)
        contentView.addSubview(textLabelView)
        contentView.addSubview(collectionView)
        contentView.addSubview(textContenView)
        contentView.addSubview(labelLine)
        contentView.addSubview(contentLine)
    }

    func setConstrain() {
        contentView.snp.makeConstraints {
            // edge
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalToSuperview().offset(400)
        }
        statusLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.left.equalToSuperview().offset(16)
        }
        statusSegment.snp.makeConstraints {
            $0.width.equalTo(72)
            $0.height.equalTo(22)
            $0.top.equalToSuperview().offset(12)
            $0.right.equalToSuperview().offset(-16)
        }
        textLabelView.snp.makeConstraints {
            $0.top.equalTo(statusLabel.snp.bottom).offset(12)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
        }
        labelLine.snp.makeConstraints {
            $0.top.left.width.equalTo(textLabelView)
            $0.height.equalTo(0.2)
        }
        contentLine.snp.makeConstraints {
            $0.top.left.width.equalTo(textContenView)
            $0.height.equalTo(0.2)
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(textLabelView.snp.bottom)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.height.equalTo(43)
        }
        textContenView.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom)
            $0.left.right.equalTo(collectionView)
            $0.bottom.equalTo(0)
        }
    }

    func setUI() {
        setScrollView()
        setStatusLabel()
        setStatusSegment()
        setLine()
        setCollectionView()
        setTextContentView()
        setTextLabelView()
        setSubview()
        setConstrain()
    }
}
