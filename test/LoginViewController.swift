//
//  ViewController.swift
//  test
//
//  Created by 李远卓 on 2021/6/1.
//
import UIKit
import SnapKit

class LoginViewController: UIViewController {
    private let textName = LineTextField()
    private let textPassWord = LineTextField()
    private let errorLabel = UILabel()
    private let loginView = UIImageView()
    private let loginButton = UIButton(type: .system)
    private let eyeButton = UIButton(type: .custom)
    private let forgotButton = UIButton(type: .system)
    private let logSuccessBubble = UIAlertController(title: "", message: "登录成功", preferredStyle: .alert)
    override func viewDidLoad() {
        super.viewDidLoad()
        try? DBManager.db?.createTable(table: SQLNote.self)
        setUI()
        setConstraints()
        // 测试
        textName.text = "fffgrdcc@163.com"
        textPassWord.text = "123456"
    }
}

// UI
extension LoginViewController {
    func setNavigationBar() {
        // 导航控制器设置
        self.view.backgroundColor = UIColor.white
        // 当前页和返回页字符不显示
        self.title = ""
        // 按钮颜色设置
        self.navigationController?.navigationBar.tintColor = UIColor.greenColor
        // 导航控制器全透明设置
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    func setImage() {
        let image = UIImage(named: "LoginIcon")
        loginView.image = image
    }
    func setLabel() {
        errorLabel.font = UIFont.systemFont(ofSize: 12)
        errorLabel.textColor = UIColor.errorColor
        errorLabel.isHidden = true
    }
    func setTextFiled() {
        // 用户邮箱输入
        textName.borderStyle = UITextField.BorderStyle.none
        textName.placeholder = "请输入邮箱"
        textName.returnKeyType = UIReturnKeyType.done // returnKey title is done
        textName.clearButtonMode = UITextField.ViewMode.never // 编辑时显示删除图标
        textName.keyboardType = UIKeyboardType.emailAddress // 键盘类型为邮箱
        // 光标颜色
        textName.tintColor = UIColor.greenColor
        textName.textColor = UIColor.textColor
        // 用户密码输入
        textPassWord.borderStyle = UITextField.BorderStyle.none
        textPassWord.placeholder = "请输入密码"
        textPassWord.returnKeyType = UIReturnKeyType.done
        textPassWord.clearButtonMode = UITextField.ViewMode.never
        textPassWord.keyboardType = UIKeyboardType.emailAddress
        textPassWord.isSecureTextEntry = true // 是否安全输入 默认为true
        textPassWord.tintColor = UIColor.greenColor
        textPassWord.textColor = UIColor.textColor
        // 添加button
        textPassWord.rightView = eyeButton
        textPassWord.rightViewMode = .always
        // 响应
        textName.addTarget(self, action: #selector(LoginViewController.textValueChanged), for: .editingChanged)
        textPassWord.addTarget(self, action: #selector(LoginViewController.textValueChanged), for: .editingChanged)
        textName.addTarget(self, action: #selector(LoginViewController.formatDetection), for: .editingDidEnd)
        textName.addTarget(self, action: #selector(LoginViewController.resetErrorLabel), for: .editingChanged)
        textPassWord.addTarget(self, action: #selector(LoginViewController.resetErrorLabel), for: .editingChanged)
    }
    func setButton() {
        // 登陆按钮
        loginButton.backgroundColor = UIColor.buttonDisabledColor
        loginButton.setTitle("登陆", for: .normal)
        loginButton.setTitleColor(UIColor.white, for: .normal)
        loginButton.isEnabled = true
        loginButton.layer.cornerRadius = 5
        loginButton.addTarget(self, action: #selector(LoginViewController.welcomePage), for: .touchUpInside)
        // 忘记密码按钮
        forgotButton.setTitle("忘记密码", for: .normal)
        forgotButton.tintColor = UIColor.greenColor
        forgotButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        forgotButton.adjustsImageSizeForAccessibilityContentSizeCategory = true
        // 显示-隐藏密码按钮
        eyeButton.setImage(UIImage(named: "EyeOff")?
                            .withTintColor(UIColor.eyeColor, renderingMode: .automatic), for: .normal)
        // 更改自定义图片的大小, top：19是btn的top插入19个px,相当于图片向下压缩19px，参照是button的frame
        eyeButton.imageEdgeInsets = UIEdgeInsets(top: 19, left: 16, bottom: 19, right: 16)
        // view和controller之间的通信，当view被点击，通知self(controller), controller执行@objc方法
        eyeButton.addTarget(self, action: #selector(LoginViewController.eyeButtonTapped), for: .touchUpInside)
        // 关闭按钮高亮状态
        eyeButton.adjustsImageWhenHighlighted = false
    }

    func setUI() {
        setNavigationBar()
        setTextFiled()
        setImage()
        setButton()
        setLabel()
        self.view.addSubview(errorLabel)
        self.view.addSubview(loginView)
        self.view.addSubview(textName)
        self.view.addSubview(textPassWord)
        self.view.addSubview(loginButton)
        self.view.addSubview(forgotButton)
        textName.delegate = self
        textPassWord.delegate = self
    }

    func setConstraints() {
        // 约束：以线性方程式的解来确定两个矩形之间的距离关系。 distance(x1, x2) = x2 * a + c
        loginView.snp.makeConstraints {
            $0.width.equalTo(192)
            $0.height.equalTo(64)
            $0.top.equalTo(self.view).offset(124)
            $0.centerX.equalTo(self.view)
        }
        textName.snp.makeConstraints {
            $0.width.equalTo(297)
            $0.height.equalTo(44)
            $0.top.equalTo(loginView.snp.bottom).offset(48)
            $0.centerX.equalTo(self.view)
        }
        textPassWord.snp.makeConstraints {
            $0.width.height.centerX.equalTo(textName)
            $0.top.equalTo(textName.snp.bottom).offset(10)
        }
        loginButton.snp.makeConstraints {
            $0.width.height.centerX.equalTo(textName)
            $0.top.equalTo(textPassWord.snp.bottom).offset(40)
        }
        eyeButton.snp.makeConstraints {
            $0.width.height.equalTo(44)
        }
        forgotButton.snp.makeConstraints {
            $0.width.equalTo(60)
            $0.height.equalTo(32)
            $0.right.equalTo(textPassWord.snp.right)
            $0.top.equalTo(textPassWord.snp.bottom)
        }
        errorLabel.snp.makeConstraints {
            $0.width.equalTo(80)
            $0.height.equalTo(32)
            $0.left.equalTo(textPassWord)
            $0.top.equalTo(textPassWord.snp.bottom)
        }
    }
}

extension LoginViewController {
    // 导航响应的方法，视图入栈
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
                let viewController = DisplayViewController()
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
            loginButton.backgroundColor = UIColor.greenColor
            loginButton.isEnabled = true
        } else {
            loginButton.backgroundColor = UIColor.buttonDisabledColor
            loginButton.isEnabled = false
        }
    }
    // eyeButton响应方法 换图 显示密码
    @objc func eyeButtonTapped() {
        if eyeButton.isSelected {
            eyeButton.setImage(UIImage(named: "EyeOff")?
            .withTintColor(UIColor.eyeColor, renderingMode: .automatic), for: .normal)
            eyeButton.isSelected = false
            textPassWord.isSecureTextEntry = true
            eyeButton.imageEdgeInsets = UIEdgeInsets(top: 19, left: 16, bottom: 19, right: 16)
        } else {
            eyeButton.setImage(UIImage(named: "EyeOn")?
                                .withTintColor(UIColor.eyeColor, renderingMode: .automatic), for: .normal)
            eyeButton.imageEdgeInsets = UIEdgeInsets(top: 18, left: 16, bottom: 18, right: 16)
            eyeButton.isSelected = true
            textPassWord.isSecureTextEntry = false
        }
    }
    // 错误提示标签响应
    @objc func formatDetection() {
        if textName.text!.isValidateEmail {
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

extension LoginViewController: UITextFieldDelegate {
    // 代理方法，响应returnkey点击，回收键盘
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
