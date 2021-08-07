//
//  SignUpViewModel.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/20.
//

import Foundation
import RxSwift
import RxRelay

class SignUpViewModel {
    let disposeBag = DisposeBag()
    static var sharedViewModel = SignUpViewModel()
    
    var IDPWObservable = BehaviorSubject<IDPWModel>(value: IDPWModel())
    
    static var sharedModel = SignUpModel()
    var signUpModel = SignUpModel(information: Information(), subinfo: Subinfo(), activity: Activity())
    
    let checkingID = PublishSubject<String?>()
    var isIDVerified = PublishSubject<Bool>()
    var isPWVerified = PublishSubject<Bool>()
    var isPWRepeatVerified = PublishSubject<Bool>()
    
    var idTextRelay = PublishRelay<String>()
    var isIdOverlapped = PublishSubject<String?>()
    
    init() {
        signUpModel = SignUpModel(information: Information(), subinfo: Subinfo(), activity: Activity())
        
            
    }
    
    func isValidID() -> Observable<Bool> {
        
        return isIdOverlapped.map {
            $0 != nil
        }
    }
    
//    func isChangedIDValid(text: String) {
//        _ = isIDVerified
//            .filter{ $0 }
//            .onNext(Constants.isValidString(str: text, regEx: Constants.USERID_RULE))
//    }
    
    
    
    
    // MARK: -
    
    
    func setIDPW(id: String?, pw: String?) {
        SignUpViewModel.sharedViewModel.signUpModel.id = id
        SignUpViewModel.sharedViewModel.signUpModel.password = pw
    }
    
    func setPrivacy(name: String?, email: String?, birthday: String?) {
        SignUpViewModel.sharedViewModel.signUpModel.information?.name = name
        SignUpViewModel.sharedViewModel.signUpModel.information?.email = email
        SignUpViewModel.sharedViewModel.signUpModel.information?.birth = birthday
    }
    
    
    
    func isIDDuplicate(id: String, completion: @escaping () -> Void) {
//        AuthServices.idDuplicationCheck(id: id, completion: completion)
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
