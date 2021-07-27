//
//  EditNoteViewController.swift
//  test
//
//  Created by 李远卓 on 2021/7/24.
//
import UIKit
import CryptoSwift

class EditNoteViewController: UIViewController {
    private let contentView = UIView()
    private let scrollView = UIScrollView()
    private let tagLayOut = TagFlowLayout()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: tagLayOut)
    private let saveButton = UIButton(type: .system)
    private let statusLabel = UILabel()
    private var statusSegment = UISegmentedControl()
    private let labelLine = UIView()
    private let contentLine = UIView()
    private let screenFrame = UIScreen.main.bounds
    let textLabelView = TextViewWithPlacehodler(holder: "请输入标签，示例：标签/标签")
    let textContenView = TextViewWithPlacehodler(holder: "请输入搜记内容")
    var noteLabelArray = [String]()
    var onSave: (() -> Void)?
    var nid: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setConstrain()
    }

    func prepareNote(title: String, content: String, status: Int, nid: String? = nil) -> UserInfo {
        let localUpdatedAt = getDateIS08601()
        let checksum = (title + content).crc32()
        let status = status == 1 ? true : false
        let jwt = userDefault.string(forKey: UserDefaultKeys.AccountInfo.jwt.rawValue)
        let myNote = UserInfo.Note(title: title,
                                   content: content,
                                   status: status,
                                   checksum: checksum,
                                   localUpdatedAt: localUpdatedAt)
        let userInfo = UserInfo(authorization: jwt, nid: nid, note: myNote)
        return userInfo
    }
}

extension EditNoteViewController {

    func setNavigationBar() {
        self.view.backgroundColor = UIColor.white
        // 右导航按钮
        saveButton.setTitle("保存", for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        saveButton.tintColor = UIColor.grayColor
        saveButton.addTarget(self, action: #selector(saveNote), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.navigationColor
        saveButton.isEnabled = false // 放在加入右导航前面会无效
    }

    func setStatusLabel() {
        // 状态标签
        statusLabel.text = "状态"
        statusLabel.font = UIFont.systemFont(ofSize: 15)
        statusLabel.textColor = UIColor.grayColor
    }

    func setStatusSegment() {
        // 状态选择
        statusSegment = UISegmentedControl(items: ["私有", "公开"])
        statusSegment.backgroundColor = UIColor.segmentColor
        statusSegment.selectedSegmentTintColor = UIColor.greenColor
        statusSegment.setTitleTextAttributes([.foregroundColor: UIColor.grayColor], for: .normal)
        statusSegment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        statusSegment.selectedSegmentIndex = 0
        statusSegment.addTarget(self, action: #selector(activeSaveButton), for: .valueChanged)
        // statusSegment.selectedSegmentIndex = 0
    }

    func setScrollView() {
        // scroll view, display area
        scrollView.frame = screenFrame
        scrollView.showsVerticalScrollIndicator = false
    }

    func setTextLabelView() {
        // textLabelView
        textLabelView.font = UIFont.systemFont(ofSize: 15)
        textLabelView.isScrollEnabled = false
        textLabelView.textColor = UIColor.textColor
        textLabelView.tintColor = UIColor.greenColor
    }

    func setTextContentView() {
        // textContentView
        textContenView.font = UIFont.systemFont(ofSize: 15)
        textContenView.textColor = UIColor.textColor
        textContenView.tintColor = UIColor.greenColor
    }

    func setCollectionView() {
        collectionView.backgroundColor = UIColor.white
        collectionView.register(MyCollectionViewCell.self,
                                forCellWithReuseIdentifier:
                                MyCollectionViewCell.description())
        collectionView.isScrollEnabled = false
    }

    func setLine() {
        labelLine.backgroundColor = UIColor.grayColor
        contentLine.backgroundColor = UIColor.grayColor
    }

    func setUI() {
        setNavigationBar()
        setScrollView()
        setStatusLabel()
        setStatusSegment()
        setLine()
        setCollectionView()
        setTextContentView()
        setTextLabelView()
        self.view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(statusLabel)
        contentView.addSubview(statusSegment)
        contentView.addSubview(textLabelView)
        contentView.addSubview(collectionView)
        contentView.addSubview(textContenView)
        contentView.addSubview(labelLine)
        contentView.addSubview(contentLine)
        scrollView.delegate = self
        textLabelView.delegate = self
        textContenView.delegate = self
        collectionView.delegate = self
        tagLayOut.delegate = self
        collectionView.dataSource = self
    }

    func setConstrain() {
        contentView.snp.makeConstraints {
            // edge
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalToSuperview().offset(400)
        }
        statusLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.left.equalToSuperview().offset(16)
        }
        statusSegment.snp.makeConstraints {
            $0.width.equalTo(72)
            $0.height.equalTo(22)
            $0.top.equalToSuperview().offset(12)
            $0.right.equalToSuperview().offset(-16)
        }
        textLabelView.snp.makeConstraints {
            $0.top.equalTo(statusLabel.snp.bottom).offset(12)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
        }
        labelLine.snp.makeConstraints {
            $0.top.left.width.equalTo(textLabelView)
            $0.height.equalTo(0.2)
        }
        contentLine.snp.makeConstraints {
            $0.top.left.width.equalTo(textContenView)
            $0.height.equalTo(0.2)
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(textLabelView.snp.bottom)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.height.equalTo(43)
        }
        textContenView.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom)
            $0.left.right.equalTo(collectionView)
            $0.bottom.equalTo(0)
        }
    }
}

extension EditNoteViewController {
    @objc func saveNote() {
        if nid.count == 0 { // 保存
            let userInfo = prepareNote(title: textLabelView.text,
                                       content: textContenView.text,
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
                                                    content: (userInfo.note?.content)!,
                                                    status: status))
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
        } else { // 更新
            let userInfo = prepareNote(title: textLabelView.text,
                                       content: textContenView.text,
                                       status: statusSegment.selectedSegmentIndex,
                                       nid: nid)
            // 上传笔记到服务器
            requestAndResponse(userInfo: userInfo, function: .updateNotes, method: .patch) { _ in
                // 禁用保存按钮 防止重复保存一样的数据
                self.saveButton.isEnabled = false
                // 获取校验和时间
                let status = userInfo.note?.status == true ? 1 : 0
                do {
                    try DBManager.db?.updateNote(myNote: SQLNote(id: userInfo.nid!,
                                                                 tag: (userInfo.note?.title)!,
                                                                 content: (userInfo.note?.content)!,
                                                                 status: status))
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
                let bubble = UIAlertController(title: "", message: "更新成功", preferredStyle: .alert)
                self.present(bubble, animated: true, completion: nil)
                // 气泡显示延时消失
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    bubble.dismiss(animated: true, completion: nil)
                })
                self.onSave?()
            }
        }
    }

    @objc func activeSaveButton() {
        saveButton.isEnabled = true
        saveButton.tintColor = UIColor.greenColor
    }
}

extension EditNoteViewController: UICollectionViewDataSource {
    // cell个数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if noteLabelArray.count == 1 && noteLabelArray[0] == "" {
            return 0
        }
        return noteLabelArray.count
    }
    // cell内容
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.description(), for: indexPath)
        if let cell = cell as? MyCollectionViewCell {
            cell.noteLabel.text = noteLabelArray[indexPath.row]
        }
        return cell
    }
}
// UICollectionViewDelegate是UICollectionViewDelegateFlowLayout的子协议，写后者就行了
extension EditNoteViewController: UICollectionViewDelegateFlowLayout,
                                    TagFlowLayoutDelegate {
    // 每个item的大小, 坐标是系统计算，item之间的间距由自定义layout调整，长度由函数实现
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: labelWidth((noteLabelArray[indexPath.item]), 15),
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
}

extension EditNoteViewController: UITextViewDelegate {
    // placeholder+字符串分割+更新数据
    func textViewDidChange(_ textView: UITextView) {
        // placeholder 的显示
        if textView == textLabelView {
            textLabelView.text = textView.text
            noteLabelArray = textLabelView.text.array
            // reload noteLabelArray to collectionView
            collectionView.reloadData()
        }
        if textView == textContenView {
            textContenView.text = textView.text
        }
        // 激活保存按钮
        if textContenView.placeholder.isHidden && textLabelView.placeholder.isHidden {
            saveButton.isEnabled = true
            saveButton.tintColor = UIColor.greenColor
        } else {
            saveButton.isEnabled = false
            saveButton.tintColor = UIColor.grayColor
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
}
