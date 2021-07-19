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
        // 线条的高度
        let labelLineHeight: CGFloat = 0.5
        // 线条的颜色
        let labelLineColor = MyColor.eyeColor
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
            NSAttributedString.Key.foregroundColor: MyColor.textColor])
        self.setValue(attributedString, forKey: "attributedMessage")
    }
    override func addAction(_ action: UIAlertAction ) {
        super.addAction(action)
        // 通过tintColor实现按钮颜色的修改。
        self.view.tintColor = MyColor.greenColor
//        也可以通过设置 action.setValue 来实现
//        action.setValue(UIColor.orange, forKey: "titleTextColor")
    }
}
// 自定义MyCollectionViewCell
class MyCollectionViewCell: UICollectionViewCell {
    let noteLabel = UILabel()
    let view = UIView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        // 笔记标签 默认单行
        noteLabel.font = UIFont.systemFont(ofSize: 11)
        noteLabel.textAlignment = .center
        // 失效
//        noteLabel.layer.cornerRadius = 3
        noteLabel.textColor = MyColor.textColor
        noteLabel.backgroundColor = MyColor.navigationColor
        self.contentView.addSubview(view)
        self.view.addSubview(noteLabel)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        view.snp.makeConstraints { make in
            // 距离content的约束 0相当于填满整个父视图
            make.left.right.top.bottom.equalTo(0)
        }
        noteLabel.snp.makeConstraints { make in
            // 距离view的约束
            make.left.top.right.bottom.equalTo(0)
        }
    }
}
protocol TagFlowLayoutDelegate: AnyObject {
    func getCollectionViewHeightAndRows(height: CGFloat, row: Int)
}
class TagFlowLayout: UICollectionViewFlowLayout {
    weak var delegate: TagFlowLayoutDelegate?
    let maxSpacing: CGFloat = 8
    override func prepare() {
        super.prepare()
    }
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        super.layoutAttributesForElements(in: rect)
        // 系统计算的结果，所有cell布局信息的数组
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        // 水平间距调整
        if attributes.count > 0 {
            var row = 1
            // 第一个标签居左
            attributes[0].frame.origin.x = 0
            for i in 1..<attributes.count {
                let curAttr = attributes[i]
                let preAttr = attributes[i - 1]
                let origin = preAttr.frame.maxX
                let targetX = origin + maxSpacing
                let targetY = preAttr.frame.origin.y
                // 如果一行内还放得下 调整x, 否则换行（系统自动的）居左 (当前item宽度 + 前一个item的最大x坐标 + 间距 <= collectionview的宽度)
                if targetX + curAttr.frame.width <= collectionViewContentSize.width {
                    curAttr.frame.origin.x = targetX
                    // 为什么不限制y会出错
                    curAttr.frame.origin.y = targetY
                } else {
                    curAttr.frame.origin.x = 0
                    row += 1
                }
                // 获取最大高度和行数
                if i == attributes.count - 1 {
                    self.delegate?.getCollectionViewHeightAndRows(height: curAttr.frame.maxY, row: row)
                }
            }
        }
        return attributes
    }
}
// 委托/代理 设计模式：将一个类要做的事委托给另一个符合要求的类去做
protocol DisplayTagFlowLayoutDelegate: AnyObject {
    func getCollectionViewHeight(height: CGFloat)
}
class DisplayTagFlowLayout: UICollectionViewFlowLayout {
    weak var delegate: DisplayTagFlowLayoutDelegate?
    let maxSpacing: CGFloat = 8
    override func prepare() {
        super.prepare()
    }
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        super.layoutAttributesForElements(in: rect)
        // 系统计算的结果，所有cell布局信息的数组
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        // 水平间距调整 如果有标签就重新布局 否则默认值
        if attributes.count > 0 {
            var row = 1
            // 第一个标签居左
            attributes[0].frame.origin.x = 0
            // 只有一个标签 只记录高度 不调整间距
            if attributes.count == 1 {
                self.delegate?.getCollectionViewHeight(height: attributes[0].frame.maxY)
                return attributes
            }
            // 两个标签开始调整间距
            for i in 1..<attributes.count {
                let curAttr = attributes[i]
                let preAttr = attributes[i - 1]
                let origin = preAttr.frame.maxX
                let targetX = origin + maxSpacing
                let targetY = preAttr.frame.origin.y
                // 如果一行内还放得下 调整x, 否则换行（系统自动的）居左 (当前item宽度 + 前一个item的最大x坐标 + 间距 <= collectionview的宽度)
                if targetX + curAttr.frame.width <= collectionViewContentSize.width - 18 && row == 1 {
                    curAttr.frame.origin.x = targetX
                    // 不限制y会出错 why?
                    curAttr.frame.origin.y = targetY
                } else if targetX + curAttr.frame.width <= collectionViewContentSize.width && row > 1 {
                    curAttr.frame.origin.x = targetX
                    curAttr.frame.origin.y = targetY
                } else {
                    curAttr.frame.origin.x = 0
                    row += 1
                }
                // 获取最大高度和行数
                if i == attributes.count - 1 {
                    print(curAttr.frame.maxY)
                    self.delegate?.getCollectionViewHeight(height: curAttr.frame.maxY)
                }
            }
        }
        return attributes
    }
}
// 自定义显示界面TableViewCell 嵌套 collectionview
class MyTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource,
                       UICollectionViewDelegateFlowLayout, DisplayTagFlowLayoutDelegate {
    let privateLabel = UILabel()
    let contentLabel = UILabel()
    let tagLayOut = DisplayTagFlowLayout() // 用自定义的layout初始化collectionView
    // 延迟加载属性在第一次调用时才初始化
    // 因为它依赖taglayout, 而taglayout要在cell构造结束后才存在, 所以实例化cell后才能实例化collectionView, 必须延迟加载
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: tagLayOut)
    var currRow: Int = 0
    var noteLabelArray: [String] = []
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        myAdd()
        myConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func myAdd() {
//         collection view
        collectionView.backgroundColor = UIColor.white
        collectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: MyCollectionViewCell.description())
        collectionView.isScrollEnabled = false
        // 状态标签 固定大小 collection view
        privateLabel.font = UIFont.systemFont(ofSize: 11)
        privateLabel.textAlignment = .center
        privateLabel.textColor = UIColor.white
        privateLabel.backgroundColor = MyColor.greenColor
        // 内容标签
        contentLabel.backgroundColor = UIColor.white
        contentLabel.font = UIFont.systemFont(ofSize: 14)
        contentLabel.textAlignment = .left
        contentLabel.textColor = MyColor.textColor
        // 最大行，set to zero will grow with the label contents
        contentLabel.numberOfLines = 2
        self.contentView.addSubview(self.collectionView)
        self.contentView.addSubview(self.privateLabel)
        self.contentView.addSubview(self.contentLabel)
        collectionView.delegate = self
        collectionView.dataSource = self
        tagLayOut.delegate = self
    }

    func myConstraints() {
        privateLabel.snp.makeConstraints {
            $0.width.height.equalTo(18)
            $0.top.equalToSuperview().offset(12)
            $0.right.equalToSuperview().offset(-16)
        }
        collectionView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.top.equalToSuperview().offset(12)
            $0.height.equalTo(1).priority(.low) // 不设置优先级会冲突
        }
        contentLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.top.equalTo(collectionView.snp.bottom)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
    // collectionview的最大高度 后于tabelview autolayout，所以tabelview高度不能准确更新
    func getCollectionViewHeight(height: CGFloat) {
        collectionView.snp.updateConstraints {
            $0.height.equalTo(height + 8).priority(.low)
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 消除空字符串的显示bug
        if noteLabelArray.count == 1 && noteLabelArray[0] == "" {
            return 0
        }
        return noteLabelArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.description(), for: indexPath)
        if let cell = cell as? MyCollectionViewCell {
            cell.noteLabel.text = noteLabelArray[indexPath.row]
        }
        return cell
    }
    // 每个item的大小, item之间的间距由自定义layout实现，长度由函数实现
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: labelWidth(noteLabelArray[indexPath.item], 15, indexPath),
                      height: 15)
    }
    // 行间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    // 根据内容和高度计算每一个label的宽度
    func labelWidth(_ text: String, _ height: CGFloat, _ indexPath: IndexPath) -> CGFloat {
        let size = CGSize(width: 2000, height: height)
        let font = UIFont.systemFont(ofSize: 11)
        let attributes = [NSAttributedString.Key.font: font]
        let labelSize = NSString(string: text).boundingRect(with: size,
                                options: .usesLineFragmentOrigin,
                                attributes: attributes, context: nil)
        // 如果标签大于屏幕宽度，则设置一个定值
        if indexPath.row == 0 && labelSize.width + 8 > collectionView.frame.width - 18 {
            return collectionView.frame.width - 20
        } else if indexPath.row > 0 && labelSize.width + 8 > collectionView.frame.width {
            return collectionView.frame.width
        }
        return labelSize.width + 8
    }
}
