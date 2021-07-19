//
//  ViewController.swift
//  test
//
//  Created by 李远卓 on 2021/6/1.
//
import UIKit
import SnapKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    let textName = LineTextField()
    let textPassWord = LineTextField()
    let errorLabel = UILabel()
    let loginView = UIImageView()
    let loginButton = UIButton(type: .system)
    let eyeButton = UIButton(type: .custom)
    let forgotButton = UIButton(type: .system)
    let logSuccessBubble = UIAlertController(title: "", message: "登录成功", preferredStyle: .alert)
    // 页面禁止横屏，如果横屏幕还要考虑键盘遮挡问题？
    override func viewDidLoad() {
        // 父类初始化
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // open and connect database
//        do {
//            try DBManager.db?.createTable(table: SQLNote.self)
//        } catch {
//            print(DBManager.db?.errorMessage as Any)
//        }
        try? DBManager.db?.createTable(table: SQLNote.self)

        // 导航控制器设置
        self.view.backgroundColor = UIColor.white
        // 当前页和返回页字符不显示
        self.title = ""
        // 右按钮内容，颜色，响应设置
        self.navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: "立即注册", style: .plain, target: self,
                            action: #selector(LoginViewController.registerPage))
        // 按钮颜色设置
        self.navigationController?.navigationBar.tintColor = MyColor.greenColor
        // 导航控制器全透明设置
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.shadowImage = UIImage()
        // 图标设置
        let image = UIImage(named: "LoginIcon")
        loginView.image = image
        self.view.addSubview(loginView)
        // 文本输入框
        // 用户邮箱输入
        textName.borderStyle = UITextField.BorderStyle.none
        textName.placeholder = "请输入邮箱"
        textName.returnKeyType = UIReturnKeyType.done // returnKey title is done
        textName.clearButtonMode = UITextField.ViewMode.never // 编辑时显示删除图标
        textName.keyboardType = UIKeyboardType.emailAddress // 键盘类型为邮箱
        // 光标颜色
        textName.tintColor = MyColor.greenColor
        textName.textColor = MyColor.textColor
        // 用户密码输入
        textPassWord.borderStyle = UITextField.BorderStyle.none
        textPassWord.placeholder = "请输入密码"
        textPassWord.returnKeyType = UIReturnKeyType.done
        textPassWord.clearButtonMode = UITextField.ViewMode.never
        textPassWord.keyboardType = UIKeyboardType.emailAddress
        textPassWord.isSecureTextEntry = true // 是否安全输入 默认为true
        textPassWord.tintColor = MyColor.greenColor
        textPassWord.textColor = MyColor.textColor
        // 响应
        textName.addTarget(self, action: #selector(LoginViewController.textValueChanged), for: .editingChanged)
        textPassWord.addTarget(self, action: #selector(LoginViewController.textValueChanged), for: .editingChanged)
        textName.addTarget(self, action: #selector(LoginViewController.formatDetection), for: .editingDidEnd)
        textName.addTarget(self, action: #selector(LoginViewController.resetErrorLabel), for: .editingChanged)
        textPassWord.addTarget(self, action: #selector(LoginViewController.resetErrorLabel), for: .editingChanged)
        // 设置textfield对象的代理为当前视图控制器
        textName.delegate = self
        textPassWord.delegate = self
        self.view.addSubview(textName)
        self.view.addSubview(textPassWord)
        // 登陆按钮
        loginButton.backgroundColor = MyColor.buttonDisabledColor
        loginButton.setTitle("登陆", for: .normal)
        loginButton.setTitleColor(UIColor.white, for: .normal)
        // 测试改动
        loginButton.isEnabled = true
        // 圆角弧度
        loginButton.layer.cornerRadius = 5
        // 转入登陆界面
        loginButton.addTarget(self, action: #selector(LoginViewController.welcomePage), for: .touchUpInside)
        self.view.addSubview(loginButton)
        // 忘记密码按钮
        forgotButton.setTitle("忘记密码", for: .normal)
        forgotButton.tintColor = MyColor.greenColor
        forgotButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        forgotButton.adjustsImageSizeForAccessibilityContentSizeCategory = true
        // 点击进入忘记密码页面
        forgotButton.addTarget(self, action: #selector(LoginViewController.forgotPage), for: .touchUpInside)
        self.view.addSubview(forgotButton)
        // 显示-隐藏密码按钮
        eyeButton.setImage(UIImage(named: "EyeOff")?
                            .withTintColor(MyColor.eyeColor, renderingMode: .automatic), for: .normal)
        // 更改自定义图片的大小, top：19是btn的top插入19个px,相当于图片向下压缩19px，参照是button的frame
        eyeButton.imageEdgeInsets = UIEdgeInsets(top: 19, left: 16, bottom: 19, right: 16)
        eyeButton.addTarget(self, action: #selector(LoginViewController.eyeButtonTapped), for: .touchUpInside)
        // 关闭按钮高亮状态
        eyeButton.adjustsImageWhenHighlighted = false
        // 添加到密码框右侧并设置显示模式
        textPassWord.rightView = eyeButton
        textPassWord.rightViewMode = .always
        // 提示标签
        errorLabel.font = UIFont.systemFont(ofSize: 12)
        errorLabel.textColor = MyColor.errorColor
        errorLabel.isHidden = true
        self.view.addSubview(errorLabel)
        myConstraints()
        // 测试
        textName.text = "fffgrdcc@163.com"
        textPassWord.text = "123456"
    }
    // 代理方法，响应returnkey点击，回收键盘
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func myConstraints() {
        // 约束：以线性方程式的解来确定两个矩形之间的距离关系。 distance(x1, x2) = x2 * a + c
        loginView.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(192)
            make.height.equalTo(64)
            make.top.equalTo(self.view).offset(124)
            make.centerX.equalTo(self.view)
        }
        textName.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(297)
            make.height.equalTo(44)
            make.top.equalTo(loginView.snp.bottom).offset(48)
            make.centerX.equalTo(self.view)
        }
        textPassWord.snp.makeConstraints { (make) -> Void in
            make.width.height.centerX.equalTo(textName)
            make.top.equalTo(textName.snp.bottom).offset(10)
        }
        loginButton.snp.makeConstraints { (make) -> Void in
            make.width.height.centerX.equalTo(textName)
            make.top.equalTo(textPassWord.snp.bottom).offset(40)
        }
        eyeButton.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(44)
        }
        forgotButton.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(60)
            make.height.equalTo(32)
            make.right.equalTo(textPassWord.snp.right)
            make.top.equalTo(textPassWord.snp.bottom)
        }
        errorLabel.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(80)
            make.height.equalTo(32)
            make.left.equalTo(textPassWord)
            make.top.equalTo(textPassWord.snp.bottom)
        }
    }
    // 导航响应的方法，视图入栈
    @objc func registerPage() {
        let viewController = RegisterViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    @objc func forgotPage() {
        let viewController = ForgotViewController()
        // 反向页面传值, 这里是闭包的自定义
        viewController.myClosure = { [weak self] text in
            self?.textName.text = text
        }
        // 引用计数查看 print(CFGetRetainCount(self))
        // 正向页面传值
        viewController.textName.text = textName.text
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    @objc func welcomePage() {
        let userInfo = UserInfo(email: textName.text!, pwd: textPassWord.text)
        requestAndResponse(userInfo: userInfo,
                           function: .login, method: .post) { [self] serverDescription in
            if serverDescription.message == "背单词服务出错：账号或密码错误。" {
                errorLabel.text = "账号或密码错误"
                errorLabel.isHidden = false
            } else {
                // 保存jwt
                let jwt = serverDescription.jwt
                userDefault.set(jwt, forKey: UserDefaultKeys.AccountInfo.jwt.rawValue)
                let viewController = WelcomeViewController()
                textPassWord.text = ""
                navigationController?.pushViewController(viewController, animated: false)
                // 气泡显示
                present(logSuccessBubble, animated: true, completion: nil)
                perform(#selector(dismissHelper), with: logSuccessBubble, afterDelay: 1.0)
            }
        }
    }
    // 气泡延时消失
    @objc func dismissHelper() {
        logSuccessBubble.dismiss(animated: true, completion: nil)
    }
    // 文本框响应方法，登陆按钮变色
    @objc func textValueChanged() {
        if textName.text?.isEmpty == false && textPassWord.text?.isEmpty == false {
            loginButton.backgroundColor = MyColor.greenColor
            loginButton.isEnabled = true
        } else {
            loginButton.backgroundColor = MyColor.buttonDisabledColor
            loginButton.isEnabled = false
        }
    }
    // eyeButton响应方法 换图 显示密码
    @objc func eyeButtonTapped() {
        if eyeButton.isSelected {
            eyeButton.setImage(UIImage(named: "EyeOff")?
            .withTintColor(MyColor.eyeColor, renderingMode: .automatic), for: .normal)
            eyeButton.isSelected = false
            textPassWord.isSecureTextEntry = true
            eyeButton.imageEdgeInsets = UIEdgeInsets(top: 19, left: 16, bottom: 19, right: 16)
        } else {
            eyeButton.setImage(UIImage(named: "EyeOn")?
                                .withTintColor(MyColor.eyeColor, renderingMode: .automatic), for: .normal)
            eyeButton.imageEdgeInsets = UIEdgeInsets(top: 18, left: 16, bottom: 18, right: 16)
            eyeButton.isSelected = true
            textPassWord.isSecureTextEntry = false
        }
    }
    // 错误提示标签响应
    @objc func formatDetection() {
        if validateEmail(email: textName.text!) == true {
            errorLabel.isHidden = true
        } else {
            errorLabel.text = "邮箱格式错误"
            errorLabel.isHidden = false
        }
    }
    // 错误提示标签重置
    @objc func resetErrorLabel() {
        if errorLabel.isHidden == false {
            errorLabel.isHidden = true
        }
    }
}
