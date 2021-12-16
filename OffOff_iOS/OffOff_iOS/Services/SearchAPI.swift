//
//  SearchAPI.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/11/13.
//

import Foundation
import Moya

enum SearchAPI {
    case searchInBoard(boardType: String, key: String, standardId: String?)
    case totalSearch(key: String, lastPostId: String?)
}

extension SearchAPI: TargetType {
    var baseURL: URL {
        return URL(string: Constants.API_SOURCE)!
    }
    
    var path: String {
        switch self {
        case .searchInBoard(let boardType, _, _):
            return "/search/\(boardType)"
        case .totalSearch(_, _):
            return "/totalsearch"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .searchInBoard(_, _, _):
            return .get
        case .totalSearch(_, _):
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .searchInBoard(_, let key, let standardId):
            if standardId == nil {
                return .requestParameters(parameters: ["key":key], encoding: URLEncoding.default)
            } else {
                return .requestParameters(parameters: ["standardId":standardId!, "key":key], encoding: URLEncoding.default)
            }
        case .totalSearch(let key, let lastPostId):
            if lastPostId == nil {
                return .requestParameters(parameters: ["key":key], encoding: URLEncoding.default)
            } else {
                return .requestParameters(parameters: ["lastPostId":lastPostId!, "key":key], encoding: URLEncoding.default)
            }
        }
    }
    
    var headers: [String : String]? {
        return KeyChainController.shared.getAuthorizationHeader(service: Constants.ServiceString, account: "AccessToken")!
    }
}

