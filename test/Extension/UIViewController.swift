//
//  ExtensionUIViewController.swift
//  test
//
//  Created by 李远卓 on 2021/7/28.
//

import UIKit

// network request
extension UIViewController {
    // create a new note
    func createNote(userInfo: UserInfo, completion: (() -> Void)?) {
        requestAndResponse(userInfo: userInfo, function: .createNotes, method: .post) { serverDescription in
            if serverDescription.id != nil {
                let nid = serverDescription.id
                let status = userInfo.note?.status == true ? 1 : 0

                // load notes to DB
                do {
                    try DBManager.db?.insertNote(myNote: SQLNote(id: nid!, tag: (userInfo.note?.title)!,
                                                content: (userInfo.note?.content)!,
                                                status: status))
                } catch {
                    print(DBManager.db?.errorMessage as Any)
                }

                // update notes buffer
                do {
                    notes = try DBManager.db?.queryAllSQLNotes()
                } catch {
                    print(DBManager.db?.errorMessage as Any)
                }
                // excute clousure
                DispatchQueue.main.async {
                    let bubble = MyAlertController.setBubble(title: "", message: "保存成功", action: false)
                    self.presentBubbleAndDismiss(bubble)
                    completion?()
                }
            }
        }
    }

    // upadate a note
    func updateNote(userInfo: UserInfo, completion: (() -> Void)?) {
        requestAndResponse(userInfo: userInfo, function: .updateNotes, method: .patch) { _ in
            let status = userInfo.note?.status == true ? 1 : 0

            do {
                try DBManager.db?.updateNote(myNote: SQLNote(id: userInfo.nid!,
                                                             tag: (userInfo.note?.title)!,
                                                             content: (userInfo.note?.content)!,
                                                             status: status))
            } catch {
                print(DBManager.db?.errorMessage as Any)
            }

            // update notes buffer
            do {
                notes = try DBManager.db?.queryAllSQLNotes()
            } catch {
                print(DBManager.db?.errorMessage as Any)
            }
            DispatchQueue.main.async {
                completion?()
            }
        }
    }

    // delete a note
    func deleteNote(id: String, row: Int, completion: (() -> Void)?) {
        let jwt = userAccount.string(forKey: UserDefaultKeys.AccountInfo.jwt.rawValue)
        let userInfo = UserInfo(authorization: jwt!, nid: id)
        requestAndResponse(userInfo: userInfo, function: .delete, method: .delete) { _ in
            try? DBManager.db?.deleteNote(nid: id)
            notes?.remove(at: row)
            DispatchQueue.main.async {
                completion?()
            }
        }
    }

    // load all of the notes
    func loadData(_ closure: (() -> Void)?) {
        let jwt = userAccount.string(forKey: UserDefaultKeys.AccountInfo.jwt.rawValue)
        let userInfo = UserInfo(authorization: jwt)
        requestAndResponse(userInfo: userInfo, function: .getAllNotes, method: .get) { serverDescription in
            guard let response = serverDescription.items else {
                print("error download notes")
                return
            }
            // update DB
            DBManager.db?.insertAllNotesToDB(notes: response)
            // update buffer
            do {
                notes = try DBManager.db?.queryAllSQLNotes()
            } catch {
                print(DBManager.db?.errorMessage as Any)
            }
            DispatchQueue.main.async {
                closure?()
            }
        }
    }

    // login
    func loginRequest(userInfo: UserInfo, completion: @escaping ((ServerDescription) -> Void)) {
        requestAndResponse(userInfo: userInfo,
                           function: .login, method: .post) { serverDescription in
            // background queue
            completion(serverDescription)
        }
    }

    // logout
    func logoutRequest(userInfo: UserInfo, completion: @escaping ((ServerDescription) -> Void)) {
        requestAndResponse(userInfo: userInfo, function: .logout, method: .post) { serverDescription in
            completion(serverDescription)
        }
    }
}

// present bubble
extension UIViewController {
    func presentBubble(_ bubble: MyAlertController) {
        self.present(bubble, animated: true, completion: nil)
    }

    func presentBubbleAndDismiss(_ bubble: MyAlertController) {
        DispatchQueue.main.async {
            self.present(bubble, animated: true, completion: nil)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            bubble.dismiss(animated: true, completion: nil)
        })
    }
}
