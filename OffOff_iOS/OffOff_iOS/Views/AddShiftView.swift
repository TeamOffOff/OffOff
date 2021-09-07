//
//  AddShiftView.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/09/07.
//

import UIKit

class AddShiftView: UIView {
    var badgeButton = UIButton().then {
        $0.backgroundColor = .blue
        $0.setTitle("주", for: .normal)
        $0.setTitleColor(.white, for: .normal)
    }
    
    var titleTextField = UITextField().then {
        $0.placeholder = "타이틀"
        $0.textColor = .black
    }
    
    var saveButton = UIButton().then {
        $0.setTitle("저장", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = .white
    }
    
    var cancelButton = UIButton().then {
        $0.setTitle("취소", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = .white
    }
    
    var startTimeLabel = UILabel().then {
        $0.text = "시작시간"
        $0.backgroundColor = .white
        $0.textAlignment = .left
    }
    
    var startTimeButton = UIButton().then {
        $0.setTitle("설정", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = .white
        $0.titleLabel?.textAlignment = .right
    }
    
    lazy var startTimeStack = UIStackView(arrangedSubviews: [startTimeLabel, startTimeButton]).then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.backgroundColor = .white
    }
    
    var startTimePicker = UIDatePicker().then {
        $0.datePickerMode = .time
        if #available(iOS 13.4, *) { $0.preferredDatePickerStyle = .wheels }
        $0.locale = Locale(identifier: "Ko_kr")
        $0.timeZone = .current
        $0.isHidden = true
        $0.snp.makeConstraints { $0.height.equalTo(150) }
    }
    
    var endTimeLabel = UILabel().then {
        $0.text = "종료시간"
        $0.backgroundColor = .white
        $0.textAlignment = .left
    }
    
    var endTimeButton = UIButton().then {
        $0.setTitle("설정", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = .white
        $0.titleLabel?.textAlignment = .right
    }
    
    lazy var endTimeStack = UIStackView(arrangedSubviews: [endTimeLabel, endTimeButton]).then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.backgroundColor = .white
    }
    
    var endTimePicker = UIDatePicker().then {
        $0.datePickerMode = .time
        if #available(iOS 13.4, *) { $0.preferredDatePickerStyle = .wheels }
        $0.locale = Locale(identifier: "Ko_kr")
        $0.timeZone = .current
        $0.isHidden = true
        $0.snp.makeConstraints { $0.height.equalTo(150) }
    }
    
    lazy var stackView = UIStackView(arrangedSubviews: [startTimeStack, startTimePicker, endTimeStack, endTimePicker]).then {
        $0.axis = .vertical
        $0.backgroundColor = .white
        $0.spacing = 10
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.addSubview(badgeButton)
        self.addSubview(titleTextField)
        self.addSubview(saveButton)
        self.addSubview(cancelButton)
        self.addSubview(stackView)
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
        saveButton.snp.makeConstraints {
            $0.right.bottom.equalToSuperview().inset(20)
            $0.height.equalTo(30)
        }
        cancelButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(20)
            $0.right.equalTo(saveButton.snp.left).offset(-20)
            $0.height.equalTo(30)
        }
        stackView.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom).offset(20)
            $0.left.equalTo(badgeButton)
            $0.right.equalTo(titleTextField)
            $0.bottom.equalTo(cancelButton.snp.top).offset(-20)
        }
    }
}
