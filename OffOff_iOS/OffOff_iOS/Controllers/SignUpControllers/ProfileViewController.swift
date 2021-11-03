//
//  ProfileViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/23.
//

import UIKit
import RxSwift

class ProfileViewController: UIViewController {
    
    let profileView = ProfileMakeView()
    let disposeBag = DisposeBag()
    
    override func loadView() {
        self.view = profileView
        self.title = "프로필"
        profileView.makeView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileView.nickNameTextField.delegate = self
        
        // viewModel
        let viewModel = SignUpViewModel(
            input: (
                nicknameText: profileView.nickNameTextField
                    .rx.text
                    .orEmpty
                    .skip(1)
                    .distinctUntilChanged()
                    .debounce(.milliseconds(5), scheduler: ConcurrentMainScheduler.instance)
                    .asDriver(onErrorJustReturn: ""),
                signUpButtonTap: profileView.signUpButton.rx.tap.asSignal()
            )
        )
        
        // bind results
        viewModel.isNickNameConfirmed
            .drive(onNext: {
//                self.profileView.nickNameTextField.selectedLineColor
//                    = $0 ? .mainColor : .red
//                self.profileView.nickNameTextField.selectedTitleColor
//                    = $0 ? .mainColor : .red
//                self.profileView.nickNameTextField.title
//                    = $0 ?
//                    "\(self.profileView.nickNameTextField.text!)은(는) 사용가능한 닉네임입니다."
//                    : "\(self.profileView.nickNameTextField.text!)은(는) 사용할 수 없습니다."
                self.profileView.signUpButton.isUserInteractionEnabled = $0
                self.profileView.signUpButton.backgroundColor = $0 ? .g4 : .g1
            })
            .disposed(by: disposeBag)
        
        viewModel.signedUp
            .drive(onNext: { signedUp in
                print(signedUp)
                if signedUp {
                    let alert = UIAlertController(title: "회원가입 완료", message: nil, preferredStyle: .alert)
                    let action = UIAlertAction(title: "확인", style: .default) { action in
                        self.dismiss(animated: true, completion: nil)
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            })
            .disposed(by: disposeBag)
        
        self.profileView.backButton.rx.tap
            .bind {
                self.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
}

extension ProfileViewController: UITextFieldDelegate {
    // textField text 길이 제한
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str = textField.text ?? ""
        let max = Constants.USERNICKNAME_MAXLENGTH
        
        guard let stringRange = Range(range, in: str) else { return false }
        let updatedText = str.replacingCharacters(in: stringRange, with: string)
        
        return updatedText.count <= max
    }
}
