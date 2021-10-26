//
//  BoardAPI.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/08/01.
//

import Foundation
import Moya

enum BoardAPI {
    case makeBoard
    case deleteBoard
    case getBoardList
    case getPostList(_ boardType: String, _ lastContentID: String?)
}

extension BoardAPI: TargetType {
    var baseURL: URL {
        return URL(string: Constants.API_SOURCE)!
    }
    
    var path: String {
        switch self {
        case .makeBoard:
            return "/boardlist"
        case .deleteBoard:
            return "/boardlist"
        case .getBoardList:
            return "/boardlist"
        case .getPostList(let boardType, _):
            return "/postlist/\(boardType)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .makeBoard:
            return .post
        case .deleteBoard:
            return .delete
        case .getBoardList:
            return .get
        case .getPostList(_, _):
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .makeBoard:
            return .requestPlain
        case .deleteBoard:
            return .requestPlain
        case .getBoardList:
            return .requestPlain
        case .getPostList(_, _):
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
    
    
}
