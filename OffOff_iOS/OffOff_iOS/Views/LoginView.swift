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
        $0.image = UIImage(named: "IconImage")
        $0.contentMode = .scaleToFill
    }
    
    var idTextField = TextField().then {
        $0.placeholder = "아이디"
        
        $0.tintColor = .mainColor
        $0.backgroundColor = .white
        $0.autocapitalizationType = .none
        $0.autocorrectionType = .no
        $0.clearButtonMode = .whileEditing
        
        $0.setupTextField(selectedColor: .mainColor, normalColor: .gray, iconImage: .personFill, errorColor: .red)
    }

    var passwordTextField = TextField().then {
        $0.placeholder = "비밀번호"
        
        $0.tintColor = .mainColor
        $0.backgroundColor = .white
        $0.autocapitalizationType = .none
        $0.textContentType = .password
        $0.isSecureTextEntry = true
        $0.clearButtonMode = .whileEditing
        
        $0.setupTextField(selectedColor: .mainColor, normalColor: .gray, iconImage: .lockFill, errorColor: .red)
    }

    var loginButton = UIButton().then {
        $0.setTitle("로그인", for: .normal)
        $0.backgroundColor = .lightGray
        $0.setTitleColor(.white, for: .normal)
        $0.isUserInteractionEnabled = false
    }
    
    var signupButton = UIButton().then {
        $0.backgroundColor = .clear
        $0.setTitle("회원가입", for: .normal)
        $0.setTitleColor(.gray, for: .normal)
    }
    
    var searchButton = UIButton().then {
        $0.backgroundColor = .clear
        $0.setTitle("아이디 비밀번호 찾기", for: .normal)
        $0.setTitleColor(.gray, for: .normal)
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
            $0.width.equalTo(self.snp.width).dividedBy(1.25)
            $0.top.equalTo(self.passwordTextField.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
        }
        
        self.iconImageView.snp.makeConstraints {
            $0.width.equalTo(self.snp.width).dividedBy(3)
            $0.height.equalTo(self.iconImageView.snp.width)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(UIScreen.main.bounds.size.height / 10.0)
        }
        
        self.idTextField.snp.makeConstraints {
            $0.top.equalTo(self.iconImageView.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(self.snp.width).dividedBy(1.25)
        }
        
        self.passwordTextField.snp.makeConstraints {
            $0.top.equalTo(self.idTextField.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(self.snp.width).dividedBy(1.25)
        }
        
        self.signupButton.snp.makeConstraints {
            $0.top.equalTo(self.loginButton.snp.bottom).offset(12)
            $0.left.equalTo(self.loginButton.snp.left)
        }
        
        self.searchButton.snp.makeConstraints {
            $0.top.equalTo(self.loginButton.snp.bottom).offset(12)
            $0.right.equalTo(self.loginButton.snp.right)
        }
    }
}
