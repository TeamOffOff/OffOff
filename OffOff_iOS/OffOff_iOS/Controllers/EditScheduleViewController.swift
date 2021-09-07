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
    var viewModel: EditScheduleViewModel!
    
    let customView = EditScheduleView()
    
    override func loadView() {
        self.view = customView
        self.view.backgroundColor = .lightGray
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = EditScheduleViewModel(
            input: (
                selectedShift: customView.routineTable.rx.modelSelected(Shift.self).asObservable(),
                addButtonTapped: customView.addRoutineButton.rx.tap.asSignal()
            )
        )
        
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
                cell.timeLabel.text = UserRoutineManager.shared.getRoutineTime(startDate: element.startTime, endDate: element.endTime)
                cell.titleLabel.textColor = UIColor(hex: element.textColor)
                cell.titleLabel.backgroundColor = UIColor(hex: element.backgroundColor)
            }
            .disposed(by: disposeBag)
        
        viewModel.addingShift
            .observeOn(MainScheduler.instance)
            .bind {
                let vc = AddShiftViewController()
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true, completion: nil)
                print($0)
            }
            .disposed(by: disposeBag)
        
        viewModel.shiftSelected
            .observeOn(MainScheduler.instance)
            .bind {
                print($0)
            }
            .disposed(by: disposeBag)
        
        customView.makeView()
    }
    
    
}
