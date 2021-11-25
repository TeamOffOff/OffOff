//
//  SearchServices.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/11/13.
//

import Foundation

import Moya
import RxMoya
import RxSwift

class SearchServices {
    static let provider = MoyaProvider<SearchAPI>()
    
    static func searchPosts(in boardType: String, key: String, standardId: String?) -> Observable<PostList?> {
        SearchServices.provider
            .rx.request(.searchInBoard(boardType: boardType, key: key, standardId: standardId))
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .asObservable()
            .map {
                if $0.statusCode == 200 {
                    let postList = try JSONDecoder().decode(PostList.self, from: $0.data)
                    return postList
                } else {
                    return nil
                }
            }
            .catchAndReturn(nil)
    }
    
    static func totalSearch(key: String, lastPostId: String?) -> Observable<PostList?> {
        SearchServices.provider
            .rx.request(.totalSearch(key: key, lastPostId: lastPostId))
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .asObservable()
            .map {
                if $0.statusCode == 200 {
                    let postList = try JSONDecoder().decode(PostList.self, from: $0.data)
                    return postList
                } else {
                    return nil
                }
            }
    }
}
