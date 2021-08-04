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
        case delete(String) // associated values
        case update(String)
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
        case .update(let nid):
            comps.path = "/api/notes/\(nid)"
        }
        return comps.url
    }

    func test() {
        let url = URL.make(path: .login)
        print("\(String(describing: url))")
    }
}

// JSON decoder model
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
    let maimemoId: Double?
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
        case error = "error"
        case id = "id"
        case maimemoId = "maimemo_id"
        case email = "email"
        case name = "name", jwt = "jwt"
        case message = "message"
        case pagination = "pagination"
        case items = "items"
        case remoteNotes = "remote_notes"
        case remoteNotesConflict = "remote_notes_conflict"
        case title = "title"
        case tags = "tags"
        case content = "content"
        case isPublic = "is_public"
        case checksum = "checksum"
        case isFavorited = "is_favorited"
        case localUpdatedAt = "local_updated_at"
        case author = "author"
    }
}

enum Function {
    case login, logout, getAllNotes, createNotes, delete, updateNotes, search
}

// request parameters
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
                        method: HTTPMethod, searchText: String? = nil,
                        completion: @escaping (_: ServerDescription) -> Void) {
    var parameters: [String: Any]? // Any can be optional
    var headers: HTTPHeaders?
    // JSONEncoding and URLEncoding are both the Parameter type, JSON encodes body, URL encods url
    var encoding: ParameterEncoding = JSONEncoding.default
    let url: URL?
    if userInfo?.authorization != nil {
        headers = ["Authorization": "Bearer " + (userInfo?.authorization)!]
    }

    switch function {
    case .login: // post
        url = URL.make(path: .login)
        parameters = ["identity": userInfo?.email as Any, // explicit conversion when Any is optional
                      "password": userInfo?.pwd as Any]
    case .logout: // post
        url = URL.make(path: .logout)
    case .getAllNotes: // get
        url = URL.make(path: .notes)
    case .createNotes: // post
        url = URL.make(path: .createNote)
        parameters = ["title": userInfo?.note?.title as Any,
                      "content": userInfo?.note?.content as Any,
                      "is_public": userInfo?.note?.status as Any,
                      "checksum": userInfo?.note?.checksum as Any,
                      "local_updated_at": userInfo?.note?.localUpdatedAt as Any]
    case .delete: // delete
        guard let nid = userInfo?.nid else {
            print("nid is nil")
            return
        }
        url = URL.make(path: .delete(nid))
    case .updateNotes: // patch
        guard let nid = userInfo?.nid else {
            print("nid is nil")
            return
        }
        url = URL.make(path: .update(nid))
        parameters = ["title": userInfo?.note?.title as Any,
                      "content": userInfo?.note?.content as Any,
                      "is_public": userInfo?.note?.status as Any,
                      "checksum": userInfo?.note?.checksum as Any,
                      "local_updated_at": userInfo?.note?.localUpdatedAt as Any]
    case .search: // get
        url = URL.make(path: .notes)
        guard let searchText = searchText else {
            return
        }
        parameters = ["search": searchText]
        encoding = URLEncoding.default
    }

    let queue = DispatchQueue.global(qos: .utility)
    let urlString = url?.absoluteString
    var request: DataRequest?
    request =
        AF.request(urlString.safe,
                   method: method,
                   parameters: parameters,
                   encoding: encoding,
                   headers: headers).responseJSON(queue: queue) { response in
                    // 后台异步
                    DispatchQueue.global().async {
                        if let curl = request?.cURLDescription() {
                            print("API: \(curl)")
                        }
                    }
                    // 主线程
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
