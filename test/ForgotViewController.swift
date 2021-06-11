//
//  ForgotViewController.swift
//  test
//
//  Created by 李远卓 on 2021/6/5.
//

import UIKit
import Alamofire

class ForgotViewController: UIViewController, UITextFieldDelegate {

    var textName:UITextField!
    var textVerify:UITextField!
    var textNewPassWord:UITextField!
    let getCodeButton = UIButton(type: .custom) // custom
    let modifyButton = UIButton(type: .system)
    let eyeButton = UIButton(type: .custom)
    let errorLabel = UILabel()
    var countdownTimer: Timer?
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        // 1. 标签显示
        
        // 1.1 注册账号标签显示 如何根据字体大小动态调整frame?
        let registerLabel = UILabel()
        registerLabel.text = "忘记密码"
        registerLabel.font = UIFont.systemFont(ofSize: 22)
        registerLabel.textColor = UIColor.init(red: 93/225.0, green: 93/225.0, blue: 93/225.0, alpha: 1)
        self.view.addSubview(registerLabel)
        registerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 1.2 错误信息标签显示 先隐藏了 具体是啥最后填
        errorLabel.font = UIFont.systemFont(ofSize: 12)
        errorLabel.textColor = UIColor.init(red: 220/225.0, green: 102/225.0, blue: 62/225.0, alpha: 1)
        errorLabel.isHidden = true
        self.view.addSubview(errorLabel)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        // 2. 输入文本框
        // 2.1 邮箱输入
        textName = UITextField()
        textName.borderStyle = UITextField.BorderStyle.roundedRect
        textName.placeholder = "请输入邮箱"
        textName.returnKeyType = UIReturnKeyType.done // ?
        textName.clearButtonMode = UITextField.ViewMode.never // 编辑时显示删除图标
        textName.keyboardType = UIKeyboardType.emailAddress // 键盘类型为邮箱
        
        // 2.2 验证码输入
        textVerify = UITextField()
        textVerify.borderStyle = UITextField.BorderStyle.roundedRect
        textVerify.placeholder = "请输入验证码"
        textVerify.returnKeyType = UIReturnKeyType.done // ?
        textVerify.keyboardType = UIKeyboardType.emailAddress // 键盘类型为邮箱
        // 关闭默认大小写
        textVerify.autocapitalizationType = UITextAutocapitalizationType.none

        
        // 2.3 确认密码输入
        textNewPassWord = UITextField()
        textNewPassWord.borderStyle = UITextField.BorderStyle.roundedRect
        textNewPassWord.placeholder = "请输入新密码"
        textNewPassWord.returnKeyType = UIReturnKeyType.done // ?
        textNewPassWord.keyboardType = UIKeyboardType.emailAddress // 键盘类型为邮箱
        textNewPassWord.isSecureTextEntry = true // 是否安全输入 小圆点 和按钮交互
        
        // 输入->修改按钮高亮
        textName.addTarget(self, action: #selector(ForgotViewController.textValueChanged), for: UIControl.Event.editingChanged)
        textVerify.addTarget(self, action: #selector(ForgotViewController.textValueChanged), for: UIControl.Event.editingChanged)
        textNewPassWord.addTarget(self, action: #selector(ForgotViewController.textValueChanged), for: UIControl.Event.editingChanged)
        
        //邮箱输入->获取验证码高亮
        textName.addTarget(self, action: #selector(getCodeEnable), for: UIControl.Event.editingChanged)
        
        //提示标签重置
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
        modifyButton.backgroundColor = UIColor.init(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1)
        modifyButton.setTitle("修改", for: .normal)
        modifyButton.setTitleColor(UIColor.white, for: .normal)
        modifyButton.isEnabled = false
        modifyButton.addTarget(self, action: #selector(loginPage), for: .touchUpInside)
        self.view.addSubview(modifyButton)
        modifyButton.translatesAutoresizingMaskIntoConstraints = false
        
        // 3.2 显示-隐藏按钮
        eyeButton.setImage(UIImage(named: "EyeOff"), for: .normal)
        // 更改自定义图片的颜色
        eyeButton.tintColor = UIColor(red:170/255.0,green:170/255.0,blue:170/255.0,alpha: 1)
        // 更改自定义图片的大小 先不管 找合适的图片就好
        eyeButton.imageEdgeInsets = UIEdgeInsets(top: 28, left:28, bottom:28, right:28)
        eyeButton.addTarget(self, action: #selector(LoginViewController.eyeButtonTapped), for: UIControl.Event.touchUpInside)
        self.view.addSubview(eyeButton)
        eyeButton.translatesAutoresizingMaskIntoConstraints = false
        
        // 3.3 获取验证码按钮
        getCodeButton.setTitle("获取验证码", for: .normal)
        getCodeButton.setTitleColor(UIColor(red:142/255.0,green:142/255.0,blue:142/255.0,alpha: 1), for: .normal)
        // 字体右对齐
        getCodeButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
        getCodeButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        getCodeButton.isEnabled = false
        // 3.3.1 点击获取验证码
        getCodeButton.addTarget(self, action: #selector(getCode), for: .touchUpInside)
        self.view.addSubview(getCodeButton)
        getCodeButton.translatesAutoresizingMaskIntoConstraints = false
        
        // 约束 为什么写在一起，相互之间的顺序才不会有影响，而写在每个控件的后边就不行
        registerLabel.addConstraint(NSLayoutConstraint(item: registerLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 128))
        registerLabel.addConstraint(NSLayoutConstraint(item: registerLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 22))
        self.view.addConstraint(NSLayoutConstraint(item: registerLabel, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 124))
        self.view.addConstraint(NSLayoutConstraint(item: registerLabel, attribute: .left, relatedBy: .equal, toItem: textName, attribute: .left, multiplier: 1, constant: 0))
        
        textName.addConstraint(NSLayoutConstraint(item: textName!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 297))
        textName.addConstraint(NSLayoutConstraint(item: textName!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 44))
        self.view.addConstraint(NSLayoutConstraint(item: textName!, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: textName!, attribute: .top, relatedBy: .equal, toItem: registerLabel, attribute: .bottom, multiplier: 1, constant: 24))
        
        textVerify.addConstraint(NSLayoutConstraint(item: textVerify!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 297))
        textVerify.addConstraint(NSLayoutConstraint(item: textVerify!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 44))
        self.view.addConstraint(NSLayoutConstraint(item: textVerify!, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: textVerify!, attribute: .top, relatedBy: .equal, toItem: textName, attribute: .bottom, multiplier: 1, constant: 10))
        
        textNewPassWord.addConstraint(NSLayoutConstraint(item: textNewPassWord!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 297))
        textNewPassWord.addConstraint(NSLayoutConstraint(item: textNewPassWord!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 44))
        self.view.addConstraint(NSLayoutConstraint(item: textNewPassWord!, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: textNewPassWord!, attribute: .top, relatedBy: .equal, toItem: textVerify, attribute: .bottom, multiplier: 1, constant: 10))
        
        getCodeButton.addConstraint(NSLayoutConstraint(item: getCodeButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 120))
        getCodeButton.addConstraint(NSLayoutConstraint(item: getCodeButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 44))
        self.view.addConstraint(NSLayoutConstraint(item: getCodeButton, attribute: .right, relatedBy: .equal, toItem: textVerify, attribute: .right, multiplier: 1, constant: -6))
        self.view.addConstraint(NSLayoutConstraint(item: getCodeButton, attribute: .top, relatedBy: .equal, toItem: textVerify, attribute: .top, multiplier: 1, constant: 0))
        
        eyeButton.addConstraint(NSLayoutConstraint(item: eyeButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 44))
        eyeButton.addConstraint(NSLayoutConstraint(item: eyeButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 44))
        self.view.addConstraint(NSLayoutConstraint(item: eyeButton, attribute: .top, relatedBy: .equal, toItem: textNewPassWord, attribute: .top, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: eyeButton, attribute: .right, relatedBy: .equal, toItem: textNewPassWord, attribute: .right, multiplier: 1, constant: 0))
        
        errorLabel.addConstraint(NSLayoutConstraint(item: errorLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 80))
        errorLabel.addConstraint(NSLayoutConstraint(item: errorLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 32))
        self.view.addConstraint(NSLayoutConstraint(item: errorLabel, attribute: .top, relatedBy: .equal, toItem: textNewPassWord, attribute: .bottom, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: errorLabel, attribute: .left, relatedBy: .equal, toItem: textNewPassWord, attribute: .left, multiplier: 1, constant: 0))
        
        modifyButton.addConstraint(NSLayoutConstraint(item: modifyButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 297))
        modifyButton.addConstraint(NSLayoutConstraint(item: modifyButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0,constant: 44))
        self.view.addConstraint(NSLayoutConstraint(item: modifyButton, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: modifyButton, attribute: .top, relatedBy: .equal, toItem: textNewPassWord, attribute: .bottom, multiplier: 1, constant: 40))
        
        // api测试
        // getVerifyCode { ServerDescription in }
    }
    
    func textFieldShouldReturn(_ textName: UITextField) -> Bool {
        textName.resignFirstResponder()
        return true
    }
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
    func verifyCodeResponse(completion: @escaping (ServerDescription)->Void) {
        let parameters: [String: String] = ["email": textName.text!]
        // 获取验证码接口
        let url = "http://47.96.170.11/api/v1/user/password/reset/verify_code"
        // 重置接口
        // let url = "http://47.96.170.11/api/v1/user/password/reset"
        AF.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            switch response.result {
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
    
    func resetResponse(completion: @escaping (ServerDescription)->Void) {
        // 不需要token也可以重置密码，但需要加上email
        // 用token需要在登陆和注册的时候将服务器返回的token保存在本地，且不需要email
        // 所以为什么要用token
        let parameters: [String: String] = [
            //"email": textName.text!,
            "new_password": textNewPassWord.text!,
            "verify_code": textVerify.text!
        ]

        let url = "http://47.96.170.11/api/v1/user/password/reset"
        //, headers: headers
        AF.request(url, method: .post, parameters: parameters).responseJSON {
            response in
            switch response.result {
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
    
    @objc func loginPage(){
        resetResponse { [self] ServerDescription in
            if ServerDescription.success!{
                self.navigationController?.popToRootViewController(animated: false)
            }
            else {
                if ServerDescription.error?.code == "verify_code_invalid_verify_code"{
                    errorLabel.text = "无效验证码"
                    errorLabel.isHidden = false
                }
                else if ServerDescription.error?.code == "user_invalid_password_length"{
                    errorLabel.text = "密码长度大于8字符哦"
                }
            }
        }
    }
    
    @objc func textValueChanged(){
        if textName.text?.isEmpty == false && textVerify.text?.isEmpty == false && textNewPassWord.text?.isEmpty == false {
            modifyButton.backgroundColor = UIColor.init(red:54/255.0, green:181/255.0, blue:157/255.0,alpha: 1)
            modifyButton.isEnabled = true
        }
        else{
            modifyButton.backgroundColor = UIColor.init(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1)
            modifyButton.isEnabled = false
        }
    }
    
    @objc func eyeButtonTapped(){
        if eyeButton.isSelected {
            eyeButton.setImage(UIImage(named: "EyeOff"), for: .normal)
            eyeButton.isSelected = false
            textNewPassWord.isSecureTextEntry = true
        }
        else{
            // 颜色显示有问题
            eyeButton.setImage(UIImage(named: "EyeOn"), for: .normal)
            eyeButton.isSelected = true
            textNewPassWord.isSecureTextEntry = false
        }
    }
    // 倒计时
    var remainingSeconds: Int = 0 {
        willSet {
            getCodeButton.setTitle("\(newValue)秒后重新获取", for: .normal)
            getCodeButton.setTitleColor(UIColor(red:142/255.0,green:142/255.0,blue:142/255.0,alpha: 1), for: .normal)
                
            if newValue <= 0 {
                getCodeButton.setTitle("重新获取验证码", for: .normal)
                getCodeButton.setTitleColor(UIColor(red:54/255.0,green:181/255.0,blue:157/255.0,alpha: 1), for: .normal)
                isCounting = false
            }
        }
    }
    
    var isCounting = false {
        willSet {
            if newValue {
                countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TestViewController.updateTime), userInfo: nil, repeats: true)
                
                remainingSeconds = 30
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
    @objc func getCodeEnable(){
        if textName.text?.isEmpty == true {
            getCodeButton.isEnabled = false;
            getCodeButton.setTitleColor(UIColor(red:142/255.0,green:142/255.0,blue:142/255.0,alpha: 1), for: .normal)
        }
        else{
            getCodeButton.isEnabled = true
            getCodeButton.setTitleColor(UIColor(red:54/255.0,green:181/255.0,blue:157/255.0,alpha: 1), for: .normal)
        }
    }
    
    @objc func getCode(){
        verifyCodeResponse { [self] ServerDescription in
            if ServerDescription.success!{
                errorLabel.text = "验证码已发送"
                errorLabel.isHidden = false
                // 按钮灰，倒计时，计时完变色，可重发验证码
                isCounting = true
            }
            else{
                // 气泡提示？
                if ServerDescription.error?.code == "user_invalid_email_format"{
                    errorLabel.text = "邮箱格式错误"
                }
                else if ServerDescription.error?.code == "user_invalid_user"{
                    errorLabel.text = "该用户不存在"
                }
                errorLabel.isHidden = false
            }
        }
    }
    
    // 标签重置响应
    @objc func resetErrorLabel(){
        if (errorLabel.isHidden == false){
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

