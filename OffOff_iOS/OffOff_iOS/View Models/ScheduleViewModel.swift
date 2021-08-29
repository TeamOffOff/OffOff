
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
import CoreData

class ScheduleViewModel {
    private let eventStore = EKEventStore()
    private var calendarAuth = EKEventStore.authorizationStatus(for: .event)
    
    init() {
        authorizationCheck()
//        deleteAllRoutines()
//        saveNewRoutine(title: "A", startDate: Date(), endDate: Date())
//        saveNewRoutine(title: "B", startDate: Date().addingTimeInterval(10), endDate: Date())
//        fetchRoutines()
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
    
    private func saveNewRoutine(title: String, startDate: Date, endDate: Date) {
        
    }
    
    private func fetchRoutines() {
        
    }
    
    private func deleteAllRoutines() {
        
    }
}
