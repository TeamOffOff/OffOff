//
//  SubReplyServices.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/10/24.
//

import Foundation
import RxSwift
import Moya
import RxMoya

class SubReplyServices {
    static let provider = MoyaProvider<SubReplyAPI>()
    
    static func writeSubReply(writingSubReply: WritingReply) -> Observable<[Reply]?> {
        SubReplyServices.provider
            .rx.request(.writeSubReply(subReply: writingSubReply))
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
    
    static func deleteSubReply(deletingSubReply: DeletingSubReply) -> Observable<[Reply]?> {
        SubReplyServices.provider
            .rx.request(.deleteSubReply(subReply: deletingSubReply))
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
    
    static func likeSubReply(likeSubReply: PostActivity) -> Observable<Reply?> {
        SubReplyServices.provider
            .rx.request(.likeSubReply(subReply: likeSubReply))
            .asObservable()
            .map {
                if $0.statusCode == 200 {
                    do {
                        let reply = try JSONDecoder().decode(Reply.self, from: $0.data)
                        return reply
                    } catch {
                        return nil
                    }
                } else {
                    return nil
                }
            }
    }
}
