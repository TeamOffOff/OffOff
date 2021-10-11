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
                if $0.statusCode == 200 {
                    do {
                        let replyList = try JSONDecoder().decode(ReplyList.self, from: $0.data)
                        return replyList.replyList
                    } catch {
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
}
