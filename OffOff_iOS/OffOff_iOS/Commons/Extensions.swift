//
//  Extensions.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/09.
//

import Foundation

let dateFormatter = DateFormatter() //2020-01-29

extension String {
    func toDate() -> Date? {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: self)
    }
}

extension Date {
    func toString() -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
}
