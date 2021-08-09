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
    case makePost(post: Post)
//    case modifyPost
//    case deletePost
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
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getPost(_, _):
            return .get
        case .makePost(_):
            return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .getPost(let content_id, let board_type):
            return .requestParameters(parameters: ["content-id": content_id, "board-type": board_type], encoding: URLEncoding.default)
        case .makePost(let post):
            return .requestJSONEncodable(post)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
    
    
}
