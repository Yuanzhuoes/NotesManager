//
//  ViewController.swift
//  test
//
//  Created by 李远卓 on 2021/6/1.
//
import UIKit
import SnapKit

class LoginViewController: UIViewController {
    private let loginView = LoginView()

    override func viewDidLoad() {
        super.viewDidLoad()
        try? DBManager.db?.createTable(table: SQLNote.self)
        setUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        setNavigationBar()
    }
}

private extension LoginViewController {
    func setUI() {
        self.view.addSubview(loginView)
        loginView.setUI()
        setNavigationBar()
        setTarget()
        setConstrains()
    }

    func setNavigationBar() {
        self.view.backgroundColor = UIColor.white
        self.title = ""
        self.navigationController?.navigationBar.tintColor = UIColor.greenColor
        // transparent navigationbar 
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }

    func setConstrains() {
        loginView.snp.makeConstraints {
            $0.bottom.top.width.height.equalToSuperview()
        }
    }

    func setTarget() {
        loginView.textName.addTarget(self, action: #selector(LoginViewController.changeButtonColor), for: .editingChanged)
        loginView.textPassWord.addTarget(self, action: #selector(LoginViewController.changeButtonColor), for: .editingChanged)
        loginView.textName.addTarget(self, action: #selector(LoginViewController.formatDetection), for: .editingDidEnd)
        loginView.textName.addTarget(self, action: #selector(LoginViewController.resetErrorLabel), for: .editingChanged)
        loginView.textPassWord.addTarget(self, action: #selector(LoginViewController.resetErrorLabel), for: .editingChanged)
        loginView.loginButton.addTarget(self, action: #selector(LoginViewController.login), for: .touchUpInside)
        loginView.eyeButton.addTarget(self, action: #selector(LoginViewController.changeEyeButton), for: .touchUpInside)
    }
}

// response function when login successfully
private extension LoginViewController {
    func setErrorLabel() {
        loginView.errorLabel.text = "账号或密码错误"
        loginView.errorLabel.isHidden = false
    }

    func saveLoginInfo(jwt: String?, name: String?, passWord: String?) {
        userAccount.set(jwt, forKey: UserDefaultKeys.AccountInfo.jwt.rawValue)
        userAccount.set(loginView.textName.text, forKey: UserDefaultKeys.AccountInfo.userName.rawValue)
        userAccount.set(loginView.textPassWord.text, forKey: UserDefaultKeys.AccountInfo.userPassword.rawValue)
    }

    func presentDisplayPage() {
        let viewController = DisplayViewController()
        navigationController?.pushViewController(viewController, animated: false)
        let bubble = MyAlertController.setBubble(title: "", message: "登录成功", action: false)
        presentBubbleAndDismiss(bubble)
    }
}

// selector function
private extension LoginViewController {
    @objc func login() {
        let userInfo = UserInfo(email: loginView.textName.text!, pwd: loginView.textPassWord.text)
        loginRequest(userInfo: userInfo) { response in
            if response.message == "背单词服务出错：账号或密码错误。" {
                self.setErrorLabel()
            } else {
                self.saveLoginInfo(jwt: response.jwt,
                                   name: self.loginView.textName.text,
                                   passWord: self.loginView.textPassWord.text)
                self.presentDisplayPage()
            }
        }
    }

    @objc func changeButtonColor() {
        if loginView.textName.text?.isEmpty == false && loginView.textPassWord.text?.isEmpty == false {
            loginView.loginButton.backgroundColor = UIColor.greenColor
            loginView.loginButton.isEnabled = true
        } else {
            loginView.loginButton.backgroundColor = UIColor.buttonDisabledColor
            loginView.loginButton.isEnabled = false
        }
    }

    @objc func changeEyeButton() {
        if loginView.eyeButton.isSelected {
            loginView.eyeButton.setImage(UIImage(named: "EyeOff")?
            .withTintColor(UIColor.eyeColor, renderingMode: .automatic), for: .normal)
            loginView.eyeButton.isSelected = false
            loginView.textPassWord.isSecureTextEntry = true
            loginView.eyeButton.imageEdgeInsets = UIEdgeInsets(top: 19, left: 16, bottom: 19, right: 16)
        } else {
            loginView.eyeButton.setImage(UIImage(named: "EyeOn")?
                                .withTintColor(UIColor.eyeColor, renderingMode: .automatic), for: .normal)
            loginView.eyeButton.imageEdgeInsets = UIEdgeInsets(top: 18, left: 16, bottom: 18, right: 16)
            loginView.eyeButton.isSelected = true
            loginView.textPassWord.isSecureTextEntry = false
        }
    }

    @objc func formatDetection() {
        if loginView.textName.text!.isValidateEmail {
            loginView.errorLabel.isHidden = true
        } else {
            loginView.errorLabel.text = "邮箱格式错误"
            loginView.errorLabel.isHidden = false
        }
    }

    @objc func resetErrorLabel() {
        if loginView.errorLabel.isHidden == false {
            loginView.errorLabel.isHidden = true
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    // dismiss keyboard when tap return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
