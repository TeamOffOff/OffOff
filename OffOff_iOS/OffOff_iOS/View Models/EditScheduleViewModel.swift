//
//  EditScheduleViewModel.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/08/25.
//

import Foundation
import RxSwift
import RxCocoa

class EditScheduleViewModel {
    
    // outputs
    var shifts = Observable<[Shift]>.just([])
    
    init() {
        fetchRoutines()
    }
    
    func fetchRoutines() {
        shifts = UserRoutineManager.shared.getShifts()
    }
    
//    private func saveNewRoutine(model: RoutineModel) {
//        CoreDataManager.shared.saveRoutine(model: model) { print($0) }
//    }
}
