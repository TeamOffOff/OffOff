//
//  UserRoutineManager.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/08/30.
//

import RealmSwift
import RxRealm
import RxSwift

class UserRoutineManager {
    static let shared = UserRoutineManager()
    let realm = try! Realm()
    
    // Create
    func createShift() {
        let shift = Shift(id: "Shift00", title: "주", textColor: "#000000", backgroundColor: "#FFFFFF", startDate: "2021-09-02 09:00", endDate: "2021-09-02 18:00")
        
        try! realm.write {
            realm.add(shift)
        }
    }
    
    func createSavedShift(shift: Shift) {
        let savedShift = SavedShift(id: "SavedShift00", date: "2021-09-02", shift: shift)
        
        try! realm.write {
            realm.add(savedShift)
        }
    }
    
    // Read
    func getShifts() -> Observable<[Shift]> {
        Observable.array(from: realm.objects(Shift.self))
    }

    func getSavedShifts() -> Observable<[SavedShift]> {
        Observable.array(from: realm.objects(SavedShift.self))
    }
    
    func getSavedShift(of day: Date) -> Observable<[SavedShift]> {
        let savedShifts = realm.objects(SavedShift.self)
        let predicateQuery = NSPredicate(format: "date = %@", day.toString("yyyy-MM-dd"))
        let result = savedShifts.filter(predicateQuery)
        return Observable.array(from: result)
    }
    

    // Update
    func addShift(shift: Shift) {
        Observable.from(object: shift).subscribe(realm.rx.add()).dispose()
    }

    func addSavedShift(savedShift: SavedShift) {
        Observable.from(object: savedShift).subscribe(realm.rx.add()).dispose()
    }
//
//    // Delete
//    func deleteRoutine(of userId: String, by routineId: String) {
//        if let userRoutine = getUserRoutine(by: userId) {
//            try! realm.write {
//                if let routine = userRoutine.shifts.filter({ $0.id == routineId }).first {
//                    if let index = userRoutine.shifts.index(of: routine) {
//                        userRoutine.shifts.remove(at: index)
//                    }
//                }
//            }
//        } else {
//            print("User Routine is nil")
//        }
//    }
//
//    func deleteSavedRoutine(of userId: String, by savedRoutineId: String) {
//        if let userRoutine = getUserRoutine(by: userId) {
//            try! realm.write {
//                if let saved = userRoutine.savedRoutines.filter({$0.id == savedRoutineId}).first {
//                    if let index = userRoutine.savedRoutines.index(of: saved) {
//                        userRoutine.savedRoutines.remove(at: index)
//                    }
//                }
//            }
//        } else {
//            print("User Routine is nil")
//        }
//    }
    
    // Utility
    func getRoutineTime(startDate: String, endDate: String) -> String {
        return startDate.components(separatedBy: " ").last!
            + " ~ "
            + endDate.components(separatedBy: " ").last!
    }
}
