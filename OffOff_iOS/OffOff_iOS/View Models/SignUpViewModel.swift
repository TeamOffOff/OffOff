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
    
    func setIDPW(id: String?, pw: String?) {
        SignUpViewModel.shared.signUpModel.information?.id = id
        SignUpViewModel.shared.signUpModel.information?.password = pw
    }
    
    func setPrivacy(name: String?, email: String?, birthday: String?) {
        SignUpViewModel.shared.signUpModel.information?.name = name
        SignUpViewModel.shared.signUpModel.information?.email = email
        SignUpViewModel.shared.signUpModel.information?.birth = birthday
    }
    
    func isValidID(text: String) -> Bool {
        // 중복검사 추가
        return Constants.isValidString(str: text, regEx: Constants.USERID_RULE)
    }
    
    func isIDDuplicate(id: String, completion: @escaping () -> Void) {
        AuthServices.idDuplicationCheck(id: id, completion: completion)
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
    
    func isValidName(name: String) -> Bool {
        return Constants.isValidString(str: name, regEx: Constants.USERNAME_RULE)
    }
    
    func isValidEmail(email: String) -> Bool {
        return Constants.isValidString(str: email, regEx: Constants.USEREMAIL_RULE)
    }
    
    func isValidNickname(nickname: String) -> Bool {
        return Constants.isValidString(str: nickname, regEx: Constants.USERNICKNAME_RULE)
    }
}
