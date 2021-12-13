//
//  PreparingViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/12/12.
//

import UIKit

class PreparingViewController: UIViewController {
    
    var logoImageView = UIImageView().then {
        $0.image = .MainLogoWithShadow
        $0.contentMode = .scaleAspectFit
    }
    
    var commentLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.text = "캘린더 기능을\n준비중입니다 :)"
        $0.font = .defaulFont(size: 15, weight: .black)
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .g4
        self.view.addSubview(logoImageView)
        self.view.addSubview(commentLabel)
        
        logoImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(217.adjustedHeight)
            $0.width.height.equalTo(150.adjustedHeight)
        }
        
        commentLabel.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(35.adjustedHeight)
            $0.centerX.equalToSuperview()
        }
    }
}
