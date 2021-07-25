//
//  SignUpModel.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/19.
//

import Foundation

struct SignUpModel: Codable {
    struct Information: Codable {
        var id: String?
        var name: String?
        var email: String?
        var password: String?
        var birth: String?
        var type: String?
    }
    struct Subinfo: Codable {
        var nickname: String?
        var profile_image: String?
    }
    struct Activity: Codable {
        var posts: String?
        var commments: String?
        var likes: String?
        var bookmarks: String?
    }
    var information: Information?
    var subinfo: Subinfo?
    var activity: Activity?
}
