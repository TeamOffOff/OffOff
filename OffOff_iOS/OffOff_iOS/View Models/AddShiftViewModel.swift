//
//  AddShiftViewModel.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/09/07.
//

import Foundation
import RxSwift
import RxCocoa

class AddShiftViewModel {
    var isDismissing: Observable<Bool>
    var isSaving: Observable<Bool>
    var isStartTimeEditing = Observable<Bool>.just(false)
    var isEndTimeEditing = Observable<Bool>.just(false)
    var startTimeChanged: Observable<String>
    var endTimeChanged: Observable<String>
    var isShiftAdded: Observable<Bool>
    
    let disposeBag = DisposeBag()
    
    init(
        input: (
            titleText: Observable<String?>,
            cancelButtonTapped: Signal<()>,
            saveButtonTapped: Signal<()>,
            startTimeButtonTapped: Signal<()>,
            endTimeButtonTapped: Signal<()>,
            pickedStartTime: ControlProperty<Date>,
            pickedEndTime: ControlProperty<Date>
        )
    ) {
        // outputs
        isDismissing = input.cancelButtonTapped.asObservable().map { true }
        
        isSaving = input.saveButtonTapped.asObservable().map { true }
        
        isStartTimeEditing = input.startTimeButtonTapped.asObservable().map { true }
        
        isEndTimeEditing = input.endTimeButtonTapped.asObservable().map { true }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        startTimeChanged = input.pickedStartTime.map { formatter.string(from: $0) }
        endTimeChanged = input.pickedEndTime.map { formatter.string(from: $0) }
        
        let titleStartEnd = Observable.combineLatest(input.titleText, startTimeChanged, endTimeChanged)
        isShiftAdded = input.saveButtonTapped.asObservable().withLatestFrom(titleStartEnd)
            .observeOn(MainScheduler.instance)
            .flatMapLatest { (value) -> Observable<Bool> in
                let shift = Shift(id: "@@@", title: value.0 ?? "", textColor: "#FFFFFF", backgroundColor: "#000000", startTime: value.1, endTime: value.2)
                return UserRoutineManager.shared.createShift(shift: shift)
            }
    }
}
