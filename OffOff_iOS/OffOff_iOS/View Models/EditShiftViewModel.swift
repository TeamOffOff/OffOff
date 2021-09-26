//
//  EditScheduleViewModel.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/08/25.
//

import Foundation
import RxSwift
import RxCocoa

class EditShiftViewModel {
    
    // outputs
    var shifts = Observable<[Shift]>.just([])
    var addingShift: Observable<Bool>
    var shiftSelected: Observable<Shift>
    
    init(
        input: (
            selectedShift: Observable<Shift>,
            addButtonTapped: Signal<()>
        )
    ) {
        addingShift = input.addButtonTapped.asObservable().map { _ in true }
        shiftSelected = input.selectedShift.map { $0 }
        fetchRoutines()
    }
    
    func fetchRoutines() {
        shifts = UserRoutineManager.shared.getShifts()
    }
    
    func deleteShift(shift: Shift) {
        UserRoutineManager.shared.deleteShift(by: shift)
    }
    
//    private func saveNewRoutine(model: RoutineModel) {
//        CoreDataManager.shared.saveRoutine(model: model) { print($0) }
//    }
}
