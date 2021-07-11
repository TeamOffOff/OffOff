//
//  Account.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/03.
//

import Foundation

enum MemberType: Int, Codable {
    case Student = 0
    case Incumbent = 1
}

struct Account: Codable {
    let id: String
    let nickName: String
    let loginStatus: Bool
    let memberType: MemberType
}
