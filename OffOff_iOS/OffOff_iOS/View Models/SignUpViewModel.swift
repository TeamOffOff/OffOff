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
        // 중복검사 추가
        if Constants.isValidString(str: text, regEx: Constants.USERID_RULE) {
            SignUpViewModel.shared.signUpModel.information?.id = text
            return true
        } else {
            SignUpViewModel.shared.signUpModel.information?.id = nil
            return false
        }
    }
    
    func isIDDuplicate(id: String, completion: @escaping () -> Void) {
        AuthServices.idDuplicationCheck(id: id, completion: completion)
    }
    
    func isValidPW(text: String) -> Bool {
        if Constants.isValidString(str: text, regEx: Constants.USERPW_RULE) {
            return true
        } else {
            SignUpViewModel.shared.signUpModel.information?.password = nil
            return false
        }
    }
    
    func isValidPWVerify(verifyingText: String, text: String) -> Bool {
        if isValidPW(text: text) {
            if verifyingText == text {
                SignUpViewModel.shared.signUpModel.information?.password = text
                return true
            }
        }
        SignUpViewModel.shared.signUpModel.information?.password = nil
        return false
    }
}
