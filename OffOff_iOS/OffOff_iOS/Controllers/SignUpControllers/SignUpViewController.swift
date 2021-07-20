//
//  SignUpViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/18.
//

import UIKit

class SignUpViewController: UIViewController {
    
    lazy var idpwView = IDPWView(frame: .zero)
    var navController: UINavigationController?
    
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
        SignUpViewModel.shared = SignUpViewModel()
        idpwView.idTextField.delegate = self
        idpwView.passwordTextField.delegate = self
        idpwView.passwordVerifyingField.delegate = self
        idpwView.nextButton.addTarget(self, action: #selector(onNextButton), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(SignUpViewModel.shared.signUpModel.information)
        if let id = SignUpViewModel.shared.signUpModel.information?.id {
            idpwView.idTextField.text = id
        } else {
            idpwView.idTextField.setTextFieldNormal(iconImage: .ICON_USER_GRAY)
        }
        if let pw = SignUpViewModel.shared.signUpModel.information?.password {
            idpwView.passwordTextField.text = pw
        } else {
            idpwView.passwordTextField.setTextFieldNormal(iconImage: .ICON_LOCK_GRAY)
        }
    }
        
    private func verifyTextField(textField: TextField, text: String) {
        textField.errorMessage = nil
        textField.iconImage = .ICON_CHECKCIRCLE_MAINCOLOR
        
        switch textField {
        case idpwView.idTextField:
            SignUpViewModel.shared.signUpModel.information?.id = text
        case idpwView.passwordVerifyingField:
            SignUpViewModel.shared.signUpModel.information?.password = text
        default:
            return
        }
    }
    
    @objc func onNextButton(sender: UIButton) {
        sender.showAnimation {
            self.navController?.pushViewController(NameEmailViewController(), animated: true)
        }
    }
    
    @objc func onBackButton() {
        self.dismiss(animated: true)
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str = textField.text ?? ""
        
        var max = 0
        switch textField {
        case idpwView.idTextField:
            max = Constants.USERID_MAXLENGTH
        case idpwView.passwordTextField:
            max = Constants.USERPW_MAXLENGTH
        case idpwView.passwordVerifyingField:
            max = Constants.USERPW_MAXLENGTH
        default:
            max = -1
        }
        guard let stringRange = Range(range, in: str) else { return false }
        let updatedText = str.replacingCharacters(in: stringRange, with: string)
        
        if textField == idpwView.passwordVerifyingField {
            let tf = textField as? TextField
            if SignUpViewModel.shared.isValidPWVerify(verifyingText: updatedText, text: idpwView.passwordTextField.text ?? "") {
                verifyTextField(textField: tf!, text: updatedText)
            } else {
                tf!.setTextFieldFail(errorMessage: Constants.PWVERIFY_ERROR_MESSAGE)
                SignUpViewModel.shared.signUpModel.information?.password = nil
            }
        }
        
        return updatedText.count <= max
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case idpwView.idTextField:
            if SignUpViewModel.shared.isValidID(text: textField.text ?? "") {
                // TODO: 중복검사
                verifyTextField(textField: idpwView.idTextField, text: idpwView.idTextField.text!)
            } else {
                SignUpViewModel.shared.signUpModel.information?.id = nil
                idpwView.idTextField.setTextFieldFail(errorMessage: IDErrorMessage.idNotFollowRule.rawValue)
            }
        case idpwView.passwordTextField:
            if SignUpViewModel.shared.isValidPW(text: textField.text ?? "") {
                verifyTextField(textField: idpwView.passwordTextField, text: textField.text!)
            } else {
                SignUpViewModel.shared.signUpModel.information?.password = nil
                idpwView.passwordTextField.setTextFieldFail(errorMessage: Constants.PW_ERROR_MESSAGE)
            }
        default:
            return
        }
    }
}
