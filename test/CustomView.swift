//
//  MyTableViewCell.swift
//  test
//
//  Created by 李远卓 on 2021/6/24.
//

import UIKit
// 自定义UITextField
class LineTextField: UITextField {
    override func draw(_ rect: CGRect) {
        let labelLineHeight: CGFloat = 0.5
        let labelLineColor = UIColor.eyeColor
        guard let content = UIGraphicsGetCurrentContext() else { return }
        content.setFillColor(labelLineColor.cgColor)
        content.fill(CGRect.init(x: 0, y: self.frame.height - labelLineHeight,
                                 width: self.frame.width, height: labelLineHeight))
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
    }
}
// 自定义UIAlertController KVC运行时访问和修改对象属性
class MyAlertController: UIAlertController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let attributedString = NSAttributedString(string: self.message!, attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15),
            NSAttributedString.Key.foregroundColor: UIColor.textColor])
        self.setValue(attributedString, forKey: "attributedMessage")
    }
    override func addAction(_ action: UIAlertAction ) {
        super.addAction(action)
        self.view.tintColor = UIColor.greenColor
    }
}
// 自定义tableview with placeholder
class TextViewWithPlacehodler: UITextView {
    let placeholder = UILabel()
    var holder: String

    func configure() {
        addSubview(placeholder)
        updateLabelConstraints()
        placeholder.textColor = UIColor.grayColor
        placeholder.text = holder
        placeholder.font = .systemFont(ofSize: 15)
    }

    init(holder: String) {
        self.holder = holder
        super.init(frame: .zero, textContainer: nil)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var text: String! {
        didSet {
            if text == nil || text.isEmpty {
                placeholder.isHidden = false
            } else {
                placeholder.isHidden = true
            }
        }
    }

    override var attributedText: NSAttributedString! {
        didSet {
            if attributedText == nil || attributedText.string.isEmpty {
                placeholder.isHidden = false
            } else {
                placeholder.isHidden = true
            }
        }
    }

    override var textContainerInset: UIEdgeInsets {
        didSet {
            updateLabelConstraints()
        }
    }

    private func updateLabelConstraints() {
        placeholder.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(textContainerInset.top)
            make.left.equalToSuperview().offset(textContainer.lineFragmentPadding)
        }
    }
}
