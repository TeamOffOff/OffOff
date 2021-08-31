//
//  UserRoutineManager.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/08/30.
//

import RealmSwift

class UserRoutineManager {
    static let shared = UserRoutineManager()
    let realm = try! Realm()
    
    // Create
    func createUserRoutine(id: String) {
        let user = UserRoutine(id: id)
        
        try! realm.write {
            realm.add(user)
        }
    }
    
    // Read
    func getUserRoutine(by id: String) -> UserRoutine? {
        return realm.object(ofType: UserRoutine.self, forPrimaryKey: id)
    }
    
    func getRoutines(by id: String) -> [Routine] {
        if let userRoutine = getUserRoutine(by: id) {
            return Array(userRoutine.routines)
        } else {
            return []
        }
    }
    
    func getSavedRoutines(by id: String) -> [SavedRoutine] {
        if let userRoutine = getUserRoutine(by: id) {
            return Array(userRoutine.savedRoutines)
        } else {
            return []
        }
    }
    
    // Update
    func addRoutine(by id: String, routine: Routine) {
        if let userRoutine = getUserRoutine(by: id) {
            try! realm.write {
                userRoutine.routines.append(routine)
                print("New Routine \(routine) added")
            }
        } else {
            print("User Routine is nil")
        }
    }
    
    func addSavedRoutine(by id: String, savedRoutine: SavedRoutine) {
        if let userRoutine = getUserRoutine(by: id) {
            try! realm.write {
                userRoutine.savedRoutines.append(savedRoutine)
            }
        } else {
            print("User Routine is nil")
        }
    }
    
    // Delete
    func deleteRoutine(of userId: String, by routineId: String) {
        if let userRoutine = getUserRoutine(by: userId) {
            try! realm.write {
                if let routine = userRoutine.routines.filter({ $0.id == routineId }).first {
                    if let index = userRoutine.routines.index(of: routine) {
                        userRoutine.routines.remove(at: index)
                    }
                }
            }
        } else {
            print("User Routine is nil")
        }
    }
    
    func deleteSavedRoutine(of userId: String, by savedRoutineId: String) {
        if let userRoutine = getUserRoutine(by: userId) {
            try! realm.write {
                if let saved = userRoutine.savedRoutines.filter({$0.id == savedRoutineId}).first {
                    if let index = userRoutine.savedRoutines.index(of: saved) {
                        userRoutine.savedRoutines.remove(at: index)
                    }
                }
            }
        } else {
            print("User Routine is nil")
        }
    }
}
