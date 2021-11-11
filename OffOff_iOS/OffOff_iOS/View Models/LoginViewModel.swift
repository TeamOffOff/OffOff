//
//  LoginViewModel.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/17.
//

import Foundation
import RxSwift
import RxCocoa

class LoginViewModel {
    
    // outputs
    let loginButtonAvailable: Driver<Bool>
    let isSignedIn: Driver<LoginResult>
    
    init(
        input: (
            idText: Driver<String>,
            passwordText: Driver<String>,
            loginButtonTap: Signal<()>
        )
    ) {
        loginButtonAvailable = Driver.combineLatest(input.idText, input.passwordText)
            .map { $0 != "" && $1 != ""}
        
        let idAndPassword = Driver.combineLatest(input.idText, input.passwordText)
        
        isSignedIn = input.loginButtonTap.withLatestFrom(idAndPassword)
            .flatMapLatest {
                return UserServices.login(id: $0, password: $1).asDriver(onErrorJustReturn: .NotExist)
            }
    }
}
