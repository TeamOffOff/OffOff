//
//  Board.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/08/01.
//

import Foundation

//{"board" : [
//                           {"board_type": "free",
//                             "name": "자유게시판",
//                              "icon": url},
//                           {"board_type": "secret",
//                             "name": "비밀게시판",
//                              "icon": url},
//  ]
//}

struct BoardList: Codable {
    var board: [Board]
}

struct Board: Codable {
    var board_type: String
    var name: String
    var icon: String?
}
