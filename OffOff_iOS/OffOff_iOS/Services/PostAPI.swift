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
    case getPostList(_ board_type: String)
    case getBoardList
    case getPost(content_id: String, board_type: String)
//    case makePost
//    case modifyPost
//    case deletePost
}

extension PostAPI: TargetType {
    var baseURL: URL {
        return URL(string: Constants.API_SOURCE)!
    }
    
    var path: String {
        switch self {
        case .getPostList(let board_type):
            return "/postlist/\(board_type)"
        case .getBoardList:
            return "/boardlist"
        case .getPost(let content_id, let board_type):
            return "/post"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getPostList(_):
            return .get
        case .getBoardList:
            return .get
        case .getPost(_, _):
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .getPostList(_):
            return .requestPlain
        case .getBoardList:
            return .requestPlain
        case .getPost(let content_id, let board_type):
            return .requestParameters(parameters: ["content-id": content_id, "board-type": board_type], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
    
    
}
