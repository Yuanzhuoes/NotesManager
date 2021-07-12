//
//  WelcomViewController.swift
//  test
//
//  Created by 李远卓 on 2021/6/4.
//

import UIKit

class WelcomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let editButton = UIButton(type: .custom)
    let logOutButton = UIButton(type: .system)
    let bigEditButton = UIButton(type: .system)
    let searchBackground = UIView()
    let textSearch = UITextField()
    let tableView = UITableView()
    let editImageView = UIImageView()
    let editLabel = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        myUI()
        myConstraints()

        loadData { [weak self] in
            self?.tableView.reloadData()
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

    // 内容还未显示时强制更新布局可能会有bug 但不会卡顿
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // 会卡顿但没bug
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // 单元格行数 系统默认为1
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 如果没有数据 显示创建按钮
        guard let count = notes?.count else {
            print("database error rows")
            return 0
        }
        if count == 0 {
            bigEditButton.isHidden = false
        } else {
            bigEditButton.isHidden = true
        }
        return count
    }

    // 初始化和复用单元格
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 一定要向下转换为子类
        let cell = tableView.dequeueReusableCell(withIdentifier:
                                                    MyTableViewCell.description(),
                                                for: indexPath) as? MyTableViewCell
//        cell?.frame = tableView.bounds
        // Use this method to force the view to update its layout immediately.
        cell?.layoutIfNeeded()
        cell?.collectionView.reloadData()
//         单元格的内容显示
//         先从数据库载入标签 内容和状态 标签数据在自定义tabelview的collection进行可视化
        cell?.noteLabelArray = stringToArray(notes?[indexPath.row].tag)
        cell?.privateLabel.text = (notes?[indexPath.row].status == 1) ? "公" : "私"
        cell?.contentLabel.attributedText = notes?[indexPath.row].content
            .attributedString(lineSpaceing: 8, lineBreakModel: .byTruncatingTail)
        // cell 选中样式
        cell?.selectionStyle = .none
        return cell!
    }
    // 左滑删除按钮
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt
                    indexPath: IndexPath) -> UISwipeActionsConfiguration? {
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
                let userInfo = UserInfo(authorization: jwt, nid: id)
                requestAndResponse(userInfo: userInfo, function: .delete, method: .delete) { _ in
                    do {
                        // 删除数据库 缓存 UI
                        try DBManager.db?.deleteNote(nid: id)
                        notes?.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    } catch {
                        print(DBManager.db?.errorMessage as Any)
                    }
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
        // 搜索框的背景
        searchBackground.backgroundColor = MyColor.navigationColor
        // 搜索框 点击搜索框 隐藏导航栏 整体上移 图标居右 进入搜索页面
        textSearch.borderStyle = .roundedRect
        // 表格设置
        // 左右边距
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        // 去除多余下划线
        tableView.register(MyTableViewCell.self, forCellReuseIdentifier: MyTableViewCell.description())
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self

        // 添加顺序影响显示效果?
        self.view.addSubview(searchBackground)
        self.view.addSubview(textSearch)
        self.view.addSubview(tableView)
        self.view.addSubview(bigEditButton)
        bigEditButton.addSubview(editImageView)
        bigEditButton.addSubview(editLabel)
    }

    func myConstraints() {
        editButton.snp.makeConstraints { make in
            make.width.height.equalTo(16)
        }
        bigEditButton.snp.makeConstraints { make in
            make.width.equalTo(195)
            make.height.equalTo(88)
            make.centerX.equalToSuperview()
            make.top.equalTo(searchBackground.snp.bottom).offset(88)
        }
        editImageView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.centerX.equalTo(bigEditButton)
            make.top.equalTo(bigEditButton.snp.top).offset(12)
        }
        editLabel.snp.makeConstraints { make in
            make.centerX.equalTo(bigEditButton)
            make.top.equalTo(editImageView.snp.bottom).offset(12)
        }
        searchBackground.snp.makeConstraints { (make) in
            make.height.equalTo(56)
            make.width.top.leading.equalTo(self.view)
        }
        textSearch.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(searchBackground)
            make.height.equalTo(36)
            make.width.equalTo(searchBackground).offset(-16)
        }
        tableView.snp.makeConstraints { make in
            make.leading.width.height.equalToSuperview()
            make.top.equalTo(searchBackground.snp.bottom)
        }
    }

    @objc func showBubble() {
        let bubble = MyAlertController(title: "", message: "确定要退出登陆吗？", preferredStyle: .alert)
        let yes = UIAlertAction(title: "确定", style: .default) { _ in
            // 请求服务器
            // 如果成功 返回登陆界面
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

// MARK: -

extension WelcomeViewController {
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
            insertAllNotesToDB(notes: response)
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
