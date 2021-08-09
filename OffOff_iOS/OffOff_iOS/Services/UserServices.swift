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
        var message: String = "Impossible"
    }
    
    struct SignUpResult: Codable {
        var Authorization: String
        var message: String
    }
    
    static func idDuplicationCheck(id: String) -> Observable<Bool> {
        if Constants.isValidString(str: id, regEx: Constants.USERID_RULE) {
            return UserServices.provider
                .rx.request(.idChek(id))
                .asObservable()
                .map {
                    let result = try JSONDecoder().decode(Validation.self, from: $0.data)
                    return result.message == "Possible"
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
                .asObservable()
                .map {
                    print($0)
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
                .asObservable()
                .map {
                    let result = try JSONDecoder().decode(Validation.self, from: $0.data)
                    return result.message == "Possible"
                }
                .catchErrorJustReturn(false)
                
        } else {
            return Observable.just(false)
        }
    }
    
    static func signUp(with signUpModel: SignUpModel) -> Observable<Bool> {
        return UserServices.provider
            .rx.request(.signUp(signUpModel))
            .asObservable()
            .map {
                let result = try JSONDecoder().decode(SignUpResult.self, from: $0.data)
                print(result)
                return $0.statusCode == 200
            }
            .catchErrorJustReturn(false)
    }
}
