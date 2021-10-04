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
            .subscribe(onNext: { _ in
                self.editingCell?.isEditing.onNext(false)
                self.editingCell!.backgroundColor = .white
                self.calendar!.deselect(self.calendar!.selectedDate!)
                self.dismiss(animated: true, completion: nil)
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
            .bind { date in
                self.calendar!.select(date, scrollToDate: true)
                
                guard let cell = self.calendar!.cell(for: date, at: .current) as? ScheduleCalendarCell else {
                    return
                }
                self.customView.routineCollection.reloadData()
                self.editingCell?.isEditing.onNext(false)
                self.editingCell = cell
                self.editingCell?.isEditing.onNext(true)
            }
            .disposed(by: disposeBag)
        
        viewModel.dateText
            .bind {
                self.customView.dateLabel.text = $0
            }
            .disposed(by: disposeBag)
        
        // 새로운 시프트 저장처리
        viewModel.shiftSaved
            .bind {
                if $0 != nil {
                    print("saved")
                    self.editingCell?.savedShift.onNext($0)
                    if self.isEditModeOn {
                        if self.calendar!.selectedDate!.adjustDate(amount: 1, component: .day)!.day == 1 {
                            self.editingCell?.isEditing.onNext(false)
                            self.dismiss(animated: true, completion: nil)
                        } else {
                            self.viewModel.date.onNext(self.calendar!.selectedDate!.adjustDate(amount: 1, component: .day)!)
                        }
                    } else {
                        self.editingCell?.isEditing.onNext(false)
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    print("failed")
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.shiftDeleted
            .bind {
                if $0 {
                    print("Deleted")
                    self.editingCell?.savedShift.onNext(nil)
                    self.editingCell?.isEditing.onNext(false)
                    self.calendar!.deselect(self.calendar!.selectedDate!)
                    self.dismiss(animated: true, completion: nil)
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
