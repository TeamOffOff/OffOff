//
//  MyActivityView.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/11/23.
//

import UIKit

class MyActivityView: UIView {
    
    var greetingLabel = UILabel().then {
        $0.text = "안녕하세요!"
        $0.textColor = .white
        $0.font = .defaultFont(size: 22.0, bold: true)
    }
    
    lazy var upperView = UIView().then {
        $0.backgroundColor = .g4
        
        $0.bottomRoundCorner(radius: 30.adjustedHeight)
        $0.addSubview(greetingLabel)
    }
    
    var alertListButton = ActivityListButton(title: "알림 목록")
    var myPostListButton = ActivityListButton(title: "내가 쓴 글")
    var myReplyListButton = ActivityListButton(title: "댓글 단 글")
    var scrapListButton = ActivityListButton(title: "스크랩한 글")
    var messageListButton = ActivityListButton(title: "쪽지함")
    
    lazy var buttonStack = UIStackView(arrangedSubviews: [myPostListButton, myReplyListButton, scrapListButton]).then {
        $0.backgroundColor = .clear
        $0.axis = .vertical
        $0.spacing = 7.adjustedHeight
        $0.distribution = .fillEqually
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
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
            $0.height.equalTo((278 * 3 / 5).adjustedHeight)
        }
    }
}

class ActivityListButton: UIButton {
    convenience init(title: String) {
        self.init(frame: .zero)
        
        self.backgroundColor = .w2
        self.setTitle(title, for: .normal)
        self.setTitleColor(.black, for: .normal)
        self.titleLabel?.font = .defaultFont(size: 15)
        self.setCornerRadius(20.adjustedHeight)
        
        self.contentHorizontalAlignment = .left
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 22.adjustedWidth, bottom: 0, right: 0)
    }
}
