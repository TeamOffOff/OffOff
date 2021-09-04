//
//  AddShiftViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/09/04.
//

import UIKit

class AddShiftViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let testView = UIView().then { $0.backgroundColor = .white }
//        self.view.backgroundColor = .lightGray.withAlphaComponent(0.5)
        self.view.addSubview(testView)
        
        testView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.height.equalTo(self.view.snp.width).dividedBy(2.0)
        }
    }
    
}
