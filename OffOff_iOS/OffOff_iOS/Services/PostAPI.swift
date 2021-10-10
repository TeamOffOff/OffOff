//
//  PostAPI.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/27.
//

import Foundation
import Moya

// 게시글, 게시글 목록과 관련된 API

enum PostAPI {
    case getPost(content_id: String, board_type: String)
    case makePost(post: WritingPost)
//    case modifyPost
    case deletePost(post: DeletingPost)
    case likePost(post: PostActivity)
}

extension PostAPI: TargetType {
    var baseURL: URL {
        return URL(string: Constants.API_SOURCE)!
    }
    
    var path: String {
        switch self {
        case .getPost(_, _):
            return "/post"
        case .makePost(_):
            return "/post"
        case .deletePost(_):
            return "/post"
        case .likePost(_):
            return "/post"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getPost(_, _):
            return .get
        case .makePost(_):
            return .post
        case .deletePost(_):
            return .delete
        case .likePost(_):
            return .put
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .getPost(let content_id, let board_type):
            return .requestParameters(parameters: ["postId": content_id, "boardType": board_type], encoding: URLEncoding.default)
        case .makePost(let post):
            return .requestJSONEncodable(post)
        case .deletePost(let post):
            return .requestJSONEncodable(post)
        case .likePost(let post):
            return .requestJSONEncodable(post)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json", "Authorization": "Bearer \(UserDefaults.standard.string(forKey: "accessToken")!)"]
    }
    
    
}

struct DeletingPost: Codable {
    var _id: String
    var boardType: String
    var author: String
}
