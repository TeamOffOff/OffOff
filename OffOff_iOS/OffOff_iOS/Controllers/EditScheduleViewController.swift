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
    
    let customView = EditScheduleView()
    
    override func loadView() {
        self.view = customView
        self.view.backgroundColor = .lightGray
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customView.routineTable.rowHeight = 80
        
        customView.closeButton.rx.tap
            .bind {
                self.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
        
        // bind outputs
        viewModel.shifts
            .observeOn(MainScheduler.instance)
            .bind(to: customView.routineTable.rx.items(cellIdentifier: RoutineTableViewCell.identifier, cellType: RoutineTableViewCell.self)) { row, element, cell  in
                cell.titleLabel.text = String(element.title.first!)
                cell.timeLabel.text = UserRoutineManager.shared.getRoutineTime(startDate: element.startDate, endDate: element.endDate)
            }
            .disposed(by: disposeBag)
        
        customView.makeView()
    }
    
    
}
