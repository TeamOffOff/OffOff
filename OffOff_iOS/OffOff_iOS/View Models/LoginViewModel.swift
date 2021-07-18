//
//  LoginViewModel.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/17.
//

import Foundation

class LoginViewModel {
    let loginModel: Box<LoginModel?>
    
    init() {
        loginModel = Box(nil)
    }
    
    func login(loginStatus: Box<LoginStatus>) {
        if let loginModel = loginModel.value {
            print(#fileID, #function, #line, loginModel)
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            if let encodedData = try? encoder.encode(loginModel) {
                // 서버로 아이디 / 비밀번호 보내기
            }
            
            // if loginSuccess
            loginStatus.value = [LoginStatus.failed, LoginStatus.successed].randomElement()!
        }
    }
}
