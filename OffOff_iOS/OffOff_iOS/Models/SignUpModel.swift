//
//  SignUpModel.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/19.
//

import Foundation

//{
//    "id" : string,
//    "password": string
//     “information”: {
//            "name": string
//            "email": string
//            "birth": string
//            "type": string
//    },
//      “subinfo”: {
//           "nickname": string
//           "profile_image": string(url?)
//     },
//      “activity”: {
//           "posts": string(_id?)
//           "comments": string(_id?)
//          "likes": string(_id?)
//          "bookmarks": string(_id?)
//    }
//}

class SharedSignUpModel {
    static var model = SignUpModel(id: nil, password: nil, information: Information(), subinfo: Subinfo(), activity: Activity())
}

struct SignUpModel: Codable {
    var id: String?
    var password: String?
    
    var information: Information?
    var subinfo: Subinfo?
    var activity: Activity? = nil
}

struct Information: Codable {
    var name: String?
    var email: String?
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

struct IDPWModel {
    var id: String?
    var password: String?
}
