//
//  Network.swift
//  test
//
//  Created by 李远卓 on 2021/7/9.
//
import Foundation
import Alamofire
// url
struct URL {
    static let http = "http://"
    static let https = "https://"
    static let host = "mainote.maimemo.com/"
    static let login = "api/auth/login"
    static let logout = "api/auth/logout"
    static let getAllNotes = "api/notes" // 全量
    static let createNotes = "api/note"
    static let delete = "api/notes/"
    static let getNoteWithID = "api/notes"
    static let updateNotes = "api/notes/"
}
// 解析JSON
struct ServerDescription: Codable {
    struct Author: Codable {
        let id: String?
        let meimoId: String?
        let name: String?
    }
    struct Pagination: Codable {
        let limit: Int?
        let skip: Int?
        let total: Int?
    }
    struct Items: Codable {
        let id: String?
        let title: String?
        let tags: [String]?
        let content: String?
        let isPublic: Bool?
        let checksum: String?
        let isFavorited: Bool?
        let localUpdatedAt: String?
        let author: Author?
    }
    let author: Author?
    let pagination: Pagination?
    let remoteNotes: [Items]?
    let remoteNotesConflict: [Items]?
    let items: [Items]?
    let error: Int?
    let message: String?
    let id: String?
    let maimemoId: Double? // int?
    let email: String?
    let name: String?
    let jwt: String?
    let title: String?
    let tags: [String]?
    let content: String?
    let isPublic: Bool?
    let checksum: String?
    let isFavorited: Bool?
    let localUpdatedAt: String?
    private enum CodingKeys: String, CodingKey {
        case error = "error", id = "id", maimemoId = "maimemo_id"
        case email = "email", name = "name", jwt = "jwt", message = "message"
        case pagination = "pagination", items = "items", remoteNotes = "remote_notes"
        case remoteNotesConflict = "remote_notes_conflict", title = "title", tags = "tags"
        case content = "content", isPublic = "is_public", checksum = "checksum"
        case isFavorited = "is_favorited", localUpdatedAt = "local_updated_at", author = "author"
    }
 }
// 接口属性，枚举
enum Function {
    case login, logout, getAllNotes, createNotes, delete, updateNotes, getNoteWithID
}
// 请求参数 除了登录以外，其他的请求都需要在headers里面加上Authorization字段
struct UserInfo {
    struct Note {
        var title: String?
        var content: String?
        var status: Bool?
        var checksum: String?
        var localUpdatedAt: String?
    }
    var email: String?
    var pwd: String?
    var authorization: String?
    var nid: String?
    var note: Note?
}
// 请求服务器
func requestAndResponse(userInfo: UserInfo? = nil, function: Function,
                        method: HTTPMethod, completion: @escaping (_: ServerDescription) -> Void) {
    var parameters: [String: Any?]?
    var headers: HTTPHeaders?
    if userInfo?.authorization != nil {
        headers = ["Authorization": "Bearer " + (userInfo?.authorization)!]
    }
    if method == .get {
        parameters = nil
    }
    let url: String
    switch function {
    case .login:
        url = URL.https + URL.host + URL.login
        parameters = ["identity": userInfo?.email,
                      "password": userInfo?.pwd]
    case .logout:
        url = URL.https + URL.host + URL.logout
    case .getAllNotes:
        url = URL.https + URL.host + URL.getAllNotes // 全量
    case .createNotes:
        url = URL.https + URL.host + URL.createNotes
        parameters = ["title": userInfo?.note?.title,
                      "content": userInfo?.note?.content,
                      "is_public": userInfo?.note?.status,
                      "checksum": userInfo?.note?.checksum,
                      "local_updated_at": userInfo?.note?.localUpdatedAt]
    case .delete:
        guard let nid = userInfo?.nid else {
            return
        }
        url = URL.https + URL.host + URL.delete + nid
    case .getNoteWithID:
        url = URL.https + URL.host + URL.getNoteWithID
        parameters = ["identity": userInfo?.email,
                      "password": userInfo?.pwd]
    case .updateNotes:
        url = URL.https + URL.host + URL.updateNotes
        parameters = ["identity": userInfo?.email,
                      "password": userInfo?.pwd]
        parameters = ["title": userInfo?.note?.title,
                      "content": userInfo?.note?.content,
                      "is_public": userInfo?.note?.status,
                      "checksum": userInfo?.note?.checksum,
                      "local_updated_at": userInfo?.note?.localUpdatedAt]
    }
    AF.request(url, method: method, parameters: (parameters ?? nil) as? Parameters,
               encoding: JSONEncoding.default, headers: headers).responseJSON { response in
        // 大括号是closure，匿名函数，response是参数，捕获上下文
        switch response.result {
        case .success(let json):
                guard let data = response.data else { return }
                // 解析JSON和捕获异常
                do {
                    let serverDescription = try JSONDecoder().decode(ServerDescription.self, from: data)
                    completion(serverDescription)
                    print(json)
                } catch let jsonErr {
                    print("json 解析出错 : ", jsonErr)
                }
        case .failure(let error):
                print(error)
        }
    }
}
