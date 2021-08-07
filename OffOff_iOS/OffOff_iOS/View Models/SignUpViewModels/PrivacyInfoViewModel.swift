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
            .map { email in
                return Constants.isValidString(str: email, regEx: Constants.USEREMAIL_RULE)
            }
        isBirthdayConfirmed = input.birthdayText
            .map { birthday in
                return Constants.isValidString(str: birthday, regEx: Constants.USERBIRTH_RULE)
            }
        
        isNextEnabled = Driver.combineLatest(isNameConfirmed, isEmailConfirmed, isBirthdayConfirmed)
            .map { name, email, birth in
                return name && email && birth
            }
        
        isValidatedToProgress = input.nextButtonTap.withLatestFrom(isNextEnabled)
            .flatMapLatest { Driver.just($0) }
    }
}
