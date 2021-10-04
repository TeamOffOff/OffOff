//
//  CustomNavigationBar.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/15.
//

import UIKit

class CustomNavigationBar: UINavigationBar {
    var titleLabel = UILabel().then {
        $0.text = "Title"
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        $0.textColor = .white
        $0.textAlignment = .left
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .mainColor
        self.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(15)
            $0.centerY.equalToSuperview()
        }
        
//        let appearnce = UINavigationBarAppearance()
//        appearnce.backgroundColor = Constants.mainColor
//        self.standardAppearance = appearnce
//        self.scrollEdgeAppearance = appearnce
        self.shadowImage = UIImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
