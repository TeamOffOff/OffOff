//
//  EditScheduleView.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/09/01.
//

import Foundation

class EditScheduleView: UIView {
    var addRoutineButton = UIButton().then {
        $0.setTitle("근무타입 추가", for: .normal)
        $0.backgroundColor = .lightGray
        $0.setTitleColor(.black, for: .normal)
    }
    var routineTable = UITableView().then {
        $0.backgroundColor = .white
        $0.register(ShiftTableViewCell.self, forCellReuseIdentifier: ShiftTableViewCell.identifier)
    }
    var closeButton = UIButton(type: .close)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(addRoutineButton)
        self.addSubview(routineTable)
        self.addSubview(closeButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeView() {
        addRoutineButton.snp.makeConstraints {
            $0.right.top.equalTo(self.safeAreaLayoutGuide).inset(12)
        }
        closeButton.snp.makeConstraints {
            $0.left.top.equalTo(self.safeAreaLayoutGuide).inset(12)
        }
        routineTable.snp.makeConstraints {
            $0.top.equalTo(addRoutineButton.snp.bottom).offset(12)
            $0.left.right.bottom.equalTo(self.safeAreaLayoutGuide).inset(8)
        }
    }
}
