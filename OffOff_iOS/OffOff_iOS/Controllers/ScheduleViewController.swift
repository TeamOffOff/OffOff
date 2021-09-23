//
//  ScheduleViewController.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/08/23.
//

import UIKit
import RxSwift
import RxCocoa
import EventKit
import CoreData

class ScheduleViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    fileprivate weak var calendar: FSCalendar!
    var viewModel: ScheduleViewModel!
    let customView = ScheduleView()
    
    var setShiftVC = SetShiftViewController()
    
    override func loadView() {
        self.view = customView
        self.calendar = customView.calendar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.calendar.delegate = self
        self.calendar.dataSource = self
        self.calendar.register(ScheduleCalendarCell.self, forCellReuseIdentifier: ScheduleCalendarCell.identifier)
        
        let editModeButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        let editShift = UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: nil)
        
        self.navigationItem.rightBarButtonItems = [editShift, editModeButton]
        
        viewModel = ScheduleViewModel(
            input: (
                editShiftButtonTapped: editShift.rx.tap.asSignal(),
                editModeButtonTapped: editModeButton.rx.tap.asSignal()
            )
        )
        
        // bind outputs
        viewModel.isEditShiftButtonTapped
            .bind {
                if $0 {
                    let vc = EditShiftViewController()
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.isEditModeButtonTapped
            .bind {
                if $0 {
                    let controller = UIAlertController(title: "스케쥴 추가", message: "추가할 스케쥴을 선택하세요", preferredStyle: .actionSheet)
                    let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                    controller.addAction(cancel)
                    self.present(controller, animated: true, completion: nil)
                }
            }
            .disposed(by: disposeBag)
    }
}

extension ScheduleViewController: FSCalendarDataSource, FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        if let cell = cell as? ScheduleCalendarCell {
            cell.backgroundColor = .white
            let savedShift = viewModel.getSavedShift(of: date)
            savedShift.bind {
                cell.savedShift.onNext($0)
            }
            .dispose()
            
            cell.isEditing.onNext(false)
            if date == calendar.selectedDate {
                setShiftVC.editingCell = cell
                cell.isEditing.onNext(true)
            }
        } else {
            return
        }
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: ScheduleCalendarCell.identifier, for: date, at: position)
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        guard let cell = calendar.cell(for: date, at: monthPosition) as? ScheduleCalendarCell else {
            return
        }
        if date.compareComponent(with: calendar.currentPage, component: .month) != ComparisonResult.orderedSame {
            customView.calendar.select(date, scrollToDate: true)
        }
        
        setShiftVC = SetShiftViewController()
        
        setShiftVC.editingCell = cell
        setShiftVC.editingCell?.isEditing.onNext(true)
        setShiftVC.calendar = calendar
        setShiftVC.modalTransitionStyle = .coverVertical
        setShiftVC.modalPresentationStyle = .overFullScreen
        self.present(setShiftVC, animated: true, completion: nil)
        setShiftVC.viewModel.date.onNext(date)
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        // 전달로 들어온거면 현재 달 마지막 onNext
        // 다음달로 간거면 현재 달 1일 onNext
    }
}

extension FSCalendar {
    func reloadData(completion: @escaping () -> ()) {
        UIView.animate(withDuration: 0, animations: { self.reloadData() })
                    { _ in completion() }
    }
}
