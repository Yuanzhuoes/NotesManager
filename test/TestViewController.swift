//
//  TestViewController.swift
//  test
//
//  Created by 李远卓 on 2021/6/7.
//

import UIKit
import Alamofire

class TestViewController: UIViewController {
    var sendButton = UIButton(type: .custom)
    var countdownTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sendButton.frame = CGRect(x: 100, y: 100, width: 300, height: 40)
        sendButton.backgroundColor = UIColor.red
        sendButton.setTitle("获取验证码", for: .normal)
        sendButton.setTitleColor(UIColor.white, for: .normal)
        sendButton.addTarget(self, action: #selector(TestViewController.sendButtonClick), for: .touchUpInside)

        self.view.addSubview(sendButton)
        
        // Do any additional setup after loading the view.
    }
    
    var remainingSeconds: Int = 0 {
        willSet {
            sendButton.setTitle("(\(newValue)秒后重新获取)", for: .normal)
                
            if newValue <= 0 {
                sendButton.setTitle("重新获取验证码", for: .normal)
                isCounting = false
            }
        }
    }
    
    var isCounting = false {
        willSet {
            if newValue {
                countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TestViewController.updateTime), userInfo: nil, repeats: true)
                
                remainingSeconds = 10
                sendButton.backgroundColor = UIColor.gray
            } else {
                countdownTimer?.invalidate()
                countdownTimer = nil
                    
                sendButton.backgroundColor = UIColor.red
            }
                
            sendButton.isEnabled = !newValue
        }
    }
    
    @objc func updateTime(timer: Timer) {
         // 计时开始时，逐秒减少remainingSeconds的值
        remainingSeconds -= 1
    }
    
    @objc func sendButtonClick(sender: UIButton){
        isCounting = true
        // 开始发送验证码
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
