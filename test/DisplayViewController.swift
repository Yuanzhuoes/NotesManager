//
//  WelcomViewController.swift
//  test
//
//  Created by 李远卓 on 2021/6/4.
//

import UIKit

class DisplayViewController: UIViewController {
    let editButton = UIButton(type: .custom)
    let logOutButton = UIButton(type: .system)
    let bigEditButton = UIButton(type: .system)
    let tableView = UITableView()
    let editImageView = UIImageView()
    let editLabel = UILabel()
    let searchController = UISearchController()
    var searchResults = [SQLNote]()
    var pendingRequestWorkItem: DispatchWorkItem?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        myUI()
        myConstraints()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData { [weak self] in
            self?.tableView.reloadData()
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    func myUI () {
        self.view.backgroundColor = UIColor.white
        // 导航栏设置
        self.title = ""
        // 不透明，view.top下移
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = MyColor.navigationColor
        // 左导航按钮
        logOutButton.setTitle("退出登录", for: .normal)
        logOutButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        logOutButton.tintColor = MyColor.logOutColor
        logOutButton.addTarget(self, action: #selector(showBubble), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: logOutButton)
        // 右导航按钮
        editButton.setImage(UIImage(named: "Edit")?.withTintColor(MyColor.greenColor, renderingMode: .automatic), for: .normal)
        editButton.addTarget(self, action: #selector(createNotes), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editButton)
        // 编辑按钮
        editImageView.image = UIImage(named: "Edit")?.withTintColor(MyColor.grayColor, renderingMode: .automatic)
        editLabel.text = "去创建你的第一个笔记吧 >"
        editLabel.font = UIFont.systemFont(ofSize: 12)
        editLabel.textColor = MyColor.grayColor
        // 编辑按钮的响应
        bigEditButton.addTarget(self, action: #selector(createNotes), for: .touchUpInside)
//         搜索框 点击搜索框 隐藏导航栏 整体上移 图标居右 进入搜索页面
        let searchBar = searchController.searchBar
        searchBar.placeholder = "搜索"
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.borderStyle = .none
        searchBar.searchTextField.backgroundColor = UIColor.white
        searchBar.barTintColor = MyColor.navigationColor
        searchBar.tintColor = MyColor.greenColor
        searchBar.searchTextField.clearButtonMode = .never
        // 全局修改
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
            .defaultTextAttributes = [NSAttributedString.Key.foregroundColor: MyColor.textColor]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "取消"
        // 搜索控制器设置
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        searchController.hidesNavigationBarDuringPresentation = true // 点击搜索栏隐藏导航栏
        searchController.obscuresBackgroundDuringPresentation = false // 展示结果时不变暗
        searchController.searchResultsUpdater = self
        // 表格设置
        // 左右边距
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        // 去除多余下划线
        tableView.register(MyTableViewCell.self, forCellReuseIdentifier: MyTableViewCell.description())
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        // 添加顺序影响显示效果?
        self.view.addSubview(tableView)
        self.view.addSubview(bigEditButton)
        bigEditButton.addSubview(editImageView)
        bigEditButton.addSubview(editLabel)
    }
    func myConstraints() {
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
    }
    @objc func showBubble() {
        let bubble = MyAlertController(title: "", message: "确定要退出登陆吗？", preferredStyle: .alert)
        let yes = UIAlertAction(title: "确定", style: .default) { _ in
            self.loginOut()
        }
        let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
        bubble.addAction(yes)
        bubble.addAction(cancel)
        self.present(bubble, animated: true, completion: nil)
    }

    @objc func loginOut() {
        // 获取jwt
        let jwt = userDefault.string(forKey: UserDefaultKeys.AccountInfo.jwt.rawValue)
        let userInfo = UserInfo(authorization: jwt)
        // 请求服务器
        requestAndResponse(userInfo: userInfo, function: .logout, method: .post) { _ in
            // 删除本地token
            userDefault.removeObject(forKey: UserDefaultKeys.AccountInfo.jwt.rawValue)
            self.navigationController?.popToRootViewController(animated: false)
            let bubble = UIAlertController(title: "", message: "已登出", preferredStyle: .alert)
            self.present(bubble, animated: true, completion: nil)
            // 气泡显示延时消失
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                bubble.dismiss(animated: true, completion: nil)
            })
        }
    }
    @objc func createNotes() {
        // 转入创建笔记页面
        let viewController = CreateNoteViewController()
        viewController.onSave = { [weak self] in
            self?.tableView.reloadData()
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension DisplayViewController: UITableViewDataSource, UITableViewDelegate {
    // 单元格行数 系统默认为1
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 如果没有数据 显示创建按钮
        if searchController.isActive {
            return searchResults.count
        } else {
            guard let count = notes?.count else {
                return 0
            }
            if count == 0 {
                bigEditButton.isHidden = false
            } else {
                bigEditButton.isHidden = true
            }
            return count
        }
    }
    // 初始化和复用单元格
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:
                                                MyTableViewCell.description(),
                                                for: indexPath) as? MyTableViewCell
        if searchController.isActive {
            cell?.layoutIfNeeded()
            cell?.collectionView.reloadData()
            cell?.noteLabelArray = searchResults[indexPath.row].tag.array
            cell?.privateLabel.text = searchResults[indexPath.row].status.intToString
            cell?.contentLabel.attributedText = searchResults[indexPath.row].content
                .attributedString(lineSpaceing: 8, lineBreakModel: .byTruncatingTail)
            cell?.selectionStyle = .none
            return cell!
        } else {
            cell?.layoutIfNeeded()
            cell?.collectionView.reloadData()
            if let notesLabelArray = notes?[indexPath.row].tag.array {
                cell?.noteLabelArray = notesLabelArray
            } else {
                cell?.noteLabelArray = []
            }
            cell?.privateLabel.text = notes?[indexPath.row].status.intToString
            cell?.contentLabel.attributedText = notes?[indexPath.row].content
                .attributedString(lineSpaceing: 8, lineBreakModel: .byTruncatingTail)
            // cell 选中样式
            cell?.selectionStyle = .none
            return cell!
        }
    }
    // 左滑删除按钮
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt
                    indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if !searchController.isActive {
            let deleteAction = UIContextualAction(style: .normal, title: "删除") { (_, _, completionHandler) in
                // 气泡 有空封装
                let bubble = MyAlertController(title: "", message: "确定要删除该笔记吗？", preferredStyle: .alert)
                // 气泡的两个按钮
                let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
                let yes = UIAlertAction(title: "确定", style: .default) { _ in
                    // 请求服务器 先获取笔记id和用户jwt
                    guard let id = notes?[indexPath.row].id else {
                        print("Error: id is nil")
                        return
                    }
                    let jwt = userDefault.string(forKey: UserDefaultKeys.AccountInfo.jwt.rawValue)
                    let userInfo = UserInfo(authorization: jwt!, nid: id)
                    requestAndResponse(userInfo: userInfo, function: .delete, method: .delete) { _ in
                        try? DBManager.db?.deleteNote(nid: id)
                        notes?.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                }
                bubble.addAction(yes)
                bubble.addAction(cancel)
                self.present(bubble, animated: true, completion: nil)
                // 需要返回true，否则没有反应
                completionHandler(true)
            }
            deleteAction.backgroundColor = MyColor.deleteColor
            let config = UISwipeActionsConfiguration(actions: [deleteAction])
            // 取消拉太长后自动删除
            config.performsFirstActionWithFullSwipe = false
            return config
        } else {
            return UISwipeActionsConfiguration()
        }
    }
    // 选择单元格
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 进入我的搜记页面
        // if else?
        guard let myNote = notes?[indexPath.row] else {
            return
        }
        let viewController = UpdataNoteViewController()
        viewController.textLabelView.text = myNote.tag
        viewController.noteLabelArray = myNote.tag.array
        viewController.textContenView.text = myNote.content
        viewController.nid = myNote.id
        // 状态标签怎么传
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
extension DisplayViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        pendingRequestWorkItem?.cancel()
        let jwt = userDefault.string(forKey: UserDefaultKeys.AccountInfo.jwt.rawValue)
        let userInfo = UserInfo(authorization: jwt)
        let requestWorkItem = DispatchWorkItem { [self] in
            requestAndResponse(userInfo: userInfo,
                               function: .search,
                               method: .get,
                               searchText: searchController.searchBar.text) { [self] serverDescription in
                // 如果没有搜索结果 或者 没有输入，清空缓存，reload data
                if serverDescription.pagination?.total == 0 || searchController.searchBar.searchTextField.text == "" {
                    searchResults.removeAll()
                } else {
                    guard let items = serverDescription.items else {
                        print("items is nil, but couldn't be")
                        return
                    }
                    searchResults.removeAll()
                    for item in items {
                        guard let id = item.id, let tag = item.title, let content = item.content else {
                            return
                        }
                        guard let status = (item.isPublic == true) ? 1 : 0 else {
                            return
                        }
                        searchResults.append(SQLNote(id: id, tag: tag, content: content, status: status))
                    }
                }
                loadData { [weak self] in
                    self?.tableView.reloadData()
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
            }
        }
        pendingRequestWorkItem = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: requestWorkItem)
    }
}
extension DisplayViewController: UISearchControllerDelegate {
}
// MARK: -
extension DisplayViewController {
    // trailing closure
    func loadData(_ closure: (() -> Void)?) {
        // 请求网络获取所有笔记
        let jwt = userDefault.string(forKey: UserDefaultKeys.AccountInfo.jwt.rawValue)
        let userInfo = UserInfo(authorization: jwt)
        requestAndResponse(userInfo: userInfo, function: .getAllNotes, method: .get) { serverDescription in
            guard let response = serverDescription.items else {
                print("error download notes")
                return
            }
            // 写入数据库
            DBManager.db?.insertAllNotesToDB(notes: response)
            // 读取所有笔记到缓存
            do {
                notes = try DBManager.db?.queryAllSQLNotes()
            } catch {
                print(DBManager.db?.errorMessage as Any)
            }
            DispatchQueue.main.async {
                closure?()
            }
        }
    }
}
