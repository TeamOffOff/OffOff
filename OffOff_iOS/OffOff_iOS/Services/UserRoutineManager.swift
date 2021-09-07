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
    
    // Object ID
    func savedShiftID() -> String {
        "SavedShift\(realm.objects(SavedShift.self).count)"
    }
    
    // Observing changing
    var savedShiftsChanged = BehaviorSubject<Bool>(value: false)
    
    // Create
    func createShift() {
        let shift = Shift(id: "Shift00", title: "주", textColor: "#000000", backgroundColor: "#FFFFFF", startTime: "09:00", endTime: "18:00")
        
        try! realm.write {
            realm.add(shift)
        }
    }
    
    func createShift(shift: Shift) -> Observable<Bool> {
        do {
            try realm.write {
                realm.add(shift)
            }
            return Observable.just(true)
        } catch {
            return Observable.just(false)
        }
        
    }
    
    func createSavedShift(shift: Shift, date: Date) -> Observable<Bool> {
        let savedShift = SavedShift(id: savedShiftID(), date: date.toString("yyyy-MM-dd"), shift: shift)
        do {
            try realm.write {
                realm.add(savedShift)
            }
            savedShiftsChanged.onNext(true)
            return Observable.just(true)
        } catch {
            return Observable.just(false)
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

    // Delete
    func deleteAllSavedShifts() {
        do {
            try realm.write {
                realm.delete(realm.objects(SavedShift.self))
            }
        } catch {
            print("Failed to delete SavedShift")
        }
    }
    
    func deleteAllShifts() {
        do {
            try realm.write {
                realm.delete(realm.objects(Shift.self))
            }
        } catch {
            print("Failed to delete Shift")
        }
    }
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
