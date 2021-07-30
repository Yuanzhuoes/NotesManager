//
//  DispalyView.swift
//  test
//
//  Created by 李远卓 on 2021/7/28.
//

import UIKit
class DisplayView: UIView {
    let editButton = UIButton(type: .custom)
    let logOutButton = UIButton(type: .system)
    let bigEditButton = UIButton(type: .system)
    let tableView = UITableView()
    let editImageView = UIImageView()
    let editLabel = UILabel()
    let searchResultsLabel = UILabel()
    let searchController = UISearchController()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI () {
        setButton()
        setSearchBar()
        setTabelView()
        setLabel()
        setSubview()
        setConstraints()
    }

    func setSearchBar() {
        // 搜索框 点击搜索框 隐藏导航栏 整体上移 图标居右 进入搜索页面
        let searchBar = searchController.searchBar
        searchBar.placeholder = "搜索"
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.borderStyle = .none
        searchBar.searchTextField.backgroundColor = UIColor.white
        searchBar.barTintColor = UIColor.navigationColor
        searchBar.tintColor = UIColor.greenColor
        searchBar.searchTextField.clearButtonMode = .never
        // 全局修改
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
            .defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.textColor]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "取消"
        searchController.hidesNavigationBarDuringPresentation = true // 点击搜索栏隐藏导航栏
        searchController.obscuresBackgroundDuringPresentation = false // 展示结果时不变暗
    }

    func setButton() {
        logOutButton.setTitle("退出登录", for: .normal)
        logOutButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        logOutButton.tintColor = UIColor.logOutColor
        // 右导航按钮
        editButton.setImage(UIImage(named: "Edit")?.withTintColor(UIColor.greenColor, renderingMode: .automatic), for: .normal)
        // 编辑按钮视图
        editImageView.image = UIImage(named: "Edit")?.withTintColor(UIColor.grayColor, renderingMode: .automatic)
        editLabel.text = "去创建你的第一个笔记吧 >"
        editLabel.font = UIFont.systemFont(ofSize: 12)
        editLabel.textColor = UIColor.grayColor
    }

    func setLabel() {
        searchResultsLabel.text = "无搜索结果"
        searchResultsLabel.font = UIFont.systemFont(ofSize: 14)
        searchResultsLabel.textColor = UIColor.textColor
        searchResultsLabel.isHidden = SearchResults.hiddenMode
    }

    func setTabelView() {
        // 左右边距
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        // 去除多余下划线
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false
        tableView.register(MyTableViewCell.self, forCellReuseIdentifier: MyTableViewCell.description())
    }

    func setSubview() {
        // 添加顺序影响显示效果
        self.addSubview(tableView)
        self.addSubview(bigEditButton)
        self.addSubview(searchResultsLabel)
        bigEditButton.addSubview(editImageView)
        bigEditButton.addSubview(editLabel)
    }

    func setConstraints() {
        editButton.snp.makeConstraints {
            $0.width.height.equalTo(16)
        }
        bigEditButton.snp.makeConstraints {
            $0.width.equalTo(195)
            $0.height.equalTo(88)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(88)
        }
        editImageView.snp.makeConstraints {
            $0.width.height.equalTo(30)
            $0.centerX.equalTo(bigEditButton)
            $0.top.equalTo(bigEditButton.snp.top).offset(12)
        }
        editLabel.snp.makeConstraints {
            $0.centerX.equalTo(bigEditButton)
            $0.top.equalTo(editImageView.snp.bottom).offset(12)
        }
        tableView.snp.makeConstraints {
            $0.leading.width.height.equalToSuperview()
            $0.top.equalToSuperview()
        }
        searchResultsLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.centerX.equalToSuperview()
        }
    }
}
