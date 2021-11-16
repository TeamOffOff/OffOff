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
        return ReplyServices.provider
            .rx.request(.getReplies(postId, boardType))
            .asObservable()
            .map {
                print(#fileID, #function, #line, $0)
                if $0.statusCode == 200 {
                    do {
                        let replyList = try JSONDecoder().decode(ReplyList.self, from: $0.data)
                        return replyList.replyList
                    } catch {
                        print(error)
                        print(error.localizedDescription)
                        return []
                    }
                }
                return []
            }
    }
    
    static func writeReply(reply: WritingReply) -> Observable<[Reply]?> {
        ReplyServices.provider
            .rx.request(.writeReply(reply: reply))
            .asObservable()
            .map {
                print(#fileID, #function, #line, $0)
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
            .catchAndReturn(nil)
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
            .catchAndReturn(nil)
    }
}
