//
//  NameEmailView.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/20.
//

import UIKit
import SnapKit

class PrivacyInfoView: UIView {
    var nameTextField = UITextField().then {
        $0.placeholder = "이름"
        $0.font = .defaultFont(size: 14.0)
        $0.backgroundColor = .w2
        
        $0.textContentType = .username
        $0.autocapitalizationType = .none
        $0.autocorrectionType = .no
        
        $0.setCornerRadius(20.0)
        $0.addLeftPadding(value: 23.0)
        $0.tag = 0
    }
    
    var emailTextField = UITextField().then {
        $0.placeholder = "이메일 (ex: abcd@abcd.com)"
        $0.font = .defaultFont(size: 14.0)
        $0.backgroundColor = .w2
        
        $0.textContentType = .emailAddress
        $0.autocapitalizationType = .none
        $0.autocorrectionType = .no
        
        $0.setCornerRadius(20.0)
        $0.addLeftPadding(value: 23.0)
        $0.tag = 1
    }
    var emailConfirmLabel = UILabel().then {
        $0.font = .defaultFont(size: 9.0)
        $0.textColor = .w5
        $0.text = ""
    }
    
    var birthdayTextField = UITextField().then {
        $0.placeholder = "생년월일을 입력하세요"
        $0.font = .defaultFont(size: 14.0)
        $0.backgroundColor = .w2
        
        $0.autocapitalizationType = .none
        $0.autocorrectionType = .no
        
        $0.setCornerRadius(20.0)
        $0.addLeftPadding(value: 23.0)
    }
    
    var nextButton = UIButton().then {
        $0.backgroundColor = .g1
        $0.isUserInteractionEnabled = false
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
        self.addSubview(nameTextField)
        self.addSubview(emailTextField)
        self.addSubview(emailConfirmLabel)
        self.addSubview(birthdayTextField)
        self.addSubview(nextButton)
        self.addSubview(backButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeView() {
        nameTextField.snp.makeConstraints {
            $0.width.equalTo(270.0)
            $0.height.equalTo(40.0)
            $0.top.equalToSuperview().inset(174.adjustedHeight)
            $0.centerX.equalToSuperview()
        }
        emailTextField.snp.makeConstraints {
            $0.width.equalTo(270.0)
            $0.height.equalTo(40.0)
            $0.top.equalTo(nameTextField.snp.bottom).offset(32.0)
            $0.centerX.equalToSuperview()
        }
        emailConfirmLabel.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom).offset(2.0)
            $0.left.equalTo(emailTextField).offset(12.0)
        }
        birthdayTextField.snp.makeConstraints {
            $0.width.equalTo(270.0)
            $0.height.equalTo(40.0)
            $0.top.equalTo(emailTextField.snp.bottom).offset(32.0)
            $0.centerX.equalToSuperview()
        }
        
        nextButton.snp.makeConstraints {
            $0.width.equalTo(270.0)
            $0.height.equalTo(30.0)
            $0.top.equalTo(self.birthdayTextField.snp.bottom).offset(38.adjustedHeight)
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
