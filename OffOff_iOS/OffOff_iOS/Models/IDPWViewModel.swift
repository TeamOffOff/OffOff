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
    let isIdConfirmed: Driver<Bool>
    let isPasswordComfirmed: Driver<Bool>
    let isPasswordRepeatComfirmed: Driver<Bool>
    
    let isNextEnabled: Driver<Bool>
    let isValidatedToProgress: Driver<Bool>
    
    init(
        input: (
            idText: Driver<String>,
            passwordText: Driver<String>,
            passwordRepeatText: Driver<String>,
            nextButtonTap: Signal<()>
        )
    ) {
        
        // Subscription이 없기 때문에 dispose가 필요 없음
        isIdConfirmed = input.idText
            .debounce(.milliseconds(5)) // 0.5초 딜레이 주기
            .flatMapLatest { id in
                return AuthServices.idDuplicationCheck(id: id)
                    .asDriver(onErrorJustReturn: false)
            }
        
        isPasswordComfirmed = input.passwordText
            .map { password in
                return passwordValidation(password: password)
            }
        
        isPasswordRepeatComfirmed = Driver.combineLatest(input.passwordText, input.passwordRepeatText, resultSelector: passwordRepeatValidation)
        
        isNextEnabled = Driver.combineLatest(
            isIdConfirmed,
            isPasswordComfirmed,
            isPasswordRepeatComfirmed
        )   { username, password, repeatPassword in
            username && password && repeatPassword
        }
        .distinctUntilChanged()
        
        isValidatedToProgress = input.nextButtonTap.withLatestFrom(isNextEnabled)
            .flatMapLatest {
                Driver.just($0)
            }
            
    }
}

private func passwordValidation(password: String?) -> Bool {
    Constants.isValidString(str: password, regEx: Constants.USERPW_RULE)
}

private func passwordRepeatValidation(password: String?, passwordRepeat: String?) -> Bool {
    passwordValidation(password: password) && password == passwordRepeat
}
