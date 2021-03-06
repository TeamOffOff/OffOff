//
//  Post.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/05.
//

struct PostList: Codable {
    var lastPostId: String?
    var postList: [PostModel]
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lastPostId, forKey: .lastPostId)
        try container.encode(postList, forKey: .postList)
    }
}

struct MyPostList: Codable {
    var postList: [PostModel]
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(postList, forKey: .postList)
    }
}

struct MyReplyList: Codable {
    var repliesList: [PostModel]
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(repliesList, forKey: .repliesList)
    }
}

struct MyBookmarksList: Codable {
    var bookmarksList: [PostModel]
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bookmarksList, forKey: .bookmarksList)
    }
}

struct Author: Codable {
    var _id: String?
    var nickname: String?
    var type: String?
    var profileImage: [ImageObject]
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_id, forKey: ._id)
        try container.encode(nickname, forKey: .nickname)
        try container.encode(type, forKey: .type)
        try container.encode(profileImage, forKey: .profileImage)
    }
}

struct PostModel: Codable {
    var _id: String?
    var boardType: String
    var author: Author?
    var date: String
    var title: String
    var content: String
    var image: [ImageObject]
    var likes: [String]
    var views: Int
    var reports: [String]
    var bookmarks: [String]
    var replyCount: Int
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_id, forKey: ._id)
        try container.encode(author, forKey: .author)
        try container.encode(boardType, forKey: .boardType)
        try container.encode(content, forKey: .content)
        try container.encode(date, forKey: .date)
        try container.encode(image, forKey: .image)
        try container.encode(likes, forKey: .likes)
        try container.encode(reports, forKey: .reports)
        try container.encode(title, forKey: .title)
        try container.encode(views, forKey: .views)
        try container.encode(bookmarks, forKey: .bookmarks)
        try container.encode(replyCount, forKey: .replyCount)
    }
}

struct UserPostActivity: Codable {
    var boardType: String
    var postId: String
    var replyId: String
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(boardType, forKey: .boardType)
        try container.encode(postId, forKey: .postId)
        try container.encode(replyId, forKey: .replyId)
    }
}

struct PostActivity: Codable {
    var boardType: String
    var _id: String
    var activity: String
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(boardType, forKey: .boardType)
        try container.encode(_id, forKey: ._id)
        try container.encode(activity, forKey: .activity)
    }
}
