//
//  ProfileMakeView.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/23.
//

import UIKit

class ProfileMakeView: UIView {
    
    var profileImageView = CircularImageView(image: UIImage.DEFAULT_PROFILE)
    
    var nickNameTextField = TextField().then {
        $0.placeholder = "닉네임 (2-10자, 한글, 영어, 숫자 사용 가능)"
        $0.font = UIFont.preferredFont(forTextStyle: .callout)
        $0.adjustsFontForContentSizeCategory = true
        $0.tintColor = .mainColor
        $0.backgroundColor = .white
        $0.autocapitalizationType = .none
        $0.clearButtonMode = .whileEditing
        $0.autocorrectionType = .no
        $0.titleFormatter = { $0 }
        $0.iconWidth = CGFloat(2.0)
        $0.tag = 0
    }
    
    var signUpButton = UIButton().then {
        $0.backgroundColor = .mainColor
        $0.setTitle("가입", for: .normal)
        $0.setTitleColor(.white, for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.addSubview(profileImageView)
        self.addSubview(nickNameTextField)
        self.addSubview(signUpButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func makeView() {
        profileImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(UIScreen.main.bounds.size.height / 10.0)
            $0.width.equalTo(UIScreen.main.bounds.size.width / 3.0)
            $0.height.equalTo(profileImageView.snp.width)
        }
        
        nickNameTextField.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(profileImageView.snp.bottom).offset(12)
            $0.width.equalToSuperview().dividedBy(1.25)
        }
        
        signUpButton.snp.makeConstraints {
            $0.top.equalTo(nickNameTextField.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().dividedBy(1.25)
            $0.height.equalTo(UIScreen.main.bounds.size.height / 10.0)
        }
    }
}
