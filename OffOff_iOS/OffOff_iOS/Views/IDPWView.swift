//
//  IDPWView.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/18.
//

import UIKit
import FontAwesome

class IDPWView: UIView {
    var idTextField = TextField().then {
        $0.placeholder = "아이디 (5-20자 이내, 영문, 숫자 사용가능)"
        $0.font = UIFont.preferredFont(forTextStyle: .callout)
        $0.adjustsFontForContentSizeCategory = true
        $0.tintColor = .mainColor
        $0.backgroundColor = .white
        $0.autocapitalizationType = .none
        $0.clearButtonMode = .whileEditing
        $0.autocorrectionType = .no
        $0.setupTextField(selectedColor: .mainColor, normalColor: .gray, iconImage: .ICON_USER_GRAY, errorColor: .red)
    }

    var passwordTextField = TextField().then {
        $0.placeholder = "비밀번호 (8-16자, 영문, 숫자, 기호 포함)"
        $0.font = UIFont.preferredFont(forTextStyle: .callout)
        $0.adjustsFontForContentSizeCategory = true
        $0.autocorrectionType = .no
        
        $0.tintColor = .mainColor
        $0.backgroundColor = .white
        $0.autocapitalizationType = .none
        $0.clearButtonMode = .whileEditing
        
        $0.textContentType = .oneTimeCode
//        $0.isSecureTextEntry = true   // Strong Password가 TextField를 가리는 문제
        
        $0.setupTextField(selectedColor: .mainColor, normalColor: .gray, iconImage: .ICON_LOCK_GRAY, errorColor: .red)
    }
    
    var passwordVerifyingField = TextField().then {
        $0.placeholder = "비밀번호 확인"
        $0.font = UIFont.preferredFont(forTextStyle: .callout)
        $0.adjustsFontForContentSizeCategory = true
        $0.autocorrectionType = .no
        
        $0.tintColor = .mainColor
        $0.backgroundColor = .white
        $0.autocapitalizationType = .none
        $0.clearButtonMode = .whileEditing
        
        $0.textContentType = .oneTimeCode
//        $0.isSecureTextEntry = true
        
        $0.setupTextField(selectedColor: .mainColor, normalColor: .gray, iconImage: .ICON_LOCK_GRAY, errorColor: .red)
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
        self.makeView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeView() {
        textFieldStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(UIScreen.main.bounds.size.height / 10.0)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().dividedBy(1.25)
        }
        nextButton.snp.makeConstraints {
            $0.top.equalTo(self.textFieldStack.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().dividedBy(1.25)
            $0.height.equalTo(UIScreen.main.bounds.size.height / 10.0)
        }
    }
}
