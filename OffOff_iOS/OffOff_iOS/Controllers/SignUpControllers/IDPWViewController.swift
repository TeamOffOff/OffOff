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
    var navController: UINavigationController?
    
    // MARK: - TextField의 상태를 표시하기 위한 Property
    var isIDVerified: Bool = false {
        didSet {
            if isIDVerified {
                idpwView.idTextField.setTextFieldVerified()
            } else {
                idpwView.idTextField.setTextFieldFail(errorMessage: IDErrorMessage.idNotFollowRule.rawValue)
                SignUpViewModel.sharedViewModel.signUpModel.id = nil
            }
        }
    }
    var isPWVerified: Bool = false {
        didSet {
            if isPWVerified {
                idpwView.passwordTextField.setTextFieldVerified()
            } else {
                isPWRepeatVerified = false
                idpwView.passwordTextField.setTextFieldFail(errorMessage: Constants.PW_ERROR_MESSAGE)
                SignUpViewModel.sharedViewModel.signUpModel.password = nil
            }
        }
    }
    var isPWRepeatVerified: Bool = false {
        didSet {
            if isPWRepeatVerified {
                idpwView.passwordRepeatField.setTextFieldVerified()
            } else {
                idpwView.passwordRepeatField.setTextFieldFail(errorMessage: Constants.PWVERIFY_ERROR_MESSAGE)
            }
        }
    }
    
    // MARK: -
    override func loadView() {
        self.view = idpwView
        self.title = "아이디 및 비밀번호"
        navController = self.navigationController
        navController?.navigationBar.barTintColor = .mainColor
        navController?.navigationBar.tintColor = .white
        navController?.navigationBar.prefersLargeTitles = false
        navController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navController?.navigationBar.isTranslucent = false
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(onBackButton))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        idpwView.idTextField.delegate = self
        idpwView.passwordTextField.delegate = self
        idpwView.passwordRepeatField.delegate = self
        
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
                    self.idpwView.idTextField.setTextFieldVerified()
                } else {
                    self.idpwView.idTextField.setTextFieldFail(errorMessage: IDErrorMessage.idNotFollowRule.rawValue)
                    SignUpViewModel.sharedViewModel.signUpModel.id = nil
                }
            })
            .disposed(by: disposeBag)
        
        
        viewModel.isIdConfirmed
            .drive(onNext:  {
                if $0 {
                    self.idpwView.idTextField.setTextFieldVerified()
                } else {
                    self.idpwView.idTextField.setTextFieldFail(errorMessage: IDErrorMessage.idNotFollowRule.rawValue)
                    SignUpViewModel.sharedViewModel.signUpModel.id = nil
                }
            })
            .disposed(by: disposeBag)
    
        viewModel.isPasswordComfirmed
            .drive(onNext: {
                if $0 {
                    self.idpwView.passwordTextField.setTextFieldVerified()
                } else {
                    self.idpwView.passwordTextField.setTextFieldFail(errorMessage: Constants.PW_ERROR_MESSAGE)
                    SignUpViewModel.sharedViewModel.signUpModel.password = nil
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.isPasswordRepeatComfirmed
            .drive(onNext: {
                if $0 {
                    self.idpwView.passwordRepeatField.setTextFieldVerified()
                } else {
                    self.idpwView.passwordRepeatField.setTextFieldFail(errorMessage: Constants.PWVERIFY_ERROR_MESSAGE)
                    SignUpViewModel.sharedViewModel.signUpModel.password = nil
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.isValidatedToProgress
            .drive(onNext: {
                if $0 {
                    SignUpViewModel.sharedViewModel.setIDPW(id: self.idpwView.idTextField.text!, pw: self.idpwView.passwordTextField.text!)
                    self.navController?.pushViewController(PrivacyInfoViewController(), animated: true)
                }
            })
            .disposed(by: disposeBag)
        // }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let id = SignUpViewModel.sharedViewModel.signUpModel.id {
            idpwView.idTextField.text = id
        } else {
            idpwView.idTextField.setTextFieldNormal(iconImage: .ICON_USER_GRAY)
        }
        if let pw = SignUpViewModel.sharedViewModel.signUpModel.password {
            idpwView.passwordTextField.text = pw
        } else {
            idpwView.passwordTextField.setTextFieldNormal(iconImage: .ICON_LOCK_GRAY)
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
