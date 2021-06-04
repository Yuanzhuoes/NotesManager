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
    
    override func viewDidLoad() {
        //父类初始化
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
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
        
        textPassWord.delegate = self
        textName.delegate = self
        self.view.addSubview(textName)
        self.view.addSubview(textPassWord)
        
        // 3.按钮, 长度？ 字体格式？ 适配？
        // 3.1 注册按钮
        let registerButton = UIButton(type: .system)
        registerButton.frame = CGRect(x:280, y:30, width:88, height:44)
        registerButton.setTitle("立即注册", for: .normal)
        registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        registerButton.setTitleColor(UIColor(red:54/255.0,green:181/255.0,blue:157/255.0,alpha: 1), for: .normal)
        self.view.addSubview(registerButton)
        // 3.1.2 点击按钮转入注册界面
        
        // 3.2 登陆按钮
        let loginButton = UIButton(type: .system)
        loginButton.frame = CGRect(x: 0, y: 0, width: 297,height: 44)
        loginButton.center = textPassWord.center
        loginButton.center.y = textPassWord.center.y + 82
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
        forgotButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        //根据字体调整框大小
        forgotButton.adjustsImageSizeForAccessibilityContentSizeCategory = true
        //3.3.1 点击进入忘记密码页面
        
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
    func validateEmail(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest:NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }

    @objc func loginEvent(){
            let usercode = textName.text!   //获取用户名
            let password = textPassWord.text!    //获取密码
            textName.resignFirstResponder()  //通知此对象，要求其在其窗口中放弃其作为第一响应者的状态。
            textPassWord.resignFirstResponder()
            
            //如果用户名和密码都正确的话
            if usercode == "hedon" && password=="123"{
                //取得id=“Main”的Storyboard的实例
                let mainBoard:UIStoryboard! = UIStoryboard(name: "Main", bundle: nil)
                //取得identifier = “vcMain”的ViewController
                //这里需要我们自己去 Main.storyboard 里面设置
                let VCMain = mainBoard!.instantiateViewController(withIdentifier: "vcMain");
                
                UIApplication.shared.windows[0].rootViewController = VCMain
            }
            else{  //登录不成功
                //定义一个警告窗口
                let p = UIAlertController(title: "登录失败", message: "用户名或密码错误", preferredStyle: .alert)
                
                //点击确定后，自动将密码清零
                p.addAction(UIAlertAction(title: "确定", style: .default, handler: {(act:UIAlertAction)in self.textPassWord.text=""}))
                
                //呈现出错误窗口(模态)
                present(p,animated: false,completion: nil)
            }
        }
}

