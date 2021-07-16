//
//  LoginView.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/06/29.
//

import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialTextControls_OutlinedTextAreas

class LoginView: UIView {
    
    var clearButton = UIImageView(image: .xmarkCircleFill)
    
    var iconImageView = UIImageView().then {
        $0.image = UIImage(named: "IconImage")
        $0.contentMode = .scaleToFill
    }
    
    var idTextField = MDCOutlinedTextField().then {
        $0.label.text = "아이디"
        $0.leftView = UIImageView(image: .personFill).then { $0.tintColor = .gray }
        $0.leftViewMode = .always
        $0.tintColor = .mainColor
        $0.backgroundColor = .white
        $0.autocapitalizationType = .none
        $0.setOutlineColor(.gray, for: .normal)
        $0.setOutlineColor(.mainColor, for: .editing)
        $0.trailingAssistiveLabel.text = "0/20"
        $0.clearButtonMode = .whileEditing
    }

    var passwordTextField = MDCOutlinedTextField().then {
        $0.label.text = "비밀번호"
        $0.leftView = UIImageView(image: .lockFill).then { $0.tintColor = .gray }
        $0.leftViewMode = .always
        $0.tintColor = .mainColor
        $0.backgroundColor = .white
        $0.autocapitalizationType = .none
        $0.textContentType = .password
        $0.isSecureTextEntry = true
        $0.setOutlineColor(.gray, for: .normal)
        $0.setOutlineColor(.mainColor, for: .editing)
        $0.clearButtonMode = .whileEditing
    }

    var loginButton = MDCButton().then {
        $0.setTitle("로그인", for: .normal)
        $0.backgroundColor = .mainColor
        $0.setTitleColor(.white, for: .normal)
        $0.accessibilityLabel = "로그인"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.addSubview(self.iconImageView)
        self.addSubview(self.idTextField)
        self.addSubview(self.passwordTextField)
        self.addSubview(self.loginButton)
        idTextField.delegate = self
        passwordTextField.delegate = self
        self.setUpView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        self.loginButton.snp.makeConstraints {
            $0.width.equalTo(self.snp.width).dividedBy(1.25)
            $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).inset(10)
            $0.centerX.equalToSuperview()
        }
        
        self.iconImageView.snp.makeConstraints {
            $0.width.equalTo(self.snp.width).dividedBy(3)
            $0.height.equalTo(self.iconImageView.snp.width)
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().dividedBy(2.0)
        }
        
        self.idTextField.snp.makeConstraints {
            $0.top.equalTo(self.iconImageView.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(self.snp.width).dividedBy(1.25)
        }
        
        self.passwordTextField.snp.makeConstraints {
            $0.top.equalTo(self.idTextField.snp.bottom)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(self.snp.width).dividedBy(1.25)
        }
    }
}

extension LoginView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str = textField.text ?? ""
        
        var max = 0
        switch textField {
        case self.idTextField:
            max = Constants.USERID_MAXLENGTH
        case self.passwordTextField:
            max = Constants.USERPW_MAXLENGTH
        default:
            max = -1
        }
        guard let stringRange = Range(range, in: str) else { return false }
        let updatedText = str.replacingCharacters(in: stringRange, with: string)

        
        guard let tf = textField as? MDCOutlinedTextField else { return false }
        
        if updatedText.count <= max {
            tf.trailingAssistiveLabel.text = "\(updatedText.count)/\(max)"
            tf.trailingAssistiveLabel.tintColor = .gray
            tf.setOutlineColor(.mainColor, for: .editing)
            return true
        } else {
            tf.trailingAssistiveLabel.text = "\(20)/\(max)"
            tf.trailingAssistiveLabel.shadowColor = nil
            tf.setTrailingAssistiveLabelColor(.red, for: .editing)
            tf.trailingAssistiveLabel.tintColor = nil
            tf.setOutlineColor(.red, for: .editing)

            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textField == idTextField {
            
        }
    }
}
