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
import CloudKit

public class UserServices: Networkable {
    typealias Target = UserAPI
    
    static let provider = makeProvider()
    
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
                print(#fileID, #function, #line, $0)
                if $0.statusCode == 200 {
                    let response = try JSONDecoder().decode(LoginResponse.self, from: $0.data)
                    KeyChainController.shared.create(Constants.ServiceString, account: "AccessToken", value: response.accessToken)
                    KeyChainController.shared.create(Constants.ServiceString, account: "RefreshToken", value: response.refreshToken)
                    //                    UserDefaults.standard.set(response.refreshToken, forKey: "refreshToken")
                    //                    UserDefaults.standard.set(response.accessToken, forKey: "accessToken")
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
    
    static func getMyActivies(type: ActivityTypes) -> Observable<MyPostList?> {
        return UserServices.provider
            .rx.request(.getMyActivities(type: type))
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .asObservable()
            .map {
                if $0.statusCode == 200 {
                    do {
                        let postList = try JSONDecoder().decode(MyPostList.self, from: $0.data)
                        return postList
                    } catch {
                        print(error)
                    }
                }
                return nil
            }
    }
}

enum LoginResult: Int {
    case Success = 200
    case NotExist = 403
    case PasswordNotCorrect = 401
    case NoAuthorization = 400
}
