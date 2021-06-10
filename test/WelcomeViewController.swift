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
        let LoginView = UIImageView()
        // 1.2.将图标贴在view上
        let image = UIImage(named: "WelcomeIcon")
        LoginView.image = image
        self.view.addSubview(LoginView)
        LoginView.translatesAutoresizingMaskIntoConstraints = false
        
        // 2. 登出按钮
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:"登出",style:UIBarButtonItem.Style.plain,target: self, action: #selector(WelcomeViewController.loginPage))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(red:142/255.0,green:142/255.0,blue:142/255.0,alpha: 1)
        
        // 约束
        LoginView.addConstraint(NSLayoutConstraint(item: LoginView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 265))
        LoginView.addConstraint(NSLayoutConstraint(item: LoginView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 128))
        self.view.addConstraint(NSLayoutConstraint(item: LoginView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: LoginView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 7 / 10, constant: 0))
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
