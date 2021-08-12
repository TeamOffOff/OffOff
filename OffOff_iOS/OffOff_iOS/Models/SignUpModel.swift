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
    static var model = SignUpModel(_id: "", password: "", information: Information(name: "", email: "", birth: "", type: nil), subInformation: SubInformation(nickname: "", profileImage: nil), activity: Activity())
}

struct SignUpModel: Codable {
    var _id: String
    var password: String
    
    var information: Information
    var subInformation: SubInformation
    var activity: Activity
}

struct Information: Codable {
    var name: String
    var email: String
    var birth: String
    var type: String?
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
    }
}
struct SubInformation: Codable {
    var nickname: String
    var profileImage: String?
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nickname, forKey: .nickname)
        try container.encode(profileImage, forKey: .profileImage)
    }
}
struct Activity: Codable {
    var posts: [String] = []
    var replies: [String] = []
    var likes: [String] = []
    var reports: [String] = []
    var bookmarks: [String] = []
}

struct IDPWModel {
    var id: String?
    var password: String?
}
