//
//  ShiftColorSelectViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/09/09.
//

import UIKit
import RxSwift
import RxCocoa

class ShiftColorSelectViewController: UIViewController {

    let disposeBag = DisposeBag()
    let customView = ShiftColorSelectView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(customView)
        customView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.equalTo(self.view.snp.width).dividedBy(1.5)
        }
    }
}

class ShiftColorSelectView: UIView {
    
    var badge = UILabel().then {
        $0.text = "주"
        $0.backgroundColor = .green
    }
    var segment = UnderlineSegmentedControl(frame: .zero, buttonTitles: ["배경 색", "글자 색"]).then {
        $0.selectorTextColor = .black
        $0.textColor = .lightGray
        $0.indicatorColor = .black
    }
    var colorPickerContainer = UIView().then {
        $0.backgroundColor = .white
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        self.addSubview(badge)
        self.addSubview(segment)
        
        makeView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeView() {
        badge.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(20)
        }
        segment.snp.makeConstraints {
            $0.top.equalTo(badge.snp.bottom).offset(20)
            $0.left.right.equalToSuperview().inset(12)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().inset(50)
        }
    }
}
