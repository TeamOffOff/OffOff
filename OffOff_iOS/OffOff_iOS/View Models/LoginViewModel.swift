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
    let isIdConfirmed: Driver<Bool>
    let isPasswordConfirmed: Driver<Bool>
    let isSignedIn: Driver<Bool>
    
    init(
        input: (
            idText: Driver<String>,
            passwordText: Driver<String>,
            loginButtonTap: Signal<()>
        )
    ) {
        isIdConfirmed = input.idText
            .map { $0 != "" }
            .asDriver(onErrorJustReturn: false)
        
        isPasswordConfirmed = input.idText
            .map { $0 != "" }
            .asDriver()
        
        let idAndPassword = Driver.combineLatest(isIdConfirmed, isPasswordConfirmed)
        isSignedIn = input.loginButtonTap.withLatestFrom(idAndPassword)
            .map { $0 && $1 }
            .asDriver(onErrorJustReturn: false)
    }
    
//    func login(loginStatus: Box<LoginStatus>) {
//        if let loginModel = loginModel.value {
//            print(#fileID, #function, #line, loginModel)
//            let encoder = JSONEncoder()
//            encoder.outputFormatting = .prettyPrinted
//
//            if let encodedData = try? encoder.encode(loginModel) {
//                // 서버로 아이디 / 비밀번호 보내기
//            }
//
//            // if loginSuccess
//            loginStatus.value = [LoginStatus.failed, LoginStatus.successed].randomElement()!
//        }
//    }
}
