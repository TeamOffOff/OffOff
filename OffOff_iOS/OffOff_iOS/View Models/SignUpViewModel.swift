//
//  SignUpViewModel.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/20.
//

import Foundation
import SnapKit

class SignUpViewModel {
    static var shared = SignUpViewModel()
    var signUpModel = SignUpModel(information: SignUpModel.Information(), subinfo: SignUpModel.Subinfo(), activity: SignUpModel.Activity())
    
    init() {
        signUpModel = SignUpModel(information: SignUpModel.Information(), subinfo: SignUpModel.Subinfo(), activity: SignUpModel.Activity())
    }
    
    func isValidID(text: String) -> Bool {
        // 중복검사 포함시키기
        return Constants.isValidString(str: text, regEx: Constants.USERID_RULE)
    }
    
    func isValidPW(text: String) -> Bool {
        return Constants.isValidString(str: text, regEx: Constants.USERPW_RULE)
    }
    
    func isValidPWVerify(verifyingText: String, text: String) -> Bool {
        if isValidPW(text: text) {
            return verifyingText == text
        }
        return false
    }
}
