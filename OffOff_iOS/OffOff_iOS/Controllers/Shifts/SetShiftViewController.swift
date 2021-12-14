//
//  SetShiftViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/08/24.
//

import UIKit
import RxSwift
import RxGesture

class SetShiftViewController: UIViewController {
    let customView = SetRoutineView()
    var viewModel: SetShiftViewModel!
    var disposeBag = DisposeBag()
    var editingCell: ScheduleCalendarCell? = nil
    var calendar: FSCalendar? = nil
    var isEditModeOn = false
    
    let outterView = UIView().then { $0.backgroundColor = .clear }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeView()
        viewModel = SetShiftViewModel(
            input: (
                leftButtonTapped: customView.leftButton.rx.tap.asSignal(),
                rightButtonTapped: customView.rightButton.rx.tap.asSignal(),
                deleteButtonTapped:
                    customView.deleteSavedShiftButton.rx.tap.asSignal(),
                selectedShift: customView.routineCollection.rx.modelSelected(Shift.self).map { $0 }
            )
        )
        
        outterView.rx
            .tapGesture()
            .when(.recognized)
            .withUnretained(self)
            .subscribe(onNext: { (owner, _) in
                owner.editingCell?.isEditing.onNext(false)
                owner.editingCell!.backgroundColor = .white
                owner.calendar!.deselect(owner.calendar!.selectedDate!)
                owner.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        // bind outputs {
        viewModel.shifts
            .bind(to: customView.routineCollection
                    .rx.items(cellIdentifier: RoutineCell.identifier, cellType: RoutineCell.self)) { (row, element, cell) in
                cell.titleLabel.text = element.title
                cell.titleLabel.textColor = UIColor(hex: element.textColor)
                cell.backgroundColor = UIColor(hex: element.backgroundColor)
            }
            .disposed(by: disposeBag)
        
        viewModel.date
            .withUnretained(self)
            .bind { (owner, date) in
                owner.calendar!.select(date, scrollToDate: true)
                
                guard let cell = owner.calendar!.cell(for: date, at: .current) as? ScheduleCalendarCell else {
                    return
                }
                owner.customView.routineCollection.reloadData()
                owner.editingCell?.isEditing.onNext(false)
                owner.editingCell = cell
                owner.editingCell?.isEditing.onNext(true)
            }
            .disposed(by: disposeBag)
        
        viewModel.dateText
            .bind(to: customView.dateLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 새로운 시프트 저장처리
        viewModel.shiftSaved
            .withUnretained(self)
            .bind { (owner, savedShift) in
                if savedShift != nil {
                    print("saved")
                    owner.editingCell?.savedShift.onNext(savedShift)
                    if owner.isEditModeOn {
                        if owner.calendar!.selectedDate!.adjustDate(amount: 1, component: .day)!.day == 1 {
                            owner.editingCell?.isEditing.onNext(false)
                            owner.dismiss(animated: true, completion: nil)
                        } else {
                            owner.viewModel.date.onNext(owner.calendar!.selectedDate!.adjustDate(amount: 1, component: .day)!)
                        }
                    } else {
                        owner.editingCell?.isEditing.onNext(false)
                        owner.dismiss(animated: true, completion: nil)
                    }
                } else {
                    print("failed")
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.shiftDeleted
            .withUnretained(self)
            .bind { (owner, bool) in
                if bool {
                    print("Deleted")
                    owner.editingCell?.savedShift.onNext(nil)
                    owner.editingCell?.isEditing.onNext(false)
                    owner.calendar!.deselect(owner.calendar!.selectedDate!)
                    owner.dismiss(animated: true, completion: nil)
                }
            }
            .disposed(by: disposeBag)
        
        // }
        
        customView.makeView()
    }
    
    //MARK: - Private functions
    private func makeView() {
        self.view.addSubview(customView)
        self.view.addSubview(outterView)
        self.view.backgroundColor = .clear
        
        customView.routineCollection.register(RoutineCell.self, forCellWithReuseIdentifier: RoutineCell.identifier)
        customView.routineCollection.rx.setDelegate(self).disposed(by: disposeBag)
        
        customView.snp.makeConstraints {
            $0.height.equalToSuperview().multipliedBy(0.25)
            $0.left.right.bottom.equalToSuperview()
        }
        outterView.snp.makeConstraints {
            $0.left.right.top.equalToSuperview()
            $0.bottom.equalTo(customView.snp.top)
        }
    }
}

extension SetShiftViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = Constants.RoutineCellSize
        return CGSize(width: cellWidth, height: cellWidth)
    }
}
