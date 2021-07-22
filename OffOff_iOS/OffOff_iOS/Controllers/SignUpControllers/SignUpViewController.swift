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
        idpwView.passwordVerifyingField.addTarget(self, action: #selector(onPWVerifyingTextFieldChange), for: .editingChanged)
        idpwView.passwordTextField.addTarget(self, action: #selector(onPWTextFieldChange), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
     
    // MARK: - objc methods
    @objc func onNextButton(sender: UIButton) {
        sender.showAnimation {
            if self.idpwView.idTextField.isVerified(), self.idpwView.passwordTextField.isVerified(), self.idpwView.passwordVerifyingField.isVerified() {
                SignUpViewModel.shared.setIDPW(id: self.idpwView.idTextField.text!, pw: self.idpwView.passwordTextField.text!)
                self.navController?.pushViewController(PrivacyInfoViewController(), animated: true)
            } else {
                
            }
        }
    }
    
    @objc func onBackButton() {
        self.dismiss(animated: true)
    }
    
    @objc func onPWVerifyingTextFieldChange(_ textfield: TextField) {
        if idpwView.passwordTextField.isVerified(){
            if SignUpViewModel.shared.isValidPWVerify(verifyingText: textfield.text!, text: idpwView.passwordTextField.text!) {
                textfield.setTextFieldVerified()
            } else {
                textfield.setTextFieldFail(errorMessage: Constants.PWVERIFY_ERROR_MESSAGE)
            }
        } else {
            return
        }
    }
 
    @objc func onPWTextFieldChange(_ textfield: TextField) {
        if textfield.isVerified() {
            idpwView.passwordVerifyingField.text = ""
            idpwView.passwordVerifyingField.setTextFieldNormal(iconImage: .ICON_LOCK_GRAY)
        }
    }
}

// MARK: - UITextFieldDelegate
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

        return updatedText.count <= max
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case idpwView.idTextField:
            if SignUpViewModel.shared.isValidID(text: textField.text ?? "") {
                // TODO: 중복검사
                idpwView.idTextField.setTextFieldVerified()
//                SignUpViewModel.shared.isIDDuplicate(id: textField.text!) {
//                    self.verifyTextField(textField: self.idpwView.idTextField, text: self.idpwView.idTextField.text!)
//                }
            } else {
                idpwView.idTextField.setTextFieldFail(errorMessage: IDErrorMessage.idNotFollowRule.rawValue)
            }
        case idpwView.passwordTextField:
            if SignUpViewModel.shared.isValidPW(text: textField.text ?? "") {
                idpwView.passwordTextField.setTextFieldVerified()
            } else {
                idpwView.passwordTextField.setTextFieldFail(errorMessage: Constants.PW_ERROR_MESSAGE)
            }
        default:
            return
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if let tf = textField as? TextField {
            var image: UIImage?
            switch tf {
            case idpwView.idTextField:
                image = .ICON_USER_GRAY
            case idpwView.passwordTextField, idpwView.passwordVerifyingField:
                image = .ICON_LOCK_GRAY
            default:
                return true
            }
            tf.setTextFieldNormal(iconImage: image!)
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
}
