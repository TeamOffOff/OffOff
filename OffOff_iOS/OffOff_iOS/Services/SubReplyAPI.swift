//
//  SubReplyAPI.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/10/24.
//

import Foundation
import Moya

enum SubReplyAPI {
    case writeSubReply(subReply: WritingReply)
    case deleteSubReply(subReply: DeletingSubReply)
    case likeSubReply(subReply: PostActivity)
}

extension SubReplyAPI: TargetType {
    var baseURL: URL {
        return URL(string: Constants.API_SOURCE)!
    }
    
    var path: String {
        return "/subreply"
    }
    
    var method: Moya.Method {
        switch self {
        case .writeSubReply(_):
            return .post
        case .deleteSubReply(_):
            return .delete
        case .likeSubReply(_):
            return .put
        }
    }
    
    var sampleData: Data {
        Data()
    }
    
    var task: Task {
        switch self {
        case .writeSubReply(let subReply):
            return .requestJSONEncodable(subReply)
        case .deleteSubReply(let subReply):
            return .requestJSONEncodable(subReply)
        case .likeSubReply(let subReply):
            return .requestJSONEncodable(subReply)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json", "Authorization": "Bearer \(UserDefaults.standard.string(forKey: "accessToken")!)"]
    }
}
