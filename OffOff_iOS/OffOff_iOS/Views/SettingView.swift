//
//  SettingView.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/12/11.
//

import UIKit

final class SettingView: UIView {
    var greetingLabel = UILabel().then {
        $0.text = "환경설정"
        $0.textColor = .white
        $0.font = .defaultFont(size: 22.0, bold: true)
    }
    
    lazy var upperView = UIView().then {
        $0.backgroundColor = .g4
        
        $0.bottomRoundCorner(radius: 30.adjustedHeight)
        $0.addSubview(greetingLabel)
    }
    
    var profileSettingButton = ActivityListButton(title: "프로필 설정")
    var privacySettingButton = ActivityListButton(title: "개인정보 설정")
    var alertSettingButton = ActivityListButton(title: "알림 설정")
    var developerInfoButton = ActivityListButton(title: "개발자 정보")
    var appInfoButton = ActivityListButton(title: "앱 정보")
    var inquireButton = ActivityListButton(title: "문의하기")
    var signOutButton = ActivityListButton(title: "회원 탈퇴")
    var logOutButton = ActivityListButton(title: "로그아웃")
    
    lazy var buttonStack = UIStackView(arrangedSubviews: [
        profileSettingButton, privacySettingButton, alertSettingButton, developerInfoButton,
        appInfoButton, inquireButton, signOutButton, logOutButton
    ]).then {
        $0.backgroundColor = .clear
        $0.axis = .vertical
        $0.spacing = 7.adjustedHeight
        $0.distribution = .fillEqually
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(greetingLabel)
        self.addSubview(upperView)
        self.addSubview(buttonStack)
        
        makeView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeView() {
        upperView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(270.adjustedHeight)
        }
        greetingLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(106.adjustedHeight)
            $0.left.equalToSuperview().inset(54)
        }
        buttonStack.snp.makeConstraints {
            $0.top.equalTo(upperView.snp.bottom).inset(25.adjustedHeight)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(326.adjustedWidth)
            $0.height.equalTo((421).adjustedHeight)
        }
    }
}
