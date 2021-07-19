//
//  IDPWView.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/18.
//

import UIKit

class IDPWView: UIView {
    var idTextField = TextField().then {
        $0.placeholder = "아이디"
        
        $0.tintColor = .mainColor
        $0.backgroundColor = .white
        $0.autocapitalizationType = .none
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
    
    var passwordVerifyingField = TextField().then {
        $0.placeholder = "비밀번호 확인"
        
        $0.tintColor = .mainColor
        $0.backgroundColor = .white
        $0.autocapitalizationType = .none
        $0.textContentType = .password
        $0.isSecureTextEntry = true
        $0.clearButtonMode = .whileEditing
        
        $0.setupTextField(selectedColor: .mainColor, normalColor: .gray, iconImage: .lockFill, errorColor: .red)
    }
    
    var textFieldStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 18
        $0.distribution = .fill
    }
    
    var nextButton = UIButton().then {
        $0.backgroundColor = .mainColor
        $0.setTitle("다음", for: .normal)
        $0.setTitleColor(.white, for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        textFieldStack.addArrangedSubview(idTextField)
        textFieldStack.addArrangedSubview(passwordTextField)
        textFieldStack.addArrangedSubview(passwordVerifyingField)
        self.addSubview(textFieldStack)
        self.addSubview(nextButton)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        textFieldStack.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().dividedBy(1.25)
        }
        nextButton.snp.makeConstraints {
            $0.top.equalTo(self.textFieldStack.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().dividedBy(1.25)
            $0.bottom.equalToSuperview().dividedBy(2.0)
            $0.height.equalTo(textFieldStack.snp.height).dividedBy(2.5)
        }
    }
}
