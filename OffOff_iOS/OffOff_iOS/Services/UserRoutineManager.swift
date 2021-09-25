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
    
    func shiftID() -> String {
        "Shift\(realm.objects(Shift.self).count)"
    }
    
    // Observing changing
    var savedShiftsChanged = BehaviorSubject<Bool>(value: false)
    var shiftsChanged = BehaviorSubject<Bool>(value: false)
    
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
            shiftsChanged.onNext(true)
            return Observable.just(true)
        } catch {
            return Observable.just(false)
        }
        
    }
    
    func createSavedShift(shift: Shift, date: Date) -> Observable<SavedShift?> {
        print(#fileID, #function, #line, date, shift)
        let savedShifts = realm.objects(SavedShift.self)
        let predicateQuery = NSPredicate(format: "date = %@", date.toString("yyyy-MM-dd"))
        let result = savedShifts.filter(predicateQuery)
        
        if result.isEmpty {
            let savedShift = SavedShift(id: self.savedShiftID(), date: date.toString("yyyy-MM-dd"), shift: shift)
            
            do {
                try self.realm.write {
                    self.realm.add(savedShift)
                }
                self.savedShiftsChanged.onNext(true)
                return Observable.just(savedShift)
            } catch {
                return Observable.just(nil)
            }
        } else {
            let savedShift = SavedShift(id: result.first!.id, date: date.toString("yyyy-MM-dd"), shift: shift)
            
            do {
                try self.realm.write {
                    self.realm.add(savedShift, update: .modified)
                }
                self.savedShiftsChanged.onNext(true)
                return Observable.just(savedShift)
            } catch {
                return Observable.just(nil)
            }
        }
    }
    
    func createSavedShift(savedshift: SavedShift, date: Date) -> Observable<Bool> {
        let savedShift = savedshift
        savedshift.date = date.toString("yyyy-MM-dd")
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
    
    func getShift(of id: String) -> Observable<[Shift]> {
        let shifts = realm.objects(Shift.self)
        let predicateQuery = NSPredicate(format: "id = %@", id)
        let result = shifts.filter(predicateQuery)
        return Observable.array(from: result)
    }

    // Update
    func updateShift(shift: Shift) -> Observable<Bool> {
        do {
            try realm.write {
                realm.add(shift, update: .modified)
            }
            shiftsChanged.onNext(true)
            return Observable.just(true)
        } catch {
            return Observable.just(false)
        }
    }
    
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
    
    func deleteShift(by id: Int) -> Observable<Bool> {
        let shifts = realm.objects(Shift.self)
        let predicateQuery = NSPredicate(format: "id = %@", id)
        let result = shifts.filter(predicateQuery)
        
        if result.count == 1 {
            do {
                try realm.write {
                    realm.delete(result.first!)
                }
                shiftsChanged.onNext(true)
                return Observable.just(true)
            } catch {
                return Observable.just(false)
            }
        } else {
            return Observable.just(false)
        }
    }
    
    func deleteShift(by shift: Shift) -> Observable<Bool> {
        
        do {
            try realm.write {
                realm.delete(shift)
            }
            shiftsChanged.onNext(true)
            return Observable.just(true)
        } catch {
            return Observable.just(false)
        }

    }
    
    func deleteSavedShift(by date: Date) -> Observable<Bool> {
        let savedShifts = realm.objects(SavedShift.self)
        let predicateQuery = NSPredicate(format: "date = %@", date.toString("yyyy-MM-dd"))
        let result = savedShifts.filter(predicateQuery)
        
        if result.count == 1 {
            do {
                try realm.write {
                    realm.delete(result.first!)
                }
                savedShiftsChanged.onNext(true)
                return Observable.just(true)
            } catch {
                return Observable.just(false)
            }
        } else {
            return Observable.just(false)
        }
    }
    
    func deleteSavedShift(by savedShift: SavedShift) -> Observable<Bool> {
        do {
            try realm.write {
                realm.delete(savedShift)
            }
            savedShiftsChanged.onNext(true)
            return Observable.just(true)
        } catch {
            return Observable.just(false)
        }
    }
    
    // Utility
    func getRoutineTime(startDate: String, endDate: String) -> String {
        return startDate.components(separatedBy: " ").last!
            + " ~ "
            + endDate.components(separatedBy: " ").last!
    }
}
