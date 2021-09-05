//
//  AddShiftViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/09/04.
//

import UIKit

class AddShiftViewController: UIViewController {

    let customView = AddShiftView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(customView)
        
        customView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.equalTo(self.view.snp.width).dividedBy(1.5)
            $0.height.equalTo(self.view.snp.width)
        }
    }
}

class AddShiftView: UIView {
    var badgeButton = UIButton().then {
        $0.backgroundColor = .blue
        $0.setTitle("주", for: .normal)
        $0.setTitleColor(.white, for: .normal)
    }
    
    var titleTextField = UITextField().then {
        $0.text = "타이틀"
        $0.textColor = .black
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.addSubview(badgeButton)
        self.addSubview(titleTextField)
        makeView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeView() {
        badgeButton.snp.makeConstraints {
            $0.left.top.equalToSuperview().inset(20)
            $0.width.height.equalTo(40)
        }
        titleTextField.snp.makeConstraints {
            $0.centerY.equalTo(badgeButton)
            $0.right.equalToSuperview().inset(20)
        }
    }
}
