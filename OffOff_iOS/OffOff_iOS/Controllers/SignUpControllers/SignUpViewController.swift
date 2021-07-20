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
        SignUpViewModel.buttonHeight = idpwView.nextButton.snp.height
        print(SignUpViewModel.buttonHeight)
        idpwView.idTextField.delegate = self
        idpwView.passwordTextField.delegate = self
        idpwView.passwordVerifyingField.delegate = self
        idpwView.nextButton.addTarget(self, action: #selector(onNextButton), for: .touchUpInside)
    }
    
    private func verifyTextField(textField: TextField) {
        textField.errorMessage = nil
        textField.iconImage = .ICON_CHECKCIRCLE_MAINCOLOR
        
        switch textField {
        case idpwView.idTextField:
            SignUpViewModel.signUpModel.value.information?.id = textField.text
        case idpwView.passwordVerifyingField:
            SignUpViewModel.signUpModel.value.information?.password = textField.text
        default:
            return
        }
    }
    
    private func failTextField(textField: TextField, errorMessage: String) {
        textField.errorMessage = errorMessage
    }
    
    @objc func onNextButton(sender: UIButton) {
        sender.showAnimation {
            self.navController?.pushViewController(NameEmailViewController(), animated: true)
        }
    }
    
    @objc func onBackButton() {
        self.dismiss(animated: true) {
            SignUpViewModel.shared = SignUpViewModel()
            SignUpViewModel.signUpModel = Box(SignUpModel(information: SignUpModel.Information(), subinfo: SignUpModel.Subinfo(), activity: SignUpModel.Activity()))
        }
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
            if updatedText.count == idpwView.passwordTextField.text?.count {
                if SignUpViewModel.shared.isValidPWVerify(verifyingText: updatedText, text: idpwView.passwordTextField.text ?? "") {
                    verifyTextField(textField: tf!)
                }
            }
        }
        
        return updatedText.count <= max
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case idpwView.idTextField:
            if SignUpViewModel.shared.isValidID(text: textField.text ?? "") {
                // TODO: 중복검사
                verifyTextField(textField: idpwView.idTextField)
            } else {
                failTextField(textField: idpwView.idTextField, errorMessage: IDErrorMessage.idNotFollowRule.rawValue)
            }
        case idpwView.passwordTextField:
            if SignUpViewModel.shared.isValidPW(text: textField.text ?? "") {
                verifyTextField(textField: idpwView.passwordTextField)
            } else {
                failTextField(textField: idpwView.passwordTextField, errorMessage: Constants.PW_ERROR_MESSAGE)
            }
        default:
            return
        }
    }
}
