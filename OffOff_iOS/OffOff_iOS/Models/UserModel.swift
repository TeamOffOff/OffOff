//
//  UserModel.swift
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
    static var model = UserModel(_id: "", activity: Activity(), information: Information(name: "", email: "", birth: "", type: ""), password: "", subInformation: SubInformation(nickname: "", profileImage: nil))
}

struct UserModel: Codable {
    var _id: String
    var activity: Activity
    var information: Information
    var password: String
    var subInformation: SubInformation
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_id, forKey: ._id)
        try container.encode(activity, forKey: .activity)
        try container.encode(information, forKey: .information)
        try container.encode(password, forKey: .password)
        try container.encode(subInformation, forKey: .subInformation)
    }
}

struct Information: Codable {
    var name: String
    var email: String
    var birth: String
    var type: String
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encode(birth, forKey: .birth)
        try container.encode(type, forKey: .type)
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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(posts, forKey: .posts)
        try container.encode(replies, forKey: .replies)
        try container.encode(likes, forKey: .likes)
        try container.encode(reports, forKey: .reports)
        try container.encode(bookmarks, forKey: .bookmarks)
    }
}

struct IDPWModel {
    var id: String?
    var password: String?
}
