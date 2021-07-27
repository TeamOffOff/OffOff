//
//  CircularImageView.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/27.
//

import UIKit

class CircularImageView: UIImageView {
    override init(image: UIImage?) {
        super.init(image: image)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = UIScreen.main.bounds.size.width / 6.0
        self.layer.borderWidth = 1.5
        self.layer.borderColor = UIColor.mainColor.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
