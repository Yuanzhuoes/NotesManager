//
//  WelcomViewController.swift
//  test
//
//  Created by 李远卓 on 2021/6/4.
//

import UIKit

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 1. 图标显示
        let LoginView = UIImageView(frame: CGRect(x:0, y:0, width:265, height: 128))
        LoginView.center.x = self.view.center.x
        LoginView.center.y = self.view.center.y * 7 / 10
        // 1.2.将图标贴在view上
        let image = UIImage(named: "WelcomeIcon")
        LoginView.image = image
        self.view.addSubview(LoginView)
        
        // 2. 登出按钮
        let logoutButton = UIButton(type: .system)
        logoutButton.frame = CGRect(x:295, y:30, width:88, height:44)
        logoutButton.setTitle("登出", for: .normal)
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        logoutButton.setTitleColor(UIColor(red:142/255.0,green:142/255.0,blue:142/255.0,alpha: 1), for: .normal)
        self.view.addSubview(logoutButton)
        // 3.1.2 点击登出按钮返回登陆界面
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
