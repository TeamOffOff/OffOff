//
//  RoutineModel.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/08/23.
//

import RealmSwift

class Shift: Object {
    @Persisted(primaryKey: true) var id: String = ""
    @Persisted var title: String = ""
    @Persisted var textColor: String = ""
    @Persisted var backgroundColor: String = ""
    @Persisted var startTime: String = ""
    @Persisted var endTime: String = ""
    
    convenience init(id: String, title: String, textColor: String, backgroundColor: String, startTime: String, endTime: String) {
        self.init()
        self.id = id
        self.title = title
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.startTime = startTime
        self.endTime = endTime
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

class SavedShift: Object {
    @Persisted(primaryKey: true) var id: String = ""
    @Persisted var date: String = ""
    @Persisted var shift: Shift? = nil
        
    convenience init(id: String, date: String, shift: Shift) {
        self.init()
        self.id = id
        self.date = date
        self.shift = shift
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
