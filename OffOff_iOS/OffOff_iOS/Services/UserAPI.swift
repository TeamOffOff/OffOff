//
//  UserAPI.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/21.
//

import Foundation
import Moya

// 유저 로그인, 회원가입과 관련된 API

enum UserAPI {
    case idChek(_ id: String)
    case emailCheck(_ email: String)
    case nicknameCheck(_ nickname: String)
    case signUp(_ signUpModel: UserModel)
    case passwordChange(_ password: String)
    case resign
    case login(_ id: String, _ password: String)
    case getUserInfo(_ token: String)
    case modifyMemberInfo(_ signUpModel: UserModel)
    
}

extension UserAPI: TargetType {
    var baseURL: URL {
        return URL(string: "\(Constants.API_SOURCE)/user")!
    }
    
    var path: String {
        switch self {
        case .idChek(_):
            return "/register"
        case .emailCheck(_):
            return "/register"
        case .nicknameCheck(_):
            return "/register"
        case .signUp(_):
            return "/register"
        case .passwordChange(_):
            return "/register"
        case .login(_, _):
            return "/login"
        case .getUserInfo(_):
            return "/login"
        case .resign:
            return "/TODO"
        case .modifyMemberInfo(_):
            return "/TODO"
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
        case .getUserInfo(_):
            return .get
        case .resign:
            return .get
        case .modifyMemberInfo(_):
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
        case .getUserInfo(_):
            return .requestPlain
        case .resign:
            return .requestPlain
        case .modifyMemberInfo(_):
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .passwordChange(_), .resign, .modifyMemberInfo(_):
            return ["Authorization": "token_encoded"]
        case .getUserInfo(let token):
            return ["Authorization": token]
        default:
            return ["Content-type": "application/json"]
        }
        
    }
    
}
