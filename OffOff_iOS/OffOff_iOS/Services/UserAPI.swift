//
//  UserAPI.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/21.
//

import Foundation
import Moya

// 유저 로그인, 회원가입과 관련된 API

enum ActivityTypes: String {
    case posts = "내가 쓴 글"
    case replies = "댓글 단 글"
    case bookmarks = "스크랩한 글"
}

enum UserAPI {
    case idChek(_ id: String)
    case emailCheck(_ email: String)
    case nicknameCheck(_ nickname: String)
    case signUp(_ signUpModel: UserModel)
    case passwordChange(_ password: String)
    case resign
    case login(_ id: String, _ password: String)
    case getUserInfo
    case modifyMemberInfo(_ signUpModel: UserModel)
    case getMyActivities(type: ActivityTypes)
}

extension UserAPI: TargetType, AccessTokenAuthorizable {
    var baseURL: URL {
        return URL(string: "\(Constants.API_SOURCE)")!
    }
    
    var path: String {
        switch self {
        case .idChek(_):
            return "/user/register"
        case .emailCheck(_):
            return "/user/register"
        case .nicknameCheck(_):
            return "/user/register"
        case .signUp(_):
            return "/user/register"
        case .passwordChange(_):
            return "/user/register"
        case .login(_, _):
            return "/user/login"
        case .getUserInfo:
            return "/user/login"
        case .resign:
            return "/TODO"
        case .modifyMemberInfo(_):
            return "/TODO"
        case .getMyActivities(let type):
            switch type {
            case .posts:
                return "/activity/posts"
            case .replies:
                return "/activity/replies"
            case .bookmarks:
                return "/activity/bookmarks"
            }
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .idChek(_):
            return .get
        case .emailCheck(_):
            return .get
        case .nicknameCheck(_):
            return .get
        case .signUp(_):
            return .post
        case .passwordChange(_):
            return .put
        case .login(_, _):
            return .post
        case .getUserInfo:
            return .get
        case .resign:
            return .get
        case .modifyMemberInfo(_):
            return .get
        case .getMyActivities(_):
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .idChek(let id):
            return .requestParameters(parameters: ["id": id], encoding: URLEncoding.default)
        case .emailCheck(let email):
            return .requestParameters(parameters: ["email": email], encoding: URLEncoding.default)
        case .nicknameCheck(let nickname):
            return .requestParameters(parameters: ["nickname": nickname], encoding: URLEncoding.default)
        case .signUp(let signUpModel):
            return .requestJSONEncodable(signUpModel)
        case .passwordChange(let password):
            return .requestParameters(parameters: ["password": password], encoding: JSONEncoding.default)
        case .login(let id, let password):
            return .requestParameters(parameters: ["_id": id, "password": password], encoding: JSONEncoding.default)
        case .getUserInfo:
            return .requestPlain
        case .resign:
            return .requestPlain
        case .modifyMemberInfo(_):
            return .requestPlain
        case .getMyActivities(_):
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var authorizationType: AuthorizationType? {
        switch self {
        case .signUp(_), .idChek(_):
            return nil
        default:
            return .bearer
        }
    }
    
}
