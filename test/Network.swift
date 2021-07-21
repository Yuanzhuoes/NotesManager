//
//  Network.swift
//  test
//
//  Created by 李远卓 on 2021/7/9.
//
import Foundation
import Alamofire
// url
extension URL {
    enum Scheme: String {
        case http
        case https
    }
    enum Host: String {
        case main = "mainote.maimemo.com"
        case www = "www.maimemo.com"
    }
    enum Path {
        case login
        case logout
        case notes
        case createNote
        case delete(String) // 关联值
    }
    static func make(scheme: Scheme = .https, host: Host = .main, path: Path) -> URL? {
        var comps = URLComponents()
        comps.scheme = scheme.rawValue
        comps.host = host.rawValue
        switch path {
        case .login:
            comps.path = "/api/auth/login"
        case .logout:
            comps.path = "/api/auth/logout"
        case .notes:
            comps.path = "/api/notes"
        case.createNote:
            comps.path = "/api/note"
        case .delete(let nid):
            comps.path = "/api/notes/\(nid)"
        }
        return comps.url
    }

    func test() {
        let url = URL.make(path: .login)
        print("\(String(describing: url))")
    }
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
// 用可选是因为不是所有的信息都有，设默认值也不方便
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
func requestAndResponse(userInfo: UserInfo? = nil, function: Function,
                        method: HTTPMethod, completion: @escaping (_: ServerDescription) -> Void) {
    var parameters: [String: Any]? // Any可以表示可选类型 所以可以不写问号, parameters可以没有 默认为nil
    var headers: HTTPHeaders?
    let url: URL?
    if userInfo?.authorization != nil {
        headers = ["Authorization": "Bearer " + (userInfo?.authorization)!]
    }
    switch function {
    case .login:
        url = URL.make(path: .login)
        parameters = ["identity": userInfo?.email as Any, // 用Any承载可选值，需要显示转换，防止报错
                      "password": userInfo?.pwd as Any]
    case .logout:
        url = URL.make(path: .logout)
    case .getAllNotes:
        url = URL.make(path: .notes)
    case .createNotes:
        url = URL.make(path: .createNote)
        parameters = ["title": userInfo?.note?.title as Any,
                      "content": userInfo?.note?.content as Any,
                      "is_public": userInfo?.note?.status as Any,
                      "checksum": userInfo?.note?.checksum as Any,
                      "local_updated_at": userInfo?.note?.localUpdatedAt as Any]
    case .delete:
        guard let nid = userInfo?.nid else {
            print("nid is nil")
            return
        }
        url = URL.make(path: .delete(nid))
    case .getNoteWithID:
        url = URL.make(path: .notes)
        parameters = ["identity": userInfo?.email as Any,
                      "password": userInfo?.pwd as Any]
    case .updateNotes:
        url = URL.make(path: .notes)
        parameters = ["title": userInfo?.note?.title as Any,
                      "content": userInfo?.note?.content as Any,
                      "is_public": userInfo?.note?.status as Any,
                      "checksum": userInfo?.note?.checksum as Any,
                      "local_updated_at": userInfo?.note?.localUpdatedAt as Any]
    }

    // TODO: optional URL
    let urlString = url?.absoluteString
    var request: DataRequest?
    request =
        AF.request(urlString.safe,
                   method: method,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: headers).responseJSON { response in
                    DispatchQueue.global().async {
                        if let curl = request?.cURLDescription() {
                            print("API: \(curl)")
                        }
                    }
                    switch response.result {
                    case .success(let json):
                        guard let data = response.data else { return }
                        // 解析JSON和捕获异常
                        do {
                            let serverDescription = try JSONDecoder().decode(ServerDescription.self, from: data)
                            // capture serverDescription
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
// set default optional value of string to ""
extension Optional where Wrapped == String {
    var safe: String {
       return self ?? ""
    }
}
