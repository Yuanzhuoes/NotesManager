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
                self?.displayView.tableView.reloadData()
            }
        }
    }
}

// set tableView
extension DisplayViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // change datasource when search bar is active
        if displayView.searchController.isActive {
            displayView.bigEditButton.isHidden = true
            displayView.searchResultsLabel.isHidden = SearchResults.hiddenMode
            return SearchResults.noteArray.count
        } else {
            displayView.searchResultsLabel.isHidden = SearchResults.hiddenMode
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

    // init tabelview cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // init a not reusable new cell to avoid hight update error?
        guard let cell = tableView.dequeueReusableCell(withIdentifier:
                                                        MyTableViewCell.description(),
                                                        for: indexPath) as? MyTableViewCell
        else {
            return MyTableViewCell(style: .default, reuseIdentifier: "cell")
        }

        cell.selectionStyle = .none

        cell.layoutIfNeeded()
        cell.collectionView.reloadData()

        if displayView.searchController.isActive {
            cell.noteLabelArray = SearchResults.noteArray[indexPath.row].tag.array
            cell.privateLabel.text = SearchResults.noteArray[indexPath.row].status.intToString
            cell.contentLabel.attributedText = SearchResults.noteArray[indexPath.row].content
                .attributedString(lineSpaceing: 8, lineBreakModel: .byTruncatingTail)
        } else {
            if let notesLabelArray = notes?[indexPath.row].tag.array {
                cell.noteLabelArray = notesLabelArray
            } else {
                cell.noteLabelArray = []
            }
            cell.privateLabel.text = notes?[indexPath.row].status.intToString
            cell.contentLabel.attributedText = notes?[indexPath.row].content
                .attributedString(lineSpaceing: 8, lineBreakModel: .byTruncatingTail)
        }

        return cell
    }

    // delete action
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt
                    indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // set bubble
        let hander: (UIAlertAction) -> Void = {_ in
            guard let id = notes?[indexPath.row].id else {
                return
            }
            self.deleteNote(id: id, row: indexPath.row) {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
        let bubble = MyAlertController.setBubble(title: "", message: "确定要删除该笔记吗？", action: true, yesHander: hander)

        // set delete action
        if displayView.searchController.isActive {
            return UISwipeActionsConfiguration()
        } else {
            let deleteAction = UIContextualAction(style: .normal, title: "删除") { (_, _, completionHandler) in
                self.presentBubble(bubble)
                completionHandler(true)
            }
            deleteAction.backgroundColor = UIColor.deleteColor

            // return configure
            let configure = UISwipeActionsConfiguration(actions: [deleteAction])
            configure.performsFirstActionWithFullSwipe = false

            return configure
        }
    }

    // select tableview cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = EditNoteViewController()

        if displayView.searchController.isActive {
            let searchNote = SearchResults.noteArray[indexPath.row]
            let myNote = try? DBManager.db?.queryNote(nid: searchNote.id)

            if let myNote = myNote {
                configureMyNotePage(viewController: viewController, note: myNote)
            // 不是则只显示不能编辑
            } else {
                let viewController = SearchViewController()
                configureOthersSearchNotePage(viewController: viewController, note: searchNote)
                self.navigationController?.pushViewController(viewController, animated: false)
                displayView.searchController.isActive = false
                return
            }
        // update
        } else {
            guard let myNote = notes?[indexPath.row] else {
                return
            }
            configureMyNotePage(viewController: viewController, note: myNote)
        }

        self.navigationController?.pushViewController(viewController, animated: false)
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
                // 如果没有搜索结果 显示标签 否则 隐藏
                SearchResults.hiddenMode = serverDescription.pagination?.total == 0 ? false : true
                // 如果没有搜索结果 或者 没有输入，清空缓存，reload data
                if serverDescription.pagination?.total == 0 || searchController.searchBar.searchTextField.text == "" {
                    SearchResults.noteArray.removeAll()
                } else {
                    SearchResults.noteArray.removeAll()
                    guard let items = serverDescription.items else {
                        print("items is nil, but souldn't to be")
                        return
                    }
                    for item in items {
                        guard let id = item.id, let tag = item.title, let content = item.content else {
                            return
                        }
                        // search results of isPublic are always nil ?
                        guard let status = (item.isPublic == true) ? 1 : 0 else {
                            return
                        }
                        SearchResults.noteArray.append(SQLNote(id: id, tag: tag, content: content, status: status))
                        // 将搜索关键字放在最前面
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
        navigationItem.searchController = displayView.searchController
    }

    func setConstrains() {
        displayView.snp.makeConstraints {
            $0.bottom.top.leading.width.height.equalToSuperview()
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
        EditData.noteLabelArray = []
        let viewController = EditNoteViewController()
        viewController.onSave = { [weak self] in
            self?.displayView.tableView.reloadData()
            DispatchQueue.main.async {
                self?.displayView.tableView.reloadData()
            }
        }
        viewController.title = "新建笔记"
        self.navigationController?.pushViewController(viewController, animated: false)
    }

    func configureMyNotePage(viewController: EditNoteViewController, note: SQLNote) {
        viewController.editView.textLabelView.text = note.tag
        viewController.editView.textContenView.text = note.content
        EditData.noteLabelArray = note.tag.array
        EditData.nid = note.id
        EditData.segmentIndex = note.status
        viewController.title = "我的搜记"
    }

    func configureOthersSearchNotePage(viewController: SearchViewController, note: SQLNote) {
        SearchData.noteLabelArray = note.tag.array
        viewController.searchView.textContenView.text = note.content
        viewController.title = "搜记"
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
