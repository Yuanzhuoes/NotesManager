//
//  RegisterViewController.swift
//  test
//
//  Created by 李远卓 on 2021/6/4.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {

    var textName:UITextField!
    var textPassWord:UITextField!
    var textPassWordConfirm:UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 1. 标签显示
        
        // 1.1 注册账号标签显示 如何根据字体大小动态调整frame?
        let registerLabel = UILabel(frame: CGRect(x: 40, y: 84, width: 128, height: 22))
        registerLabel.text = "账号注册"
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
        
        // 2.2 密码输入
        textPassWord = UITextField(frame: CGRect(x:0,y:0,width:297,height:44))
        textPassWord.center = self.view.center
        textPassWord.center.y = textName.center.y + 54
        textPassWord.borderStyle = UITextField.BorderStyle.roundedRect
        textPassWord.placeholder = "请设置密码（8个字符以上）"
        textPassWord.returnKeyType = UIReturnKeyType.done // ?
        textPassWord.keyboardType = UIKeyboardType.default // 键盘类型为邮箱
        textPassWord.isSecureTextEntry = true // 是否安全输入 小圆点 和按钮交互
        
        // 2.3 确认密码输入
        textPassWordConfirm = UITextField(frame: CGRect(x:0,y:0,width:297,height:44))
        textPassWordConfirm.center = self.view.center
        textPassWordConfirm.center.y = textPassWord.center.y + 54
        textPassWordConfirm.borderStyle = UITextField.BorderStyle.roundedRect
        textPassWordConfirm.placeholder = "请确认密码"
        textPassWordConfirm.returnKeyType = UIReturnKeyType.done // ?
        textPassWordConfirm.keyboardType = UIKeyboardType.default // 键盘类型为邮箱
        textPassWordConfirm.isSecureTextEntry = true // 是否安全输入 小圆点 和按钮交互
        
        textName.delegate = self
        textPassWord.delegate = self
        textPassWordConfirm.delegate = self
        self.view.addSubview(textName)
        self.view.addSubview(textPassWord)
        self.view.addSubview(textPassWordConfirm)
        
        // 3. 按钮显示
        
        // 3.1 注册按钮
        let registerButton = UIButton(type: .system)
        registerButton.frame = CGRect(x: 0, y: 0, width: 297,height: 44)
        registerButton.center.x = self.view.center.x
        registerButton.center.y = textPassWordConfirm.center.y + 86
        registerButton.backgroundColor = UIColor.init(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1)
        registerButton.setTitle("注册", for: .normal)
        registerButton.setTitleColor(UIColor.white, for: .normal)
        // 3.2.1 输入后高亮
        
        self.view.addSubview(registerButton)
        
        // 2.2 显示-隐藏按钮
        let dispalyButton = UIButton(type: .system)
        dispalyButton.frame = CGRect(x:288, y:315, width:44, height:32)
        dispalyButton.setTitle("显示密码", for: .normal)
        dispalyButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        dispalyButton.adjustsImageSizeForAccessibilityContentSizeCategory = true
        // 更改颜色
        dispalyButton.tintColor = UIColor(red:54/255.0,green:181/255.0,blue:157/255.0,alpha: 1)
        // 2.2.1 点击换字
        self.view.addSubview(dispalyButton)
    }
    
    func textFieldShouldReturn(_ textName: UITextField) -> Bool {
        textName.resignFirstResponder()
        return true
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
