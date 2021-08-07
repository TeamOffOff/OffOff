//
//  AuthServices.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/21.
//

import Foundation
import Moya
import RxMoya
import RxSwift

public class AuthServices {
    static let provider = MoyaProvider<AuthAPI>()
    
    struct IDValidation: Codable {
        var message: String = "Impossible"
    }
    
    static func idDuplicationCheck(id: String) -> Observable<Bool> {
        if Constants.isValidString(str: id, regEx: Constants.USERID_RULE) {
            return AuthServices.provider
                .rx.request(.idChek(id))
                .asObservable()
                .map {
                    let result = try JSONDecoder().decode(IDValidation.self, from: $0.data)
                    return result.message == "Possible"
                }
                .catchErrorJustReturn(false)
        } else {
            return Observable.just(false)
        }
    }
}
