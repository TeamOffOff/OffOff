//
//  NameEmailViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/20.
//

import UIKit

class PrivacyInfoViewController: UIViewController {

    lazy var privacyView = PrivacyInfoView()
    var birthdayPicker: UIDatePicker?
    
    
    // MARK: - TextField의 상태를 표시하기 위한 Property
    var isNameVerified: Bool = false {
        didSet {
            if isNameVerified {
                privacyView.nameTextField.setTextFieldVerified()
            } else {
                privacyView.nameTextField.setTextFieldFail(errorMessage: Constants.NAME_ERROR_MESSAGE)
                SignUpViewModel.shared.signUpModel.information?.name = nil
            }
        }
    }
    var isEmailVerified: Bool = false {
        didSet {
            if isEmailVerified {
                privacyView.emailTextField.setTextFieldVerified()
            } else {
                privacyView.emailTextField.setTextFieldFail(errorMessage: Constants.EMAIL_ERROR_MESSAGE)
                SignUpViewModel.shared.signUpModel.information?.email = nil
            }
        }
    }
    var isBirthVerified: Bool = false {
        didSet {
            if isBirthVerified {
                privacyView.birthdayTextField.setTextFieldVerified()
            } else {
                privacyView.birthdayTextField.setTextFieldFail(errorMessage: Constants.BIRTH_ERROR_MESSAGE)
                SignUpViewModel.shared.signUpModel.information?.birth = nil
            }
        }
    }
    
    override func loadView() {
        self.view = privacyView
        self.title = "개인정보"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDatePicker(textField: privacyView.birthdayTextField)
        privacyView.nameTextField.delegate = self
        privacyView.emailTextField.delegate = self
        privacyView.emailTextField.keyboardType = .emailAddress
        privacyView.nameTextField.addTarget(self, action: #selector(onNameTextFieldChanged), for: .editingChanged)
        privacyView.emailTextField.addTarget(self, action: #selector(onEmailTextFieldChanged), for: .editingChanged)
        privacyView.nextButton.addTarget(self, action: #selector(onNextButton), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let name = SignUpViewModel.shared.signUpModel.information?.name {
            privacyView.nameTextField.text = name
            isNameVerified = true
        }
         
        if let email = SignUpViewModel.shared.signUpModel.information?.email {
            privacyView.emailTextField.text = email
            isEmailVerified = true
        }
        
        if let birth = SignUpViewModel.shared.signUpModel.information?.birth {
            privacyView.birthdayTextField.text = birth
            isBirthVerified = true
        }
    }
    
    private func resetBoolProperties() {
        isNameVerified = Bool(isNameVerified)
        isEmailVerified = Bool(isEmailVerified)
        isBirthVerified = Bool(isBirthVerified)
    }
    
    // MARK: - TextField Value Changed Handlers
    @objc func onEmailTextFieldChanged(_ textField: TextField) {
        if !isEmailVerified {
            return
        }
        
        isEmailVerified = SignUpViewModel.shared.isValidEmail(email: textField.text ?? "")
    }
    
    @objc func onNameTextFieldChanged(_ textField: TextField) {
        if !isNameVerified {
            return
        }
        
        isNameVerified = SignUpViewModel.shared.isValidName(name: textField.text ?? "")
    }
    
    // MARK: - Next Button Handler
    @objc func onNextButton(sender: UIButton) {
        sender.showAnimation {
            if self.isNameVerified, self.isEmailVerified, self.isBirthVerified {
                SignUpViewModel.shared.setPrivacy(name: self.privacyView.nameTextField.text, email: self.privacyView.emailTextField.text, birthday: self.privacyView.birthdayTextField.text)
                self.navigationController?.pushViewController(ProfileMakeViewController(), animated: true)
            } else {
                self.resetBoolProperties()
            }
        }
    }
}

extension PrivacyInfoViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str = textField.text ?? ""
        
        var max = 0
        if textField == privacyView.nameTextField {
            max = Constants.USERID_MAXLENGTH
        } else {
            return true
        }
        
        guard let stringRange = Range(range, in: str) else { return false }
        let updatedText = str.replacingCharacters(in: stringRange, with: string)

        return updatedText.count <= max
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case privacyView.nameTextField:
            isNameVerified = SignUpViewModel.shared.isValidName(name: textField.text ?? "")
        case privacyView.emailTextField:
            isEmailVerified = SignUpViewModel.shared.isValidEmail(email: textField.text ?? "")
        default:
            return
        }
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

// MARK: - 생년월일 입력 DatePicker 설정
extension PrivacyInfoViewController {
    func setDatePicker(textField: UITextField) {
        let screenWidth = UIScreen.main.bounds.size.width
        birthdayPicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))
        birthdayPicker!.datePickerMode = .date
        birthdayPicker!.locale = Locale(identifier: "ko_kr")
        birthdayPicker!.maximumDate = Date()
        birthdayPicker!.minimumDate = "1940-01-01".toDate()
        birthdayPicker!.setDate("2002-01-01".toDate()!, animated: false)
        textField.inputView = birthdayPicker
        
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44.0))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: #selector(onCancelButton))
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(onDoneButton))
        toolBar.setItems([cancelButton, flexibleSpace, doneButton], animated: false)
        textField.inputAccessoryView = toolBar
    }
    
    @objc func onCancelButton() {
        privacyView.birthdayTextField.resignFirstResponder()
    }
    
    @objc func onDoneButton() {
        let birthdayString = birthdayPicker?.date.toString()
        privacyView.birthdayTextField.text = birthdayString
        SignUpViewModel.shared.signUpModel.information?.birth = birthdayString
        privacyView.birthdayTextField.resignFirstResponder()
        isBirthVerified = true
    }
}
