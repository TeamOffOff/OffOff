//
//  PrivacyInfoViewModel.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/08/07.
//

import Foundation
import RxSwift
import RxCocoa

class PrivacyInfoViewModel {
    // Outputs
    let isNameConfirmed: Driver<Bool>
    let isEmailConfirmed: Driver<Bool>
    let isBirthdayConfirmed: Driver<Bool>
    
    let isNextEnabled: Driver<Bool>
    let isValidatedToProgress: Driver<Bool>
    
    init(
        input: (
            nameText: Driver<String>,
            emailText: Driver<String>,
            birthdayText: Driver<String>,
            nextButtonTap: Signal<()>)
    ) {
        isNameConfirmed = input.nameText
            .map { name in
                return Constants.isValidString(str: name, regEx: Constants.USERNAME_RULE)
            }
        isEmailConfirmed = input.emailText
            .debounce(.milliseconds(5)) // 0.5초 딜레이 주기
            .flatMapLatest { email in
                return UserServices.emailDuplicationCheck(email: email).asDriver(onErrorJustReturn: false)
            }
        isBirthdayConfirmed = input.birthdayText
            .map { birthday in
                return Constants.isValidString(str: birthday, regEx: Constants.USERBIRTH_RULE)
            }
        
        isNextEnabled = Driver.combineLatest(isNameConfirmed, isEmailConfirmed, isBirthdayConfirmed)
            .map { name, email, birth in
                return name && email && birth
            }
        
        let enabledAndValues = Driver.combineLatest(isNextEnabled, input.nameText, input.emailText, input.birthdayText) { (
            enabled: $0,
            name: $1,
            email: $2,
            birthday: $3
        )}
        
        isValidatedToProgress = input.nextButtonTap.withLatestFrom(enabledAndValues)
            .flatMapLatest { pair in
                if pair.enabled {
                    SharedSignUpModel.model.information?.name = pair.name
                    SharedSignUpModel.model.information?.email = pair.email
                    SharedSignUpModel.model.information?.birth = pair.birthday
                }
                
                return Driver.just(pair.enabled)
            }
    }
}
