//
//  IDPWView.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/18.
//

import UIKit
import FontAwesome

class IDPWView: UIView {
    var idTextField = UITextField().then {
        $0.placeholder = "아이디 (5-20자 이내, 영문, 숫자 사용가능)"
        $0.font = .defaultFont(size: 14.0)
        $0.backgroundColor = .w2
        
        $0.textContentType = .username
        $0.autocapitalizationType = .none
        $0.autocorrectionType = .no
        
        $0.setCornerRadius(20.0)
        $0.addLeftPadding(value: 23.0)
        
        $0.tag = 0
    }
    var idConfirmLabel = UILabel().then {
        $0.font = .defaultFont(size: 9.0)
        $0.textColor = .w5
        $0.text = ""
    }

    var passwordTextField = UITextField().then {
        $0.placeholder = "비밀번호"
        $0.font = .defaultFont(size: 14.0)
        $0.backgroundColor = .w2
        
        $0.autocapitalizationType = .none
        $0.textContentType = .password
        $0.isSecureTextEntry = true
        $0.clearButtonMode = .whileEditing
        
        $0.setCornerRadius(20.0)
        $0.addLeftPadding(value: 23.0)
        $0.tag = 1
    }
    var passwordConfirmLabel = UILabel().then {
        $0.font = .defaultFont(size: 9.0)
        $0.textColor = .w5
        $0.text = "8~16자 영문 대 소문자, 숫자, 특수문자를 사용하세요."
    }
    
    var passwordRepeatField = UITextField().then {
        $0.placeholder = "비밀번호 확인"
        $0.font = .defaultFont(size: 14.0)
        $0.backgroundColor = .w2
        
        $0.autocapitalizationType = .none
        $0.textContentType = .password
        $0.isSecureTextEntry = true
        $0.clearButtonMode = .whileEditing
        
        $0.setCornerRadius(20.0)
        $0.addLeftPadding(value: 23.0)
        $0.tag = 2
    }
    var passwordRepeatConfirmLabel = UILabel().then {
        $0.font = .defaultFont(size: 9.0)
        $0.textColor = .w5
        $0.text = ""
    }
    
    var nextButton = UIButton().then {
        $0.backgroundColor = .g1
        $0.isUserInteractionEnabled = true
        $0.setTitle("다음", for: .normal)
        $0.setTitleColor(.w1, for: .normal)
        $0.titleLabel?.font = .defaultFont(size: 16.0)
        
        $0.setCornerRadius(15.0)
    }
    
    var backButton = UIButton().then {
        $0.setImage(.LEFTARROW, for: .normal)
        $0.setTitle(nil, for: .normal)
        $0.tintColor = .g4
        $0.imageView?.contentMode = .scaleAspectFit
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.addSubview(idTextField)
        self.addSubview(idConfirmLabel)
        
        self.addSubview(passwordTextField)
        self.addSubview(passwordConfirmLabel)
        
        self.addSubview(passwordRepeatField)
        self.addSubview(passwordRepeatConfirmLabel)
        
        self.addSubview(nextButton)
        self.addSubview(backButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func makeView() {
        idTextField.snp.makeConstraints {
            $0.width.equalTo(270.0)
            $0.height.equalTo(40.0)
            $0.top.equalToSuperview().inset(174.adjustedHeight)
            $0.centerX.equalToSuperview()
        }
        idConfirmLabel.snp.makeConstraints {
            $0.top.equalTo(idTextField.snp.bottom).offset(2.0)
            $0.left.equalTo(idTextField).offset(12.0)
        }
        
        passwordTextField.snp.makeConstraints {
            $0.width.equalTo(270.0)
            $0.height.equalTo(40.0)
            $0.top.equalTo(idConfirmLabel.snp.bottom).offset(19.0)
            $0.centerX.equalToSuperview()
        }
        passwordConfirmLabel.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(2.0)
            $0.left.equalTo(passwordTextField).offset(12.0)
        }
        
        passwordRepeatField.snp.makeConstraints {
            $0.width.equalTo(270.0)
            $0.height.equalTo(40.0)
            $0.top.equalTo(passwordConfirmLabel.snp.bottom).offset(19.0)
            $0.centerX.equalToSuperview()
        }
        passwordRepeatConfirmLabel.snp.makeConstraints {
            $0.top.equalTo(passwordRepeatField.snp.bottom).offset(2.0)
            $0.left.equalTo(passwordRepeatField).offset(12.0)
        }
        
        nextButton.snp.makeConstraints {
            $0.width.equalTo(270.0)
            $0.height.equalTo(30.0)
            $0.top.equalTo(self.passwordRepeatConfirmLabel.snp.bottom).offset(25.adjustedHeight)
            $0.centerX.equalToSuperview()
        }
        backButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(87.adjustedHeight)
            $0.left.equalToSuperview().inset(47.0)
            $0.width.equalTo(25.0)
            $0.height.equalTo(22.0)
        }
    }
}
