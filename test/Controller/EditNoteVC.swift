//
//  EditNoteViewController.swift
//  test
//
//  Created by 李远卓 on 2021/7/24.
//
import UIKit
import CryptoSwift

class EditNoteViewController: UIViewController {
    let editView = EditView()
    var onSave: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setDelegate()
        addTarget()
    }
}

// collection cell
extension EditNoteViewController: UICollectionViewDataSource {
    // cell numbers
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return EditData.noteLabelArray.count
    }

    // cell content
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.description(), for: indexPath)
        if let cell = cell as? MyCollectionViewCell {
            cell.noteLabel.text = EditData.noteLabelArray[indexPath.row]
        }
        return cell
    }
}

// collectionView flowLayout
extension EditNoteViewController: UICollectionViewDelegateFlowLayout {
    // compute size of cell, depending on font content width and given hight
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: labelWidth((EditData.noteLabelArray[indexPath.item]), 15),
                      height: 15)
    }

    // line spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

// set coustom flowlayout of hight and row
extension EditNoteViewController: TagFlowLayoutDelegate {
    // max hight of collectionview
    func getCollectionViewHeightAndRows(height: CGFloat, row: Int) {
        if row >= 1 {
            editView.collectionView.snp.updateConstraints { make in
                make.height.equalTo(height + 10)
            }
        }
    }
}

// display placeholder and reload data
extension EditNoteViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView == editView.textLabelView {
            editView.textLabelView.text = textView.text
            EditData.noteLabelArray = editView.textLabelView.text.array
            editView.collectionView.reloadData()
        }
        if textView == editView.textContenView {
            editView.textContenView.text = textView.text
        }
        // active save button
        if editView.textContenView.placeholder.isHidden {
            editView.saveButton.isEnabled = true
            editView.saveButton.tintColor = UIColor.greenColor
        } else {
            editView.saveButton.isEnabled = false
            editView.saveButton.tintColor = UIColor.grayColor
        }
        // TODO: limit input
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == editView.textContenView {
            // scroll to specified location
            editView.scrollView.setContentOffset(CGPoint(x: 0, y: editView.contentLine.frame.maxY), animated: true)
        }
    }
}

// UI
private extension EditNoteViewController {
    func setUI() {
        self.view.addSubview(editView)
        setNavigationBar()
        editView.setUI()
        setConstraints()
    }

    func setConstraints() {
        editView.snp.makeConstraints {
            $0.top.bottom.width.height.equalToSuperview()
        }
    }

    func setNavigationBar() {
        self.view.backgroundColor = UIColor.white
        editView.saveButton.setTitle("保存", for: .normal)
        editView.saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        editView.saveButton.tintColor = UIColor.grayColor
        editView.saveButton.addTarget(self, action: #selector(saveNote), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editView.saveButton)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.navigationColor
        editView.saveButton.isEnabled = false // set this property after adding it on the navagation bar
    }

    func addTarget() {
        editView.statusSegment.addTarget(self, action: #selector(activeSaveButton), for: .valueChanged)
    }

    func setDelegate() {
        editView.scrollView.delegate = self
        editView.textLabelView.delegate = self
        editView.textContenView.delegate = self
        editView.collectionView.delegate = self
        editView.tagLayOut.delegate = self
        editView.collectionView.dataSource = self
    }
}

// target
private extension EditNoteViewController {
    @objc func saveNote() {
        if EditData.nid.isEmpty { // save
            let userInfo = prepareNote(title: editView.textLabelView.text,
                                       content: editView.textContenView.text,
                                       status: editView.statusSegment.selectedSegmentIndex)
            createNote(userInfo: userInfo) {
                // diable save button, show bubble, relod data
                self.editView.saveButton.isEnabled = false
                let bubble = MyAlertController.setBubble(title: "", message: "保存成功", action: false)
                self.presentBubbleAndDismiss(bubble)
                self.onSave?()
            }
        } else { // update
            let userInfo = prepareNote(title: editView.textLabelView.text,
                                       content: editView.textContenView.text,
                                       status: editView.statusSegment.selectedSegmentIndex,
                                       nid: EditData.nid)
            updateNote(userInfo: userInfo) {
                self.editView.saveButton.isEnabled = false
                let bubble = MyAlertController.setBubble(title: "", message: "更新成功", action: false)
                self.presentBubbleAndDismiss(bubble)
                self.onSave?()
            }
        }
    }

    @objc func activeSaveButton() {
        editView.saveButton.isEnabled = true
        editView.saveButton.tintColor = UIColor.greenColor
    }
}

// make userInfo
private extension EditNoteViewController {
    func prepareNote(title: String, content: String, status: Int, nid: String? = nil) -> UserInfo {
        let localUpdatedAt = getDateIS08601()
        let checksum = (title + content).crc32()
        let status = status == 1 ? true : false
        let jwt = userAccount.string(forKey: UserDefaultKeys.AccountInfo.jwt.rawValue)
        let myNote = UserInfo.Note(title: title,
                                   content: content,
                                   status: status,
                                   checksum: checksum,
                                   localUpdatedAt: localUpdatedAt)
        let userInfo = UserInfo(authorization: jwt, nid: nid, note: myNote)
        return userInfo
    }

    // compute width depending on font content and screen width
    func labelWidth(_ text: String, _ height: CGFloat) -> CGFloat {
        let size = CGSize(width: 2000, height: height)
        let font = UIFont.systemFont(ofSize: 11)
        let attributes = [NSAttributedString.Key.font: font]
        let labelSize = NSString(string: text).boundingRect(with: size,
                                options: .usesLineFragmentOrigin,
                                attributes: attributes, context: nil)

        // let max label size equal to screen width
        if labelSize.width + 8 > editView.collectionView.frame.width {
            return editView.collectionView.frame.width
        }

        return labelSize.width + 8
    }
}
