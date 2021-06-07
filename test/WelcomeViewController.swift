//
//  WelcomViewController.swift
//  test
//
//  Created by 李远卓 on 2021/6/4.
//

import UIKit
import Alamofire

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 隐藏当前视图的返回按钮 登入登出还有其他的解决方案吗
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        // 根视图背景设置，加入导航后，根视图是导航控制器，默认为黑色
        self.view.backgroundColor = UIColor.white
        // 1. 图标显示
        let LoginView = UIImageView(frame: CGRect(x:0, y:0, width:265, height: 128))
        LoginView.center.x = self.view.center.x
        LoginView.center.y = self.view.center.y * 7 / 10
        // 1.2.将图标贴在view上
        let image = UIImage(named: "WelcomeIcon")
        LoginView.image = image
        self.view.addSubview(LoginView)
        
        // 2. 登出按钮
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:"登出",style:UIBarButtonItem.Style.plain,target: self, action: #selector(WelcomeViewController.loginPage))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(red:142/255.0,green:142/255.0,blue:142/255.0,alpha: 1)
    }
    
    @objc func loginPage(){
        // 直接pop到根视图，即登陆界面
        self.navigationController?.popToRootViewController(animated: false)
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
