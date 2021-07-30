//
//  ViewController.swift
//  
//
//  Created by 李远卓 on 2021/7/29.
//

import UIKit

class SearchViewController: UIViewController {
    let searchView = SearchView()
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setDelegate()
    }
}

// collection cell
extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    // cell numbers
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SearchData.noteLabelArray.count
    }

    // cell content
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.description(), for: indexPath)
        if let cell = cell as? MyCollectionViewCell {
            cell.noteLabel.text = SearchData.noteLabelArray[indexPath.row]
        }
        return cell
    }
}

// collectionView flowLayout
extension SearchViewController: UICollectionViewDelegateFlowLayout {
    // compute size of cell, depending on font content width and given hight
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: labelWidth((SearchData.noteLabelArray[indexPath.item]), 15),
                      height: 15)
    }

    // line spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

// set coustom flowlayout of hight and row
extension SearchViewController: TagFlowLayoutDelegate {
    // max hight of collectionview
    func getCollectionViewHeightAndRows(height: CGFloat, row: Int) {
        if row >= 1 {
            searchView.collectionView.snp.updateConstraints { make in
                make.height.equalTo(height + 10)
            }
        }
    }
}

// UI
private extension SearchViewController {
    func setUI() {
        self.view.addSubview(searchView)
        searchView.setUI()
        setConstraints()
    }

    func setConstraints() {
        searchView.snp.makeConstraints {
            $0.top.bottom.width.height.equalToSuperview()
        }
    }

    func setDelegate() {
        searchView.scrollView.delegate = self
        searchView.collectionView.delegate = self
        searchView.tagLayOut.delegate = self
        searchView.collectionView.dataSource = self
    }
}

private extension SearchViewController {
    // compute width depending on font content and screen width
    func labelWidth(_ text: String, _ height: CGFloat) -> CGFloat {
        let size = CGSize(width: 2000, height: height)
        let font = UIFont.systemFont(ofSize: 11)
        let attributes = [NSAttributedString.Key.font: font]
        let labelSize = NSString(string: text).boundingRect(with: size,
                                options: .usesLineFragmentOrigin,
                                attributes: attributes, context: nil)

        // let max label size equal to screen width
        if labelSize.width + 8 > searchView.collectionView.frame.width {
            return searchView.collectionView.frame.width
        }

        return labelSize.width + 8
    }
}
