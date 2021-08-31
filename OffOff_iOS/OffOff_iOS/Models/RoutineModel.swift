//
//  RoutineModel.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/08/23.
//

import RealmSwift

class UserRoutine: Object {
    @objc dynamic var id: String = ""
    let routines: List<Routine> = List()
    let savedRoutines: List<SavedRoutine> = List()
    
    var hasRoutines: Bool {
        return routines.count > 0
    }
    
    convenience init(id: String) {
        self.init()
        self.id = id
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

class Routine: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var textColor: String = ""
    @objc dynamic var backgroundColor: String = ""
    @objc dynamic var startDate: String = ""
    @objc dynamic var endDate: String = ""
    
    // Routine object가 어떤 객체에 연결되어 있는지
    let ofUser = LinkingObjects(fromType: UserRoutine.self, property: "routines")
    
    convenience init(id: String, title: String, textColor: String, backgroundColor: String, startDate: String, endDate: String) {
        self.init()
        self.id = id
        self.title = title
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.startDate = startDate
        self.endDate = endDate
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

class SavedRoutine: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var date: String = ""
    @objc dynamic var routine: Routine? = nil
    
    // Routine object가 어떤 객체에 연결되어 있는지
    let ofUser = LinkingObjects(fromType: UserRoutine.self, property: "savedRoutines")
    
    convenience init(id: String, date: String, routine: Routine) {
        self.init()
        self.id = id
        self.date = date
        self.routine = routine
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
