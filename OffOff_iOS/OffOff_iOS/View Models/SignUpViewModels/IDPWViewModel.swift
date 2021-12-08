//
//  IDPWViewModel.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/08/05.
//

import RxSwift
import RxCocoa

final class IDPWViewModel {
    
    // Outputs
    let isIdConfirmed: Observable<IDConfirmType>
    let isPasswordComfirmed: Observable<Bool>
    let isPasswordRepeatComfirmed: Observable<Bool>
    
    let isNextEnabled: Observable<Bool>
    let isValidatedToProgress: Observable<Bool>
    
    init(
        input: (
            idText: Observable<String>,
            passwordText: Observable<String>,
            passwordRepeatText: Observable<String>,
            nextButtonTap: ControlEvent<()>
        )
    ) {
        
        // Subscription이 없기 때문에 dispose가 필요 없음
        isIdConfirmed = input.idText
            .debounce(.milliseconds(500), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMapLatest { id -> Observable<IDConfirmType> in
                if idValidation(id) {
                    return UserServices.idDuplicationCheck(id: id)
                        .map {
                            if $0 {
                                return IDConfirmType.okay
                            } else {
                                return IDConfirmType.duplicated
                            }
                        }
                } else {
                    return Observable.just(IDConfirmType.ruleNotSatisfied)
                }
                
            }
        
        isPasswordComfirmed = input.passwordText
            .map { password in
                return passwordValidation(password: password)
            }
        
        isPasswordRepeatComfirmed = Observable.combineLatest(input.passwordText, input.passwordRepeatText, resultSelector: passwordRepeatValidation)
        
        isNextEnabled = Observable.combineLatest(
            isIdConfirmed,
            isPasswordComfirmed,
            isPasswordRepeatComfirmed
        )   { username, password, repeatPassword in
            if username == .okay {
                return password && repeatPassword
            } else {
                return false
            }
        }
        .distinctUntilChanged()
        
        let enabledAndValues = Observable.combineLatest(isNextEnabled, input.idText, input.passwordRepeatText) { (enabled: $0, id: $1, password: $2) }
        
        isValidatedToProgress = input.nextButtonTap.withLatestFrom(enabledAndValues)
            .map { pair in
                if pair.enabled {
                    SharedSignUpModel.model._id = pair.id
                    SharedSignUpModel.model.password = pair.password
                }
                return pair.enabled
            }
            
    }
}

private func idValidation(_ id: String?) -> Bool {
    Constants.isValidString(str: id, regEx: Constants.USERID_RULE)
}

private func passwordValidation(password: String?) -> Bool {
    Constants.isValidString(str: password, regEx: Constants.USERPW_RULE)
}

private func passwordRepeatValidation(password: String?, passwordRepeat: String?) -> Bool {
    passwordValidation(password: password) && password == passwordRepeat
}

enum IDConfirmType {
    case duplicated
    case okay
    case ruleNotSatisfied
}
