//
//  ProfileMakeView.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/23.
//

import UIKit

class ProfileMakeView: UIView {
    
    var profileImageLabel = UILabel().then {
        $0.text = "사진"
        $0.font = .defaulFont(size: 16, weight: .black)
        $0.textColor = .w4
    }
    
    lazy var profileImageView = UIImageView().then {
        $0.backgroundColor = UIColor(hex: "F1F3F4")
        $0.setCornerRadius(26.59)
        $0.contentMode = .scaleAspectFit
        $0.addSubview(profileImageLabel)
    }
    
    var imageUploadButton = UIButton().then {
        $0.backgroundColor = .w3
        $0.setCornerRadius(10.64)
        $0.tintColor = .w5
        $0.setImage(.CAMERA, for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
        $0.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    var nickNameTextField = UITextField().then {
        $0.placeholder = "닉네임 (2-10자, 한글, 영어, 숫자 사용 가능)"
        
        $0.font = .defaultFont(size: 14.0)
        $0.backgroundColor = .w2
        
        $0.textContentType = .username
        $0.autocapitalizationType = .none
        $0.autocorrectionType = .no
        
        $0.setCornerRadius(20.0)
        $0.addLeftPadding(value: 23.0)
        $0.tag = 0
    }
    
    var signUpButton = UIButton().then {
        $0.backgroundColor = .g1
        $0.isUserInteractionEnabled = false
        $0.setTitle("완료", for: .normal)
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
        self.addSubview(profileImageView)
        self.addSubview(imageUploadButton)
        self.addSubview(nickNameTextField)
        self.addSubview(signUpButton)
        self.addSubview(backButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func makeView() {
        profileImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(162.adjustedHeight)
            $0.width.height.equalTo(102)
        }
        
        imageUploadButton.snp.makeConstraints {
            $0.bottom.right.equalTo(profileImageView).offset(7.5)
            $0.width.height.equalTo(35.0)
        }
        
        nickNameTextField.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(profileImageView.snp.bottom).offset(54.adjustedHeight)
            $0.width.equalTo(270)
            $0.height.equalTo(40)
        }
        
        signUpButton.snp.makeConstraints {
            $0.width.equalTo(270.0)
            $0.height.equalTo(30.0)
            $0.top.equalTo(nickNameTextField.snp.bottom).offset(38.adjustedHeight)
            $0.centerX.equalToSuperview()
        }
        
        backButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(87.adjustedHeight)
            $0.left.equalToSuperview().inset(47.0)
            $0.width.equalTo(25.0)
            $0.height.equalTo(22.0)
        }
        profileImageLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
