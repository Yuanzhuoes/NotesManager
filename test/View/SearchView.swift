//
//  SearchView.swift
//  test
//
//  Created by 李远卓 on 2021/7/29.
//

import UIKit

class SearchView: UIView {
    // TODO: remove content view
    let contentView = UIView()
    let scrollView = UIScrollView()
    let tagLayOut = TagFlowLayout()
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: tagLayOut)
    let screenFrame = UIScreen.main.bounds
    let textContenView = UITextView()

    func setUI() {
        setScrollView()
        setCollectionView()
        setTextContentView()
        setSubview()
        setConstrain()
    }

    private func setScrollView() {
        // scroll view, display area
        scrollView.frame = screenFrame
        scrollView.showsVerticalScrollIndicator = false
    }

    private func setTextContentView() {
        // textContentView
        textContenView.font = UIFont.systemFont(ofSize: 15)
        textContenView.textColor = UIColor.textColor
        textContenView.tintColor = UIColor.greenColor
        textContenView.showsVerticalScrollIndicator = false
        textContenView.isEditable = false
    }

    private func setCollectionView() {
        collectionView.backgroundColor = UIColor.white
        collectionView.register(MyCollectionViewCell.self,
                                forCellWithReuseIdentifier:
                                MyCollectionViewCell.description())
        collectionView.isScrollEnabled = false
    }

    private func setSubview() {
        self.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(collectionView)
        contentView.addSubview(textContenView)
    }

    private func setConstrain() {
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalToSuperview()
        }
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.height.equalTo(25)
        }
        textContenView.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom)
            $0.left.right.equalTo(collectionView)
            $0.bottom.equalTo(0)
        }
    }
}
