//
//  ForgotViewController.swift
//  test
//
//  Created by 李远卓 on 2021/6/5.
//

import UIKit

class ForgotViewController: UIViewController, UITextFieldDelegate {

    var textName:UITextField!
    var textVerify:UITextField!
    var textNewPassWord:UITextField!
    let modifyButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        // 1. 标签显示
        
        // 1.1 注册账号标签显示 如何根据字体大小动态调整frame?
        let registerLabel = UILabel(frame: CGRect(x: 40, y: 84, width: 128, height: 22))
        registerLabel.text = "忘记密码"
        registerLabel.font = UIFont.systemFont(ofSize: 22)
        registerLabel.textColor = UIColor.init(red: 93/225.0, green: 93/225.0, blue: 93/225.0, alpha: 1)
        self.view.addSubview(registerLabel)
        
        // 1.2 错误信息标签显示
        let errorLabel = UILabel(frame: CGRect(x: 40, y: 315, width: 80, height: 32))
        errorLabel.text = "密码不一致"
        errorLabel.font = UIFont.systemFont(ofSize: 12)
        errorLabel.textColor = UIColor.init(red: 220/225.0, green: 102/225.0, blue: 62/225.0, alpha: 1)
        self.view.addSubview(errorLabel)
        
        
        // 2. 输入文本框
        // 2.1 邮箱输入
        textName = UITextField(frame: CGRect(x:0,y:registerLabel.center.y + 70,width:297,height:44))
        textName.center.x = self.view.center.x
        textName.borderStyle = UITextField.BorderStyle.roundedRect
        textName.placeholder = "请输入邮箱"
        textName.returnKeyType = UIReturnKeyType.done // ?
        textName.clearButtonMode = UITextField.ViewMode.never // 编辑时显示删除图标
        textName.keyboardType = UIKeyboardType.emailAddress // 键盘类型为邮箱
        
        // 2.2 验证码输入
        textVerify = UITextField(frame: CGRect(x:0,y:0,width:297,height:44))
        textVerify.center = self.view.center
        textVerify.center.y = textName.center.y + 54
        textVerify.borderStyle = UITextField.BorderStyle.roundedRect
        textVerify.placeholder = "请输入验证码"
        textVerify.returnKeyType = UIReturnKeyType.done // ?
        textVerify.keyboardType = UIKeyboardType.default // 键盘类型为邮箱
        textVerify.isSecureTextEntry = true // 是否安全输入 小圆点 和按钮交互
        
        // 2.3 确认密码输入
        textNewPassWord = UITextField(frame: CGRect(x:0,y:0,width:297,height:44))
        textNewPassWord.center = self.view.center
        textNewPassWord.center.y = textVerify.center.y + 54
        textNewPassWord.borderStyle = UITextField.BorderStyle.roundedRect
        textNewPassWord.placeholder = "请输入新密码"
        textNewPassWord.returnKeyType = UIReturnKeyType.done // ?
        textNewPassWord.keyboardType = UIKeyboardType.default // 键盘类型为邮箱
        textNewPassWord.isSecureTextEntry = true // 是否安全输入 小圆点 和按钮交互
        
        textName.addTarget(self, action: #selector(ForgotViewController.textValueChanged), for: UIControl.Event.editingChanged)
        textVerify.addTarget(self, action: #selector(ForgotViewController.textValueChanged), for: UIControl.Event.editingChanged)
        textNewPassWord.addTarget(self, action: #selector(ForgotViewController.textValueChanged), for: UIControl.Event.editingChanged)
        
        textName.delegate = self
        textVerify.delegate = self
        textNewPassWord.delegate = self
        
        self.view.addSubview(textName)
        self.view.addSubview(textVerify)
        self.view.addSubview(textNewPassWord)
        
        // 3. 按钮显示
        
        // 3.1 修改按钮
        modifyButton.frame = CGRect(x: 0, y: 0, width: 297,height: 44)
        modifyButton.center.x = self.view.center.x
        modifyButton.center.y = textNewPassWord.center.y + 86
        modifyButton.backgroundColor = UIColor.init(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1)
        modifyButton.setTitle("修改", for: .normal)
        modifyButton.setTitleColor(UIColor.white, for: .normal)
        // 3.2.1 输入后高亮
        
        self.view.addSubview(modifyButton)
        
        // 3.2 显示-隐藏按钮
        let eyeButton = UIButton(type: .system)
        eyeButton.frame = CGRect(x:0, y:0, width:44, height:44)
        eyeButton.center.x = textNewPassWord.center.x + 126.5
        eyeButton.center.y = textNewPassWord.center.y
        eyeButton.setImage(UIImage(named: "EyeOff"), for: .normal)
        // 更改自定义图片的颜色
        eyeButton.tintColor = UIColor(red:170/255.0,green:170/255.0,blue:170/255.0,alpha: 1)
        // 更改自定义图片的大小 先不管 找合适的图片就好
        eyeButton.imageEdgeInsets = UIEdgeInsets(top: 32, left:32, bottom:32, right:32 )
        self.view.addSubview(eyeButton)
        
        // 3.3 获取验证码按钮
        let getCodeButton = UIButton(type: .system)
        getCodeButton.frame = CGRect(x:0, y:0, width:44, height:44)
        getCodeButton.center.x = textVerify.center.x + 108
        getCodeButton.center.y = textVerify.center.y + 8
        getCodeButton.setTitle("获取验证码", for: .normal)
        getCodeButton.tintColor = UIColor(red:54/255.0,green:181/255.0,blue:157/255.0,alpha: 1)
        getCodeButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        getCodeButton.adjustsImageSizeForAccessibilityContentSizeCategory = true
        // 3.3.1 点击获取验证码
        
        self.view.addSubview(getCodeButton)
    }
    
    func textFieldShouldReturn(_ textName: UITextField) -> Bool {
        textName.resignFirstResponder()
        return true
    }
    
    @objc func textValueChanged(){
        if textName.text?.isEmpty == false && textVerify.text?.isEmpty == false && textNewPassWord.text?.isEmpty == false {
            modifyButton.backgroundColor = UIColor.init(red:54/255.0, green:181/255.0, blue:157/255.0,alpha: 1)
        }
        else{
            modifyButton.backgroundColor = UIColor.init(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1)
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

