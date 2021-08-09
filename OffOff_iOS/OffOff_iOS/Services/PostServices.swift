//
//  PostServices.swift
//  OffOff_iOS
//
//  Created by Lee Nam Jun on 2021/07/12.
//

import Foundation
import Moya
import RxMoya
import RxSwift

public class PostServices {
    static let provider = MoyaProvider<PostAPI>()
    
    static func fetchPost(content_id: String, board_type: String) -> Observable<Post?> {
        PostServices.provider
            .rx.request(.getPost(content_id: content_id, board_type: board_type))
            .asObservable()
            .map {
                if $0.statusCode == 200 {
                    let response = try JSONDecoder().decode(Post.self, from: $0.data)
                    return response
                }
                return nil
            }
            .catchErrorJustReturn(nil)
    }
    
    static func createPost(post: Post) -> Observable<Bool> {
        PostServices.provider
            .rx.request(.makePost(post: post))
            .asObservable()
            .map {
                if $0.statusCode == 200 {
                    return true
                }
                return false
            }
            .catchErrorJustReturn(false)
    }
    
    
    // 새로 작성한 포스트를 바로 받아오는 버젼
//    static func createPost(post: Post) -> Observable<Post?> {
//        PostServices.provider
//            .rx.request(.makePost(post: post))
//            .asObservable()
//            .map {
//                if $0.statusCode == 200 {
//                    let post = try JSONDecoder().decode(Post.self, from: $0.data)
//                    return post
//                }
//                return nil
//            }
//            .catchErrorJustReturn(nil)
//    }
}
