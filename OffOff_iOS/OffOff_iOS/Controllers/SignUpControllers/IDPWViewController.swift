//
//  SignUpViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/18.
//

import UIKit
import RxSwift
import RxCocoa

class IDPWViewController: UIViewController {
    let disposeBag = DisposeBag()
    lazy var idpwView = IDPWView(frame: .zero)
    
    // MARK: - Life Cycle
    override func loadView() {
        self.view = idpwView
        self.navigationController?.isNavigationBarHidden = true
        
        idpwView.makeView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        idpwView.idTextField.delegate = self
        idpwView.passwordTextField.delegate = self
        idpwView.passwordRepeatField.delegate = self
        
        // Shared Model 초기화
        SharedSignUpModel.model = UserModel(_id: "", activity: Activity(), information: Information(name: "", email: "", birth: "", type: "student"), password: "", subInformation: SubInformation(nickname: "", profileImage: nil))
        
        // input과 함께 viewModel 생성
        let viewModel = IDPWViewModel(
            input: (
                idText: idpwView.idTextField
                    .rx.text
                    .orEmpty // Optional 해제
                    .skip(1) // 초기 값 스킵
                    .distinctUntilChanged() // 이전 값과 같은지 테스트
                    .asDriver(onErrorJustReturn: ""),
                passwordText: idpwView.passwordTextField
                    .rx.text
                    .orEmpty
                    .skip(1)
                    .distinctUntilChanged()
                    .asDriver(onErrorJustReturn: ""),
                passwordRepeatText: idpwView.passwordRepeatField
                    .rx.text
                    .orEmpty
                    .skip(1)
                    .distinctUntilChanged()
                    .asDriver(onErrorJustReturn: ""),
                nextButtonTap: idpwView.nextButton
                    .rx.tap
                    .asSignal()
            ))
        
        // bind result {
        viewModel.isIdConfirmed
            .drive(onNext:  {
                if $0 {
                    self.idpwView.idConfirmLabel.text = "사용 가능한 아이디입니다."
                } else {
                    self.idpwView.idConfirmLabel.text = "이미 사용 중이거나 탈퇴한 아이디입니다."
                    SharedSignUpModel.model._id = ""
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.isPasswordComfirmed
            .drive(onNext: {
                if $0 {
                    self.idpwView.passwordConfirmLabel.text = "사용 가능한 비밀번호입니다."
                } else {
                    self.idpwView.passwordConfirmLabel.text = "8~16자 영문 대 소문자, 숫자, 특수문자를 사용하세요."
                    SharedSignUpModel.model.password = ""
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.isPasswordRepeatComfirmed
            .drive(onNext: {
                if $0 {
                    self.idpwView.passwordRepeatConfirmLabel.text = "비밀번호가 일치합니다."
                } else {
                    self.idpwView.passwordRepeatConfirmLabel.text = "비밀번호가 일치하지 않습니다."
                    SharedSignUpModel.model.password = ""
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.isNextEnabled
            .drive(onNext: {
                self.idpwView.nextButton.isUserInteractionEnabled = $0
                self.idpwView.nextButton.backgroundColor = $0 ? .g4 : .g1
            })
            .disposed(by: disposeBag)
        
        viewModel.isValidatedToProgress
            .debug()
            .drive(onNext: {
                if $0 {
                    self.navigationController?.pushViewController(PrivacyInfoViewController(), animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        self.idpwView.backButton.rx.tap
            .bind {
                self.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
        // }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if SharedSignUpModel.model._id != "" {
            idpwView.idTextField.text = SharedSignUpModel.model._id
        }
        if SharedSignUpModel.model.password != "" {
            idpwView.passwordTextField.text = SharedSignUpModel.model.password
        }
    }
    
    // MARK: - objc methods
    @objc func onBackButton() {
        self.dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension IDPWViewController: UITextFieldDelegate {
    // textField text 길이 제한
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str = textField.text ?? ""
        
        var max = 0
        switch textField {
        case idpwView.idTextField:
            max = Constants.USERID_MAXLENGTH
        case idpwView.passwordTextField:
            max = Constants.USERPW_MAXLENGTH
        case idpwView.passwordRepeatField:
            max = Constants.USERPW_MAXLENGTH
        default:
            max = -1
        }
        guard let stringRange = Range(range, in: str) else { return false }
        let updatedText = str.replacingCharacters(in: stringRange, with: string)
        
        return updatedText.count <= max
    }
    
    // return button 클릭 대응
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
}
