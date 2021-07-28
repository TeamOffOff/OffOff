//
//  AuthServices.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/21.
//

import Foundation
import Moya

public class AuthServices {
    static let provider = MoyaProvider<AuthAPI>()
    
    static func idDuplicationCheck(id: String, completion: @escaping () -> Void) {
        AuthServices.provider.request(.idChek(id)) { (result) in
            switch result {
            case let .success(response):
                print(try? response.mapJSON())
                completion()
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
}
