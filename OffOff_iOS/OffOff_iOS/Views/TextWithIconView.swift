//
//  TextWithIconView.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/27.
//

import UIKit

class TextWithIconView: UIView {
    var iconImageView = UIImageView().then {
        $0.image = .LIKEICON
        $0.contentMode = .scaleAspectFill
    }
    
    var label = UILabel().then {
        $0.text = "좋아요"
        $0.textColor = .darkGray
        $0.font = UIFont.systemFont(ofSize: 13)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(iconImageView)
        self.addSubview(label)
//        label.snp.makeConstraints {
//            $0.right.equalToSuperview()
//            $0.top.bottom.equalToSuperview()
//        }
//        iconImageView.snp.makeConstraints {
//            $0.right.equalTo(label.snp.left).inset(-2.5)
//            $0.centerY.equalTo(label)
//            $0.width.height.equalTo(10.0)
//        }
        iconImageView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.centerY.equalTo(label)
            $0.width.height.equalTo(10.0)
        }
        label.snp.makeConstraints {
            $0.left.equalTo(iconImageView.snp.right).offset(4.adjustedWidth)
            $0.right.equalToSuperview()
            $0.top.bottom.equalToSuperview()
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

