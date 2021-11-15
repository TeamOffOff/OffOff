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
    var boardList: [Board]
}

struct Board: Codable {
    var boardType: String
    var name: String
    var icon: String?
    var newPost: Bool
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(boardType, forKey: .boardType)
        try container.encode(name, forKey: .name)
        try container.encode(icon, forKey: .icon)
        try container.encode(newPost, forKey: .newPost)
    }
}
