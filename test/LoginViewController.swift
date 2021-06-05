//
//  ViewController.swift
//  test
//
//  Created by 李远卓 on 2021/6/1.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var textName:UITextField!
    var textPassWord:UITextField!
    let loginButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        //父类初始化
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 导航控制器设置
        self.view.backgroundColor = UIColor.white
        // 当前页和返回页字符不显示
        self.title = ""
        // 右按钮内容，颜色，响应设置
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:"立即注册",style:UIBarButtonItem.Style.plain,target: self, action: #selector(LoginViewController.registerPage))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(red:54/255.0,green:181/255.0,blue:157/255.0,alpha: 1)
        // 返回按钮颜色设置
        self.navigationController?.navigationBar.tintColor = UIColor(red:54/255.0,green:181/255.0,blue:157/255.0,alpha: 1)
        // 全透明设置
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.shadowImage = UIImage()
        //字体大小设置？
        
        // 1.墨墨mind图标显示 封装？
        // 1.1.先将view居中再向上平移，位置，适配？
        let LoginView = UIImageView(frame: CGRect(x:0, y:0, width:209, height: 64))
        LoginView.center.x = self.view.center.x
        LoginView.center.y = self.view.center.y / 2
        // 1.2.将图标贴在view上
        let image = UIImage(named: "LoginIcon")
        LoginView.image = image
        self.view.addSubview(LoginView)
        
        // 2.文本输入框
        // 2.1 用户邮箱输入
        textName = UITextField(frame: CGRect(x:0,y:0,width:297,height:44))
        textName.center.x = LoginView.center.x
        textName.center.y = LoginView.center.y + 102
        textName.borderStyle = UITextField.BorderStyle.roundedRect
        textName.placeholder = "请输入邮箱"
        textName.returnKeyType = UIReturnKeyType.done // ?
        textName.clearButtonMode = UITextField.ViewMode.never // 编辑时显示删除图标
        textName.keyboardType = UIKeyboardType.emailAddress // 键盘类型为邮箱
        
        // 2.2 用户密码输入
        textPassWord = UITextField(frame: CGRect(x:0,y:0,width:297,height:44))
        textPassWord.center = self.view.center
        textPassWord.center.y = textName.center.y + 54
        textPassWord.borderStyle = UITextField.BorderStyle.roundedRect
        textPassWord.placeholder = "请输入密码"
        textPassWord.returnKeyType = UIReturnKeyType.done // ?
        textPassWord.clearButtonMode = UITextField.ViewMode.never //编辑时显示删除图标
        textPassWord.keyboardType = UIKeyboardType.emailAddress // 键盘类型为邮箱
        textPassWord.isSecureTextEntry = true // 是否安全输入 小圆点 和按钮交互
        
        textName.addTarget(self, action: #selector(LoginViewController.textValueChanged), for: UIControl.Event.editingChanged)
        textPassWord.addTarget(self, action: #selector(LoginViewController.textValueChanged), for: UIControl.Event.editingChanged)
        
        textPassWord.delegate = self
        textName.delegate = self
        self.view.addSubview(textName)
        self.view.addSubview(textPassWord)
        
        // 3.按钮, 长度？ 字体格式？ 适配？
        
        // 3.2 登陆按钮
        loginButton.frame = CGRect(x: 0, y: 0, width: 297,height: 44)
        loginButton.center = textPassWord.center
        loginButton.center.y = textPassWord.center.y + 82
        // loginButton.backgroungColor =
        loginButton.backgroundColor = UIColor.init(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1)
        loginButton.setTitle("登陆", for: .normal)
        loginButton.setTitleColor(UIColor.white, for: .normal)
        // 3.2.1 输入后高亮
        self.view.addSubview(loginButton)
        
        //3.3 忘记密码按钮
        let forgotButton = UIButton(type: .system)
        forgotButton.frame = CGRect(x:0, y:0, width:44, height:32)
        forgotButton.center.x = textPassWord.center.x + 112.5
        forgotButton.center.y = textPassWord.center.y + 38
        forgotButton.setTitle("忘记密码", for: .normal)
        forgotButton.tintColor = UIColor(red:54/255.0,green:181/255.0,blue:157/255.0,alpha: 1)
        forgotButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        //根据字体调整框大小
        forgotButton.adjustsImageSizeForAccessibilityContentSizeCategory = true
        //3.3.1 点击进入忘记密码页面
        forgotButton.addTarget(self, action: #selector(LoginViewController.forgotPage), for: UIControl.Event.touchUpInside)
        self.view.addSubview(forgotButton)
        
        
        //3.4 显示-隐藏密码按钮
        let eyeButton = UIButton(type: .system)
        eyeButton.frame = CGRect(x:0, y:0, width:44, height:44)
        eyeButton.center.x = textPassWord.center.x + 126.5
        eyeButton.center.y = textPassWord.center.y
        eyeButton.setImage(UIImage(named: "EyeOff"), for: .normal)
        // 更改自定义图片的颜色
        eyeButton.tintColor = UIColor(red:170/255.0,green:170/255.0,blue:170/255.0,alpha: 1)
        // 更改自定义图片的大小 先不管 找合适的图片就好
        eyeButton.imageEdgeInsets = UIEdgeInsets(top: 32, left:32, bottom:32, right:32 )
        
        
        self.view.addSubview(eyeButton)
        
        //4. 提示标签
        let errorLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 32))
        errorLabel.text = "邮箱格式错误"
        errorLabel.font = UIFont.systemFont(ofSize: 12)
        errorLabel.textColor = UIColor.init(red: 220/225.0, green: 102/225.0, blue: 62/225.0, alpha: 1)
        errorLabel.center.x = textPassWord.center.x - 108.5
        errorLabel.center.y = forgotButton.center.y
        self.view.addSubview(errorLabel)
        
        
    }
    // 回收键盘
    func textFieldShouldReturn(_ textName: UITextField) -> Bool {
        textName.resignFirstResponder()
        return true
    }
    
    // 响应的方法，视图入栈
    @objc func registerPage(){
        let viewController = RegisterViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func forgotPage(){
        let viewController = ForgotViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func textValueChanged(){
        if textName.text?.isEmpty == false && textPassWord.text?.isEmpty == false{
            loginButton.backgroundColor = UIColor.init(red:54/255.0, green:181/255.0, blue:157/255.0,alpha: 1)
        }
        else{
            loginButton.backgroundColor = UIColor.init(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1)
        }
    }
}

