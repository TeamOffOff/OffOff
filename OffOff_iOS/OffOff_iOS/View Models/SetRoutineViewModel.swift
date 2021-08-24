//
//  SetRoutineViewModel.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/08/24.
//

import Foundation
import RxSwift
import RxCocoa

class SetRoutineViewModel {
    
    //TODO: Core data에서 저장해둔 루틴들 가져오기
    let routines = Observable<[String]>.just(["주", "야", "비", "휴"])
    var date = PublishSubject<Date>()
    var dateText: Observable<String>
    
    init() {
        dateText = date.map { $0.toString("MM월 dd일 (E)") }
    }
    
}
