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

public class PostServices: Networkable {
    typealias Target = PostAPI
    static let provider = makeProvider()
    
    static func fetchPost(content_id: String, board_type: String) -> Observable<PostModel?> {
        PostServices.provider
            .rx.request(.getPost(content_id: content_id, board_type: board_type))
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .asObservable()
            .map {
                if $0.statusCode == 200 {
                    let response = try JSONDecoder().decode(PostModel.self, from: $0.data)
                    return response
                }
                return nil
            }
            .catchAndReturn(nil)
    }
    
    static func createPost(post: WritingPost) -> Observable<PostModel?> {
        PostServices.provider
            .rx.request(.makePost(post: post))
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .asObservable()
            .map {
                if $0.statusCode == 200 {
                    let post = try JSONDecoder().decode(PostModel.self, from: $0.data)
                    print(post.date)
                    return post
                }
                return nil
            }
            .catchAndReturn(nil)
    }
    
    static func deletePost(post: DeletingPost) -> Observable<Bool> {
        PostServices.provider
            .rx.request(.deletePost(post: post))
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .asObservable()
            .map {
                if $0.statusCode == 200 {
                    return true
                }
                return false
            }
    }
    
    static func likePost(post: PostActivity) -> Observable<ActivityResultType> {
        PostServices.provider
            .rx.request(.likePost(post: post))
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .asObservable()
            .map {
                print(#fileID, #function, #line, $0.statusCode)
                switch $0.statusCode {
                case 200:
                    return .cancel
                case 201:
                    return .success
                case 304:
                    return .already
                default:
                    return .error
                }
            }
    }
    
    static func modifyPost(post: WritingPost) -> Observable<PostModel?> {
        PostServices.provider
            .rx.request(.modifyPost(post: post))
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .asObservable()
            .map {
                if $0.statusCode == 200 {
                    do {
                        let postModel = try JSONDecoder().decode(PostModel.self, from: $0.data)
                        return postModel
                    } catch {
                        print(#fileID, #function, #line, "Failed to decode:\n \(try $0.mapJSON())")
                        return nil
                    }
                } else {
                    return nil
                }
            }
    }
    
    static func fetchOriginalImages(postId: String, boardType: String) -> Observable<[ImageObject]> {
        PostServices.provider
            .rx.request(.getOriginalImages(postId: postId, boardType: boardType))
            .asObservable()
            .map {
                if $0.statusCode == 200 {
                    do {
                        let images = try JSONDecoder().decode(ImageObjectResponse.self, from: $0.data)
                        return images.image
                    } catch {
                        print(#fileID, #function, #line, "Failed to decode:\n \(try $0.mapJSON())")
                        return []
                    }
                } else {
                    return []
                }
            }
    }
}


struct ImageObjectResponse: Codable {
    var image: [ImageObject]
}

enum ActivityResultType {
    case success
    case cancel
    case already
    case error
}
