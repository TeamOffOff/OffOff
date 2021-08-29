//
//  EditScheduleViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/08/25.
//

import UIKit
import RxSwift

class EditScheduleViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let viewModel = EditScheduleViewModel()
    
    var addRoutineButton = UIButton().then {
        $0.setTitle("근무타입 추가", for: .normal)
        $0.backgroundColor = .lightGray
        $0.setTitleColor(.black, for: .normal)
    }
    var routineTable = UITableView()
    
    override func loadView() {
        self.view = UIView()
        self.view.backgroundColor = .white
        self.view.addSubview(addRoutineButton)
        self.view.addSubview(routineTable)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        viewModel.savedRutines
//            .bind { print($0) }
//            .disposed(by: disposeBag)
        
        makeView()
    }
    
    private func makeView() {
        addRoutineButton.snp.makeConstraints {
            $0.right.top.equalTo(self.view.safeAreaLayoutGuide).inset(12)
        }
        routineTable.snp.makeConstraints {
            $0.top.equalTo(addRoutineButton.snp.bottom).offset(12)
            $0.left.right.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(8)
        }
    }
}
