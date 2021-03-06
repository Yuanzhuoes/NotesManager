//
//  WelcomViewController.swift
//  test
//
//  Created by ζθΏε on 2021/6/4.
//

import UIKit

class DisplayViewController: UIViewController {
    private let displayView = DisplayView()
    private var searchResults = SearchResults()
    private var pendingRequestWorkItem: DispatchWorkItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUI()
        addTarget()
        setDelegate()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData { [weak self] in
            self?.displayView.tableView.reloadData()
            DispatchQueue.main.async {
                self?.displayView.tableView.reloadData()
            }
        }
    }
}

// set tableView
extension DisplayViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // change datasource when search bar is active
        if displayView.searchController.isActive {
            displayView.bigEditButton.isHidden = true
            displayView.searchResultsLabel.isHidden = SearchResults.hiddenMode
            return SearchResults.noteArray.count
        } else {
            displayView.searchResultsLabel.isHidden = SearchResults.hiddenMode
            guard let count = notes?.count else {
                return 0
            }
            if count == 0 {
                displayView.bigEditButton.isHidden = false
            } else {
                displayView.bigEditButton.isHidden = true
            }
            return count
        }
    }

//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 10
//    }

    // init tabelview cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // init a not reusable new cell to avoid hight update error?
        guard let cell = tableView.dequeueReusableCell(withIdentifier:
                                                        MyTableViewCell.description(),
                                                        for: indexPath) as? MyTableViewCell
        else {
            return MyTableViewCell(style: .default, reuseIdentifier: "cell")
        }

        cell.selectionStyle = .none
        cell.layoutIfNeeded()
        cell.collectionView.reloadData()

        if displayView.searchController.isActive {
            if let keyword = displayView.searchController.searchBar.searchTextField.text {
                SearchResults.sortedLabelArray = SearchResults.sort(keyword: keyword,
                                                                    text: SearchResults
                                                                        .noteArray[indexPath.row]
                                                                        .tag.array)
                SearchResults.clippedNoteContent = SearchResults.clipNoteContent(keyword: keyword,
                                                                                 text: SearchResults
                                                                                    .noteArray[indexPath.row]
                                                                                    .content)
                SearchResults.keyword = keyword
            }

            cell.noteLabelArray = SearchResults.sortedLabelArray
            cell.privateLabel.text = "ε¬"
            cell.contentLabel.attributedText = SearchResults.clippedNoteContent
                                                            .attributedString(lineSpaceing: 8,
                                                                              lineBreakModel: .byTruncatingTail,
                                                                              keyword: SearchResults.keyword)
        } else {
            SearchResults.keyword.removeAll()
            if let notesLabelArray = notes?[indexPath.row].tag.array {
                cell.noteLabelArray = notesLabelArray
            } else {
                cell.noteLabelArray = []
            }
            cell.privateLabel.text = notes?[indexPath.row].status.intToString
            cell.contentLabel.attributedText = notes?[indexPath.row].content
                .attributedString(lineSpaceing: 8, lineBreakModel: .byTruncatingTail)
        }
        return cell
    }

    // delete action
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt
                    indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // set bubble
        let hander: (UIAlertAction) -> Void = {_ in
            guard let id = notes?[indexPath.row].id else {
                return
            }
            self.deleteNote(id: id, row: indexPath.row) {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
        let bubble = MyAlertController.setBubble(title: "", message: "η‘?ε?θ¦ε ι€θ―₯η¬θ?°εοΌ", action: true, yesHander: hander)

        // set delete action
        if displayView.searchController.isActive {
            return UISwipeActionsConfiguration()
        } else {
            let deleteAction = UIContextualAction(style: .normal, title: "ε ι€") { (_, _, completionHandler) in
                self.presentBubble(bubble)
                completionHandler(true)
            }
            deleteAction.backgroundColor = UIColor.deleteColor

            // return configure
            let configure = UISwipeActionsConfiguration(actions: [deleteAction])
            configure.performsFirstActionWithFullSwipe = false

            return configure
        }
    }

    // select tableview cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = EditNoteViewController()

        if displayView.searchController.isActive {
            let searchNote = SearchResults.noteArray[indexPath.row]
            let myNote = try? DBManager.db?.queryNote(nid: searchNote.id)

            if let myNote = myNote {
                configureMyNotePage(viewController: viewController, note: myNote)
            // δΈζ―εεͺζΎη€ΊδΈθ½ηΌθΎ
            } else {
                let viewController = SearchViewController()
                configureOthersSearchNotePage(viewController: viewController, note: searchNote)
                self.navigationController?.pushViewController(viewController, animated: false)
                return
            }
        // update
        } else {
            guard let myNote = notes?[indexPath.row] else {
                return
            }
            configureMyNotePage(viewController: viewController, note: myNote)
        }
        self.navigationController?.pushViewController(viewController, animated: false)
    }
}

// search
extension DisplayViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        pendingRequestWorkItem?.cancel()

        let jwt = userAccount.string(forKey: UserDefaultKeys.AccountInfo.jwt.rawValue)
        let userInfo = UserInfo(authorization: jwt)
        var text: String?
        DispatchQueue.main.async {
            text = searchController.searchBar.searchTextField.text
        }
        let requestWorkItem = DispatchWorkItem { [self] in
            requestAndResponse(userInfo: userInfo,
                               function: .search,
                               method: .get,
                               searchText: searchController.searchBar.text) { [self] serverDescription in

                // ε¦ζζ²‘ζζη΄’η»ζ ζΎη€Ίζ η­Ύ ε¦ε ιθ
                SearchResults.hiddenMode = serverDescription.pagination?.total == 0 ? false : true
                // ε¦ζζ²‘ζζη΄’η»ζ ζθ ζ²‘ζθΎε₯οΌζΈη©ΊηΌε­οΌreload data
                if serverDescription.pagination?.total == 0 || text == "" {
                    SearchResults.noteArray.removeAll()
                } else {
                    SearchResults.noteArray.removeAll()
                    guard let items = serverDescription.items else {
                        print("items is nil, but souldn't to be")
                        return
                    }
                    for item in items {
                        guard let id = item.id, let tag = item.title, let content = item.content else {
                            return
                        }
                        // search results of isPublic are always nil ?
                        guard let status = (item.isPublic == true) ? 1 : 0 else {
                            return
                        }
                        SearchResults.noteArray.append(SQLNote(id: id, tag: tag, content: content, status: status))
                    }
                }
                loadData { [weak self] in
                    self?.displayView.tableView.reloadData()
                    DispatchQueue.main.async {
                        self?.displayView.tableView.reloadData()
                    }
                }
            }
        }
        pendingRequestWorkItem = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: requestWorkItem)
    }
}

// UI
private extension DisplayViewController {
    func setUI() {
        self.view.addSubview(displayView)
        setNavigationBar()
        displayView.setUI()
        setConstrains()
    }

    func setNavigationBar() {
        self.view.backgroundColor = UIColor.white
        self.title = ""
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.navigationColor
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: displayView.logOutButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: displayView.editButton)
        // set searchbar
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = displayView.searchController
    }

    func setConstrains() {
        displayView.snp.makeConstraints {
            $0.bottom.top.leading.width.height.equalToSuperview()
        }
    }

    func addTarget() {
        displayView.bigEditButton.addTarget(self, action: #selector(createNotes), for: .touchUpInside)
        displayView.logOutButton.addTarget(self, action: #selector(showBubble), for: .touchUpInside)
        displayView.editButton.addTarget(self, action: #selector(createNotes), for: .touchUpInside)
    }

    func setDelegate() {
        displayView.tableView.dataSource = self
        displayView.tableView.delegate = self
        displayView.searchController.searchResultsUpdater = self
    }
}

// UI response
private extension DisplayViewController {
    func deleteUserDefaulte() {
        userAccount.removeObject(forKey: UserDefaultKeys.AccountInfo.jwt.rawValue)
    }

    func presentLoginPage() {
        self.navigationController?.popToRootViewController(animated: false)
        let bubble = MyAlertController.setBubble(title: "", message: "ε·²η»εΊ", action: false)
        presentBubbleAndDismiss(bubble)
    }

    func presentEditPage() {
        EditData.noteLabelArray = []
        EditData.nid = ""
        let viewController = EditNoteViewController()
        viewController.onSave = { [weak self] in
            self?.displayView.tableView.reloadData()
            DispatchQueue.main.async {
                self?.displayView.tableView.reloadData()
            }
        }
        viewController.title = "ζ°ε»Ίη¬θ?°"
        self.navigationController?.pushViewController(viewController, animated: false)
    }

    func configureMyNotePage(viewController: EditNoteViewController, note: SQLNote) {
        EditData.noteLabelArray = note.tag.array
        EditData.nid = note.id
        EditData.segmentIndex = note.status
        viewController.editView.textLabelView.text = note.tag
        viewController.editView.textContenView.text = note.content
        viewController.title = "ζηζθ?°"
    }

    func configureOthersSearchNotePage(viewController: SearchViewController, note: SQLNote) {
        SearchData.noteLabelArray = note.tag.array
        viewController.searchView.textContenView.text = note.content
        viewController.title = "ζθ?°"
    }
}

// target
private extension DisplayViewController {
    @objc func showBubble() {
        let bubble = MyAlertController.setBubble(title: "", message: "η‘?ε?θ¦ιεΊη»ιεοΌ", action: true, yesHander: { _ in
        self.loginOut() })
        presentBubble(bubble)
    }

    @objc func loginOut() {
        // get jwt
        let jwt = userAccount.string(forKey: UserDefaultKeys.AccountInfo.jwt.rawValue)
        let userInfo = UserInfo(authorization: jwt)
        logoutRequest(userInfo: userInfo) { _ in
            self.deleteUserDefaulte()
            DispatchQueue.main.async {
                self.presentLoginPage()
            }
        }
    }

    @objc func createNotes() {
        presentEditPage()
    }
}
