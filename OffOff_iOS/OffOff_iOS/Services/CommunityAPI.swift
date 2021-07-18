//
//  CommunityAPI.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/14.
//

/*
    Community 기능과 관련된 API
*/
import Foundation
import Moya

enum CommunityAPI {
    case newPost(_ post: PostModel)
    case getPost(_ id: String)
//    case deletePost
//    case openPost
}

extension CommunityAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://3.34.138.102:5000")!
    }
    
    var path: String {
        switch self {
        case .newPost(let post):
            return "/post/content-id=\(post.content_id)"
        case .getPost(_):
            return "/post"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .newPost(_):
            return .put
        case .getPost(_):
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .newPost(let post):
            return .requestJSONEncodable(post)
        case .getPost(let id):
            return .requestParameters(parameters: ["_id": id], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
    
    
}

//static func makeNewPost(post: PostModel, completion: @escaping MakeNewPostCompletion) {
//    #if DEBUG
//    let source = "http://3.34.138.102:5000/post/content-id=\(post.content_id)"
//    AF.request(source, method: .put, parameters: post, encoder: JSONParameterEncoder.default).response { (response) in
//        print(response)
//        completion(post, response.error)
//    }
//    #endif
//}
