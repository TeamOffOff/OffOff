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
    case writeReply(reply: WritingReply)
    case likeReply(reply: PostActivity)
    case deleteReply(reply: DeletingReply)
}

extension ReplyAPI: TargetType {
    var baseURL: URL {
        return URL(string: Constants.API_SOURCE)!
    }
    
    var path: String {
        switch self {
        case .getReplies(_, _):
            return "/reply"
        case .writeReply(_):
            return "/reply"
        case .likeReply(_):
            return "/reply"
        case .deleteReply(_):
            return "/reply"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getReplies(_, _):
            return .get
        case .writeReply(_):
            return .post
        case .likeReply(_):
            return .put
        case .deleteReply(_):
            return .delete
        }
    }
    
    var sampleData: Data {
        Data()
    }
    
    var task: Task {
        switch self {
        case .getReplies(let postId, let boardType):
            return .requestParameters(parameters: ["postId": postId, "boardType": boardType], encoding: URLEncoding.default)
        case .writeReply(let reply):
            return .requestJSONEncodable(reply)
        case .likeReply(let reply):
            return .requestJSONEncodable(reply)
        case .deleteReply(let reply):
            return .requestJSONEncodable(reply)
        }
    }
    
    var headers: [String : String]? {
        return ["Authorization": "Bearer \(UserDefaults.standard.string(forKey: "accessToken")!)"]
    }
}
