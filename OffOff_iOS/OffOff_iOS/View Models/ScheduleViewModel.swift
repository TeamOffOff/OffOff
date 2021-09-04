
//
//  ScheduleViewModel.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/08/23.
//

import UIKit.UIApplication
import Foundation
import RxSwift
import RxCocoa
import EventKit
import RealmSwift

class ScheduleViewModel {
    private let eventStore = EKEventStore()
    private var calendarAuth = EKEventStore.authorizationStatus(for: .event)
    
    var savedShiftsChanged = UserRoutineManager.shared.savedShiftsChanged
    
    init() {
        authorizationCheck()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    private func authorizationCheck() {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            self.calendarAuth = .authorized
        case .denied:
            print("Access denied")
        case .notDetermined:
            eventStore.requestAccess(to: .event, completion: { (granted: Bool, NSError) -> Void in
                if granted {
                    self.calendarAuth = .authorized
                } else {
                    self.calendarAuth = .denied
                    print("Access denied")
                }
            })
        default:
            print("Case Default")
        }
    }
    
    func getSavedShift(of day: Date) -> Observable<SavedShift?> {
        UserRoutineManager.shared.getSavedShift(of: day).map { $0.isEmpty ? nil : $0.first!}
    }
    
    private func saveNewRoutine(title: String, startDate: Date, endDate: Date) {
        
    }
    
    private func fetchRoutines() -> [SavedShift] {
//        UserRoutineManager.shared.getSavedRoutines(by: "Test")
        return []
    }
    
    private func deleteAllRoutines() {
        
    }
}
