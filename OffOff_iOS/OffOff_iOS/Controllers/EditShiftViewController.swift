//
//  EditShiftViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/08/25.
//

import UIKit
import RxSwift

class EditShiftViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    var viewModel: EditShiftViewModel!
    
    let customView = EditScheduleView()
    
    override func loadView() {
        self.view = customView
        self.view.backgroundColor = .lightGray
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = EditShiftViewModel(
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
            .bind(to: customView.routineTable.rx.items(cellIdentifier: ShiftTableViewCell.identifier, cellType: ShiftTableViewCell.self)) { row, element, cell  in
                cell.shift.onNext(element)
                cell.editingShift.bind { self.cellButtonAction(shift: $0!) }.disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        viewModel.addingShift
            .observeOn(MainScheduler.instance)
            .bind { _ in
                self.presentAddShiftViewController()
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
    
    private func cellButtonAction(shift: Shift) {
        let alert = UIAlertController(title: "동작", message: "선택하세요", preferredStyle: .actionSheet)
        let edit = UIAlertAction(title: "수정", style: .default) { _ in self.presentAddShiftViewController(shift: shift) }
        let delete = UIAlertAction(title: "삭제", style: .destructive) { _ in self.viewModel.deleteShift(shift: shift) }
        let action = UIAlertAction(title: "취소", style: .cancel) { _ in alert.dismiss(animated: true, completion: nil) }
        alert.addAction(edit)
        alert.addAction(delete)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func presentAddShiftViewController(shift: Shift? = nil) {
        let vc = AddShiftViewController()
        vc.editingShift = Observable.just(shift)
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    
}
