//
//  RegisterViewController.swift
//  test
//
//  Created by 李远卓 on 2021/6/4.
//

import UIKit
import Alamofire

class RegisterViewController: UIViewController, UITextFieldDelegate {

    var textName:UITextField!
    var textPassWord:UITextField!
    var textPassWordConfirm:UITextField!
    var errorLabel: UILabel!
    let displayButton = UIButton(type: .custom)
    var registerButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 导航控制器设置
        
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        // 1. 标签显示
        
        // 1.1 注册账号标签显示 如何根据字体大小动态调整frame?
        let registerLabel = UILabel()
        registerLabel.text = "账号注册"
        registerLabel.font = UIFont.systemFont(ofSize: 22)
        registerLabel.textColor = UIColor.init(red: 93/225.0, green: 93/225.0, blue: 93/225.0, alpha: 1)
        self.view.addSubview(registerLabel)
        
        registerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 2. 输入文本框
        // 2.1 邮箱输入
        textName = UITextField()
        textName.borderStyle = UITextField.BorderStyle.roundedRect
        textName.placeholder = "请输入邮箱"
        textName.returnKeyType = UIReturnKeyType.done // ?
        textName.clearButtonMode = UITextField.ViewMode.never // 编辑时显示删除图标
        textName.keyboardType = UIKeyboardType.emailAddress // 键盘类型为邮箱
        
        // 2.2 密码输入
        textPassWord = UITextField()
        textPassWord.center = self.view.center
        textPassWord.borderStyle = UITextField.BorderStyle.roundedRect
        textPassWord.placeholder = "请设置密码（8个字符以上）"
        textPassWord.returnKeyType = UIReturnKeyType.done // ?
        textPassWord.keyboardType = UIKeyboardType.default // 键盘类型为邮箱
        textPassWord.isSecureTextEntry = true // 是否安全输入 小圆点 和按钮交互
        
        // 2.3 确认密码输入
        textPassWordConfirm = UITextField()
        textPassWordConfirm.borderStyle = UITextField.BorderStyle.roundedRect
        textPassWordConfirm.placeholder = "请确认密码"
        textPassWordConfirm.returnKeyType = UIReturnKeyType.done // ?
        textPassWordConfirm.keyboardType = UIKeyboardType.default // 键盘类型为邮箱
        textPassWordConfirm.isSecureTextEntry = true // 是否安全输入 小圆点 和按钮交互
        
        // 2.4 全部有输入后高亮
        textName.addTarget(self, action: #selector(RegisterViewController.textValueChanged), for: UIControl.Event.editingChanged)
        textPassWord.addTarget(self, action: #selector(RegisterViewController.textValueChanged), for: UIControl.Event.editingChanged)
        textPassWordConfirm.addTarget(self, action: #selector(RegisterViewController.textValueChanged), for: UIControl.Event.editingChanged)
        
        // 2.5 再次编辑密码时标签隐藏
        textPassWord.addTarget(self, action: #selector(LoginViewController.resetErrorLabel), for: .editingChanged)
        textPassWordConfirm.addTarget(self, action: #selector(LoginViewController.resetErrorLabel), for: .editingChanged)
        
        
        textName.delegate = self
        textPassWord.delegate = self
        textPassWordConfirm.delegate = self
        
        self.view.addSubview(textName)
        self.view.addSubview(textPassWord)
        self.view.addSubview(textPassWordConfirm)
        
        textName.translatesAutoresizingMaskIntoConstraints = false
        textPassWord.translatesAutoresizingMaskIntoConstraints = false
        textPassWordConfirm.translatesAutoresizingMaskIntoConstraints = false
        
        
        // 3. 按钮显示
        
        // 3.1 注册按钮
        registerButton.backgroundColor = UIColor.init(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1)
        registerButton.setTitle("注册", for: .normal)
        registerButton.setTitleColor(UIColor.white, for: .normal)
        registerButton.isEnabled = false
        
        // 3.1.1 注册按钮点击后请求服务器连接，转入欢迎界面
        registerButton.addTarget(self, action: #selector(LoginViewController.welcomePage), for: UIControl.Event.touchUpInside)
        self.view.addSubview(registerButton)
        
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        
        // 3.2 显示-隐藏按钮
        displayButton.setTitle("显示密码", for: .normal)
        displayButton.titleLabel!.font = UIFont.systemFont(ofSize: 12)
        displayButton.setTitleColor(UIColor(red:54/255.0,green:181/255.0,blue:157/255.0,alpha: 1), for: .normal)
        displayButton.isSelected = true
        
        // 3.2.1 点击切换状态
        displayButton.addTarget(self, action: #selector(RegisterViewController.displayButtonTapped), for: UIControl.Event.touchUpInside)
        
        self.view.addSubview(displayButton)
        
        displayButton.translatesAutoresizingMaskIntoConstraints = false
        
        // 1.2 错误信息标签显示
        errorLabel.font = UIFont.systemFont(ofSize: 12)
        errorLabel.textColor = UIColor.init(red: 220/225.0, green: 102/225.0, blue: 62/225.0, alpha: 1)
        errorLabel.isHidden = true
        self.view.addSubview(errorLabel)
        
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 约束
        registerLabel.addConstraint(NSLayoutConstraint(item: registerLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 128))
        registerLabel.addConstraint(NSLayoutConstraint(item: registerLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 22))
        self.view.addConstraint(NSLayoutConstraint(item: registerLabel, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 124))
        self.view.addConstraint(NSLayoutConstraint(item: registerLabel, attribute: .left, relatedBy: .equal, toItem: textName, attribute: .left, multiplier: 1, constant: 0))
        
        textName.addConstraint(NSLayoutConstraint(item: textName!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 297))
        textName.addConstraint(NSLayoutConstraint(item: textName!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 44))
        self.view.addConstraint(NSLayoutConstraint(item: textName!, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: textName!, attribute: .top, relatedBy: .equal, toItem: registerLabel, attribute: .bottom, multiplier: 1, constant: 24))
        
        textPassWord.addConstraint(NSLayoutConstraint(item: textPassWord!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 297))
        textPassWord.addConstraint(NSLayoutConstraint(item: textPassWord!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 44))
        self.view.addConstraint(NSLayoutConstraint(item: textPassWord!, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: textPassWord!, attribute: .top, relatedBy: .equal, toItem: textName, attribute: .bottom, multiplier: 1, constant: 10))
        
        textPassWordConfirm.addConstraint(NSLayoutConstraint(item: textPassWordConfirm!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 297))
        textPassWordConfirm.addConstraint(NSLayoutConstraint(item: textPassWordConfirm!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 44))
        self.view.addConstraint(NSLayoutConstraint(item: textPassWordConfirm!, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: textPassWordConfirm!, attribute: .top, relatedBy: .equal, toItem: textPassWord, attribute: .bottom, multiplier: 1, constant: 10))
        
        registerButton.addConstraint(NSLayoutConstraint(item: registerButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 297))
        registerButton.addConstraint(NSLayoutConstraint(item: registerButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 44))
        self.view.addConstraint(NSLayoutConstraint(item: registerButton, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: registerButton, attribute: .top, relatedBy: .equal, toItem: textPassWordConfirm, attribute: .bottom, multiplier: 1, constant: 40))
        
        displayButton.addConstraint(NSLayoutConstraint(item: displayButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 50))
        displayButton.addConstraint(NSLayoutConstraint(item: displayButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 32))
        self.view.addConstraint(NSLayoutConstraint(item: displayButton, attribute: .top, relatedBy: .equal, toItem: textPassWordConfirm, attribute: .bottom, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: displayButton, attribute: .right, relatedBy: .equal, toItem: textPassWordConfirm, attribute: .right, multiplier: 1, constant: 0))
        
        errorLabel.addConstraint(NSLayoutConstraint(item: errorLabel!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 120))
        errorLabel.addConstraint(NSLayoutConstraint(item: errorLabel!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 32))
        self.view.addConstraint(NSLayoutConstraint(item: errorLabel!, attribute: .top, relatedBy: .equal, toItem: textPassWordConfirm, attribute: .bottom, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: errorLabel!, attribute: .left, relatedBy: .equal, toItem: textPassWordConfirm, attribute: .left, multiplier: 1, constant: 0))
        
        
    }
    
    func textFieldShouldReturn(_ textName: UITextField) -> Bool {
        textName.resignFirstResponder()
        return true
    }
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
        let success: Bool?
    }
    //
    func registerResponse(completion: @escaping (ServerDescription)->Void) {
        let parameters: [String: String] = [
            "email": textName.text!,
            "password": textPassWord.text!,
        ]
        let url = "http://47.96.170.11/api/v1/user/register"
        AF.request(url, method: .post, parameters: parameters).responseJSON {
            // 大括号是closure，匿名函数，response是参数，捕获上下文
            response in
            switch response.result {
                // 请求成功
            case .success(let json):
                    guard let data = response.data else { return }
                    do {
                        let ServerDescription = try JSONDecoder().decode(ServerDescription.self, from: data)
                        completion(ServerDescription)
                        print(json)
                    }
                    catch let jsonErr {
                            print("json 解析出错 : ", jsonErr)
                    }
                case .failure(let error):
                    print(error)
            }
        }

    }
    // 欢迎界面响应
    @objc func welcomePage(){
        // Client先检测两次密码是否一致，一致再进入服务器验证阶段
        if textPassWord.text?.elementsEqual(textPassWordConfirm.text!) == true {
            errorLabel.isHidden = true
            registerResponse { [self] ServerDescription in
                if ServerDescription.success!{
                    let viewController = WelcomeViewController()
                    self.navigationController?.pushViewController(viewController, animated: false)
                }
                else {
                    // 服务器逻辑有问题？
                    // 应该先检测邮箱格式-〉邮箱是否注册-〉密码格式
                    // 测试结果是邮箱格式-〉密码格式-〉邮箱是否注册
                    // 且服务器不会检测两次密码是否一致
                    // 交互需求文档的注册单元逻辑和流程图不符
                    if ServerDescription.error?.code == "user_invalid_email_format"{
                        errorLabel.text = "邮箱格式错误"
                        errorLabel.isHidden = false
                        // 高亮邮箱
                    }
                    else if ServerDescription.error?.code == "user_existed_email"{
                        errorLabel.text = "邮箱已注册"
                        errorLabel.isHidden = false
                        // 高亮邮箱
                    }
                    else if ServerDescription.error?.code == "user_invalid_password_length"{
                        errorLabel.text = "密码最少为8字符哦"
                        errorLabel.isHidden = false
                        // 高亮密码
                    }
                }
            }
        }
        else{
            errorLabel.text = "密码不一致"
            errorLabel.isHidden = false
        }
        
    }
    
    // 注册按钮变色响应
    @objc func textValueChanged(){
        if textName.text?.isEmpty == false && textPassWord.text?.isEmpty == false && textPassWordConfirm.text?.isEmpty == false {
            registerButton.backgroundColor = UIColor.init(red:54/255.0, green:181/255.0, blue:157/255.0,alpha: 1)
            registerButton.isEnabled = true
        }
        else{
            registerButton.backgroundColor = UIColor.init(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1)
            registerButton.isEnabled = false
        }
    }
    
    // 显示-隐藏按钮响应 为什么开始要多点一次才触发 可能是初始状态设置，用断点检测
    @objc func displayButtonTapped(){
        if displayButton.isSelected == true{
            
            displayButton.setTitle("隐藏密码", for: .normal)
            displayButton.isSelected = false
            
            textPassWord.isSecureTextEntry = false
            textPassWordConfirm.isSecureTextEntry = false
            
        }
        else{
            
            displayButton.setTitle("显示密码", for: .normal)
            displayButton.isSelected = true
            
            textPassWord.isSecureTextEntry = true
            textPassWordConfirm.isSecureTextEntry = true
        }
    }
    
    // 错误提示标签重置
    @objc func resetErrorLabel(){
        if (errorLabel.isHidden == false){
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
