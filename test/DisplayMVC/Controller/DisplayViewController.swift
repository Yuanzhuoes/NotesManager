//
//  WelcomViewController.swift
//  test
//
//  Created by 李远卓 on 2021/6/4.
//

import UIKit

class DisplayViewController: UIViewController {
    private let displayView = DisplayView()
    private var searchResults = SearchResults()
    private var pendingRequestWorkItem: DispatchWorkItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUI()
        addTarget()
        setDelegate()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData { [weak self] in
            self?.displayView.tableView.reloadData()
            DispatchQueue.main.async {
                self?.displayView.tableView.reloadData()
            }
        }
    }
}

// set tableView
extension DisplayViewController: UITableViewDataSource, UITableViewDelegate {
    // 单元格行数 系统默认为1
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 如果搜索栏激活，数据源用searchResults, 并且隐藏编辑标签
        if displayView.searchController.isActive {
            displayView.bigEditButton.isHidden = true
            return searchResults.noteArray.count
        } else {
            guard let count = notes?.count else {
                return 0
            }
            if count == 0 {
                displayView.bigEditButton.isHidden = false
            } else {
                displayView.bigEditButton.isHidden = true
            }
            return count
        }
    }

    // 初始化和复用单元格
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:
                                                MyTableViewCell.description(),
                                                for: indexPath) as? MyTableViewCell
        cell?.selectionStyle = .none
        cell?.layoutIfNeeded()
        cell?.collectionView.reloadData()

        if displayView.searchController.isActive {
            cell?.noteLabelArray = searchResults.noteArray[indexPath.row].tag.array
            cell?.privateLabel.text = searchResults.noteArray[indexPath.row].status.intToString
            cell?.contentLabel.attributedText = searchResults.noteArray[indexPath.row].content
                .attributedString(lineSpaceing: 8, lineBreakModel: .byTruncatingTail)
        } else {
            if let notesLabelArray = notes?[indexPath.row].tag.array {
                cell?.noteLabelArray = notesLabelArray
            } else {
                cell?.noteLabelArray = []
            }
            cell?.privateLabel.text = notes?[indexPath.row].status.intToString
            cell?.contentLabel.attributedText = notes?[indexPath.row].content
                .attributedString(lineSpaceing: 8, lineBreakModel: .byTruncatingTail)
        }

        return cell!
    }

    // 左滑删除按钮
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt
                    indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 设置气泡
        let hander: (UIAlertAction) -> Void = {_ in
            guard let id = notes?[indexPath.row].id else {
                return
            }
            self.deleteNote(id: id, row: indexPath.row) {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
        let bubble = MyAlertController.setBubble(title: "", message: "确定要删除该笔记吗？", action: true, yesHander: hander)

        // 删除
        if displayView.searchController.isActive {
            return UISwipeActionsConfiguration()
        } else {
            // 设置删除动作
            let deleteAction = UIContextualAction(style: .normal, title: "删除") { (_, _, completionHandler) in
                self.presentBubble(bubble)
                completionHandler(true)
            }
            deleteAction.backgroundColor = UIColor.deleteColor

            // 返回删除设置
            let configure = UISwipeActionsConfiguration(actions: [deleteAction])
            configure.performsFirstActionWithFullSwipe = false

            return configure
        }
    }

    // 选择单元格
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 进入笔记显示页面
        let viewController = EditNoteViewController()

        if displayView.searchController.isActive {
            let searchNote = searchResults.noteArray[indexPath.row]
            let myNote = try? DBManager.db?.queryNote(nid: searchNote.id)
            // 判断笔记是不是我的
            if let myNote = myNote {
                viewController.editView.textLabelView.text = myNote.tag
                viewController.editView.textContenView.text = myNote.content
                viewController.editData.noteLabelArray = myNote.tag.array
                viewController.editData.nid = myNote.id
                viewController.title = "我的搜记"
            // 不是则只显示不能编辑
            } else {
                viewController.editView.textLabelView.text = searchNote.tag
                viewController.editData.noteLabelArray = searchNote.tag.array
                viewController.editView.textContenView.text = searchNote.content
                viewController.title = "搜记"
            }
        // 进入我的搜记页面 传nid更新
        } else {
            guard let myNote = notes?[indexPath.row] else {
                return
            }
            viewController.editView.textLabelView.text = myNote.tag
            viewController.editData.noteLabelArray = myNote.tag.array
            viewController.editView.textContenView.text = myNote.content
            viewController.editData.nid = myNote.id
            viewController.title = "我的搜记"
            // 状态标签怎么传
        }

        self.navigationController?.pushViewController(viewController, animated: true)
        // 点击搜索列表并且跳转后禁用searchBar, 写在这里动画是最流畅的
        displayView.searchController.isActive = false
    }
}

// search
extension DisplayViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        pendingRequestWorkItem?.cancel()

        let jwt = userAccount.string(forKey: UserDefaultKeys.AccountInfo.jwt.rawValue)
        let userInfo = UserInfo(authorization: jwt)
        let requestWorkItem = DispatchWorkItem { [self] in
            requestAndResponse(userInfo: userInfo,
                               function: .search,
                               method: .get,
                               searchText: searchController.searchBar.text) { [self] serverDescription in
                // 如果没有搜索结果 或者 没有输入，清空缓存，reload data
                if serverDescription.pagination?.total == 0 || searchController.searchBar.searchTextField.text == "" {
                    searchResults.noteArray.removeAll()
                } else {
                    guard let items = serverDescription.items else {
                        print("items is nil, but souldn't to be")
                        return
                    }
                    searchResults.noteArray.removeAll()
                    for item in items {
                        guard let id = item.id, let tag = item.title, let content = item.content else {
                            return
                        }
                        guard let status = (item.isPublic == true) ? 1 : 0 else {
                            return
                        }
                        searchResults.noteArray.append(SQLNote(id: id, tag: tag, content: content, status: status))
                    }
                }
                loadData { [weak self] in
                    self?.displayView.tableView.reloadData()
                    DispatchQueue.main.async {
                        self?.displayView.tableView.reloadData()
                    }
                }
            }
        }
        pendingRequestWorkItem = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: requestWorkItem)
    }
}

// UI
private extension DisplayViewController {
    func setUI() {
        self.view.addSubview(displayView)
        setNavigationBar()
        displayView.setUI()
        setConstrains()
    }

    func setNavigationBar() {
        self.view.backgroundColor = UIColor.white
        self.title = ""
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.navigationColor
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: displayView.logOutButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: displayView.editButton)
        // set searchbar
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController =  displayView.searchController
    }

    func setConstrains() {
        displayView.snp.makeConstraints {
            $0.bottom.top.width.height.equalToSuperview()
        }
    }

    func addTarget() {
        displayView.bigEditButton.addTarget(self, action: #selector(createNotes), for: .touchUpInside)
        displayView.logOutButton.addTarget(self, action: #selector(showBubble), for: .touchUpInside)
        displayView.editButton.addTarget(self, action: #selector(createNotes), for: .touchUpInside)
    }

    func setDelegate() {
        displayView.tableView.dataSource = self
        displayView.tableView.delegate = self
        displayView.searchController.searchResultsUpdater = self
    }

}

// UI response
private extension DisplayViewController {
    func deleteUserDefaulte() {
        userAccount.removeObject(forKey: UserDefaultKeys.AccountInfo.jwt.rawValue)
    }

    func presentLoginPage() {
        self.navigationController?.popToRootViewController(animated: false)
        let bubble = MyAlertController.setBubble(title: "", message: "已登出", action: false)
        presentBubbleAndDismiss(bubble)
    }

    func presentEditPage() {
        let viewController = EditNoteViewController()
        viewController.onSave = { [weak self] in
            self?.displayView.tableView.reloadData()
            DispatchQueue.main.async {
                self?.displayView.tableView.reloadData()
            }
        }
        viewController.title = "新建笔记"
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

// target
private extension DisplayViewController {
    @objc func showBubble() {
        let bubble = MyAlertController.setBubble(title: "", message: "确定要退出登陆吗？", action: true, yesHander: { _ in
        self.loginOut() })
        presentBubble(bubble)
    }

    @objc func loginOut() {
        // get jwt
        let jwt = userAccount.string(forKey: UserDefaultKeys.AccountInfo.jwt.rawValue)
        let userInfo = UserInfo(authorization: jwt)
        logoutRequest(userInfo: userInfo) { _ in
            self.deleteUserDefaulte()
            self.presentLoginPage()
        }
    }

    @objc func createNotes() {
        presentEditPage()
    }
}
