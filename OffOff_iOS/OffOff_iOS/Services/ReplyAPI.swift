//
//  ReplyAPI.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/10/01.
//

import Foundation
import Moya

enum ReplyAPI {
    case getReplies(_ postId: String, _ boardType: String)
//    case writeReply
//    case deleteReply
//    case likeReply
}

extension ReplyAPI: TargetType {
    var baseURL: URL {
        return URL(string: Constants.API_SOURCE)!
    }
    
    var path: String {
        switch self {
        case .getReplies(_, _):
            return "/reply"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getReplies(_, _):
            return .get
        }
    }
    
    var sampleData: Data {
        Data()
    }
    
    var task: Task {
        switch self {
        case .getReplies(let postId, let boardType):
            return .requestParameters(parameters: ["postId": postId, "boardType": boardType], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        nil
    }
    
    
}
