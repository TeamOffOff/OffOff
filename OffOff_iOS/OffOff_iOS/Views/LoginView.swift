//
//  LoginView.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/06/29.
//

import UIKit
import SkyFloatingLabelTextField

class LoginView: UIView {
    var iconImageView = UIImageView().then {
        $0.image = UIImage(named: "IconImageCircle")
        $0.contentMode = .scaleAspectFit
    }
    
    var idTextField = UITextField().then {
        $0.placeholder = "아이디"
        $0.font = .defaultFont(size: 14.0)
        $0.backgroundColor = .w2
        
        $0.textContentType = .username
        $0.autocapitalizationType = .none
        $0.autocorrectionType = .no
        
        $0.setCornerRadius(20.0)
        $0.addLeftPadding(value: 23.0)
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
    }

    var loginButton = UIButton().then {
        $0.setTitle("로그인", for: .normal)
        $0.backgroundColor = .g4
        
        $0.titleLabel?.font = .defaultFont(size: 16.0)
        $0.setTitleColor(.w1, for: .normal)
        
        $0.isUserInteractionEnabled = false
        $0.backgroundColor = .g1
        
        $0.setCornerRadius(15.0)
    }
    
    var signupButton = UIButton().then {
        $0.backgroundColor = .white
        $0.setTitle("회원가입", for: .normal)
        $0.setTitleColor(.w5, for: .normal)
        
        $0.titleLabel?.font = .defaultFont(size: 12.0)
    }
    
    var searchButton = UIButton().then {
        $0.backgroundColor = .white
        $0.setTitle("아이디 / 비밀번호 찾기", for: .normal)
        $0.setTitleColor(.w5, for: .normal)
        
        $0.titleLabel?.font = .defaultFont(size: 12.0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.addSubview(self.iconImageView)
        self.addSubview(self.idTextField)
        self.addSubview(self.passwordTextField)
        self.addSubview(self.loginButton)
        self.addSubview(self.signupButton)
        self.addSubview(self.searchButton)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func makeView() {
        self.loginButton.snp.makeConstraints {
            $0.top.equalTo(self.passwordTextField.snp.bottom).offset(38.adjustedHeight)
            $0.centerX.equalToSuperview()
            
            $0.width.equalTo(270.0)
            $0.height.equalTo(30.0)
        }
        
        self.iconImageView.snp.makeConstraints {
            $0.width.height.equalTo(100)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(112.0.adjustedHeight)
        }
        
        self.idTextField.snp.makeConstraints {
            $0.top.equalTo(self.iconImageView.snp.bottom).offset(34.0)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(270.0)
            $0.height.equalTo(40.0)
        }
        
        self.passwordTextField.snp.makeConstraints {
            $0.top.equalTo(self.idTextField.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(270.0)
            $0.height.equalTo(40.0)
        }
        
        self.searchButton.snp.makeConstraints {
            $0.top.equalTo(self.loginButton.snp.bottom).offset(16)
            $0.left.equalTo(self.loginButton.snp.left)
        }
        
        self.signupButton.snp.makeConstraints {
            $0.top.equalTo(self.loginButton.snp.bottom).offset(16)
            $0.right.equalTo(self.loginButton.snp.right)
        }
    }
}
