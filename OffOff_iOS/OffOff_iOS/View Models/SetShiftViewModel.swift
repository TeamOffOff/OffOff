//
//  SetShiftViewModel.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/08/24.
//

import Foundation
import RxSwift
import RxCocoa

class SetShiftViewModel {
    
    let disposeBag = DisposeBag()
    
    var shifts: Observable<[Shift]>
    var date = PublishSubject<Date>()
    var dateText: Observable<String>
    var shiftSaved: Observable<SavedShift?>
    var shiftDeleted: Observable<Bool>
    
    init(
        input: (
            leftButtonTapped: Signal<()>,
            rightButtonTapped: Signal<()>,
            deleteButtonTapped: Signal<()>,
            selectedShift: Observable<Shift>
        )
    ) {
        // outputs
        shifts = UserRoutineManager.shared.getShifts()
        dateText = date.map { $0.toString("M월 d일 (E)") }

        let shiftAndDate = Observable.zip(input.selectedShift, date)
        shiftSaved = shiftAndDate
            .flatMap { shift, date -> Observable<SavedShift?> in
                return UserRoutineManager.shared.createSavedShift(shift: shift, date: date)
                    .map {
                        $0
                    }
            }
        
        shiftDeleted = input.deleteButtonTapped
            .asObservable()
            .withLatestFrom(date)
            .flatMap {
                UserRoutineManager.shared.deleteSavedShift(by: $0)
            }
        
        // bind inputs
        input.leftButtonTapped.asObservable()
            .withLatestFrom(date)
            .bind {
                self.date.onNext($0.adjustDate(amount: -1, component: .day)!)
            }
            .disposed(by: disposeBag)
        
        input.rightButtonTapped.asObservable()
            .withLatestFrom(date)
            .bind {
                self.date.onNext($0.adjustDate(amount: 1, component: .day)!)
            }
            .disposed(by: disposeBag)
        
        
    }
    
}
