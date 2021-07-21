//
//  RegisterViewController.swift
//  test
//
//  Created by 李远卓 on 2021/6/4.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {
    // 类是引用类型，let类似于指针常量（int* const), var 类似 int*
    // 结构体和BDT是值类型，let类似于const int, var 类似 int
    let registerLabel = UILabel()
    let errorLabel = UILabel()
    let displayButton = UIButton(type: .custom)
    let registerButton = UIButton(type: .system)
    let textName = LineTextField(), textPassWord = LineTextField(), textPassWordConfirm = LineTextField()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 导航控制器设置
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.shadowImage = UIImage()
        // 标签显示
        registerLabel.text = "账号注册"
        registerLabel.font = UIFont.systemFont(ofSize: 22)
        registerLabel.textColor = MyColor.textColor
        self.view.addSubview(registerLabel)
        // 输入文本框
        // 邮箱输入
        textName.borderStyle = UITextField.BorderStyle.none
        textName.placeholder = "请输入邮箱"
        textName.returnKeyType = UIReturnKeyType.done
        textName.clearButtonMode = UITextField.ViewMode.never
        textName.keyboardType = UIKeyboardType.emailAddress
        textName.tintColor = MyColor.greenColor
        textName.textColor = MyColor.textColor
        // 密码输入
        textPassWord.center = self.view.center
        textPassWord.borderStyle = UITextField.BorderStyle.none
        textPassWord.placeholder = "请设置密码（8个字符以上）"
        textPassWord.returnKeyType = UIReturnKeyType.done
        textPassWord.keyboardType = UIKeyboardType.default
        textPassWord.isSecureTextEntry = true
        textPassWord.tintColor = MyColor.greenColor
        textPassWord.textColor = MyColor.textColor
        // 确认密码输入
        textPassWordConfirm.borderStyle = UITextField.BorderStyle.none
        textPassWordConfirm.placeholder = "请确认密码"
        textPassWordConfirm.returnKeyType = UIReturnKeyType.done
        textPassWordConfirm.keyboardType = UIKeyboardType.default
        textPassWordConfirm.isSecureTextEntry = true
        textPassWordConfirm.tintColor = MyColor.greenColor
        textPassWordConfirm.textColor = MyColor.textColor
        // 全部有输入后高亮
        textName.addTarget(self, action: #selector(RegisterViewController.textValueChanged), for: .editingChanged)
        textPassWord.addTarget(self, action: #selector(RegisterViewController.textValueChanged), for: .editingChanged)
        textPassWordConfirm.addTarget(self, action: #selector(RegisterViewController.textValueChanged),
                                      for: .editingChanged)
        // 再次编辑密码时标签隐藏
        textPassWord.addTarget(self, action: #selector(LoginViewController.resetErrorLabel),
                               for: .editingChanged)
        textPassWordConfirm.addTarget(self, action: #selector(LoginViewController.resetErrorLabel),
                                      for: .editingChanged)
        textName.delegate = self
        textPassWord.delegate = self
        textPassWordConfirm.delegate = self
        self.view.addSubview(textName)
        self.view.addSubview(textPassWord)
        self.view.addSubview(textPassWordConfirm)
        // 按钮显示
        // 注册按钮
        registerButton.backgroundColor = MyColor.buttonDisabledColor
        registerButton.setTitle("注册", for: .normal)
        registerButton.setTitleColor(UIColor.white, for: .normal)
        registerButton.isEnabled = false
        registerButton.layer.cornerRadius = 5
        // 注册按钮点击后请求服务器连接，转入欢迎界面
        registerButton.addTarget(self, action: #selector(LoginViewController.welcomePage), for: .touchUpInside)
        self.view.addSubview(registerButton)
        // 显示-隐藏按钮
        displayButton.setTitle("显示密码", for: .normal)
        displayButton.titleLabel!.font = UIFont.systemFont(ofSize: 12)
        displayButton.setTitleColor(MyColor.greenColor, for: .normal)
        displayButton.isSelected = true
        // 点击切换状态
        displayButton.addTarget(self, action: #selector(RegisterViewController.displayButtonTapped),
                                for: .touchUpInside)
        self.view.addSubview(displayButton)
        // 错误信息标签显示
        errorLabel.font = UIFont.systemFont(ofSize: 12)
        errorLabel.textColor = MyColor.errorColor
        errorLabel.isHidden = true
        self.view.addSubview(errorLabel)
        displayButton.translatesAutoresizingMaskIntoConstraints = false
        registerLabel.translatesAutoresizingMaskIntoConstraints = false
        textName.translatesAutoresizingMaskIntoConstraints = false
        textPassWord.translatesAutoresizingMaskIntoConstraints = false
        textPassWordConfirm.translatesAutoresizingMaskIntoConstraints = false
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        // 约束
        registerLabel.addConstraint(NSLayoutConstraint(item: registerLabel, attribute: .width, relatedBy: .equal,
                                                       toItem: nil, attribute: .notAnAttribute,
                                                       multiplier: 0, constant: 128))
        registerLabel.addConstraint(NSLayoutConstraint(item: registerLabel, attribute: .height, relatedBy: .equal,
                                                       toItem: nil, attribute: .notAnAttribute,
                                                       multiplier: 0, constant: 22))
        self.view.addConstraint(NSLayoutConstraint(item: registerLabel, attribute: .top, relatedBy: .equal,
                                                   toItem: self.view, attribute: .top,
                                                   multiplier: 1, constant: 124))
        self.view.addConstraint(NSLayoutConstraint(item: registerLabel, attribute: .left, relatedBy: .equal,
                                                   toItem: textName, attribute: .left,
                                                   multiplier: 1, constant: 0))
        textName.addConstraint(NSLayoutConstraint(item: textName, attribute: .width, relatedBy: .equal,
                                                  toItem: nil, attribute: .notAnAttribute,
                                                  multiplier: 0, constant: 297))
        textName.addConstraint(NSLayoutConstraint(item: textName, attribute: .height, relatedBy: .equal,
                                                  toItem: nil, attribute: .notAnAttribute,
                                                  multiplier: 0, constant: 44))
        self.view.addConstraint(NSLayoutConstraint(item: textName, attribute: .centerX, relatedBy: .equal,
                                                   toItem: self.view, attribute: .centerX,
                                                   multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: textName, attribute: .top, relatedBy: .equal,
                                                   toItem: registerLabel, attribute: .bottom,
                                                   multiplier: 1, constant: 24))
        textPassWord.addConstraint(NSLayoutConstraint(item: textPassWord, attribute: .width, relatedBy: .equal,
                                                      toItem: nil, attribute: .notAnAttribute,
                                                      multiplier: 0, constant: 297))
        textPassWord.addConstraint(NSLayoutConstraint(item: textPassWord, attribute: .height, relatedBy: .equal,
                                                      toItem: nil, attribute: .notAnAttribute,
                                                      multiplier: 0, constant: 44))
        self.view.addConstraint(NSLayoutConstraint(item: textPassWord, attribute: .centerX, relatedBy: .equal,
                                                   toItem: self.view, attribute: .centerX,
                                                   multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: textPassWord, attribute: .top, relatedBy: .equal,
                                                   toItem: textName, attribute: .bottom,
                                                   multiplier: 1, constant: 10))
        textPassWordConfirm.addConstraint(NSLayoutConstraint(item: textPassWordConfirm, attribute: .width,
                                                             relatedBy: .equal,
                                                             toItem: nil, attribute: .notAnAttribute,
                                                             multiplier: 0, constant: 297))
        textPassWordConfirm.addConstraint(NSLayoutConstraint(item: textPassWordConfirm, attribute: .height,
                                                             relatedBy: .equal,
                                                             toItem: nil, attribute: .notAnAttribute,
                                                             multiplier: 0, constant: 44))
        self.view.addConstraint(NSLayoutConstraint(item: textPassWordConfirm, attribute: .centerX, relatedBy: .equal,
                                                   toItem: self.view, attribute: .centerX,
                                                   multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: textPassWordConfirm, attribute: .top, relatedBy: .equal,
                                                   toItem: textPassWord, attribute: .bottom,
                                                   multiplier: 1, constant: 10))
        registerButton.addConstraint(NSLayoutConstraint(item: registerButton, attribute: .width, relatedBy: .equal,
                                                        toItem: nil, attribute: .notAnAttribute,
                                                        multiplier: 0, constant: 297))
        registerButton.addConstraint(NSLayoutConstraint(item: registerButton, attribute: .height, relatedBy: .equal,
                                                        toItem: nil, attribute: .notAnAttribute,
                                                        multiplier: 0, constant: 44))
        self.view.addConstraint(NSLayoutConstraint(item: registerButton, attribute: .centerX, relatedBy: .equal,
                                                   toItem: self.view, attribute: .centerX,
                                                   multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: registerButton, attribute: .top, relatedBy: .equal,
                                                   toItem: textPassWordConfirm, attribute: .bottom,
                                                   multiplier: 1, constant: 40))
        displayButton.addConstraint(NSLayoutConstraint(item: displayButton, attribute: .width, relatedBy: .equal,
                                                       toItem: nil, attribute: .notAnAttribute,
                                                       multiplier: 0, constant: 50))
        displayButton.addConstraint(NSLayoutConstraint(item: displayButton, attribute: .height, relatedBy: .equal,
                                                       toItem: nil, attribute: .notAnAttribute,
                                                       multiplier: 0, constant: 32))
        self.view.addConstraint(NSLayoutConstraint(item: displayButton, attribute: .top, relatedBy: .equal,
                                                   toItem: textPassWordConfirm, attribute: .bottom,
                                                   multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: displayButton, attribute: .right, relatedBy: .equal,
                                                   toItem: textPassWordConfirm, attribute: .right,
                                                   multiplier: 1, constant: 0))
        errorLabel.addConstraint(NSLayoutConstraint(item: errorLabel, attribute: .width, relatedBy: .equal,
                                                    toItem: nil, attribute: .notAnAttribute,
                                                    multiplier: 0, constant: 120))
        errorLabel.addConstraint(NSLayoutConstraint(item: errorLabel, attribute: .height, relatedBy: .equal,
                                                    toItem: nil, attribute: .notAnAttribute,
                                                    multiplier: 0, constant: 32))
        self.view.addConstraint(NSLayoutConstraint(item: errorLabel, attribute: .top, relatedBy: .equal,
                                                   toItem: textPassWordConfirm, attribute: .bottom,
                                                   multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: errorLabel, attribute: .left, relatedBy: .equal,
                                                   toItem: textPassWordConfirm, attribute: .left,
                                                   multiplier: 1, constant: 0))
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    // 欢迎界面响应
    @objc func welcomePage() {
        // Client先检测两次密码是否一致，一致再进入服务器验证阶段
//        if textPassWord.text?.elementsEqual(textPassWordConfirm.text!) == true {
//            errorLabel.isHidden = true
//            requestAndResponse(email: textName.text, pwd: textPassWord.text,
//                               function: .register, method: .post) { [weak self] serverDescription in
//                if serverDescription.success! {
//                    let viewController = DisplayViewController()
//                    self?.navigationController?.pushViewController(viewController, animated: false)
//                } else {
//                    if serverDescription.error?.code == "user_invalid_email_format"{
//                        self?.errorLabel.text = "邮箱格式错误"
//                        self?.errorLabel.isHidden = false
//                        // 高亮邮箱
//                    } else if serverDescription.error?.code == "user_existed_email"{
//                        self?.errorLabel.text = "邮箱已注册"
//                        self?.errorLabel.isHidden = false
//                        // 高亮邮箱
//                    } else if serverDescription.error?.code == "user_invalid_password_length"{
//                        self?.errorLabel.text = "密码最少为8字符哦"
//                        self?.errorLabel.isHidden = false
//                        // 高亮密码
//                    }
//                }
//            }
//        } else {
//            errorLabel.text = "密码不一致"
//            errorLabel.isHidden = false
//        }
    }
    // 注册按钮变色响应
    @objc func textValueChanged() {
        if textName.text?.isEmpty == false && textPassWord.text?.isEmpty == false
            && textPassWordConfirm.text?.isEmpty == false {
            registerButton.backgroundColor = MyColor.greenColor
            registerButton.isEnabled = true
        } else {
            registerButton.backgroundColor = MyColor.grayColor
            registerButton.isEnabled = false
        }
    }
    // 显示-隐藏按钮响应 为什么开始要多点一次才触发 可能是初始状态设置，用断点检测
    @objc func displayButtonTapped() {
        if displayButton.isSelected == true {
            displayButton.setTitle("隐藏密码", for: .normal)
            displayButton.isSelected = false
            textPassWord.isSecureTextEntry = false
            textPassWordConfirm.isSecureTextEntry = false
        } else {
            displayButton.setTitle("显示密码", for: .normal)
            displayButton.isSelected = true
            textPassWord.isSecureTextEntry = true
            textPassWordConfirm.isSecureTextEntry = true
        }
    }
    // 错误提示标签重置
    @objc func resetErrorLabel() {
        if errorLabel.isHidden == false {
            errorLabel.isHidden = true
        }
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
