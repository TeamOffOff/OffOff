//
//  Reply.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/10/01.
//

import Foundation

struct WritingReply: Codable {
    var _id: String? = nil
    var boardType: String
    var postId: String
    var parentReplyId: String?
    var content: String
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(boardType, forKey: .boardType)
        try container.encode(postId, forKey: .postId)
        try container.encode(parentReplyId, forKey: .parentReplyId)
        try container.encode(content, forKey: .content)
        try container.encode(_id, forKey: ._id)
    }
}

struct Reply: Codable {
    var _id: String
    var author: Author
    var boardType: String
    var content: String
    var date: String
    var likes: [String]
    var parentReplyId: String?
    var postId: String
    var childrenReplies: [Reply]?
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_id, forKey: ._id)
        try container.encode(author, forKey: .author)
        try container.encode(boardType, forKey: .boardType)
        try container.encode(content, forKey: .content)
        try container.encode(date, forKey: .date)
        try container.encode(likes, forKey: .likes)
        try container.encode(parentReplyId, forKey: .parentReplyId)
        try container.encode(postId, forKey: .postId)
        try container.encode(childrenReplies, forKey: .childrenReplies)
    }
}

struct ReplyList: Codable {
    var replyList: [Reply]
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(replyList, forKey: .replyList)
    }
}

struct DeletingReply: Codable {
    var _id: String
    var postId: String
    var boardType: String
    var author: String
    var isChildReply: Bool
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_id, forKey: ._id)
        try container.encode(postId, forKey: .postId)
        try container.encode(boardType, forKey: .boardType)
        try container.encode(author, forKey: .author)
        try container.encode(isChildReply, forKey: .isChildReply)
    }
}

struct DeletingSubReply: Codable {
    var _id: String
    var boardType: String
    var postId: String
    var parentReplyId: String
    var author: String
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_id, forKey: ._id)
        try container.encode(boardType, forKey: .boardType)
        try container.encode(postId, forKey: .postId)
        try container.encode(parentReplyId, forKey: .parentReplyId)
        try container.encode(author, forKey: .author)
    }
}
