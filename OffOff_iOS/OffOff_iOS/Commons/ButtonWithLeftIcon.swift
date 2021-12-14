//
//  ButtonWithLeftIcon.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/12/07.
//

import Foundation
import UIKit

final class ButtonWithLeftIcon: UIButton {
    var textLabel = UILabel()
    var iconView = UIImageView()
    
    convenience init(frame: CGRect = .zero, image: UIImage, title: String, iconPadding: Double, textPadding: Double, iconSize: CGSize) {
        self.init(frame: frame)
    
        self.addSubview(iconView)
        iconView.image = image
        iconView.contentMode = .scaleAspectFit
        iconView.snp.makeConstraints {
            $0.left.equalToSuperview().inset(iconPadding)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(iconSize.width)
            $0.height.equalTo(iconSize.height)
        }
        
        self.addSubview(textLabel)
        textLabel.text = title
        
        textLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().inset(textPadding)
        }
    }
}

//var scrapButton = UIButton().then {
//    $0.setImage(.ScrapIconBold, for: .normal)
//    $0.setTitleColor(.g4, for: .normal)
//    $0.setTitle("스크랩", for: .normal)
//    $0.imageView?.contentMode = .scaleAspectFit
//    $0.titleLabel?.font = .defaultFont(size: 12, bold: true)
//    $0.backgroundColor = .g1
//    $0.tintColor = .g4
//    $0.setCornerRadius(8.adjustedHeight)
//    $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 7.3.adjustedHeight)
//    $0.imageView?.snp.remakeConstraints {
//        $0.left.equalToSuperview().inset(7.adjustedHeight)
//        $0.centerY.equalToSuperview()
//        $0.width.equalTo(11.adjustedHeight)
//        $0.height.equalTo(11.adjustedHeight)
//    }
//}
