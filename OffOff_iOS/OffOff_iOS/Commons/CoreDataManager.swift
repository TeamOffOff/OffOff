//
//  CoreDataManager.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/08/24.
//

import UIKit
import CoreData

class CoreDataManager {
    static let shared: CoreDataManager = CoreDataManager()
    
    let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
    lazy var context = appDelegate?.persistentContainer.viewContext
    
    let modelName: String = "WorkRoutine"
    
    func getRutines(ascending: Bool = false) -> [WorkRoutine] {
        var models: [WorkRoutine] = [WorkRoutine]()
        
        if let context = context {
            let fetchRequest: NSFetchRequest<NSManagedObject>
                = NSFetchRequest<NSManagedObject>(entityName: modelName)
//            fetchRequest.sortDescriptors = [idSort]
            
            do {
                if let fetchResult: [WorkRoutine] = try context.fetch(fetchRequest) as? [WorkRoutine] {
                    models = fetchResult
                }
            } catch let error as NSError {
                print("Could not fetch🥺: \(error), \(error.userInfo)")
            }
        }
        return models
    }
    
    func saveRoutine(title: String, startDate: Date, endDate: Date, onSuccess: @escaping ((Bool) -> Void)) {
        if let context = context,
            let entity: NSEntityDescription
            = NSEntityDescription.entity(forEntityName: modelName, in: context) {
            
            if let routine: WorkRoutine = NSManagedObject(entity: entity, insertInto: context) as? WorkRoutine {
                routine.title = title
                routine.startDate = startDate
                routine.endDate = endDate
                
                contextSave { success in
                    onSuccess(success)
                }
            }
        }
    }
    
    func deleteAllRoutine() {
        let entity = "WorkRoutine"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try context!.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                context!.delete(objectData)
            }
        } catch let error {
            print("Detele all data in \(entity) error :", error)
        }
    }

    
    
//    func deleteUser(id: Int64, onSuccess: @escaping ((Bool) -> Void)) {
//        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = filteredRequest(id: id)
//
//        do {
//            if let results: [Users] = try context?.fetch(fetchRequest) as? [Users] {
//                if results.count != 0 {
//                    context?.delete(results[0])
//                }
//            }
//        } catch let error as NSError {
//            print("Could not fatch🥺: \(error), \(error.userInfo)")
//            onSuccess(false)
//        }
//
//        contextSave { success in
//            onSuccess(success)
//        }
//    }
}

extension CoreDataManager {
    fileprivate func filteredRequest(id: Int64) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
            = NSFetchRequest<NSFetchRequestResult>(entityName: modelName)
        fetchRequest.predicate = NSPredicate(format: "id = %@", NSNumber(value: id))
        return fetchRequest
    }
    
    fileprivate func contextSave(onSuccess: ((Bool) -> Void)) {
        do {
            try context?.save()
            onSuccess(true)
        } catch let error as NSError {
            print("Could not save🥶: \(error), \(error.userInfo)")
            onSuccess(false)
        }
    }
}
