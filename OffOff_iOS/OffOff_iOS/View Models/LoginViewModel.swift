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
