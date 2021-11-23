//
//  PostListNavigationBar.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/11/09.
//

import UIKit

class PostListNavigationBar: UIView {

    var titleLabel = UILabel().then {
        $0.backgroundColor = .g4
        $0.font = .defaultFont(size: 22)
        $0.textColor = .white
        $0.text = "무슨게시판"
    }

    var searchButton = UIButton().then {
        $0.setImage(.SEARCHIMAGE.resize(to: CGSize(width: 20.adjustedWidth, height: 20.adjustedWidth)), for: .normal)
        $0.tintColor = .white
    }
    
    var menuButton = UIButton().then {
        $0.setImage(.MOREICON.resize(to: CGSize(width: 4.adjustedWidth, height: 20.adjustedWidth)), for: .normal)
        $0.tintColor = .white
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .g4
        
        self.addSubview(titleLabel)
        self.addSubview(searchButton)
        self.addSubview(menuButton)
        
        makeView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeView() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().inset(46.adjustedWidth)
        }
        menuButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().inset(32.adjustedWidth)
        }
        searchButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalTo(menuButton.snp.left).offset(-18.adjustedWidth)

        }
    }
}
