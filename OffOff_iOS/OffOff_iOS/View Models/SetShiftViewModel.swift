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
    
    //TODO: Core data에서 저장해둔 루틴들 가져오기
    var shifts: Observable<[Shift]>
    var date = PublishSubject<Date>()
    var dateText: Observable<String>
    
    init() {
        shifts = UserRoutineManager.shared.getShifts()
        dateText = date.map { $0.toString("M월 d일 (E)") }
    }
    
}
