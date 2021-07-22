//
//  AuthAPI.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/21.
//

import Foundation
import Moya

// 유저 로그인, 회원가입과 관련된 API

enum AuthAPI {
    case idChek(_ id: String)
    case signUp(_ signUpModel: SignUpModel)
    case passwordChange(_ password: String)
//    case resign(_)
    case login(_ id: String, _ password: String)
    case getMemberInfo
//    case modifyMemberInfo

}

extension AuthAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://3.34.138.102:5000/Auth")!
    }
    
    var path: String {
        switch self {
        case .idChek(_):
            return "/register"
        case .signUp(_):
            return "/register"
        case .passwordChange(_):
            return "/register"
        case .login(_, _):
            return "/login"
        case .getMemberInfo:
            return "/login"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .idChek(_):
            return .get
        case .signUp(_):
            return .post
        case .passwordChange(_):
            return .put
        case .login(_, _):
            return .post
        case .getMemberInfo:
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .idChek(let id):
            return .requestParameters(parameters: ["id": id], encoding: JSONEncoding.default)
        case .signUp(let signUpModel):
            return .requestJSONEncodable(signUpModel)
        case .passwordChange(let password):
            return .requestParameters(parameters: ["password": password], encoding: JSONEncoding.default)
        case .login(let id, let password):
            return .requestParameters(parameters: ["id": id, "password": password], encoding: JSONEncoding.default)
        case .getMemberInfo:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
    
    
}
