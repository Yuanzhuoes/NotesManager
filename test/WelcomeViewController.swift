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
    let editLable = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        // 导航栏设置
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
        editLable.text = "去创建你的第一个笔记吧 >"
        editLable.font = UIFont.systemFont(ofSize: 12)
        editLable.textColor = MyColor.grayColor
        bigEditButton.isHidden = true
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
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        self.view.addSubview(tableView)
        self.view.addSubview(searchBackground)
        self.view.addSubview(textSearch)
        self.view.addSubview(bigEditButton)
        bigEditButton.addSubview(editImageView)
        bigEditButton.addSubview(editLable)
        myConstraints()
    }
    // 单元格行数 默认为1
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 如果没有数据 显示创建按钮
        if dataSuorceArrary.count == 0 {
            bigEditButton.isHidden = false
        } else {
            bigEditButton.isHidden = true
        }
        return dataSuorceArrary.count
    }
    // cell高度 这个函数是先执行的 所以要先获取cell高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 返回label的高度
        return UITableView.automaticDimension
    }
    // 初始化和复用单元格
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "CellID"
        // 一定要转换
        var cell: MyTableViewCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? MyTableViewCell
        if cell == nil {
            // 创建cell
            cell = MyTableViewCell(style: .default, reuseIdentifier: identifier)
        }
        // 单元格的内容显示
        // 标签
        cell?.privateLable.text = "私"
        cell?.noteLable.text = "哈哈哈"
        // 文本
        cell?.textLable.attributedText = dataSuorceArrary[indexPath.row]
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
                // 请求服务器
                // success 删除本地笔记
                // failure 气泡提示删除失败
                dataSuorceArrary.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
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
    func myConstraints() {
        // 约束
        editButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(16)
        }
        bigEditButton.snp.makeConstraints { (make) in
            make.width.equalTo(195)
            make.height.equalTo(88)
            make.centerX.equalTo(self.view)
            make.top.equalTo(searchBackground.snp.bottom).offset(88)
        }
        editImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(30)
            make.centerX.equalTo(bigEditButton)
            make.top.equalTo(bigEditButton.snp.top).offset(12)
        }
        editLable.snp.makeConstraints { (make) in
            make.centerX.equalTo(bigEditButton)
            make.top.equalTo(editImageView.snp.bottom).offset(12)
        }
        searchBackground.snp.makeConstraints { (make) in
            make.height.equalTo(56)
            make.width.top.equalTo(self.view)
        }
        textSearch.snp.makeConstraints { (make) in
            make.centerX.centerY.equalTo(searchBackground)
            make.height.equalTo(36)
            make.width.equalTo(searchBackground).offset(-16)
        }
        tableView.snp.makeConstraints { make in
            make.width.height.equalTo(self.view)
            make.top.equalTo(searchBackground.snp.bottom)
        }
    }
    @objc func showBubble() {
        let bubble = MyAlertController(title: "", message: "确定要退出登陆吗？", preferredStyle: .alert)
        let yes = UIAlertAction(title: "确定", style: .default) { _ in
            // 请求服务器
            // 如果成功 返回登陆界面
            self.loginPage()
        }
        let cancel = UIAlertAction(title: "取消", style: .default, handler: nil)
        bubble.addAction(yes)
        bubble.addAction(cancel)
        self.present(bubble, animated: true, completion: nil)
    }
    @objc func loginPage() {
        // 请求服务器
        self.navigationController?.popToRootViewController(animated: false)
        let bubble = UIAlertController(title: "", message: "已登出", preferredStyle: .alert)
        self.present(bubble, animated: true, completion: nil)
        // 气泡显示延时消失
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            bubble.dismiss(animated: true, completion: nil)
        })
    }
    @objc func createNotes() {
        // 转入创建笔记页面
        print("ok")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
