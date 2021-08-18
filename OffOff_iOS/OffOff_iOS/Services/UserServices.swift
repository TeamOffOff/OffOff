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
        var Authorization: String
        var queryStatus: String
    }
    
    static func idDuplicationCheck(id: String) -> Observable<Bool> {
        if Constants.isValidString(str: id, regEx: Constants.USERID_RULE) {
            return UserServices.provider
                .rx.request(.idChek(id))
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .asObservable()
                .map {
                    let result = try JSONDecoder().decode(Validation.self, from: $0.data)
                    return result.queryStatus == "possible"
                }
                .catchErrorJustReturn(false)
        } else {
            return Observable.just(false)
        }
    }
    
    static func emailDuplicationCheck(email: String) -> Observable<Bool> {
        if Constants.isValidString(str: email, regEx: Constants.USEREMAIL_RULE) {
            return UserServices.provider
                .rx.request(.emailCheck(email))
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .asObservable()
                .map {
                    return $0.statusCode == 200
//                    let result = try JSONDecoder().decode(Validation.self, from: $0.data)
//                    return result.message == "possible"
                }
                .catchErrorJustReturn(false)
        } else {
            return Observable.just(false)
        }
    }
    
    static func nicknameDuplicationCheck(nickname: String) -> Observable<Bool> {
        if Constants.isValidString(str: nickname, regEx: Constants.USERNICKNAME_RULE) {
            return UserServices.provider
                .rx.request(.nicknameCheck(nickname))
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .asObservable()
                .map {
                    let result = try JSONDecoder().decode(Validation.self, from: $0.data)
                    return result.queryStatus == "possible"
                }
                .catchErrorJustReturn(false)
                
        } else {
            return Observable.just(false)
        }
    }
    
    static func signUp(with signUpModel: UserModel) -> Observable<Bool> {
        return UserServices.provider
            .rx.request(.signUp(signUpModel))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .asObservable()
            .map {
                return $0.statusCode == 200
            }
            .catchErrorJustReturn(false)
    }
    
    static func login(id: String, password: String) -> Observable<LoginResult> {
        return UserServices.provider
            .rx.request(.login(id, password))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .asObservable()
            .map {
                let response = try JSONDecoder().decode(LoginResponse.self, from: $0.data)
                UserDefaults.standard.set(response.Authorization, forKey: "loginToken")
                return LoginResult(rawValue: $0.statusCode)!
            }
            .catchErrorJustReturn(.NotExist)
    }
    
    static func getUserInfo(token: String) -> Observable<UserModel?> {
        return UserServices.provider
            .rx.request(.getUserInfo(token))
            .observeOn(MainScheduler.instance)
            .asObservable()
            .map {
                let response = try JSONDecoder().decode(UserModel.self, from: $0.data)
                return response
            }
            .catchErrorJustReturn(nil)
    }
}

enum LoginResult: Int {
    case Success = 200
    case NotExist = 404
    case PasswordNotCorrect = 500
}