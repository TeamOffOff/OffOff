//
//  SignUpViewModel.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/20.
//

import Foundation
import RxSwift
import RxCocoa

class SignUpViewModel {
    
    // Outputs
    let isNickNameConfirmed: Driver<Bool>
    let signedUp: Driver<Bool>
    let isUploadingImage: Observable<Bool>
    
    init(
        input: (
            nicknameText: Driver<String>,
            signUpButtonTap: Signal<()>,
            imageUploadButtonTap: Signal<()>
        )
    ) {
        isUploadingImage = input.imageUploadButtonTap.asObservable().map { true }
        
        isNickNameConfirmed = input.nicknameText
            .flatMapLatest { nickName in
                return UserServices.nicknameDuplicationCheck(nickname: nickName).asDriver(onErrorJustReturn: false) }
        
        let nickNameAndProfileImage = Driver.combineLatest(isNickNameConfirmed, input.nicknameText) { (confirmed: $0, nickname: $1) }
        
        signedUp = input.signUpButtonTap.withLatestFrom(nickNameAndProfileImage)
            .flatMapLatest { pair in
                if pair.confirmed {
                    SharedSignUpModel.model.subInformation.nickname = pair.nickname
                    return UserServices.signUp(with: SharedSignUpModel.model).asDriver(onErrorJustReturn: false)
                } else {
                    return Driver.just(false)
                }
            }
    }
}

private func isValidNickname(nickname: String) -> Bool {
    return Constants.isValidString(str: nickname, regEx: Constants.USERNICKNAME_RULE)
}
