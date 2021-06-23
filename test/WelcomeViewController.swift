//
//  WelcomViewController.swift
//  test
//
//  Created by 李远卓 on 2021/6/4.
//

import UIKit

class WelcomeViewController: UIViewController {

    let bubble = UIAlertController(title: "", message: "已登出", preferredStyle: .alert)
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // 隐藏当前视图的返回按钮吗？
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.view.backgroundColor = UIColor.white
        // 导航栏颜色
        self.navigationController?.navigationBar.backgroundColor = MyColor.navigationColor
        // 登出按钮
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "退出登录", style: UIBarButtonItem.Style.plain,
                                                                 target: self,
                                                                 action: #selector(WelcomeViewController.loginPage))
        self.navigationItem.leftBarButtonItem?.tintColor = MyColor.logOutColor
        // 创建按钮
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "退出登录", style: UIBarButtonItem.Style.plain,
                                                                 target: self,
                                                                 action: #selector(WelcomeViewController.loginPage))
        self.navigationItem.rightBarButtonItem?.tintColor = MyColor.logOutColor
    }
    @objc func loginPage() {
        self.navigationController?.popToRootViewController(animated: false)
        // 气泡显示延时消失
        self.present(bubble, animated: true, completion: nil)
        self.perform(#selector(dismissHelper), with: bubble, afterDelay: 1.0)
    }
    @objc func dismissHelper() {
        bubble.dismiss(animated: true, completion: nil)
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
