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
    // outputs
    var textChanged: Observable<String?>
    var isDismissing: Observable<Bool>
    var isSaving: Observable<Bool>
    var isStartTimeEditing = Observable<Bool>.just(false)
    var isEndTimeEditing = Observable<Bool>.just(false)
    var startTimeChanged: Observable<String>
    var endTimeChanged: Observable<String>
    var isShiftChanged: Observable<Bool>
    var isEditingShiftColor: Observable<Bool>
    var isEditingShift = Observable<Shift?>.just(nil)
    
    var exsistingId: String?
    let disposeBag = DisposeBag()
    
    init(
        input: (
            editingShift: Observable<Shift?>,
            badgeTapped: Signal<()>,
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
        isEditingShift = input.editingShift.map {
            if $0 != nil {
                return $0
            } else {
                return nil
            }
        }
        
        textChanged = input.titleText.map { $0 }
        
        isEditingShiftColor = input.badgeTapped.asObservable().map { true }
        
        isDismissing = input.cancelButtonTapped.asObservable().map { true }
        
        isSaving = input.saveButtonTapped.asObservable().map { true }
        
        isStartTimeEditing = input.startTimeButtonTapped.asObservable().map { true }
        
        isEndTimeEditing = input.endTimeButtonTapped.asObservable().map { true }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        startTimeChanged = input.pickedStartTime.map { formatter.string(from: $0) }
        endTimeChanged = input.pickedEndTime.map { formatter.string(from: $0) }
        
        let titleStartEnd = Observable.combineLatest(input.titleText, startTimeChanged, endTimeChanged, isEditingShift)
        isShiftChanged = input.saveButtonTapped.asObservable().withLatestFrom(titleStartEnd)
            .observe(on: MainScheduler.instance)
            .flatMapLatest { (values) -> Observable<Bool> in
                if values.0 == nil || values.0 == "" {
                    return Observable.just(false)
                }
                
                if values.3 != nil {
                    let shift = Shift(id: values.3!.id, title: values.0 ?? "", textColor: "#FFFFFF", backgroundColor: "#000000", startTime: values.1, endTime: values.2)
                    return UserRoutineManager.shared.updateShift(shift: shift)
                } else {
                    let shift = Shift(id: UserRoutineManager.shared.shiftID(), title: values.0 ?? "", textColor: "#FFFFFF", backgroundColor: "#000000", startTime: values.1, endTime: values.2)
                    return UserRoutineManager.shared.createShift(shift: shift)
                }
            }
    }
    
    private func bindOutputs() {
        
    }
}
