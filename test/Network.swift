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

    enum Path: String {
        case login      = "/api/auth/login"
        case logout     = "/api/auth/logout"
        case notes      = "/api/notes"          // 全量
        case createNote = "/api/note"
        case delete     = "/api/notes/"
    }

    static func make(scheme: Scheme = .https, host: Host = .main, path: Path) -> URL? {
        var comps = URLComponents()
        comps.scheme = scheme.rawValue
        comps.host = host.rawValue
        comps.path = path.rawValue
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

// swiftlint:disable:next cyclomatic_complexity
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
    let url: URL?
    switch function {
    case .login:
        url = URL.make(path: .login)
        parameters = ["identity": userInfo?.email,
                      "password": userInfo?.pwd]
    case .logout:
        url = URL.make(path: .logout)
    case .getAllNotes:
        url = URL.make(path: .notes)
    case .createNotes:
        url = URL.make(path: .createNote)
        parameters = ["title": userInfo?.note?.title,
                      "content": userInfo?.note?.content,
                      "is_public": userInfo?.note?.status,
                      "checksum": userInfo?.note?.checksum,
                      "local_updated_at": userInfo?.note?.localUpdatedAt]
    case .delete:
        if userInfo?.nid == nil {
            return
        }
        url = URL.make(path: .delete)
    case .getNoteWithID:
        url = URL.make(path: .notes)
        parameters = ["identity": userInfo?.email,
                      "password": userInfo?.pwd]
    case .updateNotes:
        url = URL.make(path: .notes)
        parameters = ["identity": userInfo?.email,
                      "password": userInfo?.pwd]
        parameters = ["title": userInfo?.note?.title,
                      "content": userInfo?.note?.content,
                      "is_public": userInfo?.note?.status,
                      "checksum": userInfo?.note?.checksum,
                      "local_updated_at": userInfo?.note?.localUpdatedAt]
    }

    var params = [String: Any]()
    for (key, value) in parameters ?? [:] {
        if let value = value {
            params[key] = value
        }
    }

    // TODO: optional URL
    let urlString = url?.absoluteString
    var request: DataRequest?
    request =
        AF.request(urlString!,
                   method: method,
                   parameters: params,
                   encoding: JSONEncoding.default,
                   headers: headers).responseJSON { response in
                    DispatchQueue.global().async {
                        if let curl = request?.cURLDescription() {
                            print("API: \(curl)")
                        }
                    }
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
