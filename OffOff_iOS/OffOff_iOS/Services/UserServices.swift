//
//  UserServices.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/21.
//

import Foundation
import Moya
import RxMoya
import RxSwift

public class UserServices {
    static let provider = MoyaProvider<UserAPI>()
    
    struct Validation: Codable {
        var queryStatus: String = "Impossible"
    }
    
    struct LoginResponse: Codable {
        var accessToken: String
        var refreshToken: String
//        var queryStatus: String
        var user: UserModel
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(accessToken, forKey: .accessToken)
            try container.encode(refreshToken, forKey: .refreshToken)
//            try container.encode(queryStatus, forKey: .queryStatus)
            try container.encode(user, forKey: .user)
        }
    }
    
    static func idDuplicationCheck(id: String) -> Observable<Bool> {
        if Constants.isValidString(str: id, regEx: Constants.USERID_RULE) {
            return UserServices.provider
                .rx.request(.idChek(id))
                .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                .asObservable()
                .map {
                    let result = try JSONDecoder().decode(Validation.self, from: $0.data)
                    return result.queryStatus == "possible"
                }
                .catchAndReturn(false)
        } else {
            return Observable.just(false)
        }
    }
    
    static func emailDuplicationCheck(email: String) -> Observable<Bool> {
        if Constants.isValidString(str: email, regEx: Constants.USEREMAIL_RULE) {
            return UserServices.provider
                .rx.request(.emailCheck(email))
                .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                .asObservable()
                .map {
                    return $0.statusCode == 200
//                    let result = try JSONDecoder().decode(Validation.self, from: $0.data)
//                    return result.message == "possible"
                }
                .catchAndReturn(false)
        } else {
            return Observable.just(false)
        }
    }
    
    static func nicknameDuplicationCheck(nickname: String) -> Observable<Bool> {
        if Constants.isValidString(str: nickname, regEx: Constants.USERNICKNAME_RULE) {
            return UserServices.provider
                .rx.request(.nicknameCheck(nickname))
                .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                .asObservable()
                .map {
                    let result = try JSONDecoder().decode(Validation.self, from: $0.data)
                    return result.queryStatus == "possible"
                }
                .catchAndReturn(false)
                
        } else {
            return Observable.just(false)
        }
    }
    
    static func signUp(with signUpModel: UserModel) -> Observable<Bool> {
        return UserServices.provider
            .rx.request(.signUp(signUpModel))
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .asObservable()
            .map {
                print($0)
                return $0.statusCode == 200
            }
            .catchAndReturn(false)
    }
    
    static func login(id: String, password: String) -> Observable<LoginResult> {
        return UserServices.provider
            .rx.request(.login(id, password))
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .asObservable()
            .map {
                if $0.statusCode == 200 {
                    let response = try JSONDecoder().decode(LoginResponse.self, from: $0.data)
                    UserDefaults.standard.set(response.refreshToken, forKey: "refreshToken")
                    UserDefaults.standard.set(response.accessToken, forKey: "accessToken")
                }
                return LoginResult(rawValue: $0.statusCode)!
            }
            .catchAndReturn(.NotExist)
    }
    
    static func getUserInfo() -> Observable<UserInfo?> {
        return UserServices.provider
            .rx.request(.getUserInfo)
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .asObservable()
            .map {
                let response = try JSONDecoder().decode(UserInfoResult.self, from: $0.data)
                Constants.loginUser = response.user
                return response.user
            }
            .catchAndReturn(nil)
    }
}

enum LoginResult: Int {
    case Success = 200
    case NotExist = 403
    case PasswordNotCorrect = 401
    case NoAuthorization = 400
}
