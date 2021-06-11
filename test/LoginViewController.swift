//
//  ViewController.swift
//  test
//
//  Created by 李远卓 on 2021/6/1.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var textName:UITextField! // detail
    var textPassWord:UITextField!
    var errorLabel = UILabel()
    let loginButton = UIButton(type: .system)
    let eyeButton = UIButton(type: .custom)
    // 页面禁止横屏，如果横屏幕还要考虑键盘遮挡问题？
    // 生命周期和view大小
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
        // 按钮颜色设置
        self.navigationController?.navigationBar.tintColor = UIColor(red:54/255.0,green:181/255.0,blue:157/255.0,alpha: 1)
        // 导航控制器全透明设置
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.shadowImage = UIImage()
        //字体大小设置？
        
        // 1.墨墨mind图标显示 封装？
        // 1.1.先将view居中再向上平移，位置，适配？
        let LoginView = UIImageView()
        // 1.2.将图标贴在view上
        let image = UIImage(named: "LoginIcon")
        LoginView.image = image
        self.view.addSubview(LoginView)
        
        // 必须关闭自动约束
        LoginView.translatesAutoresizingMaskIntoConstraints = false
        // 约束：以线性方程式的解来确定两个矩形之间的距离关系。 distance(x1, x2) = x2 * a + c
        // 宽高自己约束自己，约束有优先级吗？
        LoginView.addConstraint(NSLayoutConstraint(item: LoginView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 192))
        LoginView.addConstraint(NSLayoutConstraint(item: LoginView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 64))
        // 上和中央，为什么是给view加约束，是因为旋转吗
        self.view.addConstraint(NSLayoutConstraint(item: LoginView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 124))
        self.view.addConstraint(NSLayoutConstraint(item: LoginView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
        
        // 2.文本输入框
        // 2.1 用户邮箱输入
        textName = UITextField()
        textName.borderStyle = UITextField.BorderStyle.roundedRect
        textName.placeholder = "请输入邮箱"
        textName.returnKeyType = UIReturnKeyType.done // ?
        textName.clearButtonMode = UITextField.ViewMode.never // 编辑时显示删除图标
        textName.keyboardType = UIKeyboardType.emailAddress // 键盘类型为邮箱
        
        // 2.2 用户密码输入
        textPassWord = UITextField()
        textPassWord.borderStyle = UITextField.BorderStyle.roundedRect
        textPassWord.placeholder = "请输入密码"
        textPassWord.returnKeyType = UIReturnKeyType.done // ?
        textPassWord.clearButtonMode = UITextField.ViewMode.never //编辑时显示删除图标
        textPassWord.keyboardType = UIKeyboardType.emailAddress // 键盘类型为邮箱
        textPassWord.isSecureTextEntry = true // 是否安全输入 默认为true
        
        textName.addTarget(self, action: #selector(LoginViewController.textValueChanged), for: UIControl.Event.editingChanged)
        textPassWord.addTarget(self, action: #selector(LoginViewController.textValueChanged), for: UIControl.Event.editingChanged)
        textName.addTarget(self, action: #selector(LoginViewController.formatDetection), for: UIControl.Event.editingDidEnd)
        textName.addTarget(self, action: #selector(LoginViewController.resetErrorLabel), for: .editingChanged)
        textPassWord.addTarget(self, action: #selector(LoginViewController.resetErrorLabel), for: .editingChanged)
        
        textName.delegate = self
        textPassWord.delegate = self
        self.view.addSubview(textName)
        self.view.addSubview(textPassWord)
        
        textName.translatesAutoresizingMaskIntoConstraints = false
        textPassWord.translatesAutoresizingMaskIntoConstraints = false
        
        textName.addConstraint(NSLayoutConstraint(item: textName!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 297))
        textName.addConstraint(NSLayoutConstraint(item: textName!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 44))
        // 这里必须是self.view  否则报错 Does the constraint reference something from outside the subtree of the view?  That's illegal.
        self.view.addConstraint(NSLayoutConstraint(item: textName!, attribute: .top, relatedBy: .equal, toItem: LoginView, attribute: .bottom, multiplier: 1,constant: 48))
        self.view.addConstraint(NSLayoutConstraint(item: textName!, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1,constant: 0))
        
        textPassWord.addConstraint(NSLayoutConstraint(item: textPassWord!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 297))
        textPassWord.addConstraint(NSLayoutConstraint(item: textPassWord!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 44))
        self.view.addConstraint(NSLayoutConstraint(item: textPassWord!, attribute: .top, relatedBy: .equal, toItem: textName, attribute: .bottom, multiplier: 1,constant: 10))
        self.view.addConstraint(NSLayoutConstraint(item: textPassWord!, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1,constant: 0))
        
        // 3.按钮, 长度？ 字体格式？ 适配？
        
        // 3.2 登陆按钮
        loginButton.backgroundColor = UIColor.init(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1)
        loginButton.setTitle("登陆", for: .normal)
        loginButton.setTitleColor(UIColor.white, for: .normal)
        loginButton.isEnabled = false
        // 3.2.1 转入登陆界面
        loginButton.addTarget(self, action: #selector(LoginViewController.welcomePage), for: UIControl.Event.touchUpInside)
       
        self.view.addSubview(loginButton)
        
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        loginButton.addConstraint(NSLayoutConstraint(item: loginButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 297))
        loginButton.addConstraint(NSLayoutConstraint(item: loginButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 44))
        self.view.addConstraint(NSLayoutConstraint(item: loginButton, attribute: .top, relatedBy: .equal, toItem: textPassWord, attribute: .bottom, multiplier: 1,constant: 40))
        self.view.addConstraint(NSLayoutConstraint(item: loginButton, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1,constant: 0))
        
        //3.3 忘记密码按钮
        let forgotButton = UIButton(type: .system)
        forgotButton.setTitle("忘记密码", for: .normal)
        forgotButton.tintColor = UIColor(red:54/255.0,green:181/255.0,blue:157/255.0,alpha: 1)
        forgotButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        //根据字体调整框大小, 添加约束后失效，如何在约束的情况下解决
        forgotButton.adjustsImageSizeForAccessibilityContentSizeCategory = true
        //3.3.1 点击进入忘记密码页面
        forgotButton.addTarget(self, action: #selector(LoginViewController.forgotPage), for: UIControl.Event.touchUpInside)
        
        self.view.addSubview(forgotButton)
        
        forgotButton.translatesAutoresizingMaskIntoConstraints = false
        forgotButton.addConstraint(NSLayoutConstraint(item: forgotButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 60))
        forgotButton.addConstraint(NSLayoutConstraint(item: forgotButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 32))
        self.view.addConstraint(NSLayoutConstraint(item: forgotButton, attribute: .top, relatedBy: .equal, toItem: textPassWord, attribute: .bottom, multiplier: 1,constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: forgotButton, attribute: .right, relatedBy: .equal, toItem: textPassWord, attribute: .right, multiplier: 1,constant: 0))
        
        
        //3.4 显示-隐藏密码按钮
        eyeButton.setImage(UIImage(named: "EyeOff"), for: .normal)
        // 图像颜色设置? 密码过长的显示问题？
        eyeButton.currentImage!.withTintColor(UIColor(red:170/255.0,green:170/255.0,blue:170/255.0,alpha: 1))
        // 更改自定义图片的大小
        eyeButton.imageEdgeInsets = UIEdgeInsets(top: 28, left:28, bottom:28, right:28)
        
        eyeButton.addTarget(self, action: #selector(LoginViewController.eyeButtonTapped), for: UIControl.Event.touchUpInside)
        
        self.view.addSubview(eyeButton)
        
        eyeButton.translatesAutoresizingMaskIntoConstraints = false
        
        eyeButton.addConstraint(NSLayoutConstraint(item: eyeButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 44))
        eyeButton.addConstraint(NSLayoutConstraint(item: eyeButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 44))
        self.view.addConstraint(NSLayoutConstraint(item: eyeButton, attribute: .centerY, relatedBy: .equal, toItem: textPassWord, attribute: .centerY, multiplier: 1,constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: eyeButton, attribute: .right, relatedBy: .equal, toItem: textPassWord, attribute: .right, multiplier: 1,constant: 0))
        
        
        //4. 提示标签
        errorLabel.font = UIFont.systemFont(ofSize: 12)
        errorLabel.textColor = UIColor(red: 220/225.0, green: 102/225.0, blue: 62/225.0, alpha: 1)
        errorLabel.isHidden = true
        self.view.addSubview(errorLabel)
        
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        errorLabel.addConstraint(NSLayoutConstraint(item: errorLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 80))
        errorLabel.addConstraint(NSLayoutConstraint(item: errorLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 32))
        self.view.addConstraint(NSLayoutConstraint(item: errorLabel, attribute: .left, relatedBy: .equal, toItem: textPassWord, attribute: .left, multiplier: 1,constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: errorLabel, attribute: .top, relatedBy: .equal, toItem: textPassWord, attribute: .bottom, multiplier: 1,constant: 0))
        
    }
    // 回收键盘
    func textFieldShouldReturn(_ textName: UITextField) -> Bool {
        textName.resignFirstResponder()
        return true
    }
    // 键盘遮挡问题？
    
    // 装入解析后的JSON,用于interactive,有简单的写法吗？
    struct Data: Codable{
        let token: String?
    }
    
    struct Error: Codable {
        let code: String?
        let info: String?
        let message: String?
    }
    
    struct ServerDescription: Codable {
        let data: Data?
        let error: Error?
        // JSON里的1，0可能是数字，可能是bool，根据报错提示来判断
        let success: Bool?
    }
    //
    func loginResponse(completion: @escaping (ServerDescription)->Void) {
        // 用户验证请求
        let parameters: [String: String] = [
            "email": textName.text!,
            "password": textPassWord.text!
        ]
        let url = "http://47.96.170.11/api/v1/user/login"
        // let url = "http://47.96.170.11/api/v1/user/register"
        // authenticate是用来干啥的
        AF.request(url, method: .post, parameters: parameters).responseJSON {
            // 大括号是closure，匿名函数，response是参数，捕获上下文
            response in
            switch response.result {
                // 请求成功
            case .success(let json):
                    // 保证不为nil?
                    guard let data = response.data else { return }
                    // 解析JSON和捕获异常
                    do {
                        let ServerDescription = try JSONDecoder().decode(ServerDescription.self, from: data)
                        completion(ServerDescription)
                        print(json)
                    }
                    catch let jsonErr {
                            print("json 解析出错 : ", jsonErr)
                    }
                // 失败
            case .failure(let error):
                    print(error)
            }
        }

    }
    
    // 导航响应的方法，视图入栈
    @objc func registerPage(){
        let viewController = RegisterViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func forgotPage(){
        let viewController = ForgotViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func welcomePage(){
        // 邮箱格式对了再验证
        if validateEmail(email: textName.text!) {
            loginResponse { [self] ServerDescription in
                // 如果success,转入登陆界面
                if (ServerDescription.success!){
                    let viewController = WelcomeViewController()
                    self.navigationController?.pushViewController(viewController, animated: false)
                }
                // 如果!success
                else {
                    if (ServerDescription.error?.code == "user_invalid_user"){
                        // 提示账号错误，并且高亮,为啥要self
                        errorLabel.text = "账号错误"
                        errorLabel.isHidden = false
                    }
                    else if (ServerDescription.error?.code == "user_invalid_password_length" || ServerDescription.error?.code == "user_invalid_password"){
                        // 提示密码错误，并且高亮
                        errorLabel.text = "密码错误"
                        errorLabel.isHidden = false

                    }
                }
            }
            
        }
        // 格式不对直接提示，不转入登陆界面
        else {
            errorLabel.text = "邮箱格式错误"
            errorLabel.isHidden = false
        }
    }
    
    // 文本框响应方法，登陆按钮变色
    @objc func textValueChanged(){
        if textName.text?.isEmpty == false && textPassWord.text?.isEmpty == false {
            loginButton.backgroundColor = UIColor.init(red:54/255.0, green:181/255.0, blue:157/255.0,alpha: 1)
            loginButton.isEnabled = true
        }
        else{
            loginButton.backgroundColor = UIColor.init(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1)
            loginButton.isEnabled = false
        }
    }
    
    // eyeButton响应方法 换图 显示密码
    @objc func eyeButtonTapped(){
        if eyeButton.isSelected {
            eyeButton.setImage(UIImage(named: "EyeOff"), for: .normal)
            eyeButton.isSelected = false
            textPassWord.isSecureTextEntry = true
        }
        else{
            // 颜色显示有问题
            eyeButton.setImage(UIImage(named: "EyeOn"), for: .normal)
            eyeButton.isSelected = true
            textPassWord.isSecureTextEntry = false
        }
    }
    
    // 错误提示标签响应
    @objc func formatDetection(){
        if validateEmail(email: textName.text!) == true{
            errorLabel.isHidden = true
        }
        else{
            errorLabel.text = "邮箱格式错误"
            errorLabel.isHidden = false
        }
    }
    
    // 错误提示标签重置
    @objc func resetErrorLabel(){
        if (errorLabel.isHidden == false){
            errorLabel.isHidden = true
        }
    }
    
}

