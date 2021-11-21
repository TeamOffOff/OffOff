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
    let isEntering: Observable<Bool>
    let isLoading: Observable<Bool>
    
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
        
        isLoading = input.loginButtonTap.map { true }.asObservable()
        
        isSignedIn = input.loginButtonTap.withLatestFrom(idAndPassword)
            .flatMapLatest {
                return UserServices.login(id: $0, password: $1).asDriver(onErrorJustReturn: .NotExist)
            }
        
        isEntering = isSignedIn
            .asObservable()
            .filter { $0 == .Success }
            .flatMapLatest { _ in
                return UserServices.getUserInfo()
            }
            .map {
                return $0 != nil ? true : false
            }
    }
}
