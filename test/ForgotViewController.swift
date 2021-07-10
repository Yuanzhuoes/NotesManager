//
//  ForgotViewController.swift
//  test
//
//  Created by 李远卓 on 2021/6/5.
//

import UIKit

class ForgotViewController: UIViewController, UITextFieldDelegate {
    let textName = LineTextField()
    let textVerify = LineTextField()
    let textNewPassWord = LineTextField()
    let getCodeButton = UIButton(type: .custom) // custom
    let modifyButton = UIButton(type: .system)
    let eyeButton = UIButton(type: .custom)
    let errorLabel = UILabel()
    var countdownTimer: Timer?
    // 声明一个闭包类型，没有默认的定义，需要调用的时候自定义
    typealias MyClosure = (_ text: String) -> Void
    var myClosure: MyClosure?
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        // 1. 标签显示
        // 1.1 注册账号标签显示 如何根据字体大小动态调整frame?
        let registerLabel = UILabel()
        registerLabel.text = "忘记密码"
        registerLabel.font = UIFont.systemFont(ofSize: 22)
        registerLabel.textColor = MyColor.textColor
        self.view.addSubview(registerLabel)
        registerLabel.translatesAutoresizingMaskIntoConstraints = false
        // 1.2 错误信息标签显示 先隐藏了 具体是啥最后填
        errorLabel.font = UIFont.systemFont(ofSize: 12)
        errorLabel.textColor = MyColor.errorColor
        errorLabel.isHidden = true
        self.view.addSubview(errorLabel)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        // 2. 输入文本框
        // 2.1 邮箱输入
        textName.borderStyle = UITextField.BorderStyle.none
        textName.placeholder = "请输入邮箱"
        textName.returnKeyType = UIReturnKeyType.done // ?
        textName.clearButtonMode = UITextField.ViewMode.never // 编辑时显示删除图标
        textName.keyboardType = UIKeyboardType.emailAddress // 键盘类型为邮箱
        textName.tintColor = MyColor.greenColor
        textName.textColor = MyColor.textColor
        // 2.2 验证码输入
        textVerify.borderStyle = UITextField.BorderStyle.none
        textVerify.placeholder = "请输入验证码"
        textVerify.returnKeyType = UIReturnKeyType.done // ?
        textVerify.keyboardType = UIKeyboardType.emailAddress // 键盘类型为邮箱
        textVerify.tintColor = MyColor.greenColor
        textVerify.textColor = MyColor.textColor
        // 关闭默认大小写
        textVerify.autocapitalizationType = UITextAutocapitalizationType.none
        textVerify.tintColor = MyColor.greenColor
        // 2.3 确认密码输入
        textNewPassWord.borderStyle = UITextField.BorderStyle.none
        textNewPassWord.placeholder = "请输入新密码"
        textNewPassWord.returnKeyType = UIReturnKeyType.done // ?
        textNewPassWord.keyboardType = UIKeyboardType.emailAddress // 键盘类型为邮箱
        textNewPassWord.isSecureTextEntry = true // 是否安全输入 小圆点 和按钮交互
        textNewPassWord.tintColor = MyColor.greenColor
        textNewPassWord.textColor = MyColor.textColor

        // 输入->修改按钮高亮
        textName.addTarget(self, action: #selector(ForgotViewController.textValueChanged), for: .editingChanged)
        textVerify.addTarget(self, action: #selector(ForgotViewController.textValueChanged), for: .editingChanged)
        textNewPassWord.addTarget(self, action: #selector(ForgotViewController.textValueChanged), for: .editingChanged)
        // 邮箱输入->获取验证码高亮
        textName.addTarget(self, action: #selector(getCodeEnable), for: UIControl.Event.editingChanged)
        // 提示标签重置
        textName.addTarget(self, action: #selector(LoginViewController.resetErrorLabel), for: .editingChanged)
        textNewPassWord.addTarget(self, action: #selector(LoginViewController.resetErrorLabel), for: .editingChanged)
        textName.delegate = self
        textVerify.delegate = self
        textNewPassWord.delegate = self
        self.view.addSubview(textName)
        self.view.addSubview(textVerify)
        self.view.addSubview(textNewPassWord)
        textName.translatesAutoresizingMaskIntoConstraints = false
        textVerify.translatesAutoresizingMaskIntoConstraints = false
        textNewPassWord.translatesAutoresizingMaskIntoConstraints = false
        // 3. 按钮显示
        // 3.1 修改按钮
        modifyButton.setTitle("修改", for: .normal)
        modifyButton.setTitleColor(UIColor.white, for: .normal)
        modifyButton.isEnabled = false
        modifyButton.layer.cornerRadius = 5
        modifyButton.backgroundColor = MyColor.buttonDisabledColor
        modifyButton.addTarget(self, action: #selector(loginPage), for: .touchUpInside)
        self.view.addSubview(modifyButton)
        modifyButton.translatesAutoresizingMaskIntoConstraints = false
        // 3.2 显示-隐藏按钮
        eyeButton.setImage(UIImage(named: "EyeOff")?
            .withTintColor(MyColor.eyeColor, renderingMode: .automatic), for: .normal)
        eyeButton.adjustsImageWhenHighlighted = false
        // 更改自定义图片的大小 先不管 找合适的图片就好
        eyeButton.imageEdgeInsets = UIEdgeInsets(top: 19, left: 16, bottom: 19, right: 16)
        eyeButton.addTarget(self, action: #selector(ForgotViewController.eyeButtonTapped), for: .touchUpInside)
        self.view.addSubview(eyeButton)
        eyeButton.translatesAutoresizingMaskIntoConstraints = false
                // 3.3 获取验证码按钮
        getCodeButton.setTitle("获取验证码", for: .normal)
        getCodeButton.setTitleColor(MyColor.grayColor, for: .normal)
        // 字体右对齐
        getCodeButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
        getCodeButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        getCodeButton.isEnabled = false
        // 3.3.1 点击获取验证码
        getCodeButton.addTarget(self, action: #selector(getCode), for: .touchUpInside)
        self.view.addSubview(getCodeButton)
        getCodeButton.translatesAutoresizingMaskIntoConstraints = false
        // 添加约束的另一写法
        NSLayoutConstraint.activate([NSLayoutConstraint(item: registerLabel, attribute: .width, relatedBy: .equal,
                                    toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 128)])
        NSLayoutConstraint.activate([NSLayoutConstraint(item: registerLabel, attribute: .height, relatedBy: .equal,
                                    toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 22)])
        NSLayoutConstraint.activate([NSLayoutConstraint(item: registerLabel, attribute: .top, relatedBy: .equal,
                                    toItem: self.view, attribute: .top, multiplier: 1, constant: 124)])
        NSLayoutConstraint.activate([NSLayoutConstraint(item: registerLabel, attribute: .left, relatedBy: .equal,
                                    toItem: textName, attribute: .left, multiplier: 1, constant: 0)])
        textName.addConstraint(NSLayoutConstraint(item: textName, attribute: .width, relatedBy: .equal,
                                    toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 297))
        textName.addConstraint(NSLayoutConstraint(item: textName, attribute: .height, relatedBy: .equal,
                                    toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 44))
        self.view.addConstraint(NSLayoutConstraint(item: textName, attribute: .centerX, relatedBy: .equal,
                                    toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: textName, attribute: .top, relatedBy: .equal,
                                    toItem: registerLabel, attribute: .bottom, multiplier: 1, constant: 24))
        textVerify.addConstraint(NSLayoutConstraint(item: textVerify, attribute: .width, relatedBy: .equal,
                                    toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 297))
        textVerify.addConstraint(NSLayoutConstraint(item: textVerify, attribute: .height, relatedBy: .equal,
                                    toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 44))
        self.view.addConstraint(NSLayoutConstraint(item: textVerify, attribute: .centerX, relatedBy: .equal,
                                    toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: textVerify, attribute: .top, relatedBy: .equal,
                                    toItem: textName, attribute: .bottom, multiplier: 1, constant: 10))
        textNewPassWord.addConstraint(NSLayoutConstraint(item: textNewPassWord, attribute: .width, relatedBy: .equal,
                                    toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 297))
        textNewPassWord.addConstraint(NSLayoutConstraint(item: textNewPassWord, attribute: .height, relatedBy: .equal,
                                    toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 44))
        self.view.addConstraint(NSLayoutConstraint(item: textNewPassWord, attribute: .centerX, relatedBy: .equal,
                                    toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: textNewPassWord, attribute: .top, relatedBy: .equal,
                                    toItem: textVerify, attribute: .bottom, multiplier: 1, constant: 10))
        getCodeButton.addConstraint(NSLayoutConstraint(item: getCodeButton, attribute: .width, relatedBy: .equal,
                                    toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 120))
        getCodeButton.addConstraint(NSLayoutConstraint(item: getCodeButton, attribute: .height, relatedBy: .equal,
                                    toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 44))
        self.view.addConstraint(NSLayoutConstraint(item: getCodeButton, attribute: .right, relatedBy: .equal,
                                    toItem: textVerify, attribute: .right, multiplier: 1, constant: -6))
        self.view.addConstraint(NSLayoutConstraint(item: getCodeButton, attribute: .top, relatedBy: .equal,
                                    toItem: textVerify, attribute: .top, multiplier: 1, constant: 0))
        eyeButton.addConstraint(NSLayoutConstraint(item: eyeButton, attribute: .width, relatedBy: .equal,
                                    toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 44))
        eyeButton.addConstraint(NSLayoutConstraint(item: eyeButton, attribute: .height, relatedBy: .equal,
                                    toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 44))
        self.view.addConstraint(NSLayoutConstraint(item: eyeButton, attribute: .top, relatedBy: .equal,
                                    toItem: textNewPassWord, attribute: .top, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: eyeButton, attribute: .right, relatedBy: .equal,
                                    toItem: textNewPassWord, attribute: .right, multiplier: 1, constant: 0))
        errorLabel.addConstraint(NSLayoutConstraint(item: errorLabel, attribute: .width, relatedBy: .equal,
                                    toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 80))
        errorLabel.addConstraint(NSLayoutConstraint(item: errorLabel, attribute: .height, relatedBy: .equal,
                                    toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 32))
        self.view.addConstraint(NSLayoutConstraint(item: errorLabel, attribute: .top, relatedBy: .equal,
                                    toItem: textNewPassWord, attribute: .bottom, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: errorLabel, attribute: .left, relatedBy: .equal,
                                    toItem: textNewPassWord, attribute: .left, multiplier: 1, constant: 0))
        modifyButton.addConstraint(NSLayoutConstraint(item: modifyButton, attribute: .width, relatedBy: .equal,
                                    toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 297))
        modifyButton.addConstraint(NSLayoutConstraint(item: modifyButton, attribute: .height, relatedBy: .equal,
                                    toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 44))
        self.view.addConstraint(NSLayoutConstraint(item: modifyButton, attribute: .centerX, relatedBy: .equal,
                                    toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: modifyButton, attribute: .top, relatedBy: .equal,
                                    toItem: textNewPassWord, attribute: .bottom, multiplier: 1, constant: 40))
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @objc func getCode() {
//        requestAndResponse(email: textName.text,
//                           function: .verify_code, method: .get) { [weak self] serverDescription in
//            if serverDescription.success! {
//                self?.errorLabel.text = "验证码已发送"
//                self?.errorLabel.isHidden = false
//                // 按钮灰，倒计时，计时完变色，可重发验证码
//                self?.isCounting = true
//            } else {
//                // 气泡提示？
//                if serverDescription.error?.code == "user_invalid_email_format"{
//                    self?.errorLabel.text = "邮箱格式错误"
//                } else if serverDescription.error?.code == "user_invalid_user"{
//                    self?.errorLabel.text = "该用户不存在"
//                }
//                self?.errorLabel.isHidden = false
//            }
//        }
    }
    @objc func loginPage() {
//        requestAndResponse(email: textName.text, pwd: textNewPassWord.text, code: textVerify.text,
//                           function: .reset, method: .post) { [self] serverDescription in
//            if serverDescription.success! {
//                // 通过调用闭包把栈上.text局部变量放到堆上
//                myClosure?(textName.text!)
//                self.navigationController?.popToRootViewController(animated: false)
//            } else {
//                if serverDescription.error?.code == "verify_code_invalid_verify_code"{
//                    errorLabel.text = "无效验证码"
//                    errorLabel.isHidden = false
//                } else if serverDescription.error?.code == "user_invalid_password_length"{
//                    errorLabel.text = "密码长度错误"
//                    errorLabel.isHidden = false
//                }
//            }
//        }
    }
    @objc func textValueChanged() {
        if textName.text?.isEmpty == false && textVerify.text?.isEmpty == false
            && textNewPassWord.text?.isEmpty == false {
            modifyButton.backgroundColor = MyColor.greenColor
            modifyButton.isEnabled = true
        } else {
            modifyButton.backgroundColor = MyColor.buttonDisabledColor
            modifyButton.isEnabled = false
        }
    }
    @objc func eyeButtonTapped() {
        if eyeButton.isSelected {
            eyeButton.setImage(UIImage(named: "EyeOff")?
                                .withTintColor(MyColor.eyeColor, renderingMode: .automatic), for: .normal)
            eyeButton.isSelected = false
            textNewPassWord.isSecureTextEntry = true
        } else {
            // 颜色显示有问题
            eyeButton.setImage(UIImage(named: "EyeOn")?
                                .withTintColor(MyColor.eyeColor, renderingMode: .automatic), for: .normal)
            eyeButton.imageEdgeInsets = UIEdgeInsets(top: 18, left: 16, bottom: 18, right: 16)
            eyeButton.isSelected = true
            textNewPassWord.isSecureTextEntry = false
        }
    }
    // 倒计时
    var remainingSeconds: Int = 0 {
        willSet {
            getCodeButton.setTitle("\(newValue)秒后重新获取", for: .normal)
            getCodeButton.setTitleColor(MyColor.grayColor, for: .normal)
            if newValue <= 0 {
                getCodeButton.setTitle("重新获取验证码", for: .normal)
                getCodeButton.setTitleColor(MyColor.greenColor, for: .normal)
                isCounting = false
            }
        }
    }
    var isCounting = false {
        willSet {
            if newValue {
                countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector:
                                    #selector(updateTime), userInfo: nil, repeats: true)
                remainingSeconds = 60
            } else {
                countdownTimer?.invalidate()
                countdownTimer = nil
            }
            getCodeButton.isEnabled = !newValue
        }
    }
    @objc func updateTime(timer: Timer) {
         // 计时开始时，逐秒减少remainingSeconds的值
        remainingSeconds -= 1
    }
    // 邮箱有输入，激活按钮
    @objc func getCodeEnable() {
        if textName.text?.isEmpty == true {
            getCodeButton.isEnabled = false
            getCodeButton.setTitleColor(MyColor.grayColor, for: .normal)
        } else {
            getCodeButton.isEnabled = true
            getCodeButton.setTitleColor(MyColor.greenColor, for: .normal)
        }
    }
    // 标签重置响应
    @objc func resetErrorLabel() {
        if errorLabel.isHidden == false {
            errorLabel.isHidden = true
        }
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
