//
//  CreateNoteViewController.swift
//  test
//
//  Created by 李远卓 on 2021/6/29.
//

import UIKit
import CryptoSwift

class TextViewWithPlacehodler: UITextView {
    let label = UILabel()

    func configure() {
        addSubview(label)
        updateConstraints()
        label.textColor = MyColor.grayColor
        label.font = .systemFont(ofSize: 15)
        label.text = "请输入标签，示例：标签/标签"
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    override var text: String! {
        didSet {
            if text == nil || text.isEmpty {
                label.text = "请输入标签，示例：标签/标签"
            } else {
                label.text = ""
            }
        }
    }

    override var attributedText: NSAttributedString! {
        didSet {
            if attributedText == nil || attributedText.string.isEmpty {
                label.text = "请输入标签，示例：标签/标签"
            } else {
                label.text = ""
            }
        }
    }

    override var textContainerInset: UIEdgeInsets {
        didSet {
            updateConstraints()
        }
    }

    private func udpateLabelConstraints() {
        label.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(textContainerInset.top)
            make.left.equalToSuperview().offset(textContainer.lineFragmentPadding)
        }
    }
}

class CreateNoteViewController: UIViewController, UIScrollViewDelegate,
                                UITextViewDelegate, UICollectionViewDelegate,
                                UICollectionViewDataSource,
                                UICollectionViewDelegateFlowLayout, TagFlowLayoutDelegate {
    let contentView = UIView()
    let scrollView = UIScrollView()
    let textLabelView = TextViewWithPlacehodler()
    let textContenView = UITextView()
    let tagLayOut = TagFlowLayout()
    // lazy load memory property. collectionView 第一次被调用时才初始化, 因为taglayout先于初始化
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: tagLayOut)
    let saveButton = UIButton(type: .system)
    let statusLabel = UILabel()
    var statusSegment = UISegmentedControl()
    let labelLine = UIView()
    let contentLine = UIView()
    let textLabelPlaceHolder = UILabel()
    let textContentPlaceHolder = UILabel()
    let screenFrame = UIScreen.main.bounds
    var dataArrary: [String] = []

    var onSave: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        myUI()
        myConstrain()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 消除空字符串的显示bug
        if dataArrary.count == 1 && dataArrary[0] == "" {
            return 0
        }
        return dataArrary.count
    }

    // cell的内容
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.description(), for: indexPath)
        if let cell = cell as? MyCollectionViewCell {
            cell.noteLabel.text = dataArrary[indexPath.row]
        }
        return cell
    }

    // 每个item的大小, 坐标是系统计算，item之间的间距由自定义layout调整，长度由函数实现
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: labelWidth((dataArrary[indexPath.item]), 15),
                      height: 15)
    }

    // 行间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    // 根据内容和高度计算每一个label的宽度
    func labelWidth(_ text: String, _ height: CGFloat) -> CGFloat {
        let size = CGSize(width: 2000, height: height)
        let font = UIFont.systemFont(ofSize: 11)
        let attributes = [NSAttributedString.Key.font: font]
        let labelSize = NSString(string: text).boundingRect(with: size,
                                options: .usesLineFragmentOrigin,
                                attributes: attributes, context: nil)
        // 如果标签大于屏幕宽度，则设置一个定值
        if labelSize.width + 8 > collectionView.frame.width {
            return collectionView.frame.width
        }
        return labelSize.width + 8
    }

    // collectionview的最大高度
    func getCollectionViewHeightAndRows(height: CGFloat, row: Int) {
        // 超过两行再更新高度，因为默认高度可显示两行
        if row >= 2 {
            collectionView.snp.updateConstraints { make in
                make.height.equalTo(height + 10)
            }
        }
    }

    // placeholder+字符串分割+更新数据
    func textViewDidChange(_ textView: UITextView) {
        // placeholder 的显示
        if textView == textLabelView {
            textLabelView.text = textView.text
//            dataArrary = stringToArray(textLabelView.text)
            dataArrary = textLabelView.text.array
            // reload dataArrary to collectionView
            collectionView.reloadData()
            if textLabelView.text == nil || textLabelView.text == "" {
                textLabelPlaceHolder.text = "请输入标签，示例：标签/标签"
            } else {
                textLabelPlaceHolder.text = ""
            }
        }
        if textView == textContenView {
            textContenView.text = textView.text
            if textContenView.text == nil || textContenView.text == "" {
                textContentPlaceHolder.text = "请输入搜记内容"
            } else {
                textContentPlaceHolder.text = ""
            }
        }

        // 激活保存按钮
        if textContentPlaceHolder.text == "" && textLabelPlaceHolder.text == "" {
            saveButton.isEnabled = true
            saveButton.tintColor = MyColor.greenColor
        } else {
            saveButton.isEnabled = false
            saveButton.tintColor = MyColor.grayColor
        }

        // 限制输入大小？
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == textContenView {
            // 滑动到指定位置
            scrollView.setContentOffset(CGPoint(x: 0, y: contentLine.frame.maxY), animated: true)
            // scrollRectToVisible() 是滑动到一个当前不可见的rect, 如果rect当前可见则无动作
        }
    }

    func myUI() {
        self.view.backgroundColor = UIColor.white
        // 导航栏设置
        self.title = "创建搜记" // 样式
        // 不透明，view.top下移
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = MyColor.navigationColor
        // 右导航按钮
        saveButton.setTitle("保存", for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        saveButton.tintColor = MyColor.grayColor
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        saveButton.isEnabled = false // 放在加入右导航前面会无效
        saveButton.addTarget(self, action: #selector(saveNote), for: .touchUpInside)
        // 状态标签
        statusLabel.text = "状态"
        statusLabel.font = UIFont.systemFont(ofSize: 15)
        statusLabel.textColor = MyColor.grayColor
        // 状态选择
        statusSegment = UISegmentedControl(items: ["私有", "公开"])
        statusSegment.backgroundColor = MyColor.segmentColor
        statusSegment.selectedSegmentTintColor = MyColor.greenColor
        statusSegment.setTitleTextAttributes([.foregroundColor: MyColor.grayColor], for: .normal)
        statusSegment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        statusSegment.selectedSegmentIndex = 0
        // scroll view
        // display area
        scrollView.frame = screenFrame
        scrollView.showsVerticalScrollIndicator = false
        // contentview
//        contentView.backgroundColor = UIColor.blue
        // textLabelView
        textLabelView.font = UIFont.systemFont(ofSize: 15)
        textLabelView.isScrollEnabled = false
        textLabelView.textColor = MyColor.textColor
        textLabelView.tintColor = MyColor.greenColor
        // Line
        labelLine.backgroundColor = MyColor.grayColor
        contentLine.backgroundColor = MyColor.grayColor
        // collectionView
        collectionView.backgroundColor = UIColor.white
        collectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: MyCollectionViewCell.description())
        collectionView.isScrollEnabled = false
        // textContentView
//        textContenView.backgroundColor = UIColor.yellow
        textContenView.font = UIFont.systemFont(ofSize: 15)
        textContenView.textColor = MyColor.textColor
        textContenView.tintColor = MyColor.greenColor
        // placeholder
        textLabelPlaceHolder.textColor = MyColor.grayColor
        textLabelPlaceHolder.font = .systemFont(ofSize: 15)
        textLabelPlaceHolder.text = "请输入标签，示例：标签/标签"
        textContentPlaceHolder.textColor = MyColor.grayColor
        textContentPlaceHolder.font = .systemFont(ofSize: 15)
        textContentPlaceHolder.text = "请输入搜记内容"
        self.view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(statusLabel)
        contentView.addSubview(statusSegment)
        contentView.addSubview(textLabelView)
        contentView.addSubview(collectionView)
        contentView.addSubview(textContenView)
        contentView.addSubview(labelLine)
        contentView.addSubview(contentLine)
        // contentView.addSubview(textLabelPlaceHolder)
        contentView.addSubview(textContentPlaceHolder)
        scrollView.delegate = self
        textLabelView.delegate = self
        textContenView.delegate = self
        collectionView.delegate = self
        tagLayOut.delegate = self
        collectionView.dataSource = self
    }
    func myConstrain() {
        contentView.snp.makeConstraints { make in
            // edge
            make.edges.equalToSuperview()
            // content height 自适应 scroll view的frame和content size？
            make.width.equalToSuperview()
            make.height.equalToSuperview().offset(400)
        }
        statusLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(16)
        }
        statusSegment.snp.makeConstraints { make in
            make.width.equalTo(72)
            make.height.equalTo(22)
            make.top.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-16)
        }
        textLabelView.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        labelLine.snp.makeConstraints { make in
            make.top.left.width.equalTo(textLabelView)
            make.height.equalTo(0.2)
        }
        contentLine.snp.makeConstraints { make in
            make.top.left.width.equalTo(textContenView)
            make.height.equalTo(0.2)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(textLabelView.snp.bottom)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(43)
        }
        textContenView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom)
            make.left.right.equalTo(collectionView)
            make.bottom.equalTo(0)
        }
//        textLabelPlaceHolder.snp.makeConstraints { make in
//            make.top.equalTo(textLabelView).offset(textLabelView.textContainerInset.top)
//            make.left.equalTo(textLabelView).offset(textLabelView.textContainer.lineFragmentPadding)
//        }
        textContentPlaceHolder.snp.makeConstraints { make in
            make.top.equalTo(textContenView).offset(10)
            make.left.equalTo(textContenView)
        }
    }
    @objc func saveNote() {
        // save note
        // 获取用户信息
        let userInfo = prepareNote(title: textLabelView.text, content: textContenView.text,
                                   status: statusSegment.selectedSegmentIndex)
        // 上传笔记到服务器
        requestAndResponse(userInfo: userInfo, function: .createNotes, method: .post) { serverDescription in
            if serverDescription.id != nil {
                // 禁用保存按钮 防止重复保存一样的数据
                self.saveButton.isEnabled = false
                // 获取笔记id
                let nid = serverDescription.id
                // 获取校验和时间
                let status = userInfo.note?.status == true ? 1 : 0
                // 将笔记信息写入数据库
                do {
                    try DBManager.db?.insertNote(myNote: SQLNote(id: nid!, tag: (userInfo.note?.title)!,
                                                              content: (userInfo.note?.content)!, status: status))
                } catch {
                    print(DBManager.db?.errorMessage as Any)
                }
                // 更新缓存
                do {
                    notes = try DBManager.db?.queryAllSQLNotes()
                } catch {
                    print(DBManager.db?.errorMessage as Any)
                }
                // 显示保存成功气泡 封装一下
                let bubble = UIAlertController(title: "", message: "保存成功", preferredStyle: .alert)
                self.present(bubble, animated: true, completion: nil)
                // 气泡显示延时消失
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    bubble.dismiss(animated: true, completion: nil)
                })

                self.onSave?()
            }
        }
    }

    func prepareNote(title: String, content: String, status: Int) -> UserInfo {
        let localUpdatedAt = getDateIS08601()
        let checksum = (title + content).crc32()
        let status = status == 1 ? true : false
        let jwt = userDefault.string(forKey: UserDefaultKeys.AccountInfo.jwt.rawValue)
        let myNote = UserInfo.Note(title: title, content: content,
                                   status: status, checksum: checksum, localUpdatedAt: localUpdatedAt)
        let userInfo = UserInfo(authorization: jwt, note: myNote)
        return userInfo
    }
}
