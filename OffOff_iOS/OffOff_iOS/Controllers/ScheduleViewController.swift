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
    var viewModel = ScheduleViewModel()
    let customView = ScheduleView()
    
    override func loadView() {
        self.view = customView
        self.calendar = customView.calendar
    }
    
    // TODO: 근무 일정 설정할 수 있는 화면 만들기
    override func viewDidLoad() {
        super.viewDidLoad()
        self.calendar.delegate = self
        self.calendar.dataSource = self
        self.calendar.register(ScheduleCalendarCell.self, forCellReuseIdentifier: ScheduleCalendarCell.identifier)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        
        self.navigationItem.rightBarButtonItem!
            .rx.tap
            .bind {
                // + 버튼을 누르면 설정 해둔 근무 일정들을 표시
                let controller = UIAlertController(title: "스케쥴 추가", message: "추가할 스케쥴을 선택하세요", preferredStyle: .actionSheet)
                let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                controller.addAction(cancel)
                self.present(controller, animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
        
        
    }
}

extension ScheduleViewController: FSCalendarDataSource, FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        if let cell = cell as? ScheduleCalendarCell {
            cell.eventTitleLabel.text = ["D", "N", "", "", ""].randomElement()
        } else {
            return
        }
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: ScheduleCalendarCell.identifier, for: date, at: position)
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let vc = SetRoutineViewController()
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
        vc.viewModel.date.onNext(date)
    }
}
