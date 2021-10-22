//
//  ReplyServices.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/10/01.
//

import Foundation
import Moya
import RxMoya
import RxSwift

class ReplyServices {
    static let provider = MoyaProvider<ReplyAPI>()
    
    static func fetchReplies(of postId: String, in boardType: String) -> Observable<[Reply]> {
        let reply2 = Reply(_id: "2", boardType: "free", postId: "616e378db8a86b1a5f87e9b6", parentReplyId: "1", content: "123", date: "2021년 10월 19일 22시 59분", author: Author(_id: "test123", nickname: "tester", type: nil, profileImage: nil), likes: [], childrenReplies: [])
        let reply3 = Reply(_id: "3", boardType: "free", postId: "616e378db8a86b1a5f87e9b6", parentReplyId: "1", content: "123", date: "2021년 10월 19일 22시 59분", author: Author(_id: "test123", nickname: "tester", type: nil, profileImage: nil), likes: [], childrenReplies: [])
        
        let reply1 = Reply(_id: "1", boardType: "free", postId: "616e378db8a86b1a5f87e9b6", parentReplyId: nil, content: "123", date: "2021년 10월 19일 22시 59분", author: Author(_id: "test123", nickname: "tester", type: nil, profileImage: nil), likes: [], childrenReplies: [reply2, reply3])
        
        let reply4 = Reply(_id: "4", boardType: "free", postId: "616e378db8a86b1a5f87e9b6", parentReplyId: nil, content: "123", date: "2021년 10월 19일 22시 59분", author: Author(_id: "test123", nickname: "tester", type: nil, profileImage: nil), likes: [], childrenReplies: [])
        
        let replies = [reply2, reply3, reply1, reply4]
        
        return Observable.just(replies)
        
//        return ReplyServices.provider
//            .rx.request(.getReplies(postId, boardType))
//            .asObservable()
//            .map {
//                if $0.statusCode == 200 {
//                    do {
//                        let replyList = try JSONDecoder().decode(ReplyList.self, from: $0.data)
//                        print(replyList.replyList)
//                        return replyList.replyList
//                    } catch {
//                        return []
//                    }
//                }
//                return []
//            }
    }
    
    static func writeReply(reply: WritingReply) -> Observable<[Reply]?> {
        ReplyServices.provider
            .rx.request(.writeReply(reply: reply))
            .asObservable()
            .map {
                if $0.statusCode == 200 {
                    do {
                        let replyList = try JSONDecoder().decode(ReplyList.self, from: $0.data)
                        return replyList.replyList
                    } catch {
                        return nil
                    }
                } else {
                    return nil
                }
            }
    }
    
    static func likeReply(reply: PostActivity) -> Observable<Reply?> {
        ReplyServices.provider
            .rx.request(.likeReply(reply: reply))
            .asObservable()
            .map {
                
                if $0.statusCode == 200 {
                    let reply = try JSONDecoder().decode(Reply.self, from: $0.data)
                    return reply
                } else {
                    return nil
                }
            }
            .catchErrorJustReturn(nil)
    }
    
    static func deleteReply(reply: DeletingReply) -> Observable<[Reply]?> {
        ReplyServices.provider
            .rx.request(.deleteReply(reply: reply))
            .asObservable()
            .map {
                if $0.statusCode == 200 {
                    let replies = try JSONDecoder().decode(ReplyList.self, from: $0.data)
                    return replies.replyList
                }
                return nil
            }
            .catchErrorJustReturn(nil)
    }
}
