//
//  LoginView.swift
//  test
//
//  Created by 李远卓 on 2021/7/28.
//

import UIKit

class LoginView: UIView {
    let textName = LineTextField()
    let textPassWord = LineTextField()
    let errorLabel = UILabel()
    let loginView = UIImageView()
    let loginButton = UIButton(type: .system)
    let eyeButton = UIButton(type: .custom)

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        // user email input field
        textName.borderStyle = UITextField.BorderStyle.none
        textName.placeholder = "请输入邮箱"
        textName.returnKeyType = UIReturnKeyType.done // returnKey title is done
        textName.clearButtonMode = UITextField.ViewMode.never // delete icon mode
        textName.keyboardType = UIKeyboardType.emailAddress // keyboardType is email type
        textName.tintColor = UIColor.greenColor
        textName.textColor = UIColor.textColor

        // user pwd input field
        textPassWord.borderStyle = UITextField.BorderStyle.none
        textPassWord.placeholder = "请输入密码"
        textPassWord.returnKeyType = UIReturnKeyType.done
        textPassWord.clearButtonMode = UITextField.ViewMode.never
        textPassWord.keyboardType = UIKeyboardType.emailAddress
        textPassWord.isSecureTextEntry = true // black dot
        textPassWord.tintColor = UIColor.greenColor
        textPassWord.textColor = UIColor.textColor
        textPassWord.rightView = eyeButton
        textPassWord.rightViewMode = .always

        textName.text = userAccount.string(forKey: UserDefaultKeys.AccountInfo.userName.rawValue)
        textPassWord.text = userAccount.string(forKey: UserDefaultKeys.AccountInfo.userPassword.rawValue)
    }

    func setButton() {
        loginButton.setTitle("登陆", for: .normal)
        loginButton.setTitleColor(UIColor.white, for: .normal)
        loginButton.layer.cornerRadius = 5
        loginButton.backgroundColor = UIColor.greenColor
        loginButton.isEnabled = true
        eyeButton.setImage(UIImage(named: "EyeOff")?
                            .withTintColor(UIColor.eyeColor, renderingMode: .automatic), for: .normal)
        // change size of custom image
        eyeButton.imageEdgeInsets = UIEdgeInsets(top: 19, left: 16, bottom: 19, right: 16)
        // disable highlight status of button
        eyeButton.adjustsImageWhenHighlighted = false
    }

    func setConstraints() {
        loginView.snp.makeConstraints {
            $0.width.equalTo(192)
            $0.height.equalTo(64)
            $0.top.equalToSuperview().offset(124)
            $0.centerX.equalToSuperview()
        }
        textName.snp.makeConstraints {
            $0.width.equalTo(297)
            $0.height.equalTo(44)
            $0.top.equalTo(loginView.snp.bottom).offset(48)
            $0.centerX.equalToSuperview()
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
        errorLabel.snp.makeConstraints {
            $0.width.equalTo(120)
            $0.height.equalTo(32)
            $0.left.equalTo(textPassWord)
            $0.top.equalTo(textPassWord.snp.bottom)
        }
    }

    func setSubView() {
        self.addSubview(errorLabel)
        self.addSubview(loginView)
        self.addSubview(textName)
        self.addSubview(textPassWord)
        self.addSubview(loginButton)
    }

    func setUI() {
        setTextFiled()
        setImage()
        setButton()
        setLabel()
        setSubView()
        setConstraints()
    }
}
