//
//  Post.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/05.
//

struct PostList: Codable {
    var lastPostId: String
    var postList: [PostModel]
}

struct PostModel: Codable {
    var _id: String?
    var author: String
    var boardType: String
    var content: String
    var date: String
    var image: String?
    var likes: Int
    var replyCount: Int
    var reportCount: Int
    var title: String
    var viewCount: Int
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_id, forKey: ._id)
        try container.encode(author, forKey: .author)
        try container.encode(boardType, forKey: .boardType)
        try container.encode(content, forKey: .content)
        try container.encode(date, forKey: .date)
        try container.encode(image, forKey: .image)
        try container.encode(likes, forKey: .likes)
        try container.encode(replyCount, forKey: .replyCount)
        try container.encode(reportCount, forKey: .reportCount)
        try container.encode(title, forKey: .title)
        try container.encode(viewCount, forKey: .viewCount)
    }
}

@propertyWrapper
struct NullCodable<T>: Codable where T: Codable {
    
    var wrappedValue: T?
    
    init(wrappedValue: T?) {
        self.wrappedValue = wrappedValue
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch wrappedValue {
        case .some(let value): try container.encode(value)
        case .none: try container.encodeNil()
        }
    }
}
